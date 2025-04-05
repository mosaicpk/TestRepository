/**
* @File Name : MassUpdateQuoteLinesHandler.cls
* @Description :
* @Author : Kaushik  Gohain
* @Last Modified By :
* @Last Modified On : March 3 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 3, 2025 |   | Initial Version
**/

public class MassUpdateQuoteLinesHandler {
    
    public static void massUpdateQuoteLines(List<SBQQ__QuoteLine__c> quoteLineItemNewList, Map<Id,SBQQ__QuoteLine__c> quoteLineItemoldMap) {
        for(SBQQ__QuoteLine__c quoteLine : quoteLineItemNewList) {
           /* if(quoteLine.PMC_CPQ_ProductPackTypeIndicator__c )   
            {
                quoteLine.PMC_CPQ_PackType__c = quoteLineItemoldMap.get(quoteLine.Id).PMC_CPQ_PackType__c; 
            }
            if(quoteLine.PMC_CPQ_ProductPackageTypeIndicator__c || quoteline.PMC_CPQ_PackType__c =='Bulk')  {
                quoteLine.PMC_CPQ_PackageType__c = quoteLineItemoldMap.get(quoteLine.Id).PMC_CPQ_PackageType__c; 
            } */
            
            if(quoteLine.ProductLocation_Location__c != null) {
                quoteLine.PMC_CPQ_ProductLocation__c = quoteLineItemoldMap.get(quoteLine.Id).PMC_CPQ_ProductLocation__c; 
            }
        }
    }
}