/**
* @description This test class will be used to cover all the methods of PMC_SS_DeleteDuplicatePartnersBatch.
* @author Chetna
* @storynumber GDASF-21683
*/

@isTest(seeAllData = false)
private with sharing class PMC_SS_DeleteDuplicatePartnersTest {

    /**
    * @description This Method will be used to setup the data for the test class execution.
    */
    @TestSetup
    public static void testDuplicatePartnerDataSetup() {
        List<PMC_SS_AccountPartnerRelationships__c> lstPartnersToInsert = new List<PMC_SS_AccountPartnerRelationships__c>();
        
         //Create Accounts Test Data
         List<Account> lstAccounts = new List<Account>();
        Account objAccount;
        for(Integer intAccountCount = 0; intAccountCount < 2; intAccountCount++) {
            objAccount = new Account();
            objAccount = PMC_TestUtilityClass.createAccount('Deloitte' + intAccountCount,'PMC_SS_Customer');
            lstAccounts.add(objAccount);
        }
        lstAccounts[1].Type='Ship-to';
        lstAccounts[1].PMC_SS_SAPCustomerNumber__c='1111';
        lstAccounts[0].Type='Sold-to';
        lstAccounts[0].PMC_SS_SAPCustomerNumber__c='112';
        upsert(lstAccounts);
        
        List<User> lstUser = new List<User>();
        PermissionSetGroup perSetGrpAdmin = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'PMC_Administrator_Permission_Set_Group'];
        Profile objUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        if(objUserProfile != null) {
            lstUser = PMC_TestUtilityClass.createUser(1);
            if(lstUser != null && !lstUser.isEmpty()) {
                lstUser[0].ProfileId = objUserProfile.Id;
                lstUser[0].LastName = 'Admin User Test';
                lstUser[0].isActive = true;
            }
            Database.upsert(lstUser) ;
            PMC_TestUtilityClass.assignPermissionSetGroupToUsers(lstUser, perSetGrpAdmin);
        }
        
        
   
        
        User objSystemAdminUser = lstUser[0];
        System.runAs(objSystemAdminUser){
            lstPartnersToInsert = PMC_TestUtilityClass.createPartnerObjectWrapper(50,lstAccounts[0].Id,lstAccounts[1].Id);
            Database.insert(lstPartnersToInsert); 
    	}	
    }

    @isTest
    private static void testDeleteDuplicatePartnersSchedule() {		
        Test.startTest();
        User objAdminUser = [SELECT Id, Name FROM User WHERE Lastname = 'Admin User Test' WITH SECURITY_ENFORCED LIMIT 1];
        if(objAdminUser != NULL) {
            System.runAs(objAdminUser) {
                PMC_SS_DeleteDuplicatePartnersSchedule objScheduler = new PMC_SS_DeleteDuplicatePartnersSchedule();
        		String sch = '0 0 23 * * ?';
        		System.schedule('Delete Duplicate Partners Schedule', sch, objScheduler );
                
                System.assertNotEquals(0,[SELECT count() FROM PMC_SS_AccountPartnerRelationships__c WHERE PMC_SS_RelatedAccountSalesArea__c = null], 'Duplicate partner records exists');
            }
        }
        Test.stopTest();
	}
}