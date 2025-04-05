public class PMC_CPQ_FetchAndStoreData implements Schedulable {

    public void execute(SchedulableContext sc) {
        // Make callouts to API, process data, and insert records in intellitrans shipment
        fetchAndInsertData();
        //Database.executeBatch(new PMC_IntellitransShipmentBatchUpdate(), 200);
    }
    private static final String GETTOKENNAME = 'IntelliTransGetToken';
    private static final String GETSHIPPMENTNAME = 'IntelliTransGetShipmentData';
    
    
    
    
    public static PMC_DH_IntegrationSettings__mdt getIntegrationSettings(String developerName) {
        PMC_DH_IntegrationSettings__mdt integrationSettings = [
            SELECT 
                Id, 
                DeveloperName,
                PMC_DH_CalloutMethod__c,
                PMC_DH_ContentType__c,
                PMC_DH_EndpointURL__c,
                PMC_DH_RefreshToken__c,
                PMC_DH_Accept__c,
                PMC_DH_RetryCount__c, 
                PMC_DH_RetryTimeout__c,
                PMC_DH_Timeout__c,
                PMC_DH_Authorization__c,
                PMC_DH_CachedTime__c,
                PMC_DH_ClientId__c,
                PMC_DH_ClientSecret__c
            FROM
                PMC_DH_IntegrationSettings__mdt 
            WHERE 
                DeveloperName =: developerName 
            WITH USER_MODE
            LIMIT 1
        ];

        return integrationSettings;
    }

    public class ShipmentData {
        @AuraEnabled public String DELIVERYNUMBER { get; set; }
        @AuraEnabled public String EQUIPMENTID { get; set; }
        @AuraEnabled public Datetime ETA { get; set; }
        @AuraEnabled public String BOL { get; set; }
        @AuraEnabled public String BOLNUMBER { get; set; }
        @AuraEnabled public String CUSTORDERNO { get; set; }
        @AuraEnabled public String SHIPMENTNUMBER_CNTORDER { get; set; }
        @AuraEnabled public String PONUMBER { get; set; }
        @AuraEnabled public String CURRENTCARRIER { get; set; }
        @AuraEnabled public String DESTINATIONCARRIER { get; set; }
        @AuraEnabled public String FLEETTOWNAME { get; set; }
        @AuraEnabled public String COMMENTS { get; set; }
        @AuraEnabled public String SIGHTINGLOADOREMPTY { get; set; }
        @AuraEnabled public String CURRENTLOCATION { get; set; }
        @AuraEnabled public String DESTINATIONMM { get; set; }
        @AuraEnabled public String LATESTTRIPSIGHTINGID { get; set; }
        @AuraEnabled public String LATESTINTERNALCOMMENT { get; set; }
        @AuraEnabled public String SIGHTINGDESTINATION { get; set; }
        @AuraEnabled public Double LATITUDE { get; set; }
        @AuraEnabled public Double LONGITUDE { get; set; }
    }
    
    @future(callout=true)
    public static void fetchAndInsertData() {
         String token;
        PMC_DH_IntegrationSettings__mdt getTokenIntegrationSettings = getIntegrationSettings(GETTOKENNAME);
         
        Map<String,Object> mapResponse;
       
        Map<String,String> headersMap = new Map<String,String>();
        List<PMC_CPQ_FetchAndStoreData.ShipmentData> shipmentDataList;
        Map<String, String> bodyMap = new Map<String, String>();
        HttpRequest request = new HttpRequest();
         Http http = new Http();
        HttpResponse response = new HttpResponse();

       
		
		Integer intTimeoutValue = 120000;
        
        request.setMethod('GET');
        request.setTimeout(intTimeoutValue);
        request.setEndpoint(getTokenIntegrationSettings.PMC_DH_EndpointURL__c);
        request.setHeader('loginid',getTokenIntegrationSettings.PMC_DH_ClientId__c);
		request.setHeader('pwd',getTokenIntegrationSettings.PMC_DH_ClientSecret__c);		
        request.setHeader('Content-Type',getTokenIntegrationSettings.PMC_DH_ContentType__c);
        
          try {
         response = http.send(request);
			 if(response.getStatusCode() == 200) {
                
                token = (String)JSON.deserializeUntyped(response.getBody());
            }
            else {
                token = '';
            }}
        catch(PMC_DH_Validation.CustomException ex){
            throw new PMC_DH_Validation.CustomException('Callout Failed');
        }
        catch (Exception ex) {
            throw  new AuraHandledException(ex.getMessage());
        }


        request = new HttpRequest();
        http = new Http();
        response = new HttpResponse();



        getTokenIntegrationSettings = getIntegrationSettings(GETSHIPPMENTNAME);
        bodyMap.put('equipmentNumbers', '');
        bodyMap.put('shipDateFrom', '');
        bodyMap.put('shipDateTo', '');
        bodyMap.put('searchTemplateName', 'Salesforce API');
        bodyMap.put('resultTemplateName', 'Salesforce API');
        bodyMap.put('loginId', 'Salesforce_API');
        bodyMap.put('shipmentType', 'Current');
        String body = JSON.serialize(bodyMap);        
       
        
        request.setMethod('GET');
        request.setTimeout(intTimeoutValue);
        request.setEndpoint(getTokenIntegrationSettings.PMC_DH_EndpointURL__c);
        request.setBody(body);
        request.setHeader('TokenID',token);
        request.setHeader('Content-Type',getTokenIntegrationSettings.PMC_DH_ContentType__c);
      
       
        try{
            response = http.send(request);
            if (response.getStatusCode() == 200) {       
                 
                shipmentDataList = (List<PMC_CPQ_FetchAndStoreData.ShipmentData>) JSON.deserialize(
                    response.getBody(),
                    List<PMC_CPQ_FetchAndStoreData.ShipmentData>.class
                );
                List<PMC_Shipment_Data__c> recordsToInsert = new List<PMC_Shipment_Data__c>();
                for (Integer i=0;i<shipmentDataList.size();i++) {
                     PMC_Shipment_Data__c customObj = new PMC_Shipment_Data__c();
                        customObj.PMC_CPQ_SAPDeliveryID__c = shipmentDataList[i].DELIVERYNUMBER;
                        customObj.PMC_DELIVERYNUMBER__c = shipmentDataList[i].DELIVERYNUMBER;
                        customObj.PMC_EQUIPMENTID__c = shipmentDataList[i].EQUIPMENTID;
                        customObj.PMC_ETA__c = shipmentDataList[i].ETA;
                        customObj.PMC_BOL__c = shipmentDataList[i].BOL;
                        customObj.PMC_BOLNUMBER__c = shipmentDataList[i].BOLNUMBER;
                        string custOrdNumber = shipmentDataList[i].CUSTORDERNO;
                        
                        If(custOrdNumber!=null){
                              customObj.PMC_CUSTORDERNO__c = custOrdNumber.removeStart('00');
                              
                        }else{
                            
                            customObj.PMC_CUSTORDERNO__c = shipmentDataList[i].CUSTORDERNO;
                        }
						customObj.PMC_SHIPMENTNUMBER_CNTORDER__c = shipmentDataList[i].SHIPMENTNUMBER_CNTORDER;
						customObj.PMC_PONUMBER__c = shipmentDataList[i].PONUMBER;
						customObj.PMC_CURRENTCARRIER__c = shipmentDataList[i].CURRENTCARRIER;
						customObj.PMC_DESTINATIONCARRIER__c = shipmentDataList[i].DESTINATIONCARRIER;
						customObj.PMC_FLEETTOWNAME__c = shipmentDataList[i].FLEETTOWNAME;
						customObj.PMC_COMMENTS__c = shipmentDataList[i].COMMENTS;
						customObj.PMC_SIGHTINGLOADOREMPTY__c = shipmentDataList[i].SIGHTINGLOADOREMPTY;
						customObj.PMC_DESTINATIONMM__c = shipmentDataList[i].DESTINATIONMM;
						customObj.PMC_LATESTTRIPSIGHTINGID__c = shipmentDataList[i].LATESTTRIPSIGHTINGID;
						customObj.PMC_LATESTINTERNALCOMMENT__c = shipmentDataList[i].LATESTINTERNALCOMMENT;
						customObj.PMC_SIGHTINGDESTINATION__c = shipmentDataList[i].SIGHTINGDESTINATION;
                        customObj.PMC_CPQ_CurrentCoordinates__latitude__s = shipmentDataList[i].LATITUDE;
                        customObj.PMC_CPQ_CurrentCoordinates__longitude__s = shipmentDataList[i].LONGITUDE;
                        customObj.PMC_CPQ_Shipment_PO__c =shipmentDataList[i].CUSTORDERNO+shipmentDataList[i].EQUIPMENTID;
                        customObj.Name = shipmentDataList[i].CUSTORDERNO;
                        customObj.PMC_Deliveries_Updated__c =FALSE;
                      recordsToInsert.add(customObj);
                  
                }
                PMC_DH_LoggingUtils.createDHTransactionLogs(
                request,
                response,
                getTokenIntegrationSettings.PMC_DH_EndpointURL__c
           );
                 if (!recordsToInsert.isEmpty()) {
                    try {
                        Schema.SObjectField ExtId = PMC_Shipment_Data__c.Fields.PMC_CPQ_Shipment_PO__c;
                        Database.upsert(recordsToInsert,ExtId,false);
                        System.debug('Records inserted successfully: ' + recordsToInsert.size());
                        
                        } catch (DMLException e) {
                             System.debug('Error inserting records: ' + e.getMessage());
                              
                        }
                }
            }
         else {
                System.debug('HTTP Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
                 System.debug('HTTP Error: ' + request + ' - ' + response);
                  PMC_DH_LoggingUtils.createDHTransactionLogs(
                request,
                response,
                getTokenIntegrationSettings.PMC_DH_EndpointURL__c
            );
        }
        }
             catch(PMC_DH_Validation.CustomException ex){
            throw new PMC_DH_Validation.CustomException('Callout Failed');
        }
        catch (Exception ex) {
            throw  new AuraHandledException(ex.getMessage());
        }finally{
            //Database.executeBatch(new PMC_IntellitransShipmentBatchUpdate(), 200);
        }
        
      

    
            
       
    }
}