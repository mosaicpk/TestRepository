public with sharing class PMC_DH_AddToCart {
    @InvocableMethod
    public static void addCartItems(List<CartItem> objCartItem){
        WebCart objWebCart = [SELECT Id, Status, AccountId, PMC_DH_ContractStartDate__c, PMC_DH_ContractEndDate__c, PMC_DH_Currency__c, PMC_DH_PaymentMethod__c, PMC_DH_PaymentTerms__c, PMC_DH_QuoteFriendlyName__c, CurrencyIsoCode ,
                              PMC_DH_Account__c
                              FROM WebCart
                              WHERE Id =: objCartItem[0].CartId WITH SECURITY_ENFORCED LIMIT 1];
        List<CartItem> lstExistingCartitems = [Select Id, Quantity, Product2Id, Product2.StockKeepingUnit, PMC_DH_Source__c, PMC_DH_ShipTo__c, PMC_DH_DeliveryMode__c, PMC_DH_Incoterms__c, PMC_DH_PlantShipFrom__c, PMC_DH_Contract__c from CartItem where CartId = :objCartItem[0].cartId and Product2Id = : objCartItem[0].Product2Id];
        for(CartItem objCrtItm : lstExistingCartitems){
            if(objCrtItm.Product2Id == objCartItem[0].Product2Id && objCrtItm.PMC_DH_Source__c != objCartItem[0].PMC_DH_Source__c ){
                upsert  objCartItem;
            }
        }
    }
}