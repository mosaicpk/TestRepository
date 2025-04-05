/**
 * @description       : 
 * @author            : Bruno Orlandin
 * @group             : 
 * @last modified on  : 07-17-2024
 * @last modified by  : Bruno Orlandin
**/
public with sharing class PMC_DH_IntelliTransCalloutHelper {

    /**
    * @description retrieves metadata info
    * @author Bruno Orlandin | 07-17-2024 
    * @param developerName 
    * @return PMC_DH_IntegrationSettings__mdt 
    **/
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
        @AuraEnabled public Double LATESTTRIPSIGHTINGID { get; set; }
        @AuraEnabled public String LATESTINTERNALCOMMENT { get; set; }
        @AuraEnabled public String SIGHTINGDESTINATION { get; set; }
        @AuraEnabled public Double LATITUDE { get; set; }
        @AuraEnabled public Double LONGITUDE { get; set; }
    }
}