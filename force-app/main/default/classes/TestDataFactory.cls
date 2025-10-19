@IsTest
public with sharing class TestDataFactory {
    
    // Create test contact
    public static Contact createContact(String firstName, String lastName, String uuid) {
        return new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@example.com',
            UUID__c = uuid
        );
    }
    
    // Create product information record
    public static Product_Information__c createProductInfo(String name, String planType, String countryCode, 
                                                           Decimal monthlyCost, Decimal atmFee, Decimal cardReplacementCost) {
        return new Product_Information__c(
            Name = name,
            Plan_Type__c = planType,
            Country_Code__c = countryCode,
            Monthly_Cost__c = monthlyCost,
            ATM_Fee__c = atmFee,
            Card_Replacement_Cost__c = cardReplacementCost
        );
    }
    
    // Create contact product record (junction object)
    public static Contact_Product__c createContactProduct(Id contactId, Id productInfoId, 
                                                         Integer contractTermMonths, Decimal specialDiscount) {
        return new Contact_Product__c(
            Contact__c = contactId,
            Product_Information__c = productInfoId,
            Contract_Term_Months__c = contractTermMonths,
            Special_Discount__c = specialDiscount
        );
    }
    
    // Creates complete test setup including contact, product information, and contact product
    public static Map<String, SObject> createCompleteTestSetup() {
        Map<String, SObject> testData = new Map<String, SObject>();
        
        // Create contact
        Contact testContact = createContact('Test', 'Contact', 'test-uuid-123');
        insert testContact;
        testData.put('contact', testContact);
        
        // Create product information
        Product_Information__c productInfo = createProductInfo('Metal-DE', 'Metal', 'DE', 16.90, 0, 45);
        insert productInfo;
        testData.put('productInfo', productInfo);
        
        // Create contact product
        Contact_Product__c contactProduct = createContactProduct(testContact.Id, productInfo.Id, 12, 10.0);
        insert contactProduct;
        testData.put('contactProduct', contactProduct);
        
        return testData;
    }
    
    // Create test setup for multiple products
    public static Map<String, List<SObject>> createMultipleProductsSetup() {
        Map<String, List<SObject>> testData = new Map<String, List<SObject>>();
        
        // Create contact
        Contact testContact = createContact('Multi', 'Product', 'multi-product-uuid');
        insert testContact;
        testData.put('contacts', new List<Contact>{testContact});
        
        // Create multiple product information records
        List<Product_Information__c> productInfos = new List<Product_Information__c>{
            createProductInfo('Standard-DE', 'Standard', 'DE', 0, 1.7, 6),
            createProductInfo('Black-DE', 'Black', 'DE', 9.90, 0, 6),
            createProductInfo('Metal-DE', 'Metal', 'DE', 16.90, 0, 45)
        };
        insert productInfos;
        testData.put('productInfos', productInfos);
        
        return testData;
    }
    
    // Create a contact without any product information
    public static Contact createContactWithoutProduct() {
        Contact contactWithoutProduct = createContact('No', 'Product', 'no-product-uuid');
        insert contactWithoutProduct;
        return contactWithoutProduct;
    }
}