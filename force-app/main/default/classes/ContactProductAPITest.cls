@IsTest
public with sharing class ContactProductAPITest {
    
    @TestSetup
    static void setupTestData() {
        // Use TestDataFactory to create test data
        TestDataFactory.createCompleteTestSetup();
    }

    @IsTest
    static void testGetProductInfoByUUID_Success() {
        // Setup REST context
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/contact-product-info/test-uuid-123';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ContactProductAPI.getProductInfoByUUID();
        Test.stopTest();

        // Verify response. Status code should be 200
        System.assertEquals(200, RestContext.response.statusCode);
        
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        
        // Verify response content matches the test data
        System.assertEquals('Metal', responseMap.get('planType'));
        System.assertEquals('DE', responseMap.get('countryCode'));
        System.assertEquals(16.90, responseMap.get('monthlyCost'));
        System.assertEquals(0, responseMap.get('atmFee'));
        System.assertEquals(45, responseMap.get('cardReplacementCost') );
        System.assertEquals(12, responseMap.get('contractTermMonths'));
        System.assertEquals(10.0, responseMap.get('specialDiscount'));
    }

    @IsTest
    static void testGetProductInfoByUUID_ContactNotFound() {
        // Setup REST context with non-existent UUID
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/contact-product-info/non-existent-uuid';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ContactProductAPI.getProductInfoByUUID();
        Test.stopTest();

        // Verify error response. Status code should be 404'
        System.assertEquals(404, RestContext.response.statusCode);
        
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        // An error message indicating contact not found should be returned
        System.assertEquals('Contact not found', responseMap.get('error'));
    }

    @IsTest
    static void testGetProductInfoByUUID_NoUUIDInURL() {
        // Setup REST context with no UUID in URL
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/contact-product-info/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ContactProductAPI.getProductInfoByUUID();
        Test.stopTest();

        // Verify error response. Status code should be 400
        System.assertEquals(400, RestContext.response.statusCode); 
        
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        
        // An Error message indicating UUID is required should be returned'
        System.assertEquals('UUID required', responseMap.get('error'));
    }

    @IsTest
    static void testGetProductInfoByUUID_NoProductInfo() {
        // Create contact without product info using TestDataFactory
        Contact contactWithoutProduct = TestDataFactory.createContactWithoutProduct();

        // Setup REST context
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/contact-product-info/no-product-uuid';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ContactProductAPI.getProductInfoByUUID();
        Test.stopTest();

        // Verify 404 error response
        System.assertEquals(404, RestContext.response.statusCode);
        
        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        // An error message indicating product info not found should be returned'
        System.assertEquals('Product information not found', responseMap.get('error'));
    }

    @IsTest
    static void testJSONResponseStructure() {
        // Test that the JSON response has the exact structure expected by external systems
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/contact-product-info/test-uuid-123';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ContactProductAPI.getProductInfoByUUID();
        Test.stopTest();

        String responseBody = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        
        // Verify all expected fields are present
        System.assert(responseMap.containsKey('planType'), 'Response should contain planType');
        System.assert(responseMap.containsKey('countryCode'), 'Response should contain countryCode');
        System.assert(responseMap.containsKey('monthlyCost'), 'Response should contain monthlyCost');
        System.assert(responseMap.containsKey('atmFee'), 'Response should contain atmFee');
        System.assert(responseMap.containsKey('cardReplacementCost'), 'Response should contain cardReplacementCost');
        System.assert(responseMap.containsKey('contractTermMonths'), 'Response should contain contractTermMonths');
        System.assert(responseMap.containsKey('specialDiscount'), 'Response should contain specialDiscount');
        
        // Verify no extra fields are present. Response should contain only 7 fields
        System.assertEquals(7, responseMap.size());
    }
}