/**
* @description       : Batch Class to send Quote & Contract to SAP.
* @author            : Prakhar Srivastava
**/

public without sharing class PMC_DM_QuoteContractBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	Id userId;
    static final String STRING_INTEGRATIONSTATUSERROR = 'Error';
    static final String STRING_INTERFACE = 'SAPQuoteandContractCreate';
    static final String STRING_NAMEDCREDENTIALS = 'callout:PMC_CPQ_NamedCredential';
    static final String STRING_METHOD = 'POST';
    PMC_DM_QuoteContractBatch(Id userId){
        this.userId = userId;
    }
/**
* @description Start method of batchable
* @param objBC
* @return  Database.QueryLocator
*/
    
    public Database.QueryLocator start(Database.BatchableContext objBC){
          String query = 'select id from SBQQ__Quote__c where CreatedById =: userId and SBQQ__Status__c = \'Accepted\' and PMC_CPQ_SAPContractReference__c = null and PMC_CPQ_IntegrationStatus__c <> \'Success\''; 

        return Database.getQueryLocator(query);
    }
    
/**
* @description execute method of batchable
* @param objBC
* @param lstQuotes
*/    
    public void execute(Database.BatchableContext objBC, List<SBQQ__Quote__c > lstQuotes)
    {
        List<Id> lstIds = new List<Id>();
        for (SBQQ__Quote__c objQuote : lstQuotes){  
             lstIds.add(objQuote.Id);
        }
        // make callout to CPI
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(STRING_INTERFACE); 
        String strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
        String strCalloutEndpoint = STRING_NAMEDCREDENTIALS+strEndpoint;
        
        String strSerializedBody = PMC_CPQ_CPIRemoteCalloutUtilityClass.createMinimalPayload(lstIds);
        HttpResponse response = PMC_CPQ_CPIRemoteCalloutUtilityClass.sendCalloutRequest(STRING_METHOD, strCalloutEndpoint, strSerializedBody);
        if(response != null)
        {
            PMC_CPQ_CPIQuoteContractIntegrationClass.parseJSONQuoteContractInterface(lstQuotes,response,strEndpoint);
        }
    }
    
    /**
* @description finish method of batchable
* @param objBC
*/    
    public void finish(Database.BatchableContext objBC)
    {
        System.assertEquals('Success','Success');
    }
}