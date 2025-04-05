/** @description This class is just for POC
 */
public without sharing class PMC_CPQ_ExtPricingTest implements Database.AllowsCallouts {
    static HttpRequest request = new HttpRequest();
    static HttpResponse response;
    static Boolean boolTransLogSuccess = false;
    static Boolean boolTransLogError = false;
    static final String STRING_INTEGRATIONSTATUSERROR = 'Error'; 
    static final String STRING_INTEGRATIONSTATUSSUCCESS = 'Success';
    static final string STRING_OBJECTNUMBER = 'OBJECT_NUMBER';
    static final string STRING_SFRECORDID = 'SFRecordId';
    static final string STRING_OBJECTNAME = 'ObjectName';
    static final string STRING_STATUSCODE = 'statusCode';
    static final string STRING_RESPONSEMESSAGE = 'responsetext';
    static final string STRING_OBJECTNAMEQUOTE = 'Quote';
    static final string STRING_OBJECTNAMECONTRACT = 'Contract';
    static final Integer INT_STATUSCODE200 = 200;
    static final Integer INT_STATUSCODE201 = 201;
    static final List<Integer> LISTINT_SUCCESSCODES = new List<Integer>{INT_STATUSCODE200,INT_STATUSCODE201};
    static List<PMC_CPQ_TransactionLog__c> lstTrl = new List<PMC_CPQ_TransactionLog__c>();
    static string QUOTE_IDGP;

   /** 
     * @description This class will make a callout to CPI.
     * @param lstQuotes - List of quotes.
     * @param strEndpoint - Endpoint that the HttpRequest will hit.
     */
    public static void makeCalloutRequest(List<SBQQ__Quote__c> lstQuotes, String strEndpoint)
    {
        Http http = new Http();
        
        Map<String, List<String>> mapJSONbody = new Map<String, List<String>>();
        List<String> lstJSOBBodyValue= new List<String>();
        List<String> lstStrMessages = new List<String>();
        
        String  strQuoteID = 'Id';

        try
        {          
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setEndpoint('callout:PMC_CPQ_NamedCredential'+strEndpoint);
            
            for(SBQQ__Quote__c curQuote : lstQuotes){   
                lstJSOBBodyValue.add(curQuote.Id);
            } 
            
            mapJSONbody.put(strQuoteID,lstJSOBBodyValue);
            String strJSON = JSON.serialize(mapJSONbody);
            request.setBody(strJSON);
            response = http.send(request); 
            PMC_CPQ_ExtPricingTest.parseJSONQuoteContractInterface(lstQuotes,response,strEndpoint);
        }
        catch(Exception e)
        {
            String strQuoteIDs = '';
            
            for(SBQQ__Quote__c curQuote: lstQuotes)
            {
                curQuote.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
                curQuote.PMC_CPQ_IntegrationMessage__c = e.getMessage();
                curQuote.Vignesh_Test__c = false;
                strQuoteIDs = curQuote.Id +' '+ strQuoteIDs;
            } 
            
            SObjectAccessDecision securityDecisionQuote = Security.stripInaccessible(AccessType.UPDATABLE, lstQuotes);
            Database.update(securityDecisionQuote.getRecords(),false);
            
            lstStrMessages.add(e.getMessage());
            createErrorLog(lstStrMessages,strQuoteIDs);
        }
    }
    /** 
     * @description This function will create an error log in the system.
     * @param lstStrMessages - List of error messages.
     * @param strQuoteIDs - String of quote ids.
     */
    public static void createErrorLog(List<String> lstStrMessages,String strQuoteIDs)
    {
        final string strClassName = 'PMC_CPQ_CPICalloutUtlilityClass';
        final string strFlowName = 'PMC CPQ After Update Quote Integration';
        final string strSourceType = 'Apex';
        final string strMethodName = 'postInfoToCPIAsync';
        
        List<PMC_ErrorLog__c> errorLogs = new List<PMC_ErrorLog__c>();

        for(String errorMessage: lstStrMessages)
        {
            PMC_ErrorLog__c errlog = new PMC_ErrorLog__c();
            errlog.PMC_ClassName__c = strClassName;
            errlog.PMC_FlowName__c = strFlowName;
            errlog.PMC_Type__c = strSourceType;
            errlog.PMC_MethodName__c = strMethodName;
            errlog.PMC_Message__c = errorMessage;
            errlog.PMC_ExternalId__c = strQuoteIDs;
            errorLogs.add(errlog);
         }
        
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, errorLogs);
        Database.insert(securityDecision.getRecords(),false); 
    } 
    /** 
     * @description Returns a filtered list of values by parsing through the payload received
     * @param lstObjContainer - Entire payload
     * @return lstFilteredList - Filtered payload
     */
    public static List<Object> getFilteredList(List<Object> lstObjContainer)
    {
        List<Object> lstFilteredList = new List<Object>();
        Set<Object> setFilteredSet = new Set<Object>();

        for(Object curObjContainer: lstObjContainer)//remove records with duplicate values and keep only values required for futher processing.
        { 
            Map<String,Object> mapCurRecord = (Map<String,Object>) curObjContainer;
            Map<String,Object> mapNewRecord = new Map<String,Object>();
            mapNewRecord.put(STRING_OBJECTNUMBER,mapCurRecord.get(STRING_OBJECTNUMBER));
            mapNewRecord.put(STRING_SFRECORDID,mapCurRecord.get(STRING_SFRECORDID));
            mapNewRecord.put(STRING_OBJECTNAME,mapCurRecord.get(STRING_OBJECTNAME));
            mapNewRecord.put(STRING_STATUSCODE,mapCurRecord.get(STRING_STATUSCODE));
            mapNewRecord.put(STRING_RESPONSEMESSAGE,mapCurRecord.get(STRING_RESPONSEMESSAGE));
            setFilteredSet.add(mapNewRecord);
        }
        lstFilteredList.addAll(setFilteredSet);
        return lstFilteredList;
    }
    
    /** 
     * @description Parses through the quote and payload.
     * @param lstQuotes - list of quotes
     * @param lstFilteredList - Filtered payload
     * @param strEndpoint - Interface Endpoint
     */
    public static void parseQuoteContractFilteredList(List<SBQQ__Quote__c> lstQuotes, List<Object> lstFilteredList, String strEndpoint)
    {
        String strInterface = 'SAPQuoteandContractCreate';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        String strQuoteAndContractReplicationEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
        
        for(SBQQ__Quote__c curQuote: lstQuotes)//parse through filtered list
        {
            Integer intResponseCodeQuote;
            Integer intResponseCodeContract;
            String strResponseMessageQuote;
            String strResponseMessageContract;
            String strSAPRefId;
            String strCombineMessage;
            String strContractMessage;
            Boolean boolFillSAPId;
            Boolean boolCombineMessages;
            
            for(Object curObjContainer: lstFilteredList)//parse through filtered list 
            {
                Map<String,Object> mapRecord = (Map<String,Object>)curObjContainer;
                Boolean boolIsCurrentQuote = mapRecord.get(STRING_OBJECTNAME) == STRING_OBJECTNAMEQUOTE && mapRecord.get(STRING_SFRECORDID) == curQuote.Id;
                Boolean boolIsCurrentContract = mapRecord.get(STRING_OBJECTNAME) == STRING_OBJECTNAMECONTRACT && mapRecord.get(STRING_SFRECORDID) == curQuote.Id;
                if(boolIsCurrentQuote)
                {
                    intResponseCodeQuote = (Integer) mapRecord.get(STRING_STATUSCODE);
                    strResponseMessageQuote = (String) mapRecord.get(STRING_RESPONSEMESSAGE);
                }
                else if(boolIsCurrentContract)
                {
                    intResponseCodeContract = (Integer) mapRecord.get(STRING_STATUSCODE);
                    strResponseMessageContract = (String) mapRecord.get(STRING_RESPONSEMESSAGE);
                    strSAPRefId = (String) mapRecord.get(STRING_OBJECTNUMBER);
                } 
            }

           boolFillSAPId = strEndpoint == strQuoteAndContractReplicationEndpoint && LISTINT_SUCCESSCODES.contains(intResponseCodeContract);
           
           if(boolFillSAPId)
           {
                //curQuote.PMC_CPQ_SAPReference__c = strSAPRefId;
           }
            
            boolCombineMessages = strResponseMessageQuote != null;
            strCombineMessage = STRING_OBJECTNAMEQUOTE+': ' +strResponseMessageQuote+'\n'+STRING_OBJECTNAMECONTRACT+': '+strResponseMessageContract;
            strContractMessage = STRING_OBJECTNAMECONTRACT+': '+strResponseMessageContract;             
            curQuote.PMC_CPQ_IntegrationMessage__c = boolCombineMessages?strCombineMessage:strContractMessage;
            curQuote.PMC_CPQ_IntegrationStatus__c = getQuoteIntegrationStatus(intResponseCodeQuote, intResponseCodeContract);
            System.debug('!!ID?!!' + curQuote.Id);
            //curQuote.PMC_CPQ_ContractStart__c = System.today().addDays(10);//'Prepay - Saskferco'; // For testing
            QUOTE_IDGP = curQuote.Id;
          	curQuote.Vignesh_Test__c = false;
        }
    }
     /** 
     * @description Returns overall order status
     * @return strIntegrationStatusError - Status = Error
     * @return strIntegrationStatusWarning - Status = Warning
     * @return strIntegrationStatusSuccess - Status = Success 
     */
    public static String getOverallTransactionStatus()
    {
        if(boolTransLogError)
        {
            return (STRING_INTEGRATIONSTATUSERROR);
        }
        return (STRING_INTEGRATIONSTATUSSUCCESS);
    }
    
   /** 
     * @description It returns the quote integration status.
     * @param intResponseCodeQuote - Response code of quote.
     * @param intResponseCodeContract - Response code of contract.
     * @return STRING_INTEGRATIONSTATUSERROR  - Return error status.
     * @return STRING_INTEGRATIONSTATUSSUCCESS - Return success status.
     */
    public static String getQuoteIntegrationStatus(Integer intResponseCodeQuote, Integer intResponseCodeContract)
    {
        if(intResponseCodeContract == null || (LISTINT_SUCCESSCODES.contains(intResponseCodeContract) == false)||(intResponseCodeQuote != null && LISTINT_SUCCESSCODES.contains(intResponseCodeQuote) == false))//Error Scenario
        {
            boolTransLogError = true;
            return STRING_INTEGRATIONSTATUSERROR;
        }
        
        boolTransLogSuccess = true; //Success Scenario
        return STRING_INTEGRATIONSTATUSSUCCESS; 
    }
    
    /** 
     * @description Parses through the response body and populates Integration fields on the quote.
     * @param lstQuotes - List of quotes.
     * @param response - Response received from the endpoint.
     * @param strEndpoint - Endpoint that the HttpRequest will hit.
     */
    public static void parseJSONQuoteContractInterface(List<SBQQ__Quote__c> lstQuotes, HttpResponse response, String strEndpoint)
    {    
        List<Object> lstFilteredList = new List<Object>();
        List<Object> lstObjContainer= new List<Object>();
        String strJSONResponseBody = response.getBody();
        PMC_CPQ_TransactionLog__c trl = new PMC_CPQ_TransactionLog__c();
        trl.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
        trl.PMC_CPQ_RequestBody__c = request.getBody();
        trl.PMC_CPQ_ResponseBody__c = strJSONResponseBody;
        trl.PMC_CPQ_InterfaceURL__c = strEndpoint;

        if(LISTINT_SUCCESSCODES.contains(response.getStatusCode()))//status code returned is 200
        {   
            try
            {
                lstObjContainer= (List<Object>) JSON.deserializeUntyped(response.getBody());
                lstFilteredList = getFilteredList(lstObjContainer);//removes duplicate records and non essential values
                parseQuoteContractFilteredList(lstQuotes, lstFilteredList, strEndpoint);
                trl.PMC_CPQ_IntegrationStatus__c = getOverallTransactionStatus();
            }
            catch(Exception e)//Exception caused due to inablitiy to parse through response.
            {
                for(SBQQ__Quote__c curQuote: lstQuotes)
                {
                    curQuote.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
                    curQuote.PMC_CPQ_IntegrationMessage__c = e.getMessage();
                    curQuote.Vignesh_Test__c = false;
                }
            }
        }
        else //status code returned is not 200
        {
            trl.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
            
            for(SBQQ__Quote__c curQuote: lstQuotes)
            {
                curQuote.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
                curQuote.PMC_CPQ_IntegrationMessage__c = response.getBody();
                curQuote.Vignesh_Test__c = false;
            }
        }
        
        lstTrl.add(trl);
        System.debug('!!'+lstQuotes);
        SObjectAccessDecision securityDecisionQuote = Security.stripInaccessible(AccessType.UPDATABLE, lstQuotes);
        Database.update(securityDecisionQuote.getRecords(),false);
        
        SObjectAccessDecision securityDecisionTrl = Security.stripInaccessible(AccessType.CREATABLE, lstTrl);
        Database.insert(securityDecisionTrl.getRecords(),false);
        String timecron = '1 0 0 0 0 *';
        //System.scheduleBatch(new SBQQ.QuotePriceRefreshBatch(SBQQ__Quote__c.sObjectType,new Set<Id>{QUOTE_IDGP}), 'Refresh quote', 0, 0);
    }
}