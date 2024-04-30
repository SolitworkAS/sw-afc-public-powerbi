# sw-afc-public-powerbi
Welcome to Solitwork's official ESG (Environmental, Social and Governance) reporting repository! This repository contains the most up-to-date versions of ESG reports, fully compatible with ESG and Carbon Accounting applications.

## Using the Report
To utilize this report effectively, please follow these steps:

1. **Download the Report**

2. **Open the Power Query Editor**

3. **Configuration**: Configure report with your specific parameters:
    - **Username**: Your organizational username for authentication.
    - **Password**: A secure password required for authentication.
    - **Base URL**: The base URL connects the report with your specific ESG and Carbon Accounting environment.

By setting up these parameters, you will ensure that the report functions correctly within your operational context, allowing you to leverage the latest insights and analyses provided.

## ESG Report Implementation Overview

![API Overview](images/API%20Overview.png)

### Parameters
In the ESG reporting system, the foundational step involves setting up parameters such as `username`, `password`, and `base URL`. These are stored as configurable parameters within the system, allowing for seamless reuse across different API endpoints. By centralizing the configuration in this manner, any updates or changes to these parameters only need to be made in one place, ensuring consistency and reducing the risk of errors across the board.

### Token Retrieval Function
To ensure secure and authorized access to the APIs, our system automates the token retrieval process through a dedicated function `fnGetToken`. This function is crucial for maintaining secure communication with the API by fetching an authentication token using your credentials.

### Data Retrieval Function
Each API endpoint is equipped with a function designed to retrieve one page of paginated data, ensuring efficient data access for our ESG reporting system. Functions such as `fnGetNextPageSurveys` dynamically adjust to retrieve the next page based on the last page accessed, facilitating seamless navigation through large datasets.

### Dynamic Pagination Function
The `fnGenerateByPage` function is designed to automate the complete retrieval of data from paginated API endpoints in Power BI. It works in conjunction with specific pagination functions, like `fnGetNextPageSurveys`, to ensure that all pages of data are fetched seamlessly until no more results are available from the API.

### Retrieving Data from the API
The primary goal is to safely and efficiently retrieve the full set of data from the API. This combines all the previously mentioned features and parameters to ensure a smooth process of importing data into a Power BI report.

```m
let
    Surveys = fnGenerateByPage(fnGetNextPageSurveys)
in
    Surveys
