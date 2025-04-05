@isTest
public class PMC_CPQ_PriceConfirmationControllerTest {

    @TestSetup
    static void insertDate(){
        
        List<String>lstProfileNames = new List<String>{'System Administrator','Sales User'};
        List<String>lstPermissionNames = new List<String>{'PMC_Administrator_Permission_Set_Group','PMC_SLS_Permission_Set_Group'};
        Map<String,Id>mapOfProfiles = PMC_TestUtilityClass.getProfiles(lstProfileNames);
        Map<String,PermissionSetGroup> mapOfPermissionGrp = PMC_TestUtilityClass.getPemissionsetGroups(lstPermissionNames);
        Integer intuserCount = 0;
        User objSystemAdminUser;  
        User objSalesUser;
        List<User> lstUser = PMC_TestUtilityClass.createUser(2);

        for (User objUser : lstUser) {

            if (intuserCount == 0) {
                objUser.LastName = 'Admin User Test';
                objUser.ProfileId = mapOfProfiles.get('System Administrator'); 
                objUser.FederationIdentifier = objUser.Username + 'Admin';
            } else if (intuserCount == 1) {
                objUser.LastName = 'Sales User Test';
                objUser.ProfileId = mapOfProfiles.get('Sales User'); 
                objUser.FederationIdentifier = objUser.Username + 'Sales';
            }

            objUser.isActive = true;                
            objUser.MobilePhone = '1234567890';
            objUser.UserPermissionsKnowledgeUser = true;
            objUser.LanguageLocaleKey = 'en_US';
            intuserCount = intuserCount + 1;
        }            
        insert lstUser;

        objSystemAdminUser = lstUser[0];
        objSalesUser = lstUser[1];

        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSystemAdminUser}, mapOfPermissionGrp.get('PMC_Administrator_Permission_Set_Group'));
        PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{objSalesUser}, mapOfPermissionGrp.get('PMC_SLS_Permission_Set_Group'));

        System.runas(objSystemAdminUser) {
            List <Product2> lstProducts; 
            lstProducts = PMC_TestUtilityClass.CreateProduct(2,'PMC_CPQ_Brazil');
        }

        System.runas(objSalesUser) {
            List<Opportunity> lstOpportunities;
            lstOpportunities = PMC_TestUtilityClass.createOpportunity(2,'Master');
            List<Contact> lstContacts;
            lstContacts = PMC_TestUtilityClass.createContact(1,'Master');
        }   

    }

    @isTest
    private static void shouldRetrieveData() {

        List<User> lstUser = [SELECT Id, Name FROM User WHERE LastName ='Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];
        
        System.runAs(lstUser.get(0)) {    
            List<Opportunity> lstOppty = [select Id, AccountId from Opportunity LIMIT 1 ];
            List<Account> lstAccount = [select Id,PMC_SS_CustomerType__c,PMC_SS_SAPCustomerNumber__c from Account where Id =:lstOppty.get(0).AccountId];
            lstAccount.get(0).PMC_SS_SAPCustomerNumber__c='0805';
            update lstAccount;  
            List<Contact> lstCont = [SELECT Id FROM Contact LIMIT 1];
            lstCont.get(0).AccountId = lstAccount.get(0).Id;
            update lstCont;  

            List<SBQQ__Quote__c> testQuotes;
            testQuotes = PMC_TestUtilityClass.createCPQQuotes(1,lstOppty,lstCont);
            List<SBQQ__Quote__c> testQuote = [SELECT Id, PMC_CPQ_AccountCountry__c FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];  
            testQuote[0].PMC_CPQ_AccountCountry__c='United States' ;
            update testQuote;

            List<Product2> lstProducts = [SELECT Id FROM Product2 WITH SECURITY_ENFORCED LIMIT 2];
            SBQQ__QuoteLine__c testQuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.get(0).Id,  SBQQ__Product__c = lstProducts.get(0).Id,PMC_CPQ_Nitrogen__c=9,PMC_CPQ_ContractType__c='Priced',PMC_CPQ_CropType__c='Alfalfa',PMC_CPQ_VCOQuotation__c=true,PMC_CPQ_QuoteRecordType__c='Domestic SA');
            insert testQuoteLine1;

            sbaa__Approver__c testApprover = new sbaa__Approver__c(
                Name = lstUser[0].Name,
                sbaa__User__c= lstUser[0].Id
            );
            
            insert testApprover;

            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true,
                Name = 'GroupEmailTemp',
                DeveloperName = 'Group_Email_Temp',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId()
            );
            insert validEmailTemplate;        

            sbaa__EmailTemplate__c testEmailTemplate = new sbaa__EmailTemplate__c(
                Name = 'TestTemplate',
                sbaa__TemplateId__c = validEmailTemplate.id
            );
            insert testEmailTemplate;
 
            sbaa__ApprovalRule__c testApprovalRule = new sbaa__ApprovalRule__c(
                Name='TestApprovalRule',
                sbaa__ApprovalTemplate__c=testEmailTemplate.id,
                sbaa__TargetObject__c='SBQQ__Quote__c'
                
            );
            insert testApprovalRule;
 
            sbaa__Approval__c testApproval = new sbaa__Approval__c(
                sbaa__Approver__c = testApprover.Id,
                sbaa__ApprovalStep__c = 1,
                sbaa__RecordField__c = 'Quote__c',
                sbaa__Rule__c = testApprovalRule.Id,
                Quote__c = testQuotes[0].Id
                
            );
            insert testApproval;

            Test.startTest();

            PMC_CPQ_PriceConfirmationController controllerClass = new PMC_CPQ_PriceConfirmationController();
            controllerClass.quoteId = testQuotes[0].Id;
            sbaa__Approval__c approval = controllerClass.approvalRecord;
            List<OrderItem> orderList = controllerClass.itemList;

            Test.stopTest();

        }
    }

    @isTest
    private static void shouldNotRetrieveData() {
        
        Test.startTest();
        PMC_CPQ_PriceConfirmationController controllerClass = new PMC_CPQ_PriceConfirmationController();
        controllerClass.quoteId = null;
        sbaa__Approval__c approval = controllerClass.approvalRecord;
        List<OrderItem> orderList = controllerClass.itemList;
        Test.stopTest();

    }


}