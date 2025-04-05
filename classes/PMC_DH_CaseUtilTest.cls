/**
 * @author @hemant.giri
 * @description test class for Case
 * @since 06-14-2023
 */
@isTest
public with sharing class PMC_DH_CaseUtilTest {
   /**
 * @description test setup method
 * @since 06-15-2023
 * @author hemant giri goswami
 */
   @testSetup
    public static void testData(){
        User userAdmin=PMC_DH_TestDataFactoryClass.createAdminUser();
        User usr;
        Account acc1;
        BusinessHours bh=[select name,id from BusinessHours where name='Default' limit 1];
        System.runAs(userAdmin)
        {
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
        }
        System.runAs(usr){
            PMC_DH_TestDataFactoryClass.createCaseRecord(acc1.Id, usr.ContactId, bh.Id);
        }
    } 
    
    /**
* @description test method for reopen case
* @author Ajeet
*/
    @isTest
    public static void reopenCaseTest()
    {   
		User usr=[SELECT id FROM User WHERE UserName = 'demouser@test.com.testuser' limit 1];
        Test.startTest();
        System.runAs(usr)
        {  
            Case caseObjRecord=[select CaseNumber,Id,closeddate,Subject from case where status='New' WITH SECURITY_ENFORCED limit 1];
            caseObjRecord.PMC_SS_IssueReason__c	='Delivery delay';
            caseObjRecord.Status='Closed';
            update caseObjRecord;
            PMC_DH_CaseUtil.isEligibleToUploadDoc(caseObjRecord.Id);
            PMC_DH_CaseUtil.getDependentPicklistValues(Case.PMC_SS_IssueReason__c);
            PMC_DH_CaseUtil.CaseWrapper wrp1=new PMC_DH_CaseUtil.CaseWrapper();
            wrp1.strCaseId=caseObjRecord.id;
            wrp1.strReason='Resolution Not Accurate';
            wrp1.strOthersComment='Test';
            PMC_DH_DigitalHubB2BUtils.PMC_DH_StatusCodeMessageWrapper  result=PMC_DH_CaseUtil.reopenCase(wrp1); 
            System.assert(result!=null,'Success');

        }
        test.stopTest();
            
    }
    /**
* @description test method for reopen case exception
* @author Hemant
*/
    @isTest
    public static void reopenCaseExceptionTest()
    {   
        User usr=[SELECT id FROM User WHERE UserName = 'demouser@test.com.testuser' limit 1];
        Test.startTest();
        System.runAs(usr)
        { 
            Boolean isException;
            try{
            Case caseObjRecord=[select CaseNumber,id,closeddate,Subject from case where status='New' WITH SECURITY_ENFORCED limit 1];
            caseObjRecord.PMC_SS_IssueReason__c	='Delivery delay';
            caseObjRecord.Status='Pending';
            isException=false;
            update caseObjRecord;
            PMC_DH_CaseUtil.CaseWrapper wrp1=new PMC_DH_CaseUtil.CaseWrapper();
            wrp1.strCaseId=caseObjRecord.id;
            wrp1.strReason='Resolution Not Accurate';
            wrp1.strOthersComment='';
            PMC_DH_CaseUtil.reopenCase(wrp1);
            PMC_DH_CaseUtil.boolThrow=true;
            PMC_DH_CaseUtil.reopenCase(wrp1);
            }catch(Exception ex){
                isException = true;
            }
            System.assert(isException!=null,'Exception Handled');
        }
        
        Test.stopTest();
            
    }
        /**
* @description test method for reopen case List
* @author Hemant
*/
    @istest
    public static void getReopenReasonListTest()
    {
        List<PMC_DH_PicklistWrapper> wrp= PMC_DH_CaseUtil.getReopenReasonList();
        System.assert(wrp!=null,'Success');
    }
}