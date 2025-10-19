@IsTest
public with sharing class ProductInformationControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Use TestDataFactory to create test data
        TestDataFactory.createCompleteTestSetup();
    }

    @IsTest
    static void testGetContactProductInfo_Success() {
        // Get test contact
        Contact testContact = [SELECT Id FROM Contact WHERE UUID__c = 'test-uuid-123' LIMIT 1];
        
        Test.startTest();
        Contact_Product__c result = ProductInformationController.getContactProductInfo(testContact.Id);
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, result, 'Contact Product should not be null');
        System.assertEquals(12, result.Contract_Term_Months__c, 'Contract term should be 12 months');
        System.assertEquals(10.0, result.Special_Discount__c, 'Special discount should be 10%');
        System.assertNotEquals(null, result.Product_Information__r, 'Product Information should be populated');
        System.assertEquals('Metal', result.Product_Information__r.Plan_Type__c, 'Plan type should be Metal');
        System.assertEquals('DE', result.Product_Information__r.Country_Code__c, 'Country code should be DE');
        System.assertEquals(16.90, result.Product_Information__r.Monthly_Cost__c, 'Monthly cost should be 16.90');
    }

    @IsTest
    static void testGetContactProductInfo_NoContactProduct() {
        // Create a contact without product using TestDataFactory
        Contact contactWithoutProduct = TestDataFactory.createContactWithoutProduct();

        Test.startTest();
        Contact_Product__c result = ProductInformationController.getContactProductInfo(contactWithoutProduct.Id);
        Test.stopTest();

        // Verify no product info returned
        System.assertEquals(null, result, 'Should return null when no contact product exists');
    }

    @IsTest
    static void testGetContactProductInfo_NullContactId() {
        Test.startTest();
        Contact_Product__c result = ProductInformationController.getContactProductInfo(null);
        Test.stopTest();

        // Verify null handling
        System.assertEquals(null, result, 'Should return null when contactId is null');
    }

    @IsTest
    static void testGetContactProductInfo_InvalidContactId() {
        Test.startTest();
        Contact_Product__c result = ProductInformationController.getContactProductInfo('001000000000000');
        Test.stopTest();

        // Verify invalid ID handling
        System.assertEquals(null, result, 'Should return null for invalid contact ID');
    }
    
    @IsTest
    static void testGetContactProductInfo_MultipleProducts() {
        // Create setup with multiple products
        Map<String, List<SObject>> testData = TestDataFactory.createMultipleProductsSetup();
        Contact testContact = (Contact)testData.get('contacts')[0];
        List<Product_Information__c> productInfos = (List<Product_Information__c>)testData.get('productInfos');
        
        // Create multiple contact products
        List<Contact_Product__c> contactProducts = new List<Contact_Product__c>{
            TestDataFactory.createContactProduct(testContact.Id, productInfos[0].Id, 6, 5.0),
            TestDataFactory.createContactProduct(testContact.Id, productInfos[1].Id, 12, 10.0)
        };
        insert contactProducts;

        Test.startTest();
        Contact_Product__c result = ProductInformationController.getContactProductInfo(testContact.Id);
        Test.stopTest();

        // Should return the most recently created product (due to ORDER BY CreatedDate DESC)
        System.assertNotEquals(null, result, 'Should return a contact product');
        System.assertEquals(12, result.Contract_Term_Months__c, 'Should return the most recent product');
    }
}