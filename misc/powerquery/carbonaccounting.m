let
    // Required parameters
    // Host: The name of the Azure Blob Storage account
    // BlobContainer: The name of the container in the Azure Blob Storage account,


    // Load files from Azure Blob Storage

    blobs = AzureStorage.Blobs(Host),
    blob_data = blobs{[Name = BlobContainer]}[Data],
    ParquetFiles = Table.SelectRows(
        blob_data, each Text.StartsWith([Name], "activities_") and Text.EndsWith([Name], ".parquet")
    ),
    AddedParsedColumn = Table.AddColumn(ParquetFiles, "ParsedParquetData", each Parquet.Document([Content])),
    CombinedData = Table.Combine(AddedParsedColumn[ParsedParquetData]),

    Source = CombinedData,

    // Expand Custom Attributes
    custom_attr_AddCustomAttributes = Table.AddColumn(Source, "customAttributes", each 
        let
            // Extract the "value" column from the nested table as a list
            list = Table.Column([customAttributeValues], "value")
        in
            [
                Value1 = if List.Count(list) >= 1 then list{0} else null,
                Value2 = if List.Count(list) >= 2 then list{1} else null,
                Value3 = if List.Count(list) >= 3 then list{2} else null,
                Value4 = if List.Count(list) >= 4 then list{3} else null,
                Value5 = if List.Count(list) >= 5 then list{4} else null
            ]
    ),
    custom_attr_ExpandedCustomAttributes = Table.ExpandRecordColumn(custom_attr_AddCustomAttributes, "customAttributes", {"Value1", "Value2", "Value3", "Value4", "Value5"}),
    custom_attr_RenameColumns = Table.RenameColumns(
        custom_attr_ExpandedCustomAttributes,
        {
            {"Value1", "Custom Attribute 1"},
            {"Value2", "Custom Attribute 2"},
            {"Value3", "Custom Attribute 3"},
            {"Value4", "Custom Attribute 4"},
            {"Value5", "Custom Attribute 5"}
        }
    ),

    with_custom_attr = custom_attr_RenameColumns,

    // Expand Exclusion Rule
    exclusion_rule_1 = Table.ExpandRecordColumn(
        with_custom_attr,
        "exclusionRule",
        {
            "exclusionRuleId",
            "ruleName",
            "filterSource",
            "filterOrganization",
            "filterVendor",
            "filterCategory",
            "filterDepartment",
            "filterComments",
            "filterUnit",
            "matchTypeSource",
            "matchTypeOrganization",
            "matchTypeVendor",
            "matchTypeCategory",
            "matchTypeDepartment",
            "matchTypeComments",
            "matchTypeUnit",
            "customAttributeExclusionFilter",
            "exclusions",
            "createdBy",
            "createdAt",
            "lastSubmittedBy",
            "lastSubmittedAt"
        },
        {
            "exclusionRule.exclusionRuleId",
            "exclusionRule.ruleName",
            "exclusionRule.filterSource",
            "exclusionRule.filterOrganization",
            "exclusionRule.filterVendor",
            "exclusionRule.filterCategory",
            "exclusionRule.filterDepartment",
            "exclusionRule.filterComments",
            "exclusionRule.filterUnit",
            "exclusionRule.matchTypeSource",
            "exclusionRule.matchTypeOrganization",
            "exclusionRule.matchTypeVendor",
            "exclusionRule.matchTypeCategory",
            "exclusionRule.matchTypeDepartment",
            "exclusionRule.matchTypeComments",
            "exclusionRule.matchTypeUnit",
            "exclusionRule.customAttributeExclusionFilter",
            "exclusionRule.exclusions",
            "exclusionRule.createdBy",
            "exclusionRule.createdAt",
            "exclusionRule.lastSubmittedBy",
            "exclusionRule.lastSubmittedAt"
        }
    ),

    with_exclusion_rule = exclusion_rule_1,

    // Expand Input Emission Factors
    emission_factors_scope_1_3_1 = Table.ExpandRecordColumn(
        with_exclusion_rule,
        "inputEmissionFactor",
        {"name", "emissionFactorSource", "factor"},
        {
            "Emission Factor (Scope 1 + 3) Name",
            "Emission Factor (Scope 1 + 3) Source",
            "Emission Factor (Scope 1 + 3)"
        }
    ),
    emission_factors_scope_1_3_2 = Table.ReplaceValue(
        emission_factors_scope_1_3_1,
        null,
        "",
        Replacer.ReplaceValue,
        {
            "Emission Factor (Scope 1 + 3) Name",
            "Emission Factor (Scope 1 + 3) Source",
            "Emission Factor (Scope 1 + 3)"
        }
    ),

    with_emission_factors_scope_1_3 = emission_factors_scope_1_3_2,

    emission_factors_scope_2_location_1 = Table.ExpandRecordColumn(
        with_emission_factors_scope_1_3,
        "inputEmissionFactor_LocationBased",
        {"name", "emissionFactorSource", "factor"},
        {
            "Emission Factor (Scope 2 Location) Name",
            "Emission Factor (Scope 2 Location) Source",
            "Emission Factor (Scope 2 Location)"
        }
    ),
    emission_factors_scope_2_location_2 = Table.ReplaceValue(
        emission_factors_scope_2_location_1,
        null,
        "",
        Replacer.ReplaceValue,
        {
            "Emission Factor (Scope 2 Location) Name",
            "Emission Factor (Scope 2 Location) Source",
            "Emission Factor (Scope 2 Location)"
        }
    ),

    with_emission_factors_scope_2_location = emission_factors_scope_2_location_2,

    emission_factors_scope_2_market_1 = Table.ExpandRecordColumn(
        with_emission_factors_scope_2_location,
        "inputEmissionFactor_MarketBased",
        {"name", "emissionFactorSource", "factor"},
        {
            "Emission Factor (Scope 2 Market) Name",
            "Emission Factor (Scope 2 Market) Source",
            "Emission Factor (Scope 2 Market)"
        }
    ),
    emission_factors_scope_2_market_2 = Table.ReplaceValue(
        emission_factors_scope_2_market_1,
        null,
        "",
        Replacer.ReplaceValue,
        {
            "Emission Factor (Scope 2 Location) Name",
            "Emission Factor (Scope 2 Location) Source",
            "Emission Factor (Scope 2 Location)"
        }
    ),

    with_emission_factors_scope_2_market = emission_factors_scope_2_market_2,


    AutoTagRules = Table.ExpandRecordColumn(
        with_emission_factors_scope_2_market,
        "autoTagRule",
        {
            "autoTagRule.accountingRuleId",
            "autoTagRule.ruleName",
            "autoTagRule.filterActivityExternalId",
            "autoTagRule.filterSource",
            "autoTagRule.filterOrganization",
            "autoTagRule.filterVendor",
            "autoTagRule.filterCategory",
            "autoTagRule.filterDepartment",
            "autoTagRule.filterComments",
            "autoTagRule.filterUnit",
            "autoTagRule.matchTypeSource",
            "autoTagRule.matchTypeOrganization",
            "autoTagRule.matchTypeVendor",
            "autoTagRule.matchTypeCategory",
            "autoTagRule.matchTypeDepartment",
            "autoTagRule.matchTypeComments",
            "autoTagRule.matchTypeUnit",
            "autoTagRule.validFrom",
            "autoTagRule.validTo",
            "autoTagRule.customAttributeAccountingFilter",
            "autoTagRule.scopeCategoryId",
            "autoTagRule.emissionFactorId",
            "autoTagRule.createdBy",
            "autoTagRule.createdAt",
            "autoTagRule.lastSubmittedBy",
            "autoTagRule.lastSubmittedAt"
        }
    ),
    #"Removed Columns1" = Table.RemoveColumns(
        AutoTagRules,
        {
            "activityId",
            "description",
            "valueWithUnit",
            "externalId",
            "userComments",
            "autoTagRule.accountingRuleId",
            "autoTagRule.filterActivityExternalId",
            "autoTagRule.filterSource",
            "autoTagRule.filterOrganization",
            "autoTagRule.filterVendor",
            "autoTagRule.filterCategory",
            "autoTagRule.filterDepartment",
            "autoTagRule.filterComments",
            "autoTagRule.filterUnit",
            "autoTagRule.matchTypeSource",
            "autoTagRule.matchTypeOrganization",
            "autoTagRule.matchTypeVendor",
            "autoTagRule.matchTypeCategory",
            "autoTagRule.matchTypeDepartment",
            "autoTagRule.matchTypeComments",
            "autoTagRule.matchTypeUnit",
            "autoTagRule.validFrom",
            "autoTagRule.validTo",
            "autoTagRule.customAttributeAccountingFilter",
            "autoTagRule.scopeCategoryId",
            "autoTagRule.emissionFactorId",
            "autoTagRule.createdBy",
            "autoTagRule.createdAt",
            "autoTagRule.lastSubmittedBy",
            "autoTagRule.lastSubmittedAt"
        }
    ),
    #"Renamed Columns" = Table.RenameColumns(
        #"Removed Columns1",
        {
            {"scope", "Scope"},
            {"unitName", "Activity_Unit"},
            {"unitValue", "Activity_Amount"},
            {"autoTagRule.ruleName", "Carbac_Rule_Name"},
            {"emissionCo2Kg", "CO2e_Amount"},
            {"emissionCo2Kg_MarketBased", "CO2e_Amount_Market"},
            {"emissionCo2Kg_LocationBased", "CO2e_Amount_Location"},
            {"isPrimaryTag", "Is_Primary"},
            {"activityDate", "Activity_Date"},
            {"category", "Category"},
            {"source", "Source"},
            {"comment", "Comment"}
        }
    ),
    #"Replaced Value" = Table.ReplaceValue(
        #"Renamed Columns",
        null,
        "",
        Replacer.ReplaceValue,
        {
            "Scope",
            "Activity_Unit",
            "Activity_Amount",
            "Carbac_Rule_Name",
            "CO2e_Amount",
            "CO2e_Amount_Market",
            "CO2e_Amount_Location",
            "Is_Primary",
            "Activity_Date",
            "Category",
            "Source",
            "Comment",
            "Emission Factor (Scope 1 + 3) Name",
            "Emission Factor (Scope 1 + 3) Source",
            "Emission Factor (Scope 1 + 3)",
            "Emission Factor (Scope 2 Location) Name",
            "Emission Factor (Scope 2 Location) Source",
            "Emission Factor (Scope 2 Location)"
        }
    ),
    #"Changed Type" = Table.TransformColumnTypes(
        #"Replaced Value",
        {
            {"Scope", type text},
            {"Activity_Unit", type text},
            {"Carbac_Rule_Name", type text},
            {"Category", type text},
            {"Source", type text},
            {"Comment", type text},
            {"Activity_Date", type datetimezone},
            {"Is_Primary", type logical},
            {"CO2e_Amount_Location", type number},
            {"CO2e_Amount_Market", type number},
            {"CO2e_Amount", type number},
            {"Activity_Amount", type number}
        },
        "en-US"
    ),
    #"Extracted Date" = Table.TransformColumns(#"Changed Type", {{"Activity_Date", DateTime.Date, type date}}),
    #"Renamed Columns1" = Table.RenameColumns(
        #"Extracted Date", {{"organization", "Organization"}, {"department", "Department"}, {"vendor", "Vendor"}}
    ),
    removedColumns2 = Table.RemoveColumns(
        #"Renamed Columns1",
        {
            "exclusionRule.exclusionRuleId",
            "exclusionRule.ruleName",
            "exclusionRule.filterSource",
            "exclusionRule.filterOrganization",
            "exclusionRule.filterVendor",
            "exclusionRule.filterCategory",
            "exclusionRule.filterDepartment",
            "exclusionRule.filterComments",
            "exclusionRule.filterUnit",
            "exclusionRule.matchTypeSource",
            "exclusionRule.matchTypeOrganization",
            "exclusionRule.matchTypeVendor",
            "exclusionRule.matchTypeCategory",
            "exclusionRule.matchTypeDepartment",
            "exclusionRule.matchTypeComments",
            "exclusionRule.matchTypeUnit",
            "exclusionRule.customAttributeExclusionFilter",
            "exclusionRule.exclusions",
            "exclusionRule.createdBy",
            "exclusionRule.createdAt",
            "exclusionRule.lastSubmittedBy",
            "exclusionRule.lastSubmittedAt"
        }
    ),
    #"Removed Columns" = Table.RemoveColumns(
        removedColumns2, {"createdBy", "createdAt", "lastSubmittedBy", "lastSubmittedAt"}
    ),
    #"Renamed Columns3" = Table.RenameColumns(
        #"Removed Columns",
        {
            {"CO2e_Amount", "Measure CO2e Amount"},
            {"CO2e_Amount_Location", "Measure CO2e Amount Location"},
            {"CO2e_Amount_Market", "Measure CO2e Amount Market"}
        }
    ),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns3", "MainScope", each Text.BeforeDelimiter([Scope], " (")),
    #"Renamed Columns4" = Table.RenameColumns(
        #"Added Custom",
        {
            {"Measure CO2e Amount", "CO2e (Scope 1 + 3)"},
            {"Measure CO2e Amount Location", "CO2e (Scope 2 - Location)"},
            {"Measure CO2e Amount Market", "CO2e (Scope 2 - Market)"},
            {"Is_Primary", "Is Primary"},
            {"Activity_Amount", "Input Value"},
            {"Activity_Unit", "Unit"},
            {"status", "Status"},
            {"MainScope", "Scope (Main)"},
            {"Carbac_Rule_Name", "Accounting Rule"},
            {"Activity_Date", "Date"}
        }
    ),
    output = #"Renamed Columns4"
    
in
    output