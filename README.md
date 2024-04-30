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
To download the latest version of the AFC ESG Report, select on latest release on this page and download the attached `.pbix` file. 





| URL                         | Description                                                                                               | Access                                                                                                   |
|-----------------------------|-----------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| `carbacc_frontend_url`      | The user interface for carbon accounting.                                                                 | Requires a user created through the ESG user interface with Carbon rights.                               |
| `carbon_api_url`            | API interface for carbon accounting. Access documentation at `/swagger/index.html`.                       | Requires a user created through the ESG user interface. The user should have the Carbon role.                               |
| `esg_frontend_url`          | The user interface for ESG.                                                                               | Requires a user with at least the Respondent role. For initial access, use the Admin User details from `terraform.tfvars`. |
| `esg_organization_api`      | API interface for setting up organizations and departments in ESG. Access documentation at `/docs`.                                        | Requires a user created through the ESG user interface with Admin role.                                |
| `esg_reporting_api`         | API interface for obtaining ESG data for reporting purposes. Access documentation at `/docs`.                                             | Requires a user created through the ESG user interface with the Admin role.                                |
| `keycloak_url`              | The Keycloak server for setting up Single Sign-On (SSO) integration.                                      | Log in with the username `admin` and the admin password set in `terraform.tfvars`. Guide available in `sw-afc-public-infra/guides/sso-setup/README.md`.          |
| `vat_api_url`               | API interface for VAT.                                                                                    |                                                                                                          |
| `vat_frontend_url`          | The user interface for VAT.                                                                               |                                                                                                          |












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
In the ESG reporting system, the foundational step involves setting up parameters such as `username`, `password`, and `base URL`. These are stored as configurable parameters within the system, allowing for seamless reuse across different API endpoints. By centralizing the configuration in this manner, any updates or changes to these parameters only need to be made in one place, ensuring consistency and reducing the risk of errors across the board.

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
