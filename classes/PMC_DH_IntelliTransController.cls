/**
 * @description       : 
 * @author            : Bruno Orlandin
 * @group             : 
 * @last modified on  : 07-17-2024
 * @last modified by  : Bruno Orlandin
**/
public with sharing class PMC_DH_IntelliTransController {

    private static final String GETTOKENNAME = 'IntelliTransGetToken';
    private static final String GETSHIPPMENTNAME = 'IntelliTransGetShipmentData';

    /**
    * @description method to retrieve Intellitrans token
    * @author Bruno Orlandin | 07-17-2024 
    * @return ResponseUtils.Response(Token parsed in JSON) 
    **/
    @AuraEnabled
    public static ResponseUtils.Response getTokenId(){
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


        ResponseUtils.Response response = new ResponseUtils.Response(
            false,
            '',
            JSON.serialize(token)
        );

        return response;
    }

    /**
    * @description method to retrieve Intellitrans shipment data
    * @author Bruno Orlandin | 07-17-2024 
    * @param token 
    * @return ResponseUtils.Response(ShipmentData list parsed in JSON)
    **/
    @AuraEnabled
    public static ResponseUtils.Response getShipmentDataCallout(String token){
        PMC_DH_IntegrationCalloutFramework.PMC_DH_CallOutWrapper callOutWrapper;
        Map<String,Object> mapResponse;
        PMC_DH_IntegrationSettings__mdt getTokenIntegrationSettings = PMC_DH_IntelliTransCalloutHelper.getIntegrationSettings(GETSHIPPMENTNAME);
        Map<String,String> headersMap = new Map<String,String>();
        PMC_DH_IntegrationCalloutFramework integrationFramework = new PMC_DH_IntegrationCalloutFramework();
        ResponseUtils.Response response;

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

                response = new ResponseUtils.Response(
                    false,
                    '',
                    JSON.serialize(shipmentDataList)
                );

            }
            else {
                response = new ResponseUtils.Response(
                    true,
                    'Could not fetch token',
                    ''
                );
            }
            PMC_DH_LoggingUtils.createDHTransactionLogs(
                callOutWrapper.request,
                callOutWrapper.response,
                getTokenIntegrationSettings.PMC_DH_EndpointURL__c
            );
        }
        catch(PMC_DH_Validation.CustomException error){
            response = new ResponseUtils.Response(error);
        }
        catch (Exception error) {
            response = new ResponseUtils.Response(error);
        }

        return response;
    }
}