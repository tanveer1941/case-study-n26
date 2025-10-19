public with sharing class ProductInformationController {
    
    @AuraEnabled(cacheable=true)
    public static Contact_Product__c getContactProductInfo(Id contactId) {
        try {
            if (contactId == null) {
                return null;
            }
            
            // Query Contact_Product__c with related Product_Information__r fields
            
            List<Contact_Product__c> contactProducts = [
                SELECT  Id,
                        Name,
                        Contract_Term_Months__c,
                        Special_Discount__c,
                        Product_Information__r.Id,
                        Product_Information__r.Name,
                        Product_Information__r.Plan_Type__c,
                        Product_Information__r.Country_Code__c,
                        Product_Information__r.Monthly_Cost__c,
                        Product_Information__r.ATM_Fee__c,
                        Product_Information__r.Card_Replacement_Cost__c
                  FROM Contact_Product__c 
                 WHERE Contact__c = :contactId 
              ORDER BY CreatedDate DESC 
                 LIMIT 1          // Here I am assuming our customer will have only one product subscription with us. 
                                  // In future if this changes to multiple then we dont need to put LIMIT 1
            ];
            
            return contactProducts.isEmpty() ? null : contactProducts[0];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving contact product information: ' + e.getMessage());
        }
    }
    
}