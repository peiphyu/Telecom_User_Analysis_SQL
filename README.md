# Telecom_User_Analysis_SQL
## Project Overveiw
This project analyzes telecom customer behavior using SQL.
The analysis focuses on customer activity, data usage, call usage, and behavioral segmentation to understand how customers interact with telecom services.
The goal of this project is to demonstrate SQL data transformation, aggregation, and customer segmentation techniques commonly used in telecom analytics.

## Dataset
## The dataset used in this project contains synthetic telecom data includings:
•	Customer Information 
•	Data Usage 
•	Call Usage
•	Plans
•	Subscriptions

## Table Used
### Table Name              Description
tbl_customer            Raw customer information
tbl_customer_list      Clean customer base
tbl_data                customer data usage
tbl_call                customer call usage
tbl_plans               plans information
tbl_subscriptions       customer subscriptions

## Project Workflow
### 1.Customer Base Creation
#### Create a unique customer list from the raw customer table.
##### tbl_customer_list

### 2.Data Usage Aggregation
#### Calculate total data usage per customer.
##### tbl_data_usage_customer

### 3.Call Usage Aggregation
#### Calculate total call minutes per customer.
##### tbl_call_usage_customer

### 4.Active Customer Identification
#### Identify whether customer is Active or Inactive based on data or call activity.
##### tbl_active_customer

### 5.Customer Segmentation
#### Customers are segmented based on:
Data Usage Segment
•	No Usage 
•	Low
•	Medium  
•	High
•	Very High

Call Usage Segment
•	No Calls 
•	Very Low
•	Low
•	Medium
•	High

### 6.Behavioral Analysis
#### Cross analysis of data usage vs call usage to identify customer behavior.
Example segments:
Segment                 Description
Data Users              High data usage but low call usage
Voice Users             High call usage but low data usage
Heavy Users             High data and high call usage
Balanced Users          Balance usage on data and call

### SQL Skills Demonstrated
#### This project demonstrates the following SQL Skills:
•	Table creation (CREATE TABLE, DROP TABLE) 
•	Data aggregation (SUM, COUNT)
•	Conditional logic using CASE statements 
•	Customer segmentation 
•	Join operations (LEFT JOIN, INNER JOIN)
•	Grouping and summarization using GROUP BY 
•	Customer behavior analysis through data and call usage segmentation

## Key Insights
•	Most customers (7,125) are Balanced Users, using both data and call services moderately.
• 4,873 customers are Data Users, indicating strong reliance on mobile internet.
•	Very few customers (2) are Heavy Users, showing that high usage of both data and voice is rare.
•	The results suggest that data services dominate customer usage patterns.







