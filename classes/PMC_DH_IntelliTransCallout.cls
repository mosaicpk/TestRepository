/**
 * @description       : 
 * @author            : Bruno Orlandin
 * @group             : 
 * @last modified on  : 07-17-2024
 * @last modified by  : Bruno Orlandin
**/
public with sharing class PMC_DH_IntelliTransCallout {
    private static final String GETTOKENNAME = 'IntelliTransGetToken';
    private static final String GETSHIPPMENTNAME = 'IntelliTransGetShipmentData';

    private String token { get; set; }
    
    /**
    * @description performs a callout to intellitrans api to retrieve token
    * @author Bruno Orlandin | 07-17-2024 
    * @return String 
    **/
    public String getTokenIdCallout(){
        PMC_DH_IntegrationCalloutFramework.PMC_DH_CallOutWrapper callOutWrapper;
        String token;
        PMC_DH_IntegrationSettings__mdt getTokenIntegrationSettings = PMC_DH_IntelliTransCalloutHelper.getIntegrationSettings(GETTOKENNAME);
        Map<String,String> headersMap = new Map<String,String>();
        PMC_DH_IntegrationCalloutFramework integrationFramework = new PMC_DH_IntegrationCalloutFramework();

        headersMap.put('ENDPOINT', getTokenIntegrationSettings.PMC_DH_EndpointURL__c );
        headersMap.put('loginid', getTokenIntegrationSettings.PMC_DH_ClientId__c);
        headersMap.put('pwd', getTokenIntegrationSettings.PMC_DH_ClientSecret__c);
      
        try {
            callOutWrapper = integrationFramework.doCallout(getTokenIntegrationSettings.PMC_DH_CalloutMethod__c, headersMap);
            if(callOutWrapper.response.getStatusCode() == 200) {

                token = (String)JSON.deserializeUntyped(callOutWrapper.response.getBody());
            }
            else {
                token = '';
            }

            PMC_DH_LoggingUtils.createDHTransactionLogs(
                callOutWrapper.request,
                callOutWrapper.response,
                getTokenIntegrationSettings.PMC_DH_EndpointURL__c
            );
            
        }
        catch(PMC_DH_Validation.CustomException ex){
            throw new PMC_DH_Validation.CustomException('Callout Failed');
        }
        catch (Exception ex) {
            throw  new AuraHandledException(ex.getMessage());
        }


        return token;
    }

    /**
    * @description performs a callout to intellitrans api to retrieve shipment data
    * @author Bruno Orlandin | 07-17-2024 
    * @param token 
    **/
    @future(callout=true)
    public static void getShipmentDataCallout(String token){
        PMC_DH_IntegrationCalloutFramework.PMC_DH_CallOutWrapper callOutWrapper;
        Map<String,Object> mapResponse;
        PMC_DH_IntegrationSettings__mdt getTokenIntegrationSettings = PMC_DH_IntelliTransCalloutHelper.getIntegrationSettings(GETSHIPPMENTNAME);
        Map<String,String> headersMap = new Map<String,String>();
        PMC_DH_IntegrationCalloutFramework integrationFramework = new PMC_DH_IntegrationCalloutFramework();

        List<PMC_DH_IntelliTransCalloutHelper.ShipmentData> shipmentDataList;

        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('equipmentNumbers', '');
        bodyMap.put('shipDateFrom', '');
        bodyMap.put('shipDateTo', '');
        bodyMap.put('searchTemplateName', 'Salesforce API');
        bodyMap.put('resultTemplateName', 'Salesforce API');
        bodyMap.put('loginId', 'Salesforce_API');
        bodyMap.put('shipmentType', 'Current');
        String body = JSON.serialize(bodyMap);
        
        headersMap.put('ENDPOINT', getTokenIntegrationSettings.PMC_DH_EndpointURL__c );
        headersMap.put('TIMEOUTVALUE', '90000');
        headersMap.put('SET_BODY',body);
        headersMap.put('TokenID', token);
        headersMap.put('Connection', 'keep-alive');
        headersMap.put('Content-Type', getTokenIntegrationSettings.PMC_DH_ContentType__c);

        try {
            callOutWrapper = integrationFramework.doCallout(getTokenIntegrationSettings.PMC_DH_CalloutMethod__c, headersMap);
            if(callOutWrapper.response.getStatusCode() == 200) {

                shipmentDataList = (List<PMC_DH_IntelliTransCalloutHelper.ShipmentData>) JSON.deserialize(
                    callOutWrapper.response.getBody(),
                    List<PMC_DH_IntelliTransCalloutHelper.ShipmentData>.class
                );

                // Implement logic to handle shipment data manipulation here

            }
            else {
                System.debug('Error');
                System.debug('callOutWrapper.response => ' + callOutWrapper.response);
                System.debug('callOutWrapper.response.getBody() ' + callOutWrapper.response.getBody());
            }
            PMC_DH_LoggingUtils.createDHTransactionLogs(
                callOutWrapper.request,
                callOutWrapper.response,
                getTokenIntegrationSettings.PMC_DH_EndpointURL__c
            );
            
        }
        catch(PMC_DH_Validation.CustomException ex){
            throw new PMC_DH_Validation.CustomException('Callout Failed');
        }
        catch (Exception ex) {
            throw  new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
    * @description method to execute the callout
    * @author Bruno Orlandin | 07-17-2024 
    **/
    public void executeShipmentDataCallout(){
        String token = getTokenIdCallout();
        
        if(String.isNotBlank(token)){
            getShipmentDataCallout(token);
        }
    }

    public class IntegrationException extends Exception {}
    
}