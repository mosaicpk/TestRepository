@isTest
public class PMC_SS_CaseAssignementRuleOnUpdateTest {
    @testSetup
    static void setup() {
        List<String>lstProfileNames = New List<String>{'System Administrator','Service User'};
        List<String>lstPermissionNames = New List<String>{'PMC_Administrator_Permission_Set_Group','PMC_SRV_Permission_Set_Group'};
    	List<Case> lstCases = new List<Case>();
        List<Account> lstAccounts = new List<Account>();
        Map<String,Id>mapOfProfiles = PMC_TestUtilityClass.getProfiles(lstProfileNames);
        UserRole objRole = [SELECT Id,Name FROM UserRole WHERE Name ='NA Customer Service Lead'];
        Map<String,PermissionSetGroup>mapOfPermissionGrp = PMC_TestUtilityClass.getPemissionsetGroups(lstPermissionNames);
        Integer intuserCount =0;
        User objSystemAdminUser;  
        User objServiceUser;
        List<User> lstUser = PMC_TestUtilityClass.createUser(2);
            for(User objUser : lstUser) {
                If(intuserCount==0){
                   objUser.LastName = 'Admin User Test';
                   objUser.ProfileId = mapOfProfiles.get('System Administrator'); 
                   objUser.FederationIdentifier = objUser.Username + 'Admin';
                }else if(intuserCount==1){
                    objUser.LastName = 'Service User Test';
                    objUser.ProfileId = mapOfProfiles.get('Service User'); 
                   objUser.FederationIdentifier = objUser.Username + 'Service';
                   objUser.UserRoleId = objRole.Id;
                } 
                objUser.isActive = true;                
                objUser.MobilePhone = '1234567890';
                intuserCount = intuserCount + 1;
            }            
            insert lstUser;
            objSystemAdminUser = lstUser[0];
            objServiceUser = lstUser[1];
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSystemAdminUser}, mapOfPermissionGrp.get('PMC_Administrator_Permission_Set_Group'));
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objServiceUser}, mapOfPermissionGrp.get('PMC_SRV_Permission_Set_Group'));
        BusinessHours objBusinessHrs = [SELECT Id, Name FROM BusinessHours WHERE isDefault = True AND IsActive = True];
        
        System.runAs(objSystemAdminUser){         
         PMC_TestUtilityClass.createLocation('Test Location');
         PMC_TestUtilityClass.createProduct(1,'PMC_CPQ_Brazil');
        }
       System.runAs(objServiceUser){
        lstAccounts = getTestAccountList();
           
            lstCases = getTestCasesList(lstAccounts, objSystemAdminUser.Id, objBusinessHrs.Id);
            insert lstCases;
            List<Contact> lstContacts = PMC_TestUtilityClass.createContact(1, '');
            if(lstContacts.size() > 0 && lstAccounts.size() > 0) {
                lstContacts[0].AccountId = lstAccounts[0].Id;
                lstContacts[0].PMC_SS_Status__c = 'Active';
                update lstContacts[0];
            
                PMC_TestUtilityClass.createCaseWithContact(objBusinessHrs.Id, lstContacts[0].Id, lstUser[0].Id);
            }
           
        }
        /*  
        // Create Queue groups
        Group saGtmQueue = new Group(DeveloperName = PMC_SS_ConstantClass.SA_GTM_QUEUE, Type = PMC_SS_ConstantClass.QUEUE);
        Group knowledgeCreatorQueue = new Group(DeveloperName = PMC_SS_ConstantClass.KNOWLEDGE_CREATOR_QUEUE, Type = PMC_SS_ConstantClass.QUEUE);
        Group gtmQueue = new Group(DeveloperName = PMC_SS_ConstantClass.GTM_QUEUE, Type = PMC_SS_ConstantClass.QUEUE);
        Group productQueue = new Group(DeveloperName = PMC_SS_ConstantClass.PRODUCT_QUEUE, Type = PMC_SS_ConstantClass.QUEUE);
        Group masterDataQueue = new Group(DeveloperName = PMC_SS_ConstantClass.MASTER_DATA_QUEUE, Type = PMC_SS_ConstantClass.QUEUE);
        insert new List<Group>{saGtmQueue, knowledgeCreatorQueue, gtmQueue, productQueue, masterDataQueue};

 
        // Create some test cases
        Case caseIndia = new Case(Subject = 'Test Case 1', Status = 'New', PMC_SS_IssueReason__c = 'Product Request');
        Case caseChina = new Case(Subject = 'Test Case 2', Status = 'New', PMC_SS_IssueReason__c = 'Rebate');
        Case caseProduct = new Case(Subject = 'Test Case 3', Status = 'New', PMC_SS_IssueReason__c = 'Incorrect Product');
        insert new List<Case>{caseIndia, caseChina, caseProduct};
 
        // Create related EmailMessage records
        EmailMessage emailIndia = new EmailMessage(ParentId = caseIndia.Id, ToAddress = PMC_SS_ConstantClass.To_Address_India);
        EmailMessage emailChina = new EmailMessage(ParentId = caseChina.Id, ToAddress = PMC_SS_ConstantClass.To_Address_China);
        insert new List<EmailMessage>{emailIndia, emailChina};
   */     
        
    }
    /**
     * @description Method will create Test Accounts 
     * @return - List<Account> return list of test accounts created
     */

    public static List<Account> getTestAccountList() {

        List<Account> lstAccounts = new List<Account>();
        for(Integer intAccountCount = 0; intAccountCount < 3; intAccountCount++) {
            Account objAccount = PMC_TestUtilityClass.createAccount('Deloitte'+intAccountCount,'PMC_SS_Customer');
            lstAccounts.add(objAccount);
        }
        return lstAccounts;
    }

    /**
     * @description Method will create Test Case 
     * @param lstAccounts - List of test accounts created
     * @param idUser - User Id as Owner
     * @param idBusinessHours - Business Hours Id
     * @return List<Case> return list of test cases created
     */

    public static List<Case> getTestCasesList(List<Account> lstAccounts, Id idUser, Id idBusinessHours) {
		Schema.Location objLocation = [SELECT ID FROM Location limit 1];
        List<Case> lstCases = new List<Case>();

        for(Integer intAccountCount = 0; intAccountCount < lstAccounts.size(); intAccountCount++) {
            Case objCase = PMC_TestUtilityClass.createCase(idBusinessHours, lstAccounts[intAccountCount].Id, idUser,objLocation.Id);
            
            objCase.Subject = intAccountCount == 0 ? 'Test Case High Priority Excemption' : 'Test Subject';
            objCase.Type = intAccountCount == 0 ? 'Internal' : 'Shipping';     
            objCase.PMC_SS_IssueReason__c = intAccountCount == 0 ? 'MDM Verification' : 'Diversion';
            objCase.PMC_SS_RouteToQuality__c = False;
            lstCases.add(objCase);
        }
        
        return lstCases;
    }
    
    /**
     * @description Method will create Test Case 
     
     */
    
    @isTest
    public static void testAttachContactLeadOnCase() {
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Service User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
            Schema.Location objLocation = [SELECT ID FROM Location limit 1];
                List<Case> lstCases = new List<Case>();
                Id idBusinessHours = [SELECT Id, Name FROM BusinessHours WHERE isDefault = True AND IsActive = True LIMIT 1].Id; 
                
                List<Contact> lstContacts = PMC_TestUtilityClass.createContact(1, '');
            	lstContacts[0].MobilePhone = '123123123123';
                lstContacts[0].Phone = '123123123';
                lstContacts[0].OtherPhone = '123123';
                lstContacts[0].HomePhone = '123';
                lstContacts[0].Email = 'hidituzig@dropjar.com';
                lstContacts[0].PMC_SS_Status__c = 'Active';
                
                update lstContacts[0];
                
                List<Lead> lstLeads = PMC_TestUtilityClass.createLead(1, '');
                lstLeads[0].Phone = '321321321321';
                lstLeads[0].Email = 'kynipub@tafmail.com';
                update lstLeads[0];
            	
                
                Case objCase = PMC_TestUtilityClass.createCaseWithoutContact(idBusinessHours, null, objUser.Id,objLocation.Id);
                objCase.SuppliedEmail='stuartLittle@lele.comm';
            	objCase.SuppliedPhone='121212121';
            objCase.OwnerId=null;
            	
            	lstCases.add(objCase);
                
                Case objCase2 = PMC_TestUtilityClass.createCase(idBusinessHours, null, objUser.Id,objLocation.Id);
                objCase2.SuppliedEmail=lstContacts[0].Email;        		            	
                lstCases.add(objCase2);
            	
            	Case objCase3 = PMC_TestUtilityClass.createCaseWithoutContact(idBusinessHours, null, objUser.Id,objLocation.Id);
                objCase3.SuppliedEmail=lstLeads[0].Email;        		            	
                lstCases.add(objCase3);
                
                Case objCase4 = PMC_TestUtilityClass.createCase(idBusinessHours, null, objUser.Id,objLocation.Id);                
                objCase4.SuppliedEmail=lstLeads[0].Email;        	
            	lstCases.add(objCase4);
                insert lstCases;
            
                System.assertEquals(objCase4.SuppliedEmail, lstLeads[0].Email, 'Lead & Case Email are matched');
            }
        
        
        Test.stopTest();
    }
    
    
    
    /** 
    * @description This method will check whether Web Email and Web Name on Case is populated
    */ 
    @isTest
    private static void testUpdateWebEmailandWebName() {
        Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Service User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
         Schema.Location objLocation = [SELECT ID FROM Location limit 1];
        BusinessHours objTestBusinessHrs = [SELECT Id, Name FROM BusinessHours WHERE isDefault = True AND IsActive = True]; 
        Account objTestAccount = [SELECT Id, Name FROM Account  WITH SECURITY_ENFORCED LIMIT 1];

        
		Case objTestCase= PMC_TestUtilityClass.createCase(objTestBusinessHrs.Id,objTestAccount.Id ,objUser.Id,objLocation.Id);
        objTestCase.Type='Internal';
        objTestCase.PMC_SS_IssueReason__c='Article Request';
            objTestCase.OwnerId=null;
        insert objTestCase;

        Case objCase1= [SELECT Id, SuppliedEmail, SuppliedName, Subject, Type, PMC_SS_IssueReason__c FROM Case WHERE Subject='Test Subject'AND Type='Internal' AND PMC_SS_IssueReason__c='Article Request'];
        Case objTestCase2= PMC_TestUtilityClass.createCase(objTestBusinessHrs.Id,objTestAccount.Id ,objUser.Id,objLocation.Id);
        objTestCase2.Type='Product';
            objTestCase2.OwnerId=null;
        insert objTestCase2;    
        objTestCase2.PMC_SS_IssueReason__c='Product Request';
      	Update objTestCase2;
        objTestCase2.PMC_SS_IssueReason__c='Incorrect Product';
      	Update objTestCase2;
        objTestCase2.Type='Transactions';    
        objTestCase2.PMC_SS_IssueReason__c='Rebate';
      	Update objTestCase2;
        objTestCase2.Type='Internal';    
        objTestCase2.PMC_SS_IssueReason__c='Article Request';
      	Update objTestCase2;
        System.assertEquals(UserInfo.getName(), objCase1.SuppliedName, 'Web Name updated');
        System.assertEquals(UserInfo.getUserEmail(), objCase1.SuppliedEmail, 'Web Email updated');
        }
    
        Test.stopTest();
    }
    
    
 
    @isTest
    static void testCaseAssignmentRule() {
        // Fetch cases for testing
        Map<Id, Case> oldCases = new Map<Id, Case>([SELECT Id, PMC_SS_IssueReason__c FROM Case]);
 
        List<Case> newCases = [SELECT Id, Subject, OwnerId, PMC_SS_IssueReason__c FROM Case];
 
        // Invoke the method
        Test.startTest();
        PMC_SS_CaseAssignementRuleOnUpdate.caseAssignmentRule(oldCases, newCases);
        Test.stopTest();
 
        // Validate assignments
        List<Case> updatedCases = [SELECT Id, OwnerId FROM Case];
 
        for (Case c : updatedCases) {
            if (c.Subject.contains('Test Case 1')) {
                System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = :PMC_SS_ConstantClass.MASTER_DATA_QUEUE LIMIT 1].Id, c.OwnerId, 'The case should be assigned to Master Data Queue');
            } else if (c.Subject.contains('Test Case 2')) {
                System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = :PMC_SS_ConstantClass.GTM_QUEUE LIMIT 1].Id, c.OwnerId, 'The case should be assigned to GTM Queue');
            } else if (c.Subject.contains('Test Case 3')) {
                System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = :PMC_SS_ConstantClass.PRODUCT_QUEUE LIMIT 1].Id, c.OwnerId, 'The case should be assigned to Product Queue');
            }
        }
    }
 
    @isTest
    static void testQueueAssignmentForProductAndArticleRequest() {
        // Fetch cases for testing
        Map<Id, Case> oldCases = new Map<Id, Case>([SELECT Id, PMC_SS_IssueReason__c FROM Case WHERE Subject = 'Test Case 1']);
 
        Case newCase = [SELECT Id, PMC_SS_IssueReason__c FROM Case WHERE Subject = 'Test Case 1' LIMIT 1];
 
        // Fetch queues
        Map<String, Id> mapQueues = new Map<String, Id>();
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN (:PMC_SS_ConstantClass.SA_GTM_QUEUE, :PMC_SS_ConstantClass.KNOWLEDGE_CREATOR_QUEUE)]) {
            mapQueues.put(g.DeveloperName, g.Id);
        }
 
        // Invoke the method
        Test.startTest();
        PMC_SS_CaseAssignementRuleOnUpdate.queueAssignmentForProductAndArticleRequest(oldCases, newCase, mapQueues);
        Test.stopTest();
 
        // Assert queue assignment
        System.assertEquals(mapQueues.get(PMC_SS_ConstantClass.SA_GTM_QUEUE), newCase.OwnerId, 'Case should be assigned to SA_GTM_QUEUE');
    }
 
    @isTest
    static void testQueueAssignmentForRebateAndIncorrectProduct() {
        // Fetch cases for testing
        Map<Id, Case> oldCases = new Map<Id, Case>([SELECT Id, PMC_SS_IssueReason__c FROM Case WHERE Subject = 'Test Case 2']);
 
        Case newCase = [SELECT Id, PMC_SS_IssueReason__c FROM Case WHERE Subject = 'Test Case 2' LIMIT 1];
 
        // Fetch queues
        Map<String, Id> mapQueues = new Map<String, Id>();
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN (:PMC_SS_ConstantClass.GTM_QUEUE, :PMC_SS_ConstantClass.PRODUCT_QUEUE)]) {
            mapQueues.put(g.DeveloperName, g.Id);
        }
 
        // Invoke the method
        Test.startTest();
        PMC_SS_CaseAssignementRuleOnUpdate.queueAssignmentForRebateAndIncorrectProduct(oldCases, newCase, mapQueues);
        Test.stopTest();
 
        // Assert queue assignment
        System.assertEquals(mapQueues.get(PMC_SS_ConstantClass.GTM_QUEUE), newCase.OwnerId, 'Case should be assigned to GTM_QUEUE');
    }
    @isTest
    public static void testCaseAssignmentRuleupdated() {
        // Create test data
        // 1. Create a Case with all required fields including the Name field
 Test.startTest();
        User objUser = [SELECT Id, Name FROM User Where LastName='Service User Test' WITH SECURITY_ENFORCED LIMIT 1];
        System.runAs(objUser) {
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Status = 'New'; // Assuming 'Status' is required
        testCase.Origin = 'Email'; // Assuming 'Origin' is required
        testCase.Priority = 'High'; // Assuming 'Priority' is required
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('YourRecordType').getRecordTypeId();
        testCase.OwnerId = UserInfo.getUserId(); // Optional, depending on your use case
        insert testCase;
 
        // Create the old case map for the method parameter
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        oldCaseMap.put(testCase.Id, testCase);
 
        // Run the method you are testing
        List<Case> lstNewCases = [SELECT Id, OwnerId, Status FROM Case WHERE Id = :testCase.Id];
        PMC_SS_CaseAssignementRuleOnUpdate.caseAssignmentRule(oldCaseMap, lstNewCases);
 
        // Add assertions to verify expected outcomes
        Case updatedCase = [SELECT OwnerId FROM Case WHERE Id = :testCase.Id];
        System.assertNotEquals(null, updatedCase.OwnerId, 'OwnerId should be updated');
    }
    }
}