# **Solitwork** AFC ESG Reporting - Deployment Guide
Welcome to Solitwork's official ESG (Environmental, Social and Governance) reporting repository! This repository contains the most up-to-date versions of the ESG report, fully compatible with the most recent ESG and Carbon Accounting applications.

This guide will outline how to:  
 - download the latest Microsoft Power BI version of the AFC ESG Report 
 - publish it to a Microsoft Power BI workspace within your organization
 - preparing the report by setting up the correct credentials and parameters
 - setting a refresh schedule 


> [!IMPORTANT]
> This ESG report is compatible with **ESG version 1.3.10** or later.
> Make sure that your ESG solution is at least on on this version before rolling out the ESG report. 
>
> Before starting, also ensure that:
>
> - All relevant users have appropriate **Microsoft Power BI licences**
> - You have access to a **Microsoft Power BI workspace**
> - You have the `username` and `password` of the **Reporting User**


## 1. Download the latest .pbix report file
To retrieve the latest version of the AFC ESG Report, click on the release section on this page and download the attached `.pbix` file. 

   ![Release](images/Navigate%20Release.png)


## 2. Upload the .pbix report file to a Power BI Workspace
The following step will outline how to upload the `.pbix` file to a Power BI Workspace, so that it can be shared and viewd within your organization. 

> [!NOTE]
> You can upload file after having it opened it in Power BI Desktop (**Option A**).
> Alternatively, you can also directly log in to Power BI Service, and upload it from there (**Option B**).
> 
> Choose the method you prefer, but be aware that **Option A** requires to have **Microsoft Power BI Desktop** installed on your computer. 

### Option A: Publish from within Power BI Desktop
<details>
<summary> Option A: click to expand</summary>

1. Launch **Power BI Desktop**
2. Open the downloaded `.pbix` file.
3. If you're not already signed in, click on **Sign in** and enter your Power BI credentials.

   ![PBI Desktop Sign In](images/PBI%20Desktop%20Signin.png)

4. Go to the **Home** tab.
5. Click on **Publish**.

   ![PBI Desktop Publish](images/PBI%20Desktop%20Publish.png)

6. You may be asked to save your report if you haven't saved it already. Do so if prompted.
7. Choose the workspace in Power BI Service where you want to publish the report.
8. Click **Select** or **OK**.
9. Continue with **Step 3** of this guide. 
</details>

### Option B: Publish from Power BI Service
<details>
<summary> Option B: click to expand</summary>

1. Log in to your **Power BI Account** (via https://app.powerbi.com)
2. Navigate to the appropriate Power BI Workspace or create a new workspace

   ![PBI Workspace](images/PBI%20Workspace.jpg)

3. Click **Upload** and select `.pbix` file you have previously downloaded. 

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

4. **Parameters**

   The empty ESG report will be configured to your organization by setting up the parameters `APIUsername`, `APIPassword`, and `APIBaseURL`. These are stored as configurable parameters within the system, allowing for seamless reuse across different API endpoints. By centralizing the configuration in this manner, any updates or      changes to these parameters only need to be made in one place, ensuring consistency and reducing the risk of errors across the board.


   | Parameter                   | Description                                                                                    | Details / Example                                                                                                                |
   |-----------------------------|------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
   | `APIUsername`               | A dedicated Reporting User, not tied to an individual / person.                                | Requires a user created through the ESG user interface with the Admin role.                                                      |
   | `APIPassword`               | The secure password required for authentication.                                               |                                                                                                                                  |
   | `APIBaseURL`                | The base URL connects the report with your specific ESG and Carbon Accounting environment.     | see highlighted `APIBaseURL` part in **bold**:  esg-frontend-service.**yellowground-7d1c049j.northeurope.azurecontainerapps.io** |

- In the **Parameters** section, replace the placeholder values with the following credentials:
  
   ![PBI Dataset Parameters](images/PBI%20Dataset%20Parameters.png)


- select **apply**.






## Using the Report
To utilize this report effectively, please follow these steps:

1. **Download the Report**

2. **Open the Power Query Editor**

3. **Configuration**: Configure report with your specific parameters:
    - **Username**: Your organizational username for authentication.
    - **Password**: A secure password required for authentication.
    - **Base URL**: The base URL connects the report with your specific ESG and Carbon Accounting environment.

By setting up these parameters, you will ensure that the report functions correctly within your operational context, allowing you to leverage the latest insights and analyses provided.

# Technical Information: ESG Report Implementation Overview

![API Overview](images/API%20Overview.png)

## Parameters
In the ESG reporting system, the foundational step involves setting up parameters such as `APIUsername`, `APIPassword`, and `APIBaseURL`. These are stored as configurable parameters within the system, allowing for seamless reuse across different API endpoints. By centralizing the configuration in this manner, any updates or changes to these parameters only need to be made in one place, ensuring consistency and reducing the risk of errors across the board.

## Token Retrieval Function
To ensure secure and authorized access to the APIs, our system automates the token retrieval process through a dedicated function `fnGetToken`. This function is crucial for maintaining secure communication with the API by fetching an authentication token using your credentials.

## Data Retrieval Function
Each API endpoint is equipped with a function designed to retrieve one page of paginated data, ensuring efficient data access for our ESG reporting system. Functions such as `fnGetNextPageSurveys` dynamically adjust to retrieve the next page based on the last page accessed, facilitating seamless navigation through large datasets.

## Dynamic Pagination Function
The `fnGenerateByPage` function is designed to automate the complete retrieval of data from paginated API endpoints in Power BI. It works in conjunction with specific pagination functions, like `fnGetNextPageSurveys`, to ensure that all pages of data are fetched seamlessly until no more results are available from the API.

## Retrieving Data from the API
The primary goal is to safely and efficiently retrieve the full set of data from the API. This combines all the previously mentioned features and parameters to ensure a smooth process of importing data into a Power BI report.

```m
let
    Surveys = fnGenerateByPage(fnGetNextPageSurveys)
in
    Surveys
