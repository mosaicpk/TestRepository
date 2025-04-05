public with sharing class OrderCasesController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getRelatedCases(Id orderId) {
        System.debug('In apex class!');
        List<Case> casesRetreived = [SELECT Id, CaseNumber, Status, Type, Contact.Name, PMC_SS_AtFaultParty__c, CreatedDate 
                FROM Case WHERE PMC_SS_Order__c = :orderId ORDER BY CreatedDate DESC];
        System.debug('casesRetreived-->' + casesRetreived);
        return casesRetreived;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getOrderDetails(Id orderId) {
        Order ord = [SELECT Id, AccountId, Contract.CustomerSignedId, PMC_CPQ_SoldToAccount__c, PMC_CPQ_SAPOrderNumber__c, OrderNumber 
                     FROM Order
                     WHERE Id = :orderId];

        Map<String, Object> result = new Map<String, Object>();
        result.put('AccountId', ord.AccountId);
        result.put('ContactId', ord.Contract.CustomerSignedId);
        result.put('PMC_SS_SoldToAccount__c', ord.AccountId);
        result.put('PMC_SS_SAPOrderNumber__c', ord.PMC_CPQ_SAPOrderNumber__c);
        result.put('PMC_SS_SNOW_OrderNumberorContractNumber__c', ord.OrderNumber);
        result.put('PMC_SS_Order__c', ord.Id);

        return result;
    }
}