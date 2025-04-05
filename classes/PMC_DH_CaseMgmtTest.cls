/**
 * @description Test Class for PMC_DH_CaseMgmtClass
 * @since 06-15-2023
 */
@isTest
public with sharing class PMC_DH_CaseMgmtTest {
    
/**
 * @description test method for getTimeline method
 * @since 06-15-2023
 * @author hemant giri goswami
 */
    @testSetup
    public static void testData(){
        BusinessHours bh;
        Account acc1;
        User usr;
        User userAdmin=PMC_DH_TestDataFactoryClass.createAdminUser();
        System.runAs(userAdmin){
        bh=[select name,id from BusinessHours where name='Default' limit 1];
        acc1=PMC_DH_TestDataFactoryClass.createParentTestAccount();
        PMC_DH_TestDataFactoryClass.createTestContact(acc1.id);
        
        Profile profile = [SELECT Id FROM Profile WHERE Name =: PMC_DH_ConstantClass.PROFILE_NAME LIMIT 1];
        PMC_DH_TestDataFactoryClass.createTestUser(acc1.Id,profile.Id);
        usr=[SELECT Id,ContactId FROM User WHERE UserName = 'demouser@test.com.testuser' limit 1];
        Id lstPermSet2=[select id from PermissionSet where Name ='PMC_DH_CPQ_PermissionSetLicense'][0].id;
        PMC_DH_TestDataFactoryClass.assignPermissionSetToUser(usr.Id,lstPermSet2);
        Id lstPermSet=[select id from PermissionSet where Name ='SteelBrickDHCPQPartnerUser'][0].id;
        PMC_DH_TestDataFactoryClass.assignPermissionSetToUser(usr.Id,lstPermSet);
        Id lstPermSet1=[select id from PermissionSet where Name ='PMC_DH_SuperBuyer'][0].id;
        PMC_DH_TestDataFactoryClass.assignPermissionSetToUser(usr.Id,lstPermSet1);
        Id lstPermSet3=[select id from PermissionSet where Name ='PMC_DH_AccountCRE'][0].id;
        PMC_DH_TestDataFactoryClass.assignPermissionSetToUser(usr.Id,lstPermSet3);
        Id lstPermSet4=[select id from PermissionSet where Name ='PMC_DH_Account_Switcher'][0].id;
        PMC_DH_TestDataFactoryClass.assignPermissionSetToUser(usr.Id,lstPermSet4);
        }
        System.runAs(usr){
            Case testCase = PMC_DH_TestDataFactoryClass.createCaseRecord(acc1.Id, usr.ContactId, bh.Id);
            
            
            /*  Case newCase=new Case(ContactId=con.Id,AccountId=acc1.Id,BusinessHoursId=bh.id,Status='New',
                Type='Shipping',Origin='Email',Priority='Low',
                Subject='test case demo',description='just for the purpose of test class',CurrencyIsoCode='USD');
                insert newCase;*/
            
            testCase.PMC_SS_IssueReason__c	='Delivery delay';
            testCase.Status='Closed';
            update testCase;
        }       
}
    /**
* @description test method to get timeline
* @author Ajeet
*/
    @isTest
    public static void getTimelineTest()
    {	
        User usr=[SELECT id FROM User WHERE UserName = 'demouser@test.com.testuser' limit 1];
        Test.startTest();
        System.runAs(usr)
        {  
            Case caseObjRecord=[select CaseNumber,id,closeddate,Subject from case where status='closed' with Security_enforced limit 1];
            Boolean result=PMC_DH_CaseMgmtClass.getTimeline(caseObjRecord.id);
            System.assertEquals(result,true,'Success');
        }
        test.stopTest();
    }

    /**
 * @description test method for get Type For Case
 * @author Ajeet
 */
@istest
public static void getTypeForCaseTest()
{
    Test.startTest();
    User usr=[SELECT id FROM User WHERE UserName = 'demouser@test.com.testuser' limit 1];
    System.runAs(usr){
        List<PMC_DH_PicklistWrapper> wrpType = PMC_DH_CaseMgmtClass.getTypeForCase();
        System.assert(wrpType!=null,'Success');
    }
    Test.stopTest();
}
/**
* @description test method for get IssueReason For Case
* @author Ajeet
*/
@istest
public static void getIssueReasonForCaseTest()
{
    Test.startTest();
    User usr=[SELECT id FROM User WHERE UserName = 'demouser@test.com.testuser' limit 1];
    System.runAs(usr){
    Map<String,List<PMC_DH_PicklistWrapper>> wrpReason = PMC_DH_CaseMgmtClass.getIssueReasonForCase();
        System.assert(wrpReason!=null,'Success');
    }
    Test.stopTest();
}
/**
* @description test method for new case creation
* @author Ajeet
*/
    @isTest
    public static void createNewCaseTest(){
        Account acc1= [SELECT id from Account where name='Parent Test Account' LIMIT 1];
        User usr=[SELECT id FROM User WHERE UserName = 'demouser@test.com.testuser' limit 1];
        Test.startTest();
        List<PMC_DH_CaseMgmtClass.PMC_DH_FileWrapper> lstFileWrapper = new List<PMC_DH_CaseMgmtClass.PMC_DH_FileWrapper>();
        PMC_DH_CaseMgmtClass.PMC_DH_FileWrapper fileWrapper = new PMC_DH_CaseMgmtClass.PMC_DH_FileWrapper();
        System.runAs(usr)
        {  
            PMC_DH_CaseMgmtClass.PMC_DH_CaseCreationWrapper caseWrapper = new PMC_DH_CaseMgmtClass.PMC_DH_CaseCreationWrapper();
            caseWrapper.strType = 'Shipping';
            caseWrapper.strIssueReason = 'Delivery Delay';
            caseWrapper.strSubject = 'Test Subject';
            caseWrapper.strDescription = 'Test Description';
            fileWrapper.strBase64Data = 'New Test Data';
            fileWrapper.strfileName = 'Test12';
            lstFileWrapper.add(fileWrapper);
            PMC_DH_CaseMgmtClass.PMC_DH_CaseDataWrapper testResult = PMC_DH_CaseMgmtClass.createNewCase(caseWrapper,lstFileWrapper,acc1.Id);
            fileWrapper.parentId=testResult.objCaseDetail.Id;
            System.assert(testResult!=null,'Success');
        }
        PMC_DH_CaseMgmtClass.saveTheChunkFile(new  List<PMC_DH_CaseMgmtClass.PMC_DH_FileWrapper>{fileWrapper});
        Test.stopTest();
    }
    /**
    * @description test method for new case creation
    * @author Ajeet
    */
    @isTest
    public static void getCaseDocumentAndCommentTest(){
        Test.startTest();
            Account acc= [SELECT id from Account where name='Parent Test Account' LIMIT 1];
            Contact con = [SELECT id from Contact where Email = 'demouser1@abc.com' LIMIT 1];
            BusinessHours bh=[select name,id from BusinessHours where name='Default' limit 1];
            Case testCase = PMC_DH_TestDataFactoryClass.createCaseRecord(acc.Id, con.id, bh.Id);
            PMC_DH_TestDataFactoryClass.createCommentAndDocForCase(testCase.Id);
            PMC_DH_CaseMgmtClass.CaseDocumentCommentWrapper result = PMC_DH_CaseMgmtClass.getCaseDocumentAndCommentRecords(testCase.Id);
            System.assertEquals(true, result.boolEligibleToAddDocAndComments,'Success');
            System.assertEquals(1, result.caseCommentList.size(), 'Success');
        Test.stopTest();
    }
    /**
    * @description test method for new case creation
    * @author Ajeet
    */
    @isTest
    public static void createCommentTest(){
        Test.startTest();
            Account acc= [SELECT id from Account where name='Parent Test Account' LIMIT 1];
            Contact con = [SELECT id from Contact where Email = 'demouser1@abc.com' LIMIT 1];
            BusinessHours bh=[select name,id from BusinessHours where name='Default' limit 1];
            Case testCase = PMC_DH_TestDataFactoryClass.createCaseRecord(acc.Id, con.id, bh.Id);
            String strComment = 'Commenting for test case';
            PMC_DH_DigitalHubB2BUtils.PMC_DH_StatusCodeMessageWrapper result = PMC_DH_CaseMgmtClass.createComment(testCase.Id, strComment);
            System.assert(result!=null, 'Success');
        Test.stopTest();
    }
}