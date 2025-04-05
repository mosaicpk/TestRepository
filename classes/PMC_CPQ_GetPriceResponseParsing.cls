/** @description This is a utility class for external callouts.
 *  @author Prakhar, Vignesh
 *  @storynumber GDASF-6987, 9437
 *  @Storynumber GDASF-6229 - Vignesh updated for cloned quote - Get Price banner display
 */
public with sharing class PMC_CPQ_GetPriceResponseParsing implements Database.AllowsCallouts {
    public static Boolean getPriceCalloutComplete = false;
    static final String STRING_INTEGRATIONSTATUSERROR = 'Error'; 
    static final String STRING_INTEGRATIONSTATUSSUCCESS = 'Success';
    static final String STRING_GETPRICEPREFIX = 'Get Price: ';
    static final Integer INT_STATUSCODE200 = 200;
    static final Integer INT_STATUSCODE201 = 201;
    static Exception objException;
    static final List<Integer> LISTINT_SUCCESSCODES = new List<Integer>{INT_STATUSCODE200,INT_STATUSCODE201};
    static HttpRequest request = new HttpRequest();
    static HttpResponse response;
    static List<PMC_CPQ_TransactionLog__c> lstTransactionLogs;
    static List<PMC_CPQ_IntegrationFieldMap__mdt> lstPriceCondMap = new List<PMC_CPQ_IntegrationFieldMap__mdt>();
    static List<PMC_CPQ_IntegrationFieldMap__mdt> lstItemMap = new List<PMC_CPQ_IntegrationFieldMap__mdt>();
    static List<String> ls = new List<String>{'', null};
    
    /** 
     * @description Parses through the response body and populates Integration fields on the quote.
     * @param lstQuotes - List of quotes.
     * @param response - response received from the endpoint.
     * @param strEndpoint - Endpoint that the HttpRequest will hit.
     */
    public static void parseJSONGetPriceInterface(List<SBQQ__Quote__c> lstQuotes, HttpResponse response, String strEndpoint)
    {    
        String strJSONResponseBody = response.getBody();
		SBQQ__Quote__c objQuote = lstQuotes[0];
        Map<String, String> mapTransactionLogFields = new Map<String,String>();
        mapTransactionLogFields.put('PMC_CPQ_IntegrationStatus__c',STRING_INTEGRATIONSTATUSERROR);
        mapTransactionLogFields.put('PMC_CPQ_InterfaceURL__c',strEndpoint);
        mapTransactionLogFields.put('PMC_CPQ_RequestBody__c',PMC_CPQ_CPIRemoteCalloutUtilityClass.request.getBody());
        mapTransactionLogFields.put('PMC_CPQ_ResponseBody__c',strJSONResponseBody);
        
        if(LISTINT_SUCCESSCODES.contains(response.getStatusCode()))//status code returned is 200
        {   
            try
            {
                responseProcess(lstQuotes, response);
                    objQuote.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSSUCCESS;
                    objQuote.PMC_CPQ_IntegrationMessage__c = STRING_GETPRICEPREFIX+STRING_INTEGRATIONSTATUSSUCCESS;
                    //Adding below assignment as part of GDASF-6229
                    objQuote.PMC_CPQ_GetPriceCallComplete__c = true;
                    getPriceCalloutComplete = true;

                mapTransactionLogFields.put('PMC_CPQ_IntegrationStatus__c',STRING_INTEGRATIONSTATUSSUCCESS);
            }
            catch(Exception e)//Exception caused due to inablitiy to parse through response.
            {
                    objQuote.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
                    objQuote.PMC_CPQ_IntegrationMessage__c = STRING_GETPRICEPREFIX+e.getMessage();
                    //Adding below If condition and assignment as part of GDASF-6229
                    objQuote.PMC_CPQ_GetPriceCallComplete__c = ((objQuote.PMC_CPQ_GetPriceCallComplete__c != true)?false:true);
                    getPriceCalloutComplete = false;
                
            }
        }
        else if(response.getStatusCode() != 500) //status code returned is not 200
        {
                objQuote.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
                
                //Check for null response under Error Details json node.
                String checkForNullResponseFromSAP;
                checkForNullResponseFromSAP = ('' + ((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('error')).get('innererror')).get('errordetails'));
                String strErrorMsg = ((checkForNullResponseFromSAP != '')?(String)((Map<String, Object>)((List<Object>)((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('error')).get('innererror')).get('errordetails')).get('errordetail'))[0]).get('message'):System.Label.PMC_CPQ_GetPriceCalloutFailedNoResponse); 
            	List<String> lstErrorMsg = new List<String>();
         		lstErrorMsg.add(strErrorMsg);
            	objQuote.PMC_CPQ_IntegrationMessage__c = STRING_GETPRICEPREFIX + PMC_CPQ_ConvertErrorMessageClass.convertToUserFriendlyMsg(lstErrorMsg)[0];
                
                //Adding below If condition and assignment as part of GDASF-6229
                objQuote.PMC_CPQ_GetPriceCallComplete__c = ((objQuote.PMC_CPQ_GetPriceCallComplete__c != true)?false:true);
                getPriceCalloutComplete = false;
        }else{
                objQuote.PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
                objQuote.PMC_CPQ_IntegrationMessage__c = STRING_GETPRICEPREFIX+STRING_INTEGRATIONSTATUSERROR;
                
                //Adding below If condition and assignment as part of GDASF-6229
                objQuote.PMC_CPQ_GetPriceCallComplete__c = ((objQuote.PMC_CPQ_GetPriceCallComplete__c != true)?false:true);
                getPriceCalloutComplete = false;
        }
        
        
        SBQQ.TriggerControl.disable();
        try {
            SObjectAccessDecision securityDecisionQuote = Security.stripInaccessible(AccessType.UPDATABLE, lstQuotes);
            Database.update(securityDecisionQuote.getRecords(),false);
            

            lstTransactionLogs = PMC_CPQ_TransactionLogUtilityClass.addTransactionLog(mapTransactionLogFields);
            PMC_CPQ_TransactionLogUtilityClass.insertTransactionLogs(lstTransactionLogs);
        } finally {
            SBQQ.TriggerControl.enable();
        }
    }
    
    /** 
     * @description Parses through the response body and populates Integration fields on the quote.
     * @param lstQuotes - List of quotes.
     * @param response - response received from the endpoint.
     */
    public static void responseProcess(List<SBQQ__Quote__c> lstQuotes, HttpResponse response){
        
        List<SBQQ__QuoteLine__c> lstQuoteLines = [Select id,SBQQ__ListPrice__c, SBQQ__Number__c,SBQQ__Quote__c,PMC_CPQ_LastPricedDate__c, SBQQ__UpgradedSubscription__c, SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.PMC_CPQ_Region__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :(lstQuotes[0].Id) WITH SECURITY_ENFORCED];
        Map<String,Object> jsonResponse = (Map<String, Object>)((Map<String, Object>)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('HeaderSet')).get('Header');
		
        
        List<Object> lstPriceCond = (List<Object>)((Map<String,Object>)((List<Object>)jsonResponse.get('Price_CondSet'))[0]).get('Price_Cond');
        
        PMC_CPQ_IntegrationFieldMap__mdt credLim = PMC_CPQ_IntegrationFieldMap__mdt.getInstance('CD1');
        PMC_CPQ_IntegrationFieldMap__mdt credExp = PMC_CPQ_IntegrationFieldMap__mdt.getInstance('CD2');  // Credit Records are being fetched manually to caputre credit details
        
        List<Object> lstItemR = (List<Object>)((Map<String,Object>)jsonResponse.get('Item_RSet')).get('Item_R');
        
        
        String checkNullCred = '' + jsonResponse.get('Credit_LimitSet');
        lstQuotes[0].put(credLim.PMC_CPQ_ApexAPIName__c, ((checkNullCred != '')?Decimal.valueOf((String)(((Map<String,Object>)((List<Object>)((Map<String,Object>)jsonResponse.get('Credit_LimitSet')).get('Credit_Limit'))[0]).get(credLim.PMC_CPQ_AttributeKey__c))):null));
		lstQuotes[0].put(credExp.PMC_CPQ_ApexAPIName__c, ((checkNullCred != '')?Decimal.valueOf((String)(((Map<String,Object>)((List<Object>)((Map<String,Object>)jsonResponse.get('Credit_LimitSet')).get('Credit_Limit'))[0]).get(credExp.PMC_CPQ_AttributeKey__c))):null));

        
        Map<String, SBQQ__QuoteLine__c> mapQuoteLine = new Map<String, SBQQ__QuoteLine__c>();//map of Item_number and respective QuoteLine
        for(SBQQ__QuoteLine__c qtline: lstQuoteLines){
                mapQuoteLine.put((''+qtline.SBQQ__Number__c), qtline);
        }
        SBQQ__QuoteLine__c qtLine = new SBQQ__QuoteLine__c();
        filterResponseMap();
        parseItemRUpdateQuoteLine(lstItemR, mapQuoteLine);
		parsePriceCondUpdateQuoteLine(lstPriceCond, mapQuoteLine);
        checkNullCred = '' + jsonResponse.get('Raw_MaterialSet');
        if(checkNullCred!=''){
            PMC_CPQ_GetPriceUtilityClass.makeRawMaterialRecords(JSON.serialize(((Map<String,Object>)jsonResponse.get('Raw_MaterialSet')).get('Raw_Material')),lstQuotes[0].Id);
        }

        SBQQ.TriggerControl.disable();
        try{
            
            SObjectAccessDecision securityDecisionQuoteLine = Security.stripInaccessible(AccessType.UPDATABLE, lstQuoteLines);
            Database.update(securityDecisionQuoteLine.getRecords(),false);
        }
        finally{
                SBQQ.TriggerControl.enable();
        }
    }
     /** 
     * @description filter through integration field map
     */
    public static void filterResponseMap(){
        List<PMC_CPQ_IntegrationFieldMap__mdt> lstCompParseMap = [select MasterLabel,PMC_CPQ_ApexAPIName__c,PMC_CPQ_DataType__c,PMC_CPQ_SFObject__c,  PMC_CPQ_AttributeKey__c from PMC_CPQ_IntegrationFieldMap__mdt where (PMC_CPQ_SFObject__c in ('Item_R', 'Price_Cond') AND PMC_CPQ_IsLookup__c = false AND PMC_CPQ_AttributeKey__c != null AND PMC_CPQ_ApexAPIName__c != null) WITH SECURITY_ENFORCED order by MasterLabel ASC];
        for(PMC_CPQ_IntegrationFieldMap__mdt s: lstCompParseMap){
            if(s.PMC_CPQ_SFObject__c == 'Price_Cond'){
                lstPriceCondMap.add(s);
                continue;
            }
            lstItemMap.add(s);
        }
    }
    /** 
     * @description Parses through the response body and populates Integration fields on the quote.
     * @param lstPriceCond - Price Condition block from Response
     * @param mapQuoteLine - QuoteLine record
     */
    public static void parsePriceCondUpdateQuoteLine(List<Object> lstPriceCond, Map<String, SBQQ__QuoteLine__c> mapQuoteLine){
        String strAPIName = '';
        SBQQ__QuoteLine__c qtLine =new SBQQ__QuoteLine__c();
        //PMC_CPQ_IntegrationFieldMap__mdt validStrtDt = PMC_CPQ_IntegrationFieldMap__mdt.getInstance('D1');
        //PMC_CPQ_IntegrationFieldMap__mdt validEndDt = PMC_CPQ_IntegrationFieldMap__mdt.getInstance('D2'); 
      
        Map<String, String> mapPriceCond = new Map<String, String>();//map of CondType and Apex API Name
        Map<String, String> mapDataTypePrcCond = new Map<String, String>();
        for(PMC_CPQ_IntegrationFieldMap__mdt priceCondLine: lstPriceCondMap){
                mapPriceCond.put(priceCondLine.PMC_CPQ_AttributeKey__c, priceCondLine.PMC_CPQ_ApexAPIName__c);
                mapDataTypePrcCond.put(priceCondLine.PMC_CPQ_AttributeKey__c, priceCondLine.PMC_CPQ_DataType__c);
        }
        
        Map<String, Object> mapResponseLine = new Map<String, Object>();
        for(Object responseKey: lstPriceCond){
                mapResponseLine = (Map<String, Object>)responseKey;
                strAPIName = mapPriceCond.get((String)mapResponseLine.get('CondType'));
                if(strAPIName == null){
              		continue;
                }
                qtLine = mapQuoteLine.get((''+mapResponseLine.get('ItmNumber')));
            /*
            	if((qtLine.SBQQ__Quote__r.SBQQ__Type__c != 'Amendment')||(qtLine.SBQQ__UpgradedSubscription__c == null)){	// GDASF-9425 - GDASF-18763
                    qtLine.put('PMC_CPQ_LastPricedDate__c', (((String)mapResponseLine.get('CondType') == 'ZLST')?System.now():qtLine.get('PMC_CPQ_LastPricedDate__c')));
            	}*/
                 
                if(mapDataTypePrcCond.get((String)mapResponseLine.get('CondType')) == 'Decimal'){
                        qtLine.put(strAPIName, Decimal.valueOf((String)mapResponseLine.get('CondValue')));
                    continue;
                }/*else if((mapDataTypePrcCond.get((String)mapResponseLine.get('CondType')) == 'Date')&&(mapResponseLine.get('CondValue')!=null)){
                        qtLine.put(strAPIName, Date.valueOf((String)mapResponseLine.get('CondValue')));
                    continue;
                }*/
                        qtLine.put(strAPIName, mapResponseLine.get('CondValue'));
        }
    }
    /** 
     * @description Parses through the response body and populates Integration fields on the quote.
     * @param lstItemR - response line from EndPoint
     * @param mapQuoteLine - QuoteLine record
     */
    public static void parseItemRUpdateQuoteLine(List<Object> lstItemR, Map<String, SBQQ__QuoteLine__c> mapQuoteLine){
        String strAPIName = '';
        Map<String, String> mapItemR = new Map<String, String>();//map of Key and Apex API name
        for(PMC_CPQ_IntegrationFieldMap__mdt itmLine: lstItemMap){
                mapItemR.put(itmLine.PMC_CPQ_AttributeKey__c, itmLine.PMC_CPQ_ApexAPIName__c);
        }
        Map<String, Object> mapResponseLine = new Map<String, Object>();
        for(Object responseKey: lstItemR){
                mapResponseLine = (Map<String, Object>)responseKey;
                for(PMC_CPQ_IntegrationFieldMap__mdt add: lstItemMap){
                    SBQQ__QuoteLine__c qtLine = mapQuoteLine.get((''+mapResponseLine.get('ItmNumber')));
                    if(qtLine.SBQQ__Quote__r.PMC_CPQ_Region__c == 'Brazil'){
                        qtLine.PMC_CPQ_FinalPricePerTonne__c = null;
                        qtLine.PMC_CPQ_InterestFees__c = null;
                        qtLine.PMC_CPQ_VCOAdjustment__c = null;
                        qtLine.PMC_CPQ_EstTax__c = null;
                        qtLine.PMC_CPQ_ReplacementCost__c = null;
                        qtLine.PMC_CPQ_ExchangeRate__c = null;
                        qtLine.SBQQ__ListPrice__c = null;
                        qtLine.PMC_CPQ_NetUnitPrice__c = null;
                        qtLine.PMC_CPQ_PriceGuidanceFloor__c = null;
                        qtLine.PMC_CPQ_PriceGuidanceTarget__c = null;
                        qtLine.PMC_CPQ_PriceGuidanceCeiling__c = null;
                        qtLine.PMC_CPQ_CommissionCurrency__c = null;
                        qtLine.PMC_CPQ_InterestPeriod__c = null;
                        qtLine.PMC_CPQ_Interest__c = null;
                        qtLine.PMC_CPQ_ReplacementMargin__c = null;
                    }
                    strAPIName = mapItemR.get((String)add.get('PMC_CPQ_AttributeKey__c'));
                    if(add.PMC_CPQ_DataType__c == 'Date'){
                            qtLine.put(strAPIName, (mapResponseLine.containsKey((String)add.get('PMC_CPQ_AttributeKey__c')) && (!(ls.contains((String)mapResponseLine.get((String)add.get('PMC_CPQ_AttributeKey__c'))))))?(Date.valueOf((String)mapResponseLine.get((String)add.get('PMC_CPQ_AttributeKey__c')))):null);
                        continue;
                    }else if(add.PMC_CPQ_DataType__c == 'Decimal'){
                            qtLine.put(strAPIName, Decimal.valueOf((String)mapResponseLine.get((String)add.get('PMC_CPQ_AttributeKey__c'))));
                        continue;
                    }else if(add.PMC_CPQ_DataType__c == 'Boolean'){
                            qtLine.put(strAPIName, Boolean.valueOf((String)mapResponseLine.get((String)add.get('PMC_CPQ_AttributeKey__c'))));
                        continue;
                    }
                    qtLine.put(strAPIName, mapResponseLine.get((String)add.get('PMC_CPQ_AttributeKey__c')));
                }
        }
    }
}