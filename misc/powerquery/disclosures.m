let
    // Custom function to sort (if needed) and concatenate a column from the nested table
    CustomConcatenate = (APTable as table, col as text) as text =>
        let
            KeysList = Table.Column(APTable, "key"),
            RequiredKeys = {"category", "disclosure", "question"},
            ApplyCustomSort = List.Sort(KeysList) = List.Sort(RequiredKeys),
            SortedAP =
                if ApplyCustomSort then
                    let
                        WithSort = Table.AddColumn(APTable, "SortOrder", each 
                            if [key] = "category" then 1 
                            else if [key] = "question" then 2 
                            else if [key] = "disclosure" then 3 
                            else 999
                        ),
                        SortedTable = Table.Sort(WithSort, {{"SortOrder", Order.Ascending}})
                    in
                        Table.RemoveColumns(SortedTable, {"SortOrder"})
                else
                    APTable,
            ConcatText = Text.Combine(
                List.Transform(Table.Column(SortedAP, col), each Text.From(_)),
                " | "
            )
        in
            ConcatText,

    // Load the source data
    Source = Parquet.Document(
        AzureStorage.BlobContents(Host & "/" & BlobContainer & "/" & "disclosures.parquet"),
        [Compression = null, LegacyColumnNameEncoding = false, MaxDepth = null]
    ),
    // Expand the inputs list and then the record in each input
    #"Expanded inputs" = Table.ExpandListColumn(Source, "inputs"),
    #"Expanded inputs1" = Table.ExpandRecordColumn(
        #"Expanded inputs", 
        "inputs", 
        {"files", "inputId", "source", "externalId", "disclosureId", "input", "unit", "analysis", "additionalProperties", "active", "comment", "startDate", "endDate", "organization", "department", "createdBy", "createdAt", "createdByName", "lastSubmittedBy", "lastSubmittedAt", "lastSubmittedByName"}, 
        {"inputs.files", "inputs.inputId", "inputs.source", "inputs.externalId", "inputs.disclosureId", "inputs.input", "inputs.unit", "inputs.analysis", "inputs.additionalProperties", "inputs.active", "inputs.comment", "inputs.startDate", "inputs.endDate", "inputs.organization", "inputs.department", "inputs.createdBy", "inputs.createdAt", "inputs.createdByName", "inputs.lastSubmittedBy", "inputs.lastSubmittedAt", "inputs.lastSubmittedByName"}
    ),
    // Rename for clarity
    #"Renamed Columns1" = Table.RenameColumns(#"Expanded inputs1", {{"inputs.startDate", "Start_Date"}, {"externalId", "External_ID"}}),
    // Expand nested department and organization records
    #"Expanded inputs.department" = Table.ExpandRecordColumn(
        #"Renamed Columns1", 
        "inputs.department", 
        {"departmentId", "name", "description", "organizationId", "mainResponsible", "mainResponsibleName", "createdByName", "lastSubmittedByName"}, 
        {"inputs.department.departmentId", "inputs.department.name", "inputs.department.description", "inputs.department.organizationId", "inputs.department.mainResponsible", "inputs.department.mainResponsibleName", "inputs.department.createdByName", "inputs.department.lastSubmittedByName"}
    ),
    #"Expanded inputs.organization" = Table.ExpandRecordColumn(
        #"Expanded inputs.department", 
        "inputs.organization", 
        {"organizationId", "name", "description", "createdByName", "lastSubmittedByName"}, 
        {"inputs.organization.organizationId", "inputs.organization.name", "inputs.organization.description", "inputs.organization.createdByName", "inputs.organization.lastSubmittedByName"}
    ),
    // Add Survey Chapter (concatenated keys) and Survey Paragraph (concatenated values)
    #"Added Survey Chapter" = Table.AddColumn(
        #"Expanded inputs.organization", 
        "Data Point Header", 
        each CustomConcatenate([inputs.additionalProperties], "key")
    ),
    #"Added Survey Paragraph" = Table.AddColumn(
        #"Added Survey Chapter", 
        "Data Point", 
        each CustomConcatenate([inputs.additionalProperties], "value")
    ),
    #"Added Custom2" = Table.AddColumn(#"Added Survey Paragraph", "Data Point (Last)", each List.Last(Text.Split(Text.From([Data Point]), "|"))),

    #"Removed Columns" = Table.RemoveColumns(#"Added Custom2",{"type", "disclosureId", "questionExternalId", "categoryExternalId", "inputs.inputId", "inputs.disclosureId", "inputs.analysis", "inputs.active", "inputs.comment", "inputs.organization.organizationId", "inputs.organization.description", "inputs.organization.createdByName", "inputs.organization.lastSubmittedByName", "inputs.department.departmentId", "inputs.department.description", "inputs.department.organizationId", "inputs.department.mainResponsible", "inputs.department.mainResponsibleName", "inputs.department.createdByName", "inputs.department.lastSubmittedByName", "inputs.createdBy", "inputs.createdAt", "inputs.createdByName", "inputs.lastSubmittedBy", "inputs.lastSubmittedAt", "inputs.lastSubmittedByName", "createdBy", "createdAt", "createdByName", "lastSubmittedBy", "lastSubmittedAt", "lastSubmittedByName"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Removed Columns",{{"inputs.endDate", "End_Date"}, {"inputs.organization.name", "Organisation"}, {"inputs.department.name", "Department"}, {"category", "Category"}, {"question", "Question"}, {"disclosure", "Disclosure"}, {"inputs.unit", "Unit"}, {"inputs.input", "Input"}, {"inputs.source", "Source"}}),
    #"Replaced Value" = Table.ReplaceValue(#"Renamed Columns2",null,"",Replacer.ReplaceValue,{"External_ID", "Start_Date", "End_Date", "Organisation", "Department", "Category", "Question", "Disclosure", "Unit", "Input", "Source"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Replaced Value",{{"External_ID", type text}, {"Organisation", type text}, {"Department", type text}, {"Category", type text}, {"Question", type text}, {"Disclosure", type text}, {"Unit", type text}, {"Source", type text}, {"Start_Date", type datetimezone}, {"End_Date", type datetimezone}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "Topic", each 
        if Text.StartsWith([External_ID], "E") then "Environment"
        else if Text.StartsWith([External_ID], "S") then "Social"
        else if Text.StartsWith([External_ID], "G") then "Governance"
        else "Other"),
    #"Extracted Date" = Table.TransformColumns(#"Added Custom",{{"Start_Date", DateTime.Date, type date}, {"End_Date", DateTime.Date, type date}}),
    #"Renamed Columns6" = Table.RenameColumns(#"Extracted Date",{{"inputs.externalId", "Survey_External_ID"}, {"External_ID", "ESRS_External_ID"}}),
    #"Replaced Value3" = Table.ReplaceValue(#"Renamed Columns6",null,"",Replacer.ReplaceValue,{"Survey_External_ID"}),
    #"Renamed Columns7" = Table.RenameColumns(#"Replaced Value3",{{"inputs.files", "Files"}}),
    #"Expanded Files" = Table.ExpandListColumn(#"Renamed Columns7", "Files"),
    #"Filtered Records Only" = Table.SelectRows(#"Expanded Files", each Type.Is(Value.Type([Input]), type record)),
    #"Expanded Column8" = Table.ExpandRecordColumn(#"Filtered Records Only", "Input", {"input"}),
    #"Expanded files" = Table.ExpandListColumn(#"Expanded Column8", "files"),
    #"Added Custom1" = Table.AddColumn(#"Expanded files", "FilesParsed", each if [Files] = null then null else "https://" & [Files]),
    #"Removed Columns1" = Table.RemoveColumns(#"Added Custom1",{"files", "Files"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Removed Columns1",{{"FilesParsed", "Files"}, {"ESRS_External_ID", "External ID (ESRS)"}, {"Survey_External_ID", "External ID (Survey)"}, {"input", "Disclosure Value (Raw)"}, {"Start_Date", "Period Start"}, {"End_Date", "Period End"}})
    
in
    #"Renamed Columns3"