/** @description Controlled class invoked from its associated VF Page PMC_CPQ_GetPricePopup.
 *  @creator Lalit Sharma
 *  @Updated by Vignesh (10-Jul)
 *  @storynumber GDASF-6819
 */

public class PMC_CPQ_GetPricePopupController {
    public String cstmLabel {Get;Set;}
    public String baseUrl = '';
    public String quoteId = '';
    
    //Standard Controller
    public PMC_CPQ_GetPricePopupController(ApexPages.StandardController controller){
        quoteId = ApexPages.currentPage().getParameters().get('id');
        baseUrl = ApexPages.currentPage().getParameters().get('baseUrl');
    }
    
    /* @description Action method invoked from its associated VF Page PMC_CPQ_GetPricePopup. This is referencing a
     * callout method which will make a callout to SAP to get the prices for the products added to the cart.
     * @param NA
     * @Returntype PageReference - redirects back to the same QLE page from where its originated.
     */
    public PageReference redirect1()
    {    
        PageReference redirectToSourceQLE = new PageReference(baseUrl+'/apex/sb?scontrolCaching=1&id='+quoteId+'#quote/le?qId='+quoteId);
        
        //Calling a Future method to make a callout to SAP to get the prices for the product.
        //PMC_CPQ_GetPriceActionClass.getPriceCallout(quoteId);
        
        Map<String, Schema.SObjectField> fieldMap = SBQQ__Quote__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap();
                
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<SBQQ__Quote__c> lstQuotes = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM SBQQ__Quote__c where Id  = \''+ quoteId + '\' WITH SECURITY_ENFORCED');
		
		List<SBQQ__QuoteLine__c> lstQuoteLine = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId];
        if(lstQuoteLine.size() == 0){
            cstmLabel = System.Label.PMC_CPQ_GetPriceNoQuoteLineWarningMessage;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, cstmLabel));
            return null;
        }
        
        String strInterface = 'ProductsExternalPricing';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        String strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
        HttpResponse response = PMC_CPQ_GetPriceOnQuickSave.makeCalloutRequest(lstQuotes,strEndpoint);
        
        if(response!=null){
            PMC_CPQ_GetPriceResponseParsing.parseJSONGetPriceInterface(lstQuotes,response,strEndpoint);
        }

        
        String integrationStatus ='';
        integrationStatus = [Select PMC_CPQ_IntegrationStatus__c from SBQQ__Quote__c where id =: quoteId].PMC_CPQ_IntegrationStatus__c;
        
        if(integrationStatus != 'Success'){
            cstmLabel = System.Label.PMC_CPQ_GetPriceCalloutFailedErrorMessage;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, cstmLabel));
            return null;
        } else {       
            redirectToSourceQLE.setRedirect(true);
            return redirectToSourceQLE;
        }/*
        redirectToSourceQLE.setRedirect(true);
        return redirectToSourceQLE;*/
    }
    
    public pageReference goBack(){
        PageReference redirectToSourceQLE_goBack = new PageReference(baseUrl+'/apex/sb?scontrolCaching=1&id='+quoteId+'#quote/le?qId='+quoteId);
        redirectToSourceQLE_goBack.setRedirect(true);
        return redirectToSourceQLE_goBack;
    }
}