public class PMC_CPQ_AttachFileToTransactionLogsClass {
    
    @InvocableMethod(label='File attachment to Transaction Logs')
    public static void createContentVersion(List<Id> logId){
        List<PMC_CPQ_TransactionLog__c> tLogs = [select id,Name,CreatedDate,PMC_CPQ_IntegrationStatus__c, PMC_CPQ_InterfaceURL__c,PMC_CPQ_RequestBody__c, PMC_CPQ_ResponseBody__c from PMC_CPQ_TransactionLog__c where id IN: logId LIMIT 1];
        String yourFilesContent = tLogs[0].PMC_CPQ_RequestBody__c;
        String yourFilesContent1 = '"sf__Id","sf__Error",PMC_CPQ_SAPOrderLineID__c,Order.PMC_CPQ_SAPOrderNumber__c,PMC_CPQ_RequestedShipDate__c,PMC_CPQ_ModeofTransportation__c,PMC_CPQ_PaymentTerms__c,PMC_CPQ_PaymentDueDate__c,PMC_CPQ_Incoterms__c,PMC_CPQ_Destination__c,Product2.PMC_CPQ_SAPProductCode__c,Quantity,PMC_CPQ_UnitOfMeasure__c,PMC_CPQ_ShipTo__r.PMC_SS_AccountExternalID__c,PMC_CPQ_PricingDate__c,PMC_CPQ_ShippingType__c,PMC_CPQ_ExSpaceIndicator__c,PMC_CPQ_ServiceRenderedDate__c,UnitPrice,PMC_CPQ_FinalPrice__c,PMC_CPQ_EstFreightPrice__c,PMC_CPQ_Discounts__c,PMC_CPQ_FPDPricefromPriceFx__c,PMC_CPQ_FinalAgreedPrice__c,SBQQ__Subscription__r.PMC_CPQ_SubscriptionNumberIdentifier__c"","FIELD_INTEGRITY_EXCEPTION:Enter a List Price.: List Price:ListPrice --","30000151_10","30000151","2023-05-06","Rail","Cash In Advance","","FOB","","1000022","200.0","STN","","2023-02-06","Box Barge","","","83.0","0.0","","","0.0","0.0","""","FIELD_INTEGRITY_EXCEPTION:Enter a List Price.: List Price:ListPrice --","30000152_10","30000152","2023-05-06","Rail","Cash In Advance","","FOB","","1000022","200.0","STN","","2023-02-06","Box Barge","","","83.0","0.0","","","0.0","0.0",""';
        system.debug('yourFilesContent'+yourFilesContent);
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = tLogs[0].Name+'_'+tLogs[0].CreatedDate+'.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = tLogs[0].Name+'_'+tLogs[0].CreatedDate+' Files'; // Display name of the files
        conVer.VersionData = Blob.valueOf(yourFilesContent1); // converting your binary string to Blob
        insert conVer;    //Insert ContentVersion
        
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = tLogs[0].id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
    }
    
}