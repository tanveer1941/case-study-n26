# Customer Product Information System

## Project Overview
A Salesforce-based solution that displays customer product information to service agents during case interactions and provides a REST API for external systems to access the same data.

## Business Requirements
- **Lightning Web Component**: Display customer product information to agents on Case pages
- **REST API**: Provide external systems with customer product data using UUID
- **Scalable Data Model**: Support multiple products per customer with flexible pricing

## Solution Architecture

### Data Model
- **Contact** (Standard Object)
  - `UUID__c` (External ID, Unique)
- **Contact_Product__c** (Junction Object)
  - `Product_Information__c` (Master-Detail)
  - `Contact__c` (Master-Detail)
  - `Contract_Term_Months__c`
  - `Special_Discount__c`
- **Product_Information__c** (Custom Object)
  - `Plan_Type__c` (Picklist: Standard, Black, Metal)
  - `Country_Code__c` (Picklist: DE, FR, ES, IT, UK)
  - `Monthly_Cost__c` (Currency)
  - `ATM_Fee__c` (Percent)
  - `Card_Replacement_Cost__c` (Currency)

### Components
- **LWC Component**: `productInfoDisplay` - Displays on Case pages
- **Apex Controller**: `ProductInformationController` - Business logic
- **REST API**: `ContactProductAPI` - External system integration
- **Test Classes**: Comprehensive test coverage