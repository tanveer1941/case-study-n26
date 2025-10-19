@RestResource(urlMapping='/v1/contact-product-info/*')
global with sharing class ContactProductAPI {
    
    @HttpGet
    global static void getProductInfoByUUID() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        try {
            String uuid = request.requestURI.substringAfterLast('/');
            
            if (String.isBlank(uuid)) {
                sendError(400, 'UUID required');
                return;
            }
            
            // Query Contact using UUID
            List<Contact> contacts = [
                SELECT Id 
                  FROM Contact 
                 WHERE UUID__c = :uuid 
                 LIMIT 1
            ];
            
            if (contacts.isEmpty()) {
                sendError(404, 'Contact not found');
                return;
            }
            
            // As we have to send the same data in response which we queried in our LWC controller so lets reuse the existing function from ProductInformationController
            Contact_Product__c contactProduct = ProductInformationController.getContactProductInfo(contacts[0].Id);
            
            if (contactProduct == null) {
                sendError(404, 'Product information not found');
                return;
            }
            
            // Build JSON response
            Map<String, Object> productInfo = new Map<String, Object>{
                'planType' => contactProduct.Product_Information__r.Plan_Type__c,
                'countryCode' => contactProduct.Product_Information__r.Country_Code__c,
                'monthlyCost' => contactProduct.Product_Information__r.Monthly_Cost__c,
                'atmFee' => contactProduct.Product_Information__r.ATM_Fee__c,
                'cardReplacementCost' => contactProduct.Product_Information__r.Card_Replacement_Cost__c,
                'contractTermMonths' => contactProduct.Contract_Term_Months__c,
                'specialDiscount' => contactProduct.Special_Discount__c
            };
            
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(productInfo));
            response.addHeader('Content-Type', 'application/json');
            
        } catch (Exception e) {
            sendError(500, 'Internal server error');
        }
    }
    
    private static void sendError(Integer statusCode, String message) {
        RestResponse response = RestContext.response;
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(JSON.serialize(
            new Map<String, Object>{
                'error' => message
            }
        ));
        response.addHeader('Content-Type', 'application/json');
    }
}