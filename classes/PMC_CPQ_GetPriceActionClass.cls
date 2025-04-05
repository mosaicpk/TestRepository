/** @description Controlled class invoked from its associated VF Page PMC_CPQ_GetPricePopup.
 *  @creator Lalit Sharma
 *  @Updated by Vignesh/Prakhar (10-Jul)
 *  @storynumber GDASF-6819
 */
public with sharing class PMC_CPQ_GetPriceActionClass {
    static List<String> ls = new List<String>{'', null};
    public String baseUrl = '';
    public String quoteId = '';
/**    
 *  @description finalMsg - final message
 */
   // public String finalMsg {get;set;}
/**    
 *  @description showBtn - Boolean flag to show message
 */
    public boolean showBtn {get;set;}
    
    /** @description Constructor of the class which is used to intialize variables using parameter.
     *  @param controller : Standard Controller Object
     */
    public PMC_CPQ_GetPriceActionClass(ApexPages.StandardController controller){
        quoteId = ApexPages.currentPage().getParameters().get('id');
        baseUrl = ApexPages.currentPage().getParameters().get('baseUrl');
        //baseUrl = URL.getOrgDomainURL().toExternalForm();
        showBtn = false;
    }
    
    /** @description Action method invoked from its associated VF Page PMC_CPQ_GetPricePopup. This is referencing a
     *  callout method which will make a callout to SAP to get the prices for the products added to the cart.
     *  @return redirectToSourceQLE - redirects back to the same QLE page from where its originated.
     */
    public PageReference redirect1()
    {    
        PageReference redirectToSourceQLE = new PageReference(baseUrl+'/apex/sb?scontrolCaching=1&id='+quoteId+'#quote/le?qId='+quoteId);
        //Calling a Future method to make a callout to SAP to get the prices for the product.
        Map<String, Schema.SObjectField> fieldMap = SBQQ__Quote__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap();
                
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String. - Additional Record Tye details fetched for Region based Request 060 
        List<SBQQ__Quote__c> lstQuotes = Database.query('SELECT ' + String.escapeSingleQuotes(String.join(lstFieldNames, ',')) + ', PMC_CPQ_SalesArea__r.PMC_SS_SalesArea__r.PMC_CPQ_SAPSalesOrganization__c, SBQQ__Source__r.Name, SBQQ__Source__r.PMC_CPQ_QuoteNumberIdentifier__c FROM SBQQ__Quote__c where Id  = \''+ String.escapeSingleQuotes(quoteId) + '\'');// WITH SECURITY_ENFORCED');
        if(ls.contains(lstQuotes[0].PMC_CPQ_SalesArea__r.PMC_SS_SalesArea__r.PMC_CPQ_SAPSalesOrganization__c)){
            String cstmWarningLabel = System.Label.PMC_CPQ_GetPriceSalesAreaError;
            showBtn = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, cstmWarningLabel));
            return null;
        }
        List<SBQQ__QuoteLine__c> lstQuoteLine = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId WITH SECURITY_ENFORCED];
        
        //When there are no quote lines in the cart to get prices, display the warning message to the AM.
        if(lstQuoteLine.size() == 0){
            String cstmWarningLabel = System.Label.PMC_CPQ_GetPriceNoQuoteLineWarningMessage;showBtn = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, cstmWarningLabel));
            return null;
        }
        
        String strInterface = 'ProductsExternalPricing';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        String strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
       system.debug('strEndpoint'+strEndpoint);
        HttpResponse response = PMC_CPQ_GetPriceOnQuickSave.makeCalloutRequest(lstQuotes,strEndpoint);
        //Check mandatory values
        if(PMC_CPQ_GetPriceOnQuickSave.strErrorMessage != '<br/>'){showBtn = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, PMC_CPQ_GetPriceOnQuickSave.strErrorMessage));
            return null;
        }

        if(response!=null){
            PMC_CPQ_GetPriceResponseParsing.parseJSONGetPriceInterface(lstQuotes,response,strEndpoint);
        }
        SBQQ__Quote__c integrationDetail = [Select PMC_CPQ_IntegrationStatus__c, PMC_CPQ_IntegrationMessage__c from SBQQ__Quote__c where id =: quoteId WITH SECURITY_ENFORCED];
        if(integrationDetail.PMC_CPQ_IntegrationStatus__c != 'Success'){
            String message = System.Label.PMC_CPQ_GetPriceCalloutFailedNoResponse;
            if(integrationDetail.PMC_CPQ_IntegrationMessage__c != null){
                message = integrationDetail.PMC_CPQ_IntegrationMessage__c;
            }
			showBtn = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, message));
            return null;
        } else {       
            redirectToSourceQLE.setRedirect(true);
            return redirectToSourceQLE;
        }
    }
    
    /** @description goBack action used to redirect to Quote Line Editor
     *  @return redirectToSourceQLEgoBack - returns original pageReference for redirect
     */
    public pageReference goBack(){
        PageReference redirectToSourceQLEgoBack = new PageReference(baseUrl+'/apex/sb?scontrolCaching=1&id='+quoteId+'#quote/le?qId='+quoteId);
        redirectToSourceQLEgoBack.setRedirect(true);
        return redirectToSourceQLEgoBack;
    }
}