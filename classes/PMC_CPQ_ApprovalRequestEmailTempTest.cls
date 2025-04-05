/*
 * This class is the test class for PMC_CPQ_ApprovalRequestEmailTempClass.
 * @author Jeyanthi Muthaiah
 * @storynumber GDASF-3258
 */

@isTest(seeAllData=false)
public with sharing class PMC_CPQ_ApprovalRequestEmailTempTest {
  /*
  * This Method will be used to setup the data for the test class execution.
  */
    @TestSetup
    private static void setup(){
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
            objSalesUser =lstUser[1];
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSystemAdminUser}, mapOfPermissionGrp.get('PMC_Administrator_Permission_Set_Group'));
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSalesUser}, mapOfPermissionGrp.get('PMC_SLS_Permission_Set_Group'));
        System.runas(objSystemAdminUser){
         List <Product2> lstProducts; 
         lstProducts = PMC_TestUtilityClass.CreateProduct(2,'PMC_CPQ_Brazil');
        }
        System.runas(objSalesUser){
        List<Opportunity> lstOpportunities;
        lstOpportunities = PMC_TestUtilityClass.createOpportunity(2,'Master');
        List<Contact> lstContacts;
        lstContacts = PMC_TestUtilityClass.createContact(1,'Master');
    }
        
    }
    
    /* 
* This method will be used to cover qLines and sendApprovalGroupEmail method of the PMC_CPQ_ApprovalGroupEmailSenderClass.
* 
*/ 
 @isTest 
public static void testGetQuoteInfoAndQuoteLines() {
       Test.startTest();
        List<User> lstUser = [SELECT Id FROM User WHERE LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        
        System.runAs(lstUser.get(0)){    
         List<Opportunity> lstOppty = [select Id, AccountId from Opportunity LIMIT 1 ];
         List<Account> lstAccount = [select Id,PMC_SS_CustomerType__c,PMC_SS_SAPCustomerNumber__c from Account where Id =:lstOppty.get(0).AccountId];
         lstAccount.get(0).PMC_SS_SAPCustomerNumber__c='0805';
         update lstAccount;  
         List<Contact> lstCont = [select Id from Contact LIMIT 1];
         lstCont.get(0).AccountId = lstAccount.get(0).Id;
         update lstCont;  
        
            
       
        // create new Quote
        List<SBQQ__Quote__c> testQuotes;
        testQuotes = PMC_TestUtilityClass.createCPQQuotes(1,lstOppty,lstCont);
        // Fetch created quote
        List<SBQQ__Quote__c> testQuote = [SELECT id,PMC_CPQ_AccountCountry__c FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];  
        testQuote[0].PMC_CPQ_AccountCountry__c='United States' ;
        update testQuote;
            
         //create new Quote Lines
        List<Product2> lstProducts = [SELECT id FROM Product2 WITH SECURITY_ENFORCED LIMIT 2];
        SBQQ__QuoteLine__c testQuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.get(0).Id,  SBQQ__Product__c = lstProducts.get(0).Id,PMC_CPQ_Nitrogen__c=9,PMC_CPQ_ContractType__c='Priced',PMC_CPQ_CropType__c='Alfalfa',PMC_CPQ_VCOQuotation__c=true,PMC_CPQ_QuoteRecordType__c='Domestic SA');
        insert testQuoteLine1;
            
       // create new blended products
       PMC_CPQ_RawMaterial__c testRawMaterial = new PMC_CPQ_RawMaterial__c(PMC_CPQ_Quote__c=testQuote.get(0).id, PMC_CPQ_QuoteLine__c=testQuoteLine1.id,PMC_CPQ_Product__c =lstProducts.get(1).Id,PMC_CPQ_SoldCFR__c=3,PMC_CPQ_ListCFR__c=5,PMC_CPQ_Quantity__c=5);
       insert testRawMaterial;
        
       PMC_CPQ_ApprovalRequestEmailTempClass controller = new PMC_CPQ_ApprovalRequestEmailTempClass();
        controller.quoteId = testQuote[0].Id;
        
       
        // Test getQuoteInfo method
        SBQQ__Quote__c quoteInfo = controller.getQuoteInfo();        
        
        //List<SBQQ__QuoteLine__c> quoteLines = qLines;
        List<SBQQ__QuoteLine__c> qLines = controller.qLines;
        //controller.calculateRawMaterialSums(blendedProducts);
        //controller.calculateRawMaterialAvg(blendedProducts);
        //System.assertEquals(1, quoteInfo.size(),'Quote count is not matching.');
        System.assertEquals(testQuote[0].PMC_CPQ_AccountCountry__c, quoteInfo.PMC_CPQ_AccountCountry__c,'Account doesnot match.');
        System.assertEquals(1, qLines.size(),'Quote Line count is not matching.');
       
 
    }
    Test.stopTest();
    }
}