public class RelatedQuoteLines {
    PUBLIC static string baseURL = '';
    public static string quoteId ='';
    public string quoteLineId = '';
    
    public RelatedQuoteLines(ApexPages.StandardController controller){
        quoteLineId = ApexPages.currentPage().getParameters().get('recid');
        system.debug('!!!!!!!!!!!' + quoteLineId);
        
    }
    
	@AuraEnabled(cacheable=true)
    public static List<SBQQ__QuoteLine__c> getQuoteLines(String quoteLineId) {
        
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id = :quoteLineId LIMIT 1];
        
        if (quoteLine != null && quoteLine.SBQQ__Quote__c != null) {
            List<SBQQ__QuoteLine__c> relatedQuoteLines = [SELECT Id,SBQQ__Number__c, SBQQ__Quote__c, Name, SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__Quote__r.PMC_CPQ_ContractStart__c, SBQQ__Quote__r.PMC_CPQ_ContractEnd__c,  PMC_CPQ_ProductLocation__r.PMC_CPQ_Address__c, PMC_CPQ_ModeofTransportation__c, PMC_CPQ_Incoterms1__c, SBQQ__Quote__r.PMC_CPQ_QLEURL__c   
                    FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__Quote__c = :quoteLine.SBQQ__Quote__c];
            baseURL = relatedQuoteLines[0].SBQQ__Quote__r.PMC_CPQ_QLEURL__c;
            quoteId = relatedQuoteLines[0].SBQQ__Quote__c;
            return relatedQuoteLines;
        } else {
            return new List<SBQQ__QuoteLine__c>();
        }
    }
    
    public PageReference redirect()
    {    
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, SBQQ__Quote__r.PMC_CPQ_QLEURL__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id = :quoteLineId LIMIT 1];
        
        PageReference redirectToSourceQLE = new PageReference(quoteLine.SBQQ__Quote__r.PMC_CPQ_QLEURL__c+'/apex/sb?scontrolCaching=1&id='+quoteLine.SBQQ__Quote__c+'#quote/le?qId='+quoteLine.SBQQ__Quote__c);
        return redirectToSourceQLE;
    }
}