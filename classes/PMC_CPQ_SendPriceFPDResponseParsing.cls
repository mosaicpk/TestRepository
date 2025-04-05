/** @description Response Parsing Class for Send Final Price to SAP on Order Detail Page
*  @creator Prakhar
*  @storynumber GDASF-12490
*/

public without sharing class PMC_CPQ_SendPriceFPDResponseParsing {    
    static final String STRING_INTEGRATIONSTATUSERROR = 'Error'; 
    static final String STRING_INTEGRATIONSTATUSSUCCESS = 'Success';
    static final String STRING_INTEGRATIONPREFIXMESSAGE = 'FPD Final Price to SAP';
    static final Integer INT_STATUSCODE200 = 200;
    static final Integer INT_STATUSCODE201 = 201;
    static final List<Integer> LISTINT_SUCCESSCODES = new List<Integer>{INT_STATUSCODE200,INT_STATUSCODE201};
    static final List<String> STRING_SUCCESSCODES = new List<String>{'S', 'W'};
    static List<PMC_CPQ_TransactionLog__c> lstTransactionLogs;
    static String strStatusTransactionLog;
    static string strEndpoint;
    
    /** @description Method to parse Success response from SAP.
*  @param lstId - List of Order Item records
*  @param response - Response from SAP
*  @param fromMassFPDUI - boolean variable to check if called from detail page/massfpdUI
*/
    public static void parseSAPDetail(List<OrderItem> lstId, HttpResponse response,Boolean fromMassFPDUI){
        String strInterface = 'SendFPD';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
        
        OrderItem ordIT = new OrderItem();
        Integer i = 0;
        map<String, OrderItem> orderItemMap = genOrderItemMap(lstId);
        List<Object> lstResponse = (List<Object>)JSON.deserializeUntyped(response.getBody());
        strStatusTransactionLog = STRING_INTEGRATIONSTATUSERROR;
        
        for(Object responseLine : lstResponse){
            Map<String, Object> mapResponseLine = (Map<String,Object>)responseLine;
            ordIT = orderItemMap.get((String)mapResponseLine.get('Recordid')); // map of order line
            try{
                //ordIT.put('PMC_CPQ_OrderItemIntegrationStatus__c', 'Error');
                //ordIT.put('PMC_CPQ_OrderItemIntegrationMessage__c', STRING_INTEGRATIONPREFIXMESSAGE + ': '+STRING_INTEGRATIONSTATUSERROR);
                
                if(STRING_SUCCESSCODES.contains((String)mapResponseLine.get('Status')))//status code returned is 200
                {   
                    i++;
                    ordIT.put('PMC_CPQ_OrderItemIntegrationStatus__c', 'Success');
                    ordIT.put('PMC_CPQ_OrderItemIntegrationMessage__c', STRING_INTEGRATIONPREFIXMESSAGE + ': '+ STRING_INTEGRATIONSTATUSSUCCESS);
                }
                else{
                    ordIT.put('PMC_CPQ_OrderItemIntegrationStatus__c', 'Error');
                    ordIT.put('PMC_CPQ_OrderItemIntegrationMessage__c', STRING_INTEGRATIONPREFIXMESSAGE + ': ' + STRING_INTEGRATIONSTATUSERROR);
                }
            }
            catch(Exception e){
                ordIT.put('PMC_CPQ_OrderItemIntegrationMessage__c', STRING_INTEGRATIONPREFIXMESSAGE + ': ' + e.getMessage().substring(0,math.mod(e.getMessage().length(),230)));
                continue;
            }
        }
        
        
        SObjectAccessDecision securityDecisionQuote = Security.stripInaccessible(AccessType.UPDATABLE, lstId);
        Database.update(securityDecisionQuote.getRecords(),false);
        
        strStatusTransactionLog = ((i<lstResponse.size())?((i==0)?'Error':'Partial Success'):'Success');
        
        createTransactionLog(response);
        if(fromMassFPDUI)
        {
            publishToFPDPlatformEvent(lstId,strStatusTransactionLog,strEndpoint);
        }
    }
    
    /** @description Method to parse Error response from SAP.
*  @param lstId - List of Order Item records
*  @param response - Response from SAP
*  @param fromMassFPDUI - boolean variable to check if called from detail page/massfpdUI
*/
    public static void parseSAPErrorDetail(List<OrderItem> lstId, HttpResponse response, Boolean fromMassFPDUI){
        String strInterface = 'SendFPD';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
        
        strStatusTransactionLog = STRING_INTEGRATIONSTATUSERROR;
        for(OrderItem ordIT : lstId){
            // map of order line
            ordIT.put('PMC_CPQ_OrderItemIntegrationStatus__c', 'Error');
            ordIT.put('PMC_CPQ_OrderItemIntegrationMessage__c', STRING_INTEGRATIONPREFIXMESSAGE + ': ' + STRING_INTEGRATIONSTATUSERROR);
        }
        SObjectAccessDecision securityDecisionQuote = Security.stripInaccessible(AccessType.UPDATABLE, lstId);
        Database.update(securityDecisionQuote.getRecords(),false);
        
        createTransactionLog(response);
        if(fromMassFPDUI)
        {
            publishToFPDPlatformEvent(lstId,strStatusTransactionLog,strEndpoint);
        }
    }
    /** @description Method to return orderitem object mapped to id.
*  @param lstId - List of Order Item records
* 	@return mapOrderItem - map of string id and order item object
*/
    public static Map<String, OrderItem> genOrderItemMap(List<OrderItem> lstId){
        Map<String, OrderItem> mapOrderItem = new Map<String, OrderItem>();
        for(OrderItem ordIt: lstId){
            mapOrderItem.put(('' + ordIt.Id),ordIt);
        }
        return mapOrderItem;
    }
    /** 
* @description this method publishes the fpd price and callout status in the fpd platform event
* @param lstOrderLines - List of order lines
* @param strTLStatus - status of the callout
* @param strTLMessage - response of the callout
*/
    public static void publishToFPDPlatformEvent(List<OrderItem> lstOrderLines, String strTLStatus, String strTLMessage)
    {
        //Start Changes for Publishing Platform event
        // Publish a platform event
        if(!lstOrderLines.isEmpty()){
            List<PMC_CPQ_FPDPriceFx__e> platformEventFPD = new List<PMC_CPQ_FPDPriceFx__e>();
            for(OrderItem op : lstOrderLines){
                
                PMC_CPQ_FPDPriceFx__e testEvent = new PMC_CPQ_FPDPriceFx__e();
                testEvent.PMC_CPQ_OrderLineIntegrationStatus__c = strTLStatus;
                testEvent.PMC_CPQ_IntegrationStatusMessage__c = op.PMC_CPQ_OrderItemIntegrationMessage__c;
                testEvent.PMC_CPQ_InterfaceURL__c = strTLMessage;
                testEvent.PMC_CPQ_OrderItemId__c = op.Id;
                testEvent.PMC_CPQ_FPDPrice__c = op.PMC_CPQ_FPDPricefromPriceFx__c;
                
                platformEventFPD.add(testEvent);
            }
            // Call method to publish events
            EventBus.publish(platformEventFPD);
            //End Changes for Publishing Platform event
        }
    }
    /** 
* @description this method updates Integration Status and Integration Message of Order Lines and Transaction Log during Exception
* @param lstOrderLines - List of order lines
*/
    public static void updateLinesOnException(List<OrderItem> lstOrderLines){
        for(OrderItem ol : lstOrderLines){
            ol.PMC_CPQ_OrderItemIntegrationStatus__c = 'Error';
            ol.PMC_CPQ_OrderItemIntegrationMessage__c = STRING_INTEGRATIONPREFIXMESSAGE + ': ' + PMC_CPQ_CPIRemoteCalloutUtilityClass.strExceptionMsg.abbreviate(225);
        }
        SObjectAccessDecision securityDecisionQuote = Security.stripInaccessible(AccessType.UPDATABLE, lstOrderLines);
        Database.update(securityDecisionQuote.getRecords(),false);
    }
    /** 
* @description this method creates Transaction log for the callout
* @param response - the http response received
*/
    public static void createTransactionLog(HttpResponse response){
        Map<String, String> mapTransactionLogFields = new Map<String,String>();
        mapTransactionLogFields.put('PMC_CPQ_IntegrationStatus__c',strStatusTransactionLog);
        mapTransactionLogFields.put('PMC_CPQ_InterfaceURL__c', strEndpoint);
        mapTransactionLogFields.put('PMC_CPQ_RequestBody__c',PMC_CPQ_CPIRemoteCalloutUtilityClass.request.getBody());
        mapTransactionLogFields.put('PMC_CPQ_ResponseBody__c',response.getBody().abbreviate(131060));
        
        lstTransactionLogs = PMC_CPQ_TransactionLogUtilityClass.addTransactionLog(mapTransactionLogFields);
        PMC_CPQ_TransactionLogUtilityClass.insertTransactionLogs(lstTransactionLogs);
    }
}