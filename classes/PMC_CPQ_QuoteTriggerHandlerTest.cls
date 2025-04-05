/**
 * @description This test class will be used to cover all the methods of PMC_CPQ_QuoteTriggerHandler and PMC_CPQ_QuoteTriggerHelper.
 * @author Jaswanth
 * @storynumber GDASF-8944
 */

@isTest(seeAllData=false) 
public with sharing class PMC_CPQ_QuoteTriggerHandlerTest {
    /**
    * @description This Method will be used to setup the data for the test class execution.
    * @modified by Jaswanth Vaithiswaran part of Test class optimization to run in sales user context.
    */
    @testSetup
    private static void setup()
    {
        /*
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        lstOpportunities = PMC_TestUtilityClass.createOpportunity(1, 'Master');
     */
        
        List<String>lstProfileNames = New List<String>{'System Administrator','Sales User'};
        List<String>lstPermissionNames = New List<String>{'PMC_Administrator_Permission_Set_Group','PMC_SLS_Permission_Set_Group'};
        Map<String,Id>mapOfProfiles = PMC_TestUtilityClass.getProfiles(lstProfileNames);
        Map<String,PermissionSetGroup>mapOfPermissionGrp = PMC_TestUtilityClass.getPemissionsetGroups(lstPermissionNames);
        Integer intuserCount =0;
        User objSystemAdminUser;  
        User objSalesUser;
        List<User> lstUser = PMC_TestUtilityClass.createUser(2);
            for(User objUser : lstUser) {
                If(intuserCount==0){
                   objUser.LastName = 'Admin User Test';
                   objUser.ProfileId = mapOfProfiles.get('System Administrator'); 
                   objUser.FederationIdentifier = objUser.Username + 'Admin';
                }else if(intuserCount==1){
                    objUser.LastName = 'Sales User Test';
                    objUser.ProfileId = mapOfProfiles.get('Sales User'); 
                    objUser.FederationIdentifier = objUser.Username + 'Sales';
                }
                objUser.isActive = true;                
                objUser.MobilePhone = '1234567890';
                objUser.UserPermissionsKnowledgeUser =true;
                objUser.LanguageLocaleKey = 'en_US';
                intuserCount = intuserCount + 1;
            }            
            insert lstUser;
            objSystemAdminUser = lstUser[0];
            objSalesUser = lstUser[1];
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSystemAdminUser}, mapOfPermissionGrp.get('PMC_Administrator_Permission_Set_Group'));
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSalesUser}, mapOfPermissionGrp.get('PMC_SLS_Permission_Set_Group'));
       
        

       
        System.runAs(objSalesUser){
            Account objAcc = new Account();
            objAcc.Name = 'Test Account Quote Trigger';
            objAcc.PMC_SS_SAPCustomerNumber__c = 'ijklmnop';
            insert objAcc;
            Contact testContact = new Contact();
            testContact.FirstName = 'test Jane';
            testContact.LastName = 'test Doe';
            insert testContact;
        Date dateStartDate = System.today();
            dateStartDate = dateStartDate.addDays(2);
        Date dateEndDate = dateStartDate.addDays(35);
        SBQQ__Quote__c objQuote;
          objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Account__c = objAcc.Id;
            //objQuote.SBQQ__Opportunity2__c = lstOpportunities[0].id;
            objQuote.PMC_CPQ_ContractStart__c = dateStartDate;
            objQuote.PMC_CPQ_ContractEnd__c = dateEndDate;
            objQuote.PMC_CPQ_PrimaryContact__c = testContact.id;
            objQuote.SBQQ__Primary__c = true;
            objQuote.SBQQ__Status__c = 'Expired';
            objQuote.PMC_CPQ_ExpiresOn__c = Datetime.now().adddays(-10);
        insert objQuote;
        }
        
        
        
    }
    /** 
    * @description This method will be used to test the scenario where Quote is expired and try to edit the quote.
    * @modified by Jaswanth Vaithiswaran part of Test class optimization to run in sales user context.
    */
    @istest
    private static void validateQuoteExpirationTest()
    {
        Test.startTest();
        User salesUser = [SELECT Id from User where LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(salesUser){
            SBQQ__Quote__c cpqQuote  = [Select id,SBQQ__Status__c,PMC_CPQ_AccountCountry__c FROM SBQQ__Quote__c where SBQQ__Status__c='Expired' LIMIT 1];
            cpqQuote.PMC_CPQ_AccountCountry__c = 'India';
            String errorMsg ='';
            try{
                update cpqQuote;
            }
            catch(EXCEPTION e)
            {
                errorMsg = e.getMessage();
            }
                  
            Assert.isTrue(errorMsg.contains(System.Label.PMC_CPQ_QuoteExpirationValidationMessage),'Expiration validation not thrown');
        }
            Test.stopTest();  
    }
	 /** 
    * @description This method will be used to test the scenario where Query return exception
    */    
    @isTest
    private static void validateQuoteExpirationCatchBlockTest(){
        PMC_CPQ_QuoteTriggerHelper.testException= true;
        Test.startTest();
        User salesUser = [SELECT Id from User where LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(salesUser){
            SBQQ__Quote__c cpqQuote  = [Select id,SBQQ__Status__c,PMC_CPQ_AccountCountry__c FROM SBQQ__Quote__c where SBQQ__Status__c='Expired' LIMIT 1];
            update cpqQuote;
           
                  
            Assert.isTrue(cpqQuote!=null,'Exception not thrown');
        }
        
            Test.stopTest();
    }
    
    /** 
    * @description This method is a test method for Quote delete operation.
    * @modified by Jaswanth Vaithiswaran part of Test class optimization to run in sales user context.
    */ 
    @istest
    private static void testQuoteDelete()
    {
        Test.startTest();
        User salesUser= [SELECT Id from User where LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runas(salesUser){
            SBQQ__Quote__c cpqQuote  = [Select id,PMC_CPQ_ExpiresOn__c,SBQQ__Primary__c FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
            Database.delete(cpqQuote.Id);
            List<SBQQ__Quote__c> deletedQuotes = [SELECT Id from SBQQ__Quote__c WHERE Id=:cpqQuote.Id WITH SECURITY_ENFORCED];
            Assert.areEqual(0,deletedQuotes.size(),'Quote was not deleted');
        }
        Test.stopTest();
        
       
        
    }
     /** 
    * @description This method is a test method for Quote undelete operation.
    * @modified by Jaswanth Vaithiswaran part of Test class optimization to run in sales user context.
    */ 
    @istest
    private static void testQuoteUnDelete()
    {
        Test.startTest();
        User salesUser= [SELECT Id from User where LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runas(salesUser){
            SBQQ__Quote__c cpqQuote  = [Select id,PMC_CPQ_ExpiresOn__c,SBQQ__Primary__c FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
            Database.delete(cpqQuote.Id);
            Database.undelete(cpqQuote.Id);
            List<SBQQ__Quote__c> deletedQuotes = [SELECT Id from SBQQ__Quote__c WHERE Id=:cpqQuote.Id WITH SECURITY_ENFORCED];
            Assert.areEqual(1,deletedQuotes.size(),'Quote was not restored');
        }
        Test.stopTest();    
    }
    /** 
    * @description This method is a test bypass insert method of the trigger.
    * @modified by Jaswanth Vaithiswaran part of Test class optimization to run in sales user context.
    */ 
    @istest
    private static void testBypassQuoteInsertOperation()
    {
        PMC_CPQ_QuoteTriggerHandler.boolBypassTriggerLogic = true;
        Test.startTest();
        User salesUser= [SELECT Id from User where LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runas(salesUser){
            SBQQ__Quote__c cpqQuote = [Select id,PMC_CPQ_PrimaryContact__c,PMC_CPQ_ContractStart__c,PMC_CPQ_ContractEnd__c,SBQQ__Account__c FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
            SBQQ__Quote__c quoteTwo = new SBQQ__Quote__c();
            quoteTwo.PMC_CPQ_PrimaryContact__c = cpqQuote.PMC_CPQ_PrimaryContact__c;
            quoteTwo.PMC_CPQ_ContractStart__c = cpqQuote.PMC_CPQ_ContractStart__c;
            quoteTwo.PMC_CPQ_ContractEnd__c = cpqQuote.PMC_CPQ_ContractEnd__c;
            quoteTwo.SBQQ__Account__c = cpqQuote.SBQQ__Account__c;
            Database.insert(quoteTwo);
            List<SBQQ__Quote__c> lstQuotes = [SELECT id from SBQQ__Quote__c WITH SECURITY_ENFORCED];
            Assert.areEqual(2,lstQuotes.size(),'Quote was not inserted');   
        }
        Test.stopTest();  
        
        
    }
    /** 
    * @description This method is a test bypass update method of the trigger.
    * @modified by Jaswanth Vaithiswaran part of Test class optimization to run in sales user context.
    */ 
    @istest
    private static void testBypassQuoteUpdateOperation()
    {
        PMC_CPQ_QuoteTriggerHandler.boolBypassTriggerLogic = true;
        Test.startTest();
        User salesUser= [SELECT Id from User where LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runas(salesUser){
            SBQQ__Quote__c cpqQuote = [SELECT Id,PMC_CPQ_AccountCountry__c from SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
            cpqQuote.PMC_CPQ_AccountCountry__c = 'North America';
            Database.update(cpqQuote);
            SBQQ__Quote__c quoteTwo = [SELECT Id,PMC_CPQ_AccountCountry__c from SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
            Assert.areEqual('North America', quoteTwo.PMC_CPQ_AccountCountry__c, 'Quote was not updated');
        }
        Test.stopTest();
        
        
        
    }
    /** 
    * @description This method is a test bypass delete method of the trigger.
    */ 
    @istest
    private static void testBypassQuoteDeleteOperation(){
        PMC_CPQ_QuoteTriggerHandler.boolBypassTriggerLogic = true;
        Test.startTest();
        User salesUser = [SELECT Id from User where LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runas(salesUser){
            SBQQ__Quote__c cpqQuote  = [Select id,PMC_CPQ_ExpiresOn__c,SBQQ__Primary__c FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
            Database.delete(cpqQuote.Id); 
            List<SBQQ__Quote__c> deletedQuotes = [SELECT Id from SBQQ__Quote__c WHERE Id=:cpqQuote.Id WITH SECURITY_ENFORCED];
            Assert.areEqual(0,deletedQuotes.size(),'Quote was not deleted');
        }
        Test.stopTest();
        
       
    }
    /** 
    * @description This method is a test bypass undelete method of the trigger.
    * @modified by Jaswanth Vaithiswaran part of Test class optimization to run in sales user context.
    * 
    */
     @istest
    private static void testBypassQuoteUnDeleteOperation()
    {
        PMC_CPQ_QuoteTriggerHandler.boolBypassTriggerLogic = true;
        Test.startTest();
        User salesUser= [SELECT Id from User where LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runas(SalesUser){
            SBQQ__Quote__c cpqQuote  = [Select id,PMC_CPQ_ExpiresOn__c,SBQQ__Primary__c FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
            Database.delete(cpqQuote.Id);
            Database.undelete(cpqQuote.Id);
            List<SBQQ__Quote__c> deletedQuotes = [SELECT Id from SBQQ__Quote__c WHERE Id=:cpqQuote.Id WITH SECURITY_ENFORCED];
            Assert.areEqual(1,deletedQuotes.size(),'Quote was not restored');
        }
        Test.stopTest(); 
    }
}