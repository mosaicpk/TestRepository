/**
* @description       : 
* @author            : @digital.hub
* @group             : 
* @last modified on  : 03-01-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PMC_DH_POC {
    
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__Quote__c> getQuoteData() {
        
        List<SBQQ__Quote__c> quotes = [Select Id,Name,CurrencyIsoCode,PMC_CPQ_ExpirationDate__c,( SELECT id,title,body,Createdby.name FROM Notes )  from SBQQ__Quote__c where Name='Q-00505'];
        return quotes;
    }
    
    @AuraEnabled
    public static SBQQ__Quote__c updateQuote(PMC_DH_QuoteUpdateWrapper quoteUpdateWrap) {
        try {
            SBQQ__Quote__c quote=new SBQQ__Quote__c();
            quote.id=quoteUpdateWrap.strQuoteId;
            quote.currencyIsoCode=quoteUpdateWrap.strCurrencyIsoCode;
            quote.SBQQ__StartDate__c=quoteUpdateWrap.datContractStartDate;
            quote.SBQQ__EndDate__c=quoteUpdateWrap.datContractEndDate;
            quote.SBQQ__PaymentTerms__c=quoteUpdateWrap.strPaymentTerms;
            quote.PMC_DH_PaymentMethod__c=quoteUpdateWrap.strPaymentMethods;
            update quote;
            return quote;
            
        } catch (Exception ex) {
            throw new AuraHandledException('Exception Occurred'+ex.getMessage());
        }
        // List<SBQQ__Quote__c> quotes = [Select Id,Name,CurrencyIsoCode,PMC_CPQ_ExpirationDate__c,( SELECT id,title,body,Createdby.name FROM Notes )  from SBQQ__Quote__c where Name='Q-00505'];
        
        
    }
    
    
    /**
* @description       : Wrapper class for VerifyAccessForUserCreation method
* @author            : @rravindraundale 
* 
**/
    public class PMC_DH_QuoteUpdateWrapper{
        /**
* @description First Name of User
* @return FirstName value
*/
        public String strQuoteId{get;set;}
        /**
* @description First Name of User
* @return FirstName value
*/
        public String strQuoteFriendlyName{get;set;}
        
        /**
* @description Contract Start Date of Cart
* @author @Krishan 
* 
**/
        @AuraEnabled
        public Date datContractStartDate {get;set;}
        
        /**
* @description Contract End Date of Cart
* @author @Krishan 
* 
**/
        @AuraEnabled
        public Date datContractEndDate{get;set;}
        
        /**
* @description List for value label picklist
* @return 		String
**/
        @AuraEnabled
        public String strCurrencyIsoCode{get;set;}
        
        /**
* @description List for value label picklist
* @return 		String
**/
        @AuraEnabled
        public String strPaymentTerms{get;set;}
        
        /**
* @description List for value label picklist
* @return 		String
**/
        @AuraEnabled
        public String strPaymentMethods{get;set;}
    }
    
    @AuraEnabled
    public static void updateOrderItem(){
        OrderItem[] orderItem =[select id,UnitPrice,Product2Id,Product2.IsActive,Product2.PMC_DH_Nitrogen__c from OrderItem where Id ='802DT0000018smEYAQ'];
        if(!orderItem.isEmpty()){
            orderItem[0].UnitPrice=899;
            orderItem[0].Product2.IsActive=true;
            orderItem[0].Product2.PMC_DH_Nitrogen__c='0-5%';
        }
        
        update orderItem[0];
    }
    
    /** 
* @description method for validation of country
* @since 07-27-2023
* @uthor hemant giri goswami
* @param strcountryRegion 
* @return                 `boolean`
*/ 
    public static boolean getCountryValidation(string strcountryRegion)
    {   
        boolean boolFlag=false;
        
        try{
            PMC_DH_Store_Configuration__mdt mdtCountryValidation= PMC_DH_Store_Configuration__mdt.getInstance('PMC_DH_PriceSummaryCountry');
            String strCountries=mdtCountryValidation.PMC_DH_Country__c;	
            List<String> lstCountries=strCountries.split(',');
            if(lstCountries.contains(strcountryRegion) && mdtCountryValidation.PMC_DH_isActive__c==true )
            {
                boolFlag=true;
            }
        }
        catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }
        return boolFlag;
    }
    /** 
* @description method for price summary
* @since 07-27-2023
* @uthor hemant giri goswami
* @param strQuoteId 
* @param strCountry 
* @return                 `PMC_DH_PricingDetailWrapper`
*/ 
    
    public static PMC_DH_PricingDetailWrapper getPriceSummary(String strQuoteId,String strCountry)
    {
        
        PMC_DH_PricingDetailWrapper priceSummaryWrapper=new PMC_DH_PricingDetailWrapper();
        list<PMC_DH_PricingDetailWrapper.PMC_DH_PricingSummaryWrapper> lstChild=new list<PMC_DH_PricingDetailWrapper.PMC_DH_PricingSummaryWrapper>();
        PMC_DH_PricingDetailWrapper.PMC_DH_PricingSummaryWrapper wrpChild;
        try{
            List<SBQQ__QuoteLine__c> lstQouteLine=[SELECT SBQQ__Quote__r.PMC_CPQ_SumOfLineTotalPrice__c,
                                                   SBQQ__Quote__r.PMC_CPQ_Currency__c,SBQQ__Product__r.name,
                                                   SBQQ__Product__r.StockKeepingUnit, PMC_CPQ_UnitofMeasure__c, 
                                                   SBQQ__Quantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:strQuoteId
                                                   WITH SECURITY_ENFORCED];
            priceSummaryWrapper.strCurrencyIsoCode=String.Valueof(lstQouteLine[0].SBQQ__Quote__r.PMC_CPQ_Currency__c);
            priceSummaryWrapper.decTotalPrice=lstQouteLine[0].SBQQ__Quote__r.PMC_CPQ_SumOfLineTotalPrice__c;
            if(getCountryValidation(strCountry)==true)
            {
                for(SBQQ__QuoteLine__c inst:lstQouteLine)
                {	wrpChild=new PMC_DH_PricingDetailWrapper.PMC_DH_PricingSummaryWrapper();
                 wrpChild.strProductName=inst.SBQQ__Product__r.name;
                 wrpChild.strProductSKU=inst.SBQQ__Product__r.StockKeepingUnit;
                 wrpChild.strUOM=inst.PMC_CPQ_UnitofMeasure__c;
                 wrpChild.intQuantity=Integer.valueof(inst.SBQQ__Quantity__c);
                 wrpChild.decPrice=00.00;
                 lstChild.add(wrpChild);  
                }
            }
            priceSummaryWrapper.lstPriceSummary=lstChild;
            
        }
        catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }
        return priceSummaryWrapper;
    }
    
    @AuraEnabled
    public static List<pocWrapper> getconsent()
    {
        List<ContactPointTypeConsent > lstC=[select ContactPointType,DataUsePurpose.Name,DataUsePurpose.LegalBasis.name,PrivacyConsentStatus,CaptureContactPointType,PartyId, party.name from ContactPointTypeConsent where CaptureSource ='digital hub'];
        List<pocWrapper> lstreturn=new List<pocWrapper>();
        for(ContactPointTypeConsent c:lstC)
        {  pocWrapper consentObj=new pocWrapper();
         consentObj.strCommuType=c.ContactPointType;
         consentObj.strName=c.DataUsePurpose.Name;
         consentObj.strParent=c.DataUsePurpose.LegalBasis.name;
         consentObj.strConsent=c.PrivacyConsentStatus;
         lstreturn.add(consentObj);
        }
        json.serialize(lstreturn);
        return lstreturn;
    }
    @AuraEnabled
    public static void createNotesAndAttachment() {
        
        
        ContentNote cn = new ContentNote();
        cn.Title = 'test2';
        String body = '<b>Hello World. Because this text is already formatted as HTML, it does not need to be escaped.' 
            +'Special characters such as &quot;, etc. must already use their HTML equivalents.</b>';
        Blob myBlob = Blob.valueof(body);            
        cn.Content = myBlob;
        //cn.ParentId='0QLDT000000K8rO4AS';
        insert(cn);
        
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(body);
        attachment.Name = String.valueOf('test.txt');
        attachment.ParentId ='a38DT000000ddz7YAA'; 
        insert attachment;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cn.id; 
        cdl.LinkedEntityId = 'a38DT000000ddz7YAA';
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert(cdl);
        
        
        Note note = new Note();
        note.Title = 'Notes';
        note.Body = 'Hello world';
        note.ParentId ='a38DT000000ddz7YAA'; 
        insert note;
        
    }
    
    
    public class pocWrapper{
        @auraEnabled
        public  String strCommuType;
        @auraEnabled
        public String strName;
        @auraEnabled
        public String strParent;
        @auraEnabled
        public String strConsent;
    }
    
    @AuraEnabled
    public static String getSeedzResponse(){
        String result;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.hml.seedz.ag/api/v1/integrations/partner-fidelity/auth');
        request.setMethod('POST');
        request.setHeader('content-type','application/json');
        request.setBody('{"email":"integracaomosaic@seedz.ag","password":"seedzintegracaomosaic"}');
        try{
            HttpResponse response = http.send(request);
            result=json.serialize(response.getBody());
            PMC_DH_LoggingUtils.createDHTransactionLogs(request, response, 'https://api.hml.seedz.ag/api/v1/integrations/partner-fidelity/auth');
            system.debug('Response >>>>>>>' +  response.getBody());
            system.debug('Response headers>>> ' + response.getHeaderKeys());
        }
        catch(exception ex){
            system.debug('Exception >>>>>>>' +  ex.getMessage());
        }
        return result;
    }
    
    
    @AuraEnabled
    public static String getSeedzBalResponse(){
        String result;
        String strToken;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.hml.seedz.ag/api/v1/integrations/customer-balance/09698122648');
        request.setMethod('GET');
        request.setHeader('Authorization','Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHBpcmVzSW4iOiIzNTZkIiwiYWxnb3JpdGhtIjoiSFMyNTYiLCJfaWQiOiI2NDQ3Y2Y0MTc1M2VlMzAwNDRiZWJlZTgiLCJjb3VudHJ5IjoiYnIiLCJwYXJ0bmVyIjoiNjI5ZmFlM2IwMzQzMTYwMDQxYjE4OGZlIiwiaXNJbnRlZ3JhdGlvbiI6dHJ1ZSwiaWF0IjoxNjk0Nzk0ODA2fQ.4jRcNCXRxGDUBXzyuWGRXD6XW3HwFjvk6SngQ34YKw0');
        try{
            HttpResponse response = http.send(request);
            result=json.serialize(response.getBody());
            system.debug('Response >>>>>>>' +  response.getBody());
            system.debug('Response headers>>> ' + response.getHeaderKeys());
            PMC_DH_LoggingUtils.createDHTransactionLogs(request, response, 'https://api.hml.seedz.ag/api/v1/integrations/customer-balance/19537471000161');
        }
        catch(exception ex){
            system.debug('Exception >>>>>>>' +  ex.getMessage());
        }
        return result;
    }
    
    /**
* @description 
* @author humera.rahath@mosaicco.com | Digital Hub | 10-07-2023 
* @param strDocCode 
* @return HttpResponse 
**/
    
    public static HttpResponse getDocument(String strDocCode) {
        String STRING_NAMEDCREDENTIALS = 'callout:PMC_CPQ_NamedCredential';
        String STRING_METHOD = 'POST';
        List<PMC_CPQ_TransactionLog__c> lstTransactionLogs;
        String strInterface = 'SAPDocuments';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        String strSchedulingEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
        
        String strCalloutEndpoint = STRING_NAMEDCREDENTIALS+strSchedulingEndpoint;
        
        
        
        PMC_DH_DocumentWrapper.PMC_DH_ReqWrapper objData=new PMC_DH_DocumentWrapper.PMC_DH_ReqWrapper();
        if(strDocCode=='COA' || strDocCode=='BOL'){
            objData.strDocumentCode=strDocCode;
            objData.strDeliveryNumber='85002368';//'0085001395';
            objData.strItemNumber='000001';
        }
        else{
            objData.strDocumentCode=strDocCode;
            objData.strBillingDocNumber='9000000184'; 
            
        }
        PMC_DH_DocumentWrapper data=new PMC_DH_DocumentWrapper();
        data.objData=objData;
        
        HttpResponse response = PMC_CPQ_CPIRemoteCalloutUtilityClass.sendCalloutRequest(STRING_METHOD, strCalloutEndpoint, Json.serialize(data,true));
        //System.debug('Data'+response.getBody())/
        Map<String, String> mapTransactionLogFields = new Map<String,String>();
        mapTransactionLogFields.put('PMC_CPQ_IntegrationStatus__c',String.valueOf(response.getStatusCode()));
        mapTransactionLogFields.put('PMC_CPQ_InterfaceURL__c',strSchedulingEndpoint);
        mapTransactionLogFields.put('PMC_CPQ_RequestBody__c',PMC_CPQ_CPIRemoteCalloutUtilityClass.request.getBody());
        mapTransactionLogFields.put('PMC_CPQ_ResponseBody__c',String.valueOf(response.getBody()));
        lstTransactionLogs = PMC_CPQ_TransactionLogUtilityClass.addTransactionLog(mapTransactionLogFields);
        PMC_CPQ_TransactionLogUtilityClass.insertTransactionLogs(lstTransactionLogs);
       
        return response;
    }

   /**
   * @description 
   * @author Mosaic Direct | Dev Team | 11-01-2023 
   * @return Map<String, Object> 
   **/
   @AuraEnabled(cacheable=true)
   public static Map<String, Object> getRebatesInfoForCustomer(){
    try {

        Map<String, Object> rebatesToCustomerInfo = new Map<String, Object>();
        List<SalesAgreement> lstSalesAgreement=[select id,Name from SalesAgreement  WITH USER_MODE limit 100];
        List<SalesAgreementProduct> lstSalesAgreementProduct=[select id,Name from SalesAgreementProduct   WITH USER_MODE limit 100];
        List<SalesAgreementProductSchedule> lstSalesAgreementProductSchedule=[select id,Name,ActualQuantity from SalesAgreementProductSchedule    WITH USER_MODE limit 100];
        List<RebateProgram> lstRebateProgram=[select id,Name from RebateProgram     WITH USER_MODE limit 100];
        List<ProgramRebateTypeBenefit> lstProgramRebateTypeBenefit=[select id,Name,MaximumQualifyingValue,BenefitValue,PMC_SS_Projected_Incentive__c from ProgramRebateTypeBenefit   WITH USER_MODE limit 100];
        List<ProgramRebateType> lstProgramRebateType=[select id,Name from ProgramRebateType   WITH USER_MODE limit 100];
        rebatesToCustomerInfo.put('SalesAgreement',lstSalesAgreement);
        rebatesToCustomerInfo.put('SalesAgreementProduct',lstSalesAgreementProduct);
        rebatesToCustomerInfo.put('SalesAgreementProductSchedule',lstSalesAgreementProductSchedule);
        rebatesToCustomerInfo.put('RebateProgram',lstRebateProgram);
        rebatesToCustomerInfo.put('ProgramRebateTypeBenefit',lstProgramRebateTypeBenefit);
        rebatesToCustomerInfo.put('ProgramRebateType',lstProgramRebateType);
        return rebatesToCustomerInfo;

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
   }
    
   @AuraEnabled(cacheable=true)
   public static List<ConnectApi.NavigationMenuItem> getNavMenu(String strcommunityId){
       ConnectApi.PublishStatus publishStatus =ConnectApi.PublishStatus.LIVE;
        List<ConnectApi.NavigationMenuItemType> menuItemTypesToSkip= new List<ConnectApi.NavigationMenuItemType>{ConnectApi.NavigationMenuItemType.NavigationalTopic};
       ConnectApi.NavigationMenuItemCollection navDetails=ConnectApi.NavigationMenu.getCommunityNavigationMenu(strcommunityId,null,'DH_Header_Menus1',publishStatus,false, false,null);
       List<ConnectApi.NavigationMenuItem> navMenu =navDetails.menuItems;
       system.debug('@@@1'+navDetails);
       system.debug('@@@2'+navMenu);
       
       return navMenu;
   }
    
    public static void getAsset(){
        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('Test Body');
        cv.Title = 'sample filename';
        cv.PathOnClient = 'https://nutricaodesafras.com.br/wp-content/uploads/2024/01/Apresentacao-Tecnica-K-mag.pdf';
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentWorkspace ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name = 'Asset library' LIMIT 1];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        cdl.LinkedEntityId = ws.Id; //important to map
        insert cdl;
    }
}  

/*

response=
{
[
{
String strCommuType='email';
String strName='invoice';
String strParent='order management';
String strConsent='opt -in';
},
{
String strCommuType='email';
String strName='delivery';
String strParent='order management';
String strConsent='opt -out'; 
},
{

}






}

*/