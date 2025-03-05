# **Solitwork** AFC ESG Reporting - Deployment Guide
Welcome to Solitwork's official ESG (Environmental, Social and Governance) reporting repository! This repository contains the most up-to-date versions of the ESG report, fully compatible with the most recent ESG and Carbon Accounting applications.

This guide will outline how to:  
 - download the latest Microsoft Power BI version of the AFC ESG Report 
 - publish it to a Microsoft Power BI workspace within your organization
 - preparing the report by setting up the correct credentials and parameters
 - setting a refresh schedule 


> [!IMPORTANT]
> This ESG report is compatible with **ESG Version 2025.02.4** or later.
> Make sure that your ESG solution is at least on on this version before rolling out the ESG report. 
>
> Before starting, also ensure that:
>
> - All relevant users have appropriate **Microsoft Power BI licences**
> - You have access to a **Microsoft Power BI workspace**
> - You have the `pbi_container_url` and `sas_token`


## 1. Download the latest .pbix report file
To retrieve the latest version of the AFC ESG Report, click on the release section on this page and download the attached `.pbix` file. 

   ![Release](images/Navigate%20Release.png)


## 2. Upload the .pbix report file to a Power BI Workspace
The following step will outline how to upload the `.pbix` file to a Power BI Workspace, so that it can be shared and viewed within your organization. 

> [!NOTE]
> You can log in to the Power BI Service and upload the file from there.

### Publish from Power BI Service

1. Log in to your **Power BI Account** (via https://app.powerbi.com)
2. Navigate to the appropriate Power BI Workspace or create a new workspace.

   ![PBI Workspace](images/PBI%20Workspace.jpg)

3. Click **Upload** and select the `.pbix` file you have previously downloaded.

   ![PBI Workspace Upload](images/PBI%20Workspace%20Upload.png)

4. Continue with **Step 3** of this guide.
</details>


## 3. Edit Power BI Dataset Credentials 

1.	**Open Power BI Service:**
    - Open your web browser.
    - Navigate to the Power BI Service at https://app.powerbi.com.
    - Sign in with your credentials.

2.	**Navigate to the Dataset:**
    - Once logged in, go to the workspace which contains the published report.
    - Find the dataset associated with your report (**Type**: `Semantic model`).

3.	**Dataset Settings:**
    - Hover over the dataset, and an ellipsis `...` / options icon will appear. **Click on it**.
    - Choose **Settings** from the dropdown menu.

    ![PBI Workspace Settings](images/PBI%20Dataset%20Settings.png)

## 4. Parameters and Credentials

   The empty ESG report will be configured to your organization by setting up the parameter `Host`. This is stored as configurable parameter within the system, allowing for seamless reuse across different endpoints. By centralizing the configuration in this manner, any updates or changes to parameter only need to be made in one place, ensuring consistency and reducing the risk of errors across the board.
   


   | Parameter                   | Description                                                                                    | Details / Example                                                                                                                |
   |-----------------------------|------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
   | `Host`               | The host url of the storage account containing the blob container with the esg parquet files                                | Example: https://something.blob.core.windows.net                                                      |
   | `BlobContainer`               | The Azure Blob Container with the ESG parquet files                                | "esgpbi"                                                      |
   | `sas_token`               | The secure credentials required for authentication.                                               |                                                                                                                                  |

   - In the **Parameters** section, replace the placeholder values with the before mentioned credentials:

   ![PBI Parameters](images/PBI%20Parameters.png)

select **apply**.
   
   - In the **Data Source Credentials** section, click on **edit credentials** to bring up configuration.
   - Choose **Shared Access Signature (SAS)** as authentication method
   - Enter your `SAS_token` in **account key** section
   - Make sure **privacy level setting for this data source** is set to **private**

   ![PBI Dataset Parameters](images/PBI%20Dataset%20Parameters.png)


select **sign in**.


## 5. Dataset Refresh Schedule

   In this step, you will set a refresh schedule to determine how often the data in your ESG Report shall be updated. Please note that the maximum number of daily refreshes is determined by the Power BI licence and capacity of the PBI Workspace. 

   - In the dataset settings, navigate to the **Refresh** section.
   - configure a refresh schedule and select the time(s) the semantic model shall update each day.

   ![PBI Refresh](images/PBI%20Refresh%20Schedule.png)

   - click **apply** once done. 

   > [!NOTE]
   > Regardless of your refresh schedule, you can always **manually trigger** a refresh of the dataset/semantic model.
   > To do so, return to the dataset in your workspace, hover over it and click on the refresh now :arrows_counterclockwise: button. 
   
   > [!NOTE]
   > The AFC ESG application updates the parquet file every full hour so we recommend you set the refresh schedule accordingly.

**Done!** :white_check_mark: You have now made all necessary adjustments to the dataset and the connected ESG Report. 
Remember that your colleagues need access to that Power BI Workspace to open and access the ESG Report. 
