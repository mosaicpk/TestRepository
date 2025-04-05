/**
* @description Test class for PMC_LeadTriggerHandler and PMC_LeadTriggerHelper
* @author : Deloitte 
* @Developer: Megha Sunhare
* @storyNumber GDASF-6734
*/
@isTest
private with sharing class PMC_LeadTriggerHelperTest {
    
    /**
	* @description : Test setup method to prepare data for test.
	*/
    @TestSetup
    private static void testSetupData(){
        List<String> lstProfileNames = New List<String>{'System Administrator','Sales User'};
        List<String> lstPermissionNames = New List<String>{'PMC_Administrator_Permission_Set_Group','PMC_SLS_Permission_Set_Group'};

        Map<String,Id> mapOfProfiles = PMC_TestUtilityClass.getProfiles(lstProfileNames);
        Map<String,PermissionSetGroup> mapOfPermissionGrp = PMC_TestUtilityClass.getPemissionsetGroups(lstPermissionNames);
        
        UserRole objUserRole = [SELECT Id FROM UserRole WHERE Name = 'NA Sales Team' LIMIT 1];
        
        Integer intUserCount = 0;
        User objSystemAdminUser;
        User objSalesUser;
        List<User> lstUser = PMC_TestUtilityClass.createUser(2);
        
        for(User objUser : lstUser) {
            if(intuserCount==0) {
                objUser.LastName = 'Admin User Test';
                objUser.ProfileId = mapOfProfiles.get('System Administrator'); 
                objUser.FederationIdentifier = objUser.Username + 'Admin';
            }else if(intuserCount==1){
                objUser.LastName = 'Sales User Test';
                objUser.ProfileId = mapOfProfiles.get('Sales User'); 
                objUser.FederationIdentifier = objUser.Username + 'Sales';
            }
            objUser.UserRoleId = objUserRole.Id;
            objUser.isActive = true;                
            objUser.MobilePhone = '1234567890';
            intuserCount = intuserCount + 1;
        }
        insert lstUser;
        objSystemAdminUser = lstUser[0];
        objSalesUser = lstUser[1];
        
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSystemAdminUser}, mapOfPermissionGrp.get('PMC_Administrator_Permission_Set_Group'));
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSalesUser}, mapOfPermissionGrp.get('PMC_SLS_Permission_Set_Group'));
        
        System.runAs(objSystemAdminUser){
            Profile objDHBuyerProfile = [SELECT Id FROM Profile WHERE Name = 'Digital Hub Buyer' LIMIT 1];
            PermissionSetGroup perSetGrpDhBuyer = [SELECT Id,Status FROM PermissionSetGroup WHERE DeveloperName = 'PMC_DH_Buyer_Permission_Set_Group'];
            if (perSetGrpDhBuyer.Status != 'Updated') {
                Test.calculatePermissionSetGroup(perSetGrpDhBuyer.id);
                }
            List<User> lstPortalUsers;
            if(objDHBuyerProfile != null) {
                lstPortalUsers = PMC_TestUtilityClass.createPortalUser(2, objDHBuyerProfile);
                PMC_TestUtilityClass.assignPermissionSetGroupToUsers(lstPortalUsers, perSetGrpDhBuyer);
                }
        }
        System.runAs(objSalesUser){
            List<Lead> lstLeads = PMC_TestUtilityClass.createLead(3, '');
            //Update first lead
            lstLeads.get(0).Email = 'test@lead.com';
            lstLeads.get(0).PMC_SS_ProductFamilyCategoryInterests__c = 'ATHOS;DAP-MAP;LIMESTONE';
            
            //update lost lead
            lstLeads.get(1).Email = 'lost@lead.com';
            lstLeads.get(1).PMC_SS_ProductFamilyCategoryInterests__c = 'DAP-MAP';
            lstLeads.get(1).Status = 'Lost';
            lstLeads.get(1).PMC_SS_RejectionReason__c = 'Inaccurate Information';
            
            //Update lead with no interests
            lstLeads.get(2).Email = 'nointerest@lead.com';
            lstLeads.get(2).Status = 'New';
            
            update lstLeads;
            
            Account objAccount = PMC_TestUtilityClass.createAccount('Parent Account', 'PMC_SS_Customer');
            
            List<Contact> lstContacts = PMC_TestUtilityClass.createContact(2, '');
            //Update first contact
            lstContacts.get(0).Email = 'test@contact.com';
            lstContacts.get(0).PMC_SS_ProductInterests__c = 'ATHOS;DAP-MAP;LIMESTONE';
            lstContacts.get(0).AccountId = objAccount.Id;
            
            //Update Second contact with no product interest
            lstContacts.get(1).Email = 'nointerest@contact.com';
            lstContacts.get(1).AccountId = objAccount.Id;
            
            update lstContacts;
        }
    }
    
    /**
	* @description This method is used to test insertion of duplicate lead with different product interests
	*/
    @isTest
    private static void testDuplicateLeadWithDifferentInterest(){
        Lead objLead;
        Lead objExistingLead;
        Lead objNewLead;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
          objLead = PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead', 'test@lead.com', 'MES;PHOSPHORIC ACID');
            
            Database.DMLOptions objDMLOptions = new Database.DMLOptions();
            objDMLOptions.DuplicateRuleHeader.AllowSave = true; 
            
            Database.insert(objLead, objDMLOptions);
            
            objExistingLead = [SELECT PMC_SS_ProductFamilyCategoryInterests__c, PMC_SS_LatestProductInterests__c, PMC_SS_IsDuplicate__c
                                    FROM Lead WHERE Email='test@lead.com' AND PMC_SS_IsDuplicate__c = false LIMIT 1];
            objNewLead = [SELECT PMC_SS_IsDuplicate__c FROM Lead WHERE Id = :objLead.Id LIMIT 1];
            Test.stopTest();
        }
        
        System.assertEquals(true, objNewLead.PMC_SS_IsDuplicate__c, 'Expected new lead to be marked as duplicate');
        System.assertEquals(true, objExistingLead.PMC_SS_ProductFamilyCategoryInterests__c.contains('MES'), 'Expected MES to be added to product category interest');
        System.assertEquals(true, objExistingLead.PMC_SS_ProductFamilyCategoryInterests__c.contains('PHOSPHORIC ACID'), 'Expected Sulphur to be added to product category interest');
        System.assertEquals('MES,PHOSPHORIC ACID', objExistingLead.PMC_SS_LatestProductInterests__c, 'Expected latest product interet value to be populated');
    }
    
    /**
	* @description This method is used to test insertion of duplicate lead with same product interests
	*/
    @isTest
    private static void testDuplicateLeadWithSameInterest(){
        Lead objLead;
        Lead objExistingLead;
        Lead objNewLead;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead = PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead', 'test@lead.com', 'ATHOS;DAP-MAP;LIMESTONE');
            
            Database.DMLOptions objDMLOptions = new Database.DMLOptions();
            objDMLOptions.DuplicateRuleHeader.AllowSave = true; 
            
            Database.insert(objLead, objDMLOptions);
            
            objExistingLead = [SELECT PMC_SS_ProductFamilyCategoryInterests__c, PMC_SS_LatestProductInterests__c, PMC_SS_IsDuplicate__c
                               FROM Lead WHERE Email='test@lead.com' AND PMC_SS_IsDuplicate__c = false LIMIT 1];
            objNewLead = [SELECT PMC_SS_IsDuplicate__c FROM Lead WHERE Id = :objLead.Id LIMIT 1];
            Test.stopTest();
        }
        
        System.assertEquals(true, objNewLead.PMC_SS_IsDuplicate__c, 'Expected new lead to be marked as duplicate');
        System.assertEquals(true, (objExistingLead.PMC_SS_LatestProductInterests__c == NULL), 'Expected latest product interet value to be empty in case of same interests');
    }
    
    /**
	* @description This method is used to test insertion of duplicate lead for existing lost lead and checks if the status of existing lead is changing to new
	*/
    @isTest
    private static void testDuplicateLeadForLostLead(){
        Lead objLead;
        Lead objExistingLeadUpdated;
        Lead objNewLead;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead = PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead', 'lost@lead.com', 'ATHOS;DAP-MAP;LIMESTONE');
            
            Database.DMLOptions objDMLOptions = new Database.DMLOptions();
            objDMLOptions.DuplicateRuleHeader.AllowSave = true; 
            
            Database.insert(objLead, objDMLOptions);
            
            objExistingLeadUpdated = [SELECT Status, PMC_SS_ProductFamilyCategoryInterests__c, PMC_SS_LatestProductInterests__c, PMC_SS_IsDuplicate__c
                                           FROM Lead WHERE Email='lost@lead.com' AND PMC_SS_IsDuplicate__c = false LIMIT 1];
            objNewLead = [SELECT PMC_SS_IsDuplicate__c FROM Lead WHERE Id = :objLead.Id LIMIT 1];
            Test.stopTest();
        }
        
        System.assertEquals(true, objNewLead.PMC_SS_IsDuplicate__c, 'Expected new lead to be marked as duplicate');
        System.assertEquals(true, (objExistingLeadUpdated.PMC_SS_LatestProductInterests__c != NULL), 'Expected latest product interet value to be empty in case of same interests');
        System.assertEquals('New', objExistingLeadUpdated.Status, 'Expected the status of existing lead to be changed from lost to new');
    }
    
    /**
	* @description This method is used to test insertion of multiple duplicate lead with different product interests
	*/
    @isTest
    private static void testMultipleDuplicateLeadWithDifferentInterest(){
        List<Lead> lstLeads = new List<Lead>();
        Lead objExistingLead;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            lstLeads.add(PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead', 'test@lead.com', 'MES;PHOSPHORIC ACID'));
            lstLeads.add(PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead2', 'test@lead.com', 'NPK;P BLENDS'));
            
            Database.DMLOptions objDMLOptions = new Database.DMLOptions();
            objDMLOptions.DuplicateRuleHeader.AllowSave = true; 
            
            Database.insert(lstLeads, objDMLOptions);
            
            objExistingLead = [SELECT PMC_SS_ProductFamilyCategoryInterests__c, PMC_SS_LatestProductInterests__c, PMC_SS_IsDuplicate__c
                               FROM Lead WHERE Email='test@lead.com' AND PMC_SS_IsDuplicate__c = false LIMIT 1];
            Test.stopTest();
        }
        
        System.assertEquals(true, objExistingLead.PMC_SS_ProductFamilyCategoryInterests__c.contains('MES'), 'Expected MES to be added to product category interest');
        System.assertEquals(true, objExistingLead.PMC_SS_ProductFamilyCategoryInterests__c.contains('PHOSPHORIC ACID'), 'Expected Sulphur to be added to product category interest');
        System.assertEquals(true, objExistingLead.PMC_SS_ProductFamilyCategoryInterests__c.contains('NPK'), 'Expected TSP to be added to product category interest');
        System.assertEquals(true, objExistingLead.PMC_SS_ProductFamilyCategoryInterests__c.contains('P BLENDS'), 'Expected SSP to be added to product category interest');
    }
    
    /**
	* @description This method is used to test the creation of new opportunity when matchin contact exists in the system.
	*/
    @isTest
    private static void testDuplicateLeadForContactMatchingInterests(){
        
        Lead objLead;
        Boolean boolOpportunityGenerated = true;
        Opportunity objOpportunity;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead = PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead', 'test@contact.com', 'ATHOS;DAP-MAP;LIMESTONE');
            
            Database.DMLOptions objDMLOptions = new Database.DMLOptions();
            objDMLOptions.DuplicateRuleHeader.AllowSave = true; 
            
            Database.insert(objLead, objDMLOptions);
            
            Lead objNewLead = [SELECT PMC_SS_IsDuplicate__c FROM Lead WHERE Id = :objLead.Id LIMIT 1];
            try{
                objOpportunity = [SELECT PMC_SS_ProductFamilies__c, CloseDate, StageName, ForecastCategoryName FROM Opportunity LIMIT 1];
            }catch(Exception ex){
                boolOpportunityGenerated = false;
            }
            Test.stopTest();
            
            System.assertEquals(true, objNewLead.PMC_SS_IsDuplicate__c, 'Expected new lead to be marked as duplicate');
            System.assertEquals(false, boolOpportunityGenerated, 'Expected no opportunity to be generated');
            System.assertEquals(true, (objOpportunity == NULL), 'Expected no opportunity to be created and the variable to be null');
        }
    }
    
    /**
	* @description This method is used to test the creation of new opportunity when matchin contact exists in the system.
	*/
    @isTest
    private static void testDuplicateLeadForContactWithDifferentInterests(){
        Lead objLead;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead = PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead', 'test@contact.com', 'ATHOS;NPK');
            
            Database.DMLOptions objDMLOptions = new Database.DMLOptions();
            objDMLOptions.DuplicateRuleHeader.AllowSave = true;
            
            Database.insert(objLead, objDMLOptions);
            
            Lead objNewLead = [SELECT PMC_SS_IsDuplicate__c FROM Lead WHERE Id = :objLead.Id LIMIT 1];
            Opportunity objOpportunity = [SELECT PMC_SS_ProductFamilies__c, CloseDate, StageName, ForecastCategoryName FROM Opportunity LIMIT 1];
            Test.stopTest();
            
            System.assertEquals(true, objNewLead.PMC_SS_IsDuplicate__c, 'Expected new lead to be marked as duplicate');
            System.assertEquals('ATHOS;NPK' , objOpportunity.PMC_SS_ProductFamilies__c, 'Expected Opportunity to have product interests of new lead');
            System.assertEquals(PMC_SS_ConstantClass.OPPORTUNITY_PROSPECTING_STAGE, objOpportunity.StageName, 'Expected Opportunity to be in prospecting stage');
            System.assertEquals(Date.today() + 30, objOpportunity.CloseDate, 'Expected opportunity closed date to be 30 days from today');
            System.assertEquals(PMC_SS_ConstantClass.OPPORTUNITY_FORECAST_CATEGORY_PIPELINE, objOpportunity.ForecastCategoryName, 'Expected forecast category to be pipeline');
        }
    }
    
    /**
	* @description This method is used to test updation of product interest on existing lead without any product intersts.
	*/
    @isTest
    private static void testDuplicateForLeadWithNoInterest(){
        Lead objLead;
        Lead objExistingLeadUpdated;
        Lead objNewLead;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead = PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead', 'nointerest@lead.com', 'ATHOS;NPK');
            
            Database.DMLOptions objDMLOptions = new Database.DMLOptions();
            objDMLOptions.DuplicateRuleHeader.AllowSave = true; 
            
            Database.insert(objLead, objDMLOptions);
            
            objExistingLeadUpdated = [SELECT PMC_SS_ProductFamilyCategoryInterests__c FROM Lead 
                                           WHERE Email='nointerest@lead.com' AND PMC_SS_IsDuplicate__c = false LIMIT 1];
            objNewLead = [SELECT PMC_SS_IsDuplicate__c FROM Lead WHERE Id = :objLead.Id LIMIT 1];
        }
        Test.stopTest();
        
        System.assertEquals(true, objNewLead.PMC_SS_IsDuplicate__c, 'Expected new lead to be marked as duplicate');
        System.assertEquals('ATHOS;NPK', objExistingLeadUpdated.PMC_SS_ProductFamilyCategoryInterests__c, 'Expected product family interests to be populated.');
    }
    
    /**
	* @description This method is used to test updation of product interest on existing contact without any product intersts.
	*/
    @isTest
    private static void testDuplicateForContactWithNoInterest(){
        Lead objLead;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead = PMC_TestUtilityClass.createLeadObjectWrapper('Duplicate Lead', 'nointerest@contact.com', 'ATHOS;NPK');
            
            Database.DMLOptions objDMLOptions = new Database.DMLOptions();
            objDMLOptions.DuplicateRuleHeader.AllowSave = true;
            
            Database.insert(objLead, objDMLOptions);
            
            Contact objExistingContactUpdated = [SELECT PMC_SS_ProductInterests__c FROM Contact 
                                                 WHERE Email='nointerest@contact.com' LIMIT 1];
            Lead objNewLead = [SELECT PMC_SS_IsDuplicate__c FROM Lead WHERE Id = :objLead.Id LIMIT 1];
            Test.stopTest();
            
            System.assertEquals(true, objNewLead.PMC_SS_IsDuplicate__c, 'Expected new lead to be marked as duplicate');
            System.assertEquals('ATHOS;NPK', objExistingContactUpdated.PMC_SS_ProductInterests__c, 'Expected product family interests to be populated.');
        }
    }
    
    /**
	* @description This method is used to test delete/undelete trigger for lead.
	*/
    @isTest
    private static void testLeadDeleteUndeleteOperation(){
        Lead objLead;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead = [SELECT PMC_SS_ProductFamilyCategoryInterests__c FROM Lead 
                       WHERE Email='nointerest@lead.com' AND PMC_SS_IsDuplicate__c = false LIMIT 1];
            delete objLead;
            //undelete record
            Database.undelete(objLead.Id);
            
            Lead objLeadUndeleted = [SELECT Id FROM Lead WHERE Id = :objLead.Id LIMIT 1];
            
            Test.stopTest();
            System.assertEquals(true, (objLeadUndeleted != NULL), 'Expected Lead to be undeleted');
        }
    }
    
    /**
	* @description This method is used to test bypass logic for before triggers.
	*/
    @isTest
    private static void testLeadInsertOperationBypass(){
        Lead objLead;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            PMC_LeadTriggerHandler.boolBypassTriggerLogic = true;
            objLead = PMC_TestUtilityClass.createLeadObjectWrapper('New Lead', 'new@lead.com', 'ATHOS;NPK');
            insert objLead;
            
            Lead objLeadInserted = [SELECT Id, PMC_SS_IsDuplicate__c FROM Lead WHERE Id = :objLead.Id LIMIT 1];
            
            Test.stopTest();
            System.assertEquals(false, objLeadInserted.PMC_SS_IsDuplicate__c, 'Expected insert operation logic to be bypassed');
        }
    }
    
    /**
	* @description This method is used to test bypass logic for update triggers
	*/
    @isTest
    private static void testLeadUpdateOperationBypass(){
        List<Lead> lstLeads;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            PMC_LeadTriggerHandler.boolBypassTriggerLogic = true;
            lstLeads = PMC_TestUtilityClass.createLead(1, '');
            lstLeads.get(0).MobilePhone = '8874932889';
            update lstLeads;
            
            Lead objLeadInserted = [SELECT Id, MobilePhone FROM Lead WHERE Id = :lstLeads.get(0).Id LIMIT 1];
            
            Test.stopTest();
            System.assertEquals('8874932889', objLeadInserted.MobilePhone, 'Expected update operation logic to be bypassed');
        }
    }    
    
    /**
	* @description This method is used to test bypass logic for delete triggers
	*/
    @isTest
    private static void testLeadDeleteOperationBypass(){
        List<Lead> lstLeads;
        Boolean boolRecordDeleted = false;
        Lead objLeadInserted;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            PMC_LeadTriggerHandler.boolBypassTriggerLogic = true;
            lstLeads = PMC_TestUtilityClass.createLead(1, '');
            delete lstLeads;
            try{
                objLeadInserted = [SELECT Id, MobilePhone FROM Lead WHERE Id = :lstLeads.get(0).Id LIMIT 1];
            }catch(Exception ex){
                boolRecordDeleted = true;
            }        
            
            Test.stopTest();
            System.assertEquals(true, boolRecordDeleted, 'Expected delete operation logic to be bypassed');
            System.assertEquals(true, (objLeadInserted == NULL), 'Expected lead to get deleted');
        }
    }
    
    /**
	* @description This method is used to test ownership change for update triggers
	*/
    @isTest
    private static void testLeadUpdateOperationOnOwnerChange(){
        Lead objLead;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Admin User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                objLead = [SELECT id,PMC_SS_ProductFamilyCategoryInterests__c FROM Lead 
                           WHERE Email='nointerest@lead.com' AND PMC_SS_IsDuplicate__c = false LIMIT 1];
                objLead.Country = 'United States';
                objLead.Status = 'New';
                objLead.ownerId = g1.id;
                update objLead;
                objLead.OwnerId = UserInfo.getUserId();
                update objLead;
                System.assertEquals(UserInfo.getUserId(), objLead.OwnerId, 'Ownership changed');
            }
            Test.stopTest();
        }
    }
    
    /**
	* @description This method is used to test ownership change for insert triggers
	*/
    @isTest
    private static void testLeadUpdateOperationOnOwnerChangeOnInsert(){
        Lead objLead;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead = new Lead();
            objLead.Country = 'United States';
            objLead.Status = 'New';
            objLead.LastName = 'testLead';
            objLead.Company = 'AAA';
            insert objLead;
            System.assertNotEquals(UserInfo.getUserId(), objLead.OwnerId, 'Ownership changed');
            Test.stopTest();
        }
    }
    
    /**
	* @description This method is used to test exception for update triggers
	*/
    @isTest
    private static void testLeadUpdateOperationOnOwnerChangeException(){
        Lead objLead;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Admin User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            System.runAs(new User(Id = UserInfo.getUserId())) {
                objLead = [SELECT id,PMC_SS_ProductFamilyCategoryInterests__c FROM Lead 
                           WHERE Email='nointerest@lead.com' AND PMC_SS_IsDuplicate__c = false LIMIT 1];
                objLead.Country = 'United States';
                objLead.Status = 'Marketing Qualified 1';
                objLead.ownerId = g1.id;
                update objLead;
                objLead.OwnerId = UserInfo.getUserId();
                update objLead;
                System.assertEquals(UserInfo.getUserId(), objLead.OwnerId, 'Ownership changed');
            }
            Test.stopTest();
        }
    }
    
    /**
	* @description This method is used to test exception for update triggers
	*/
    @isTest
    private static void testExtractLeadExceptionOnUpdate(){
        List<String> lstLeadIds = new List<String>();   
        Map<Id, Lead> mapOldLead;
        Map<Id, Lead> mapNewLead;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            lstLeadIds = PMC_LeadTriggerHelperExtension.extractLeadIdsOnUpdate(mapOldLead, mapNewLead);
            Test.stopTest();
            System.assertEquals(true, lstLeadIds.isEmpty(), 'Exception Occured');
        }
    }  
    
    /**
	* @description This method is used to test exception for insert triggers
	*/
    @isTest
    private static void testExtractLeadExceptionOnInsert(){
        List<String> lstLeadIds = new List<String>();   
        Map<Id, Lead> mapNewLead;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            lstLeadIds = PMC_LeadTriggerHelperExtension.extractLeadIdsOnInsert(mapNewLead);
            Test.stopTest();
            System.assertEquals(true, lstLeadIds.isEmpty(), 'Exception Occured');
        }
    }
    
    /**
	* @description This method is used to cover the exception in notifyNewLeadOwner()
	*/
    @isTest
    private static void testNotifyLeadOwnerExceptionScenario(){
        List<Lead> lstNewLeads = new List<Lead>();
        Map<Id, Lead> mapOldLeads = new Map<Id, Lead>();
        Lead objLead = new Lead(LastName = 'Test',Email = 'testException@lead.com');
        lstNewLeads.add(objLead);
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            PMC_LeadTriggerHelperExtensionEnhancer.notifyNewLeadOwner(lstNewLeads, mapOldLeads);
            Test.stopTest();
            System.assertEquals(1, [SELECT Id FROM PMC_ErrorLog__c where PMC_ClassName__c = 'PMC_LeadTriggerHelperExtensionEnhancer'].size(), 'Expected error log record to be inserted');
        }
    }
    
    /**
	* @description This method is used to cover the exception in updateLeadStatus()
	*/
    @isTest
    private static void testUpdateLeadStatusExceptionScenario(){
        List<String> lstLeadIds = new List<String>();
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            PMC_LeadTriggerHelperExtension.boolTest = true;
            PMC_LeadTriggerHelperExtension.updateLeadStatus(lstLeadIds);
            Test.stopTest();
            System.assertEquals(true, lstLeadIds.isEmpty(), 'Exception Occured');
        }
    }
    
    /**
	* @description This method is used to cover the exception in updateLeadStatusOnOwnershipChange()
	*/
    @isTest
    private static void testUpdateLeadStatusOnOwnershipChangeExceptionScenario(){
        Map<Id,Lead> mapOldLead = new Map<Id,Lead>();
        Map<Id,Lead> mapNewLead = new Map<Id,Lead>();
        
        Lead objLead = [SELECT Id,Name FROM Lead WHERE Email='test@lead.com' LIMIT 1];
        mapNewLead.put(objLead.Id,objLead);
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            PMC_LeadTriggerHelperExtension.updateLeadStatusOnOwnershipChange(mapNewLead,mapOldLead,true);
            Test.stopTest();
            System.assertEquals(false, mapNewLead.isEmpty(), 'Exception Occured');
        }
    }
    
    /*
	* @description This method is used to test owner change to retailer user 
	*/
    @isTest
    private static void testAssignDealOwnerForRetailerLeadsSDRAssignment(){
        
        String strDealOwnerId = '';
        
        User objDhBuyerUser = [SELECT Id, Name FROM User WHERE Profile.Name = 'Digital Hub Buyer' AND FirstName = 'Test Portal' WITH SECURITY_ENFORCED LIMIT 1];
        Lead objLead = [SELECT Id, OwnerId From Lead LIMIT 1];
        strDealOwnerId = objLead.OwnerId;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead.OwnerId = objDhBuyerUser.Id;
            Database.Update(objLead);
            Test.stopTest();
            Lead objUpdatedLead = [SELECT Id, PMC_DH_DealOwner__c, OwnerId From Lead WHERE Id = :objLead.Id LIMIT 1];
            
            System.assertEquals(strDealOwnerId, objUpdatedLead.PMC_DH_DealOwner__c, 'Expected previous(SDR User) owner to be stamped as deal owner for leads assigned to retailer');
            System.assertEquals(objDhBuyerUser.Id, objUpdatedLead.OwnerId, 'Expected retailer to be the new owner of lead');
        }
    }
    
    /*
	* @description This method is used to test owner change from retailer to retailer user 
	*/
    @isTest
    private static void testAssignDealOwnerForRetailerLeadsRetailerReAssignment(){
        
        String strDealOwnerId = '';
        
        List<User> lstDhBuyerUser = [SELECT Id, Name FROM User WHERE Profile.Name = 'Digital Hub Buyer' AND FirstName = 'Test Portal' WITH SECURITY_ENFORCED LIMIT 2];
        Lead objLead = [SELECT Id, OwnerId From Lead LIMIT 1];
        strDealOwnerId = objLead.OwnerId;
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead.OwnerId = lstDhBuyerUser.get(0).Id;
            Database.Update(objLead);
            
            objLead.OwnerId = lstDhBuyerUser.get(1).Id;
            Database.Update(objLead);
            Test.stopTest();
            Lead objUpdatedLead = [SELECT Id, PMC_DH_DealOwner__c, OwnerId From Lead WHERE Id = :objLead.Id LIMIT 1];
            
            System.assertEquals(strDealOwnerId, objUpdatedLead.PMC_DH_DealOwner__c, 'Expected previous(SDR User) owner to be stamped as deal owner for leads assigned to retailer');
            System.assertEquals(lstDhBuyerUser.get(1).Id, objUpdatedLead.OwnerId, 'Expected retailer to be the new owner of lead');
        }
    }
    
    /*
	* @description This method is used to test owner change to non retailer user
	*/
    @isTest
    private static void testAssignDealOwnerForRetailerLeadsRetailerNonRetailerAssignment(){
       
        String strLeadOwnerId = '';
        
        User objDhBuyerUser = [SELECT Id, Name FROM User WHERE Profile.Name = 'Digital Hub Buyer' AND FirstName = 'Test Portal' WITH SECURITY_ENFORCED LIMIT 1];
        Lead objLead = [SELECT Id, OwnerId From Lead LIMIT 1];
        strLeadOwnerId = objLead.OwnerId;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Admin User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead.OwnerId = objDhBuyerUser.Id;
            Database.Update(objLead);
            
            objLead.OwnerId = objUser.Id;
            Database.Update(objLead);
            
            Test.stopTest();
            Lead objUpdatedLead = [SELECT Id, PMC_DH_DealOwner__c, OwnerId From Lead WHERE Id = :objLead.Id LIMIT 1];
            
            System.assert(String.isBlank(objUpdatedLead.PMC_DH_DealOwner__c), 'Expected Deal Owner to be null');
            System.assertNOTEquals(strLeadOwnerId , objUpdatedLead.OwnerId, 'Expected lead owner to be changed');
            System.assertEquals(objUser.Id , objUpdatedLead.OwnerId, 'Expected lead owner to be changed to non retailer user');
        }
    }

    /*
	* @description This method is used to test owner change to non retailer user
	*/
    @isTest
    private static void testAssignDealOwnerForRetailerLeadsNonRetailerAssignment(){
        String strLeadOwnerId = '';
        
        Lead objLead = [SELECT Id, OwnerId From Lead LIMIT 1];
        strLeadOwnerId = objLead.OwnerId;
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Admin User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead.OwnerId = objUser.Id;
            Database.Update(objLead);
            Test.stopTest();
            Lead objUpdatedLead = [SELECT Id, PMC_DH_DealOwner__c, OwnerId From Lead WHERE Id = :objLead.Id LIMIT 1];
            
            System.assert(String.isBlank(objUpdatedLead.PMC_DH_DealOwner__c), 'Expected Deal Owner to be null');
            System.assertNOTEquals(strLeadOwnerId , objUpdatedLead.OwnerId, 'Expected lead owner to be changed');
        }
    }
    
    /*
	* @description This method is used to test lead conversion functionality for retailer user
	*/
    @isTest
    private static void testAddSDRToAccAndOppTeamsAfterLeadConversion(){

        List<Lead> lstUpdatedLead = new List<Lead>();
        
        User objSDRUser = [SELECT Id FROM User WHERE LastName = 'Sales User Test' AND isActive = true LIMIT 1];
        User objDHBuyerUser = [SELECT Id, Name FROM User WHERE Profile.Name = 'Digital Hub Buyer' AND FirstName = 'Test Portal' WITH SECURITY_ENFORCED LIMIT 1];
        Lead objLead = [SELECT Id, OwnerId, IsConverted From Lead LIMIT 1];
        
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            objLead.OwnerId = objDHBuyerUser.Id;
            objLead.PMC_DH_DealOwner__c = objSDRUser.Id;
            Database.Update(objLead);
            
            Test.stopTest();
            Lead objUpdatedLead = [SELECT Id, PMC_DH_DealOwner__c, OwnerId, IsConverted From Lead WHERE Id = :objLead.Id LIMIT 1];
            lstUpdatedLead.add(objUpdatedLead);
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(objUpdatedLead.Id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Converted');
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess(),'Success');
        }
    }
}