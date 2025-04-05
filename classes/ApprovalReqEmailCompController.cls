public class ApprovalReqEmailCompController {
    public string quoteId {get;set;}
    private SBQQ__Quote__c quoteInfo;
  
    
 
    // List of quoteline fields 
   public List<SBQQ__QuoteLine__c> qLines{
        get{
            if(quoteId!=null){
                qLines = [SELECT id, SBQQ__Product__c,SBQQ__ProductName__c,PMC_CPQ_ContractType__c,PMC_CPQ_PriceGuidanceTarget__c,PMC_CPQ_PriceGuidanceFloor__c,
                            PMC_CPQ_PriceBookValue__c,  SBQQ__EffectiveQuantity__c,PMC_CPQ_PaymentTerms__c,PMC_CPQ_Incoterms1__c,PMC_CPQ_PaymentDate__c,PMC_CPQ_VolumeDiscount__c,PMC_CPQ_Discount__c,PMC_CPQ_GeneralComments__c,PMC_CPQ_Margin__c,SBQQ__ListPrice__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId] ;
                }
                return qLines;   
        }set;
    }
    // Quote Info
    public SBQQ__Quote__c getQuoteInfo(){
        if (SBQQ__Quote__c.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.SBQQ__Quote__c.fields.Name.isAccessible() &&
            Schema.SObjectType.SBQQ__Quote__c.fields.SBQQ__ListAmount__c.isAccessible() && Schema.SObjectType.SBQQ__Quote__c.fields.SBQQ__AdditionalDiscountAmount__c.isAccessible() && Schema.SObjectType.SBQQ__Quote__c.fields.SBQQ__NetAmount__c.isAccessible() && quoteInfo == NULL && quoteId != NULL) {
            quoteInfo = [SELECT id, Name,PMC_CPQ_QuoteShortNameDescription__c,CurrencyIsoCode,PMC_CPQ_ContractEnd__c,SBQQ__Account__r.Name,CreatedDate,SBQQ__Type__c,SBQQ__Account__r.PMC_SS_Segmentation__c,PMC_CPQ_VCOQuotation__c,SubmittedDate__c                           
            from SBQQ__Quote__c where ID  =:quoteId];
        }
        return quoteInfo;
    } 
}