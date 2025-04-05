/**
 * @description       : 
 * @author            : Mosaic Direct | Dev Team
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public  class PMC_DH_ObjectWrapper {

    public PMC_DH_ReqWrapper objData {get;set;}
    public class PMC_DH_ReqWrapper{
        @AuraEnabled
        public String strDocumentCode{get;set;}
        @AuraEnabled
        public String strDeliveryNumber{get;set;}
        @AuraEnabled
        public String strItemNumber{get;set;}
        @AuraEnabled
        public string strBillingDocNumber{get;set;}
        @AuraEnabled
        public string strSalesOrderNumber{get;set;}

    }
    
    public  PMC_DH_ResWrapper objResData {get;set;}
public class PMC_DH_ResWrapper{
    @AuraEnabled
    public String strStatusCode{get;set;}
    @AuraEnabled
    public String strData{get;set;}
    @AuraEnabled
    public String strMessage{get;set;}
}

    

}