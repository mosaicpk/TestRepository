/*
* This class is the test class for PMC_CPQ_FPDMassUpdateController.
* @author Ridhu Varshini M
* @storynumber GDASF-12110
*/
@isTest(seeAllData=false)
public with sharing class PMC_CPQ_FPDMassUpdateControllerTest {
    
    /*
* This Method will be used to setup the data for the test class execution.
*/    
    @TestSetup
    private static void testSetup(){
        List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
        User objU = [select Id from User where LastName = 'System Administrator Test' LIMIT 1 ];
        List<String>lstPermissionNames = New List<String>{'PMC_SLS_Permission_Set_Group'};
        User objUserAM = PMC_CPQ_CPIRemoteCalloutUtilityTest.createCPQTestUser('Sales User',lstPermissionNames);
        System.runAs(objU){ 
        List<Opportunity> lstOpty = PMC_TestUtilityClass.createOpportunity(1,'Master');
        List<Account> lstAcct = [select Id,PMC_SS_AccountExternalID__c,PMC_SS_SAPCustomerNumber__c from Account where Id =: lstOpty[0].AccountId];
        lstAcct[0].PMC_SS_AccountExternalID__c = '2378651345';
        lstAcct[0].PMC_SS_SAPCustomerNumber__c = '2378651345';
        update lstAcct;
        List<Contact> lstCont = PMC_TestUtilityClass.createContact(1,'Master');
        List<Product2> lstProduct = PMC_TestUtilityClass.createProduct(1,'PMC_CPQ_Brazil');
        lstProduct[0].PMC_CPQ_SAPProductCode__c = '';
        update lstProduct;
        List<SBQQ__Quote__c> lstQuotes = PMC_TestUtilityClass.createCPQQuotes(1,lstOpty , lstCont);
        SBQQ__QuoteLine__c objQL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = lstQuotes.get(0).Id,  SBQQ__Product__c = lstProduct.get(0).Id, PMC_CPQ_QuoteRecordType__c = 'Domestic NA', PMC_CPQ_ContractType__c = 'FPD');
        insert objQL1;
        lstOrders[0].PMC_CPQ_SAPOrderNumber__c = '30008758';
        lstOrders[0].OwnerId = objUserAM.Id;
        update lstOrders;
        List<Contract> lstContract = PMC_TestUtilityClass.createContract(lstAcct,lstOpty);
        SBQQ__Subscription__c objSub = new SBQQ__Subscription__c();
        objSub.SBQQ__Contract__c = lstContract[0].Id;
        objSub.SBQQ__Account__c = lstAcct[0].Id;
        objSub.SBQQ__Quantity__c = 1;
        objSub.SBQQ__QuoteLine__c = objQL1.Id;
        insert objSub;
        OrderItem objOP = new OrderItem(OrderId = lstOrders[0].Id, SBQQ__QuoteLine__c = objQL1.Id,SBQQ__Subscription__c =objSub.Id, Product2Id = lstProduct.get(0).Id, Quantity=1, ListPrice=100, PMC_CPQ_ListPrice__c = 100, UnitPrice = 100,PMC_CPQ_ContractType__c = 'FPD', PMC_CPQ_ShipTo__c = lstOpty.get(0).AccountId);
        insert objOP;
        }
    }
    /* 
* This method will be used to cover the getOPDetails and getDefaultOrderLines methods of the class PMC_CPQ_FPDMassUpdateController.
*/     
    @isTest
    public static void testFPD() {
        Test.startTest();
        Opportunity objOp = [select Id, AccountId from Opportunity LIMIT 1];
        Order objOrder = [select Id,PMC_CPQ_SAPOrderNumber__c, OwnerId from Order LIMIT 1];
        User objUser = [select Id from User where Id =: objOrder.OwnerId LIMIT 1];
        Product2 objProd = [select Id from Product2];
        OrderItem objOL = [select Id,PMC_CPQ_ShipTo__c from OrderItem LIMIT 1];
        system.runAs(objUser){
            PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams paramsWrap = new PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams();
            paramsWrap.acctId = objOp.AccountId;
            paramsWrap.userId = objUser.Id;
            paramsWrap.prodId = objProd.Id;
            paramsWrap.shipId = objOL.PMC_CPQ_ShipTo__c;
            paramsWrap.ordId = objOrder.Id;
            String jsonString = JSON.serialize(paramsWrap);
            
            PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams paramsWrap1 = new PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams();
            paramsWrap1.userId = objUser.Id;
            String jsonString1 = JSON.serialize(paramsWrap1);
            
            PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams paramsWrap2 = new PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams();
            paramsWrap2.acctId = objOp.AccountId;
            String jsonString2 = JSON.serialize(paramsWrap2);
            
            PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams paramsWrap3 = new PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams();
            String jsonString3 = JSON.serialize(paramsWrap3);
            
            PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams paramsWrap4 = new PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams();
            paramsWrap4.ordId = objOrder.Id;
            String jsonString4 = JSON.serialize(paramsWrap4);
            String result7;
            try{
            PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams paramsWrap5 = new PMC_CPQ_FPDMassUpdateController.GetOPDetailsParams();
            paramsWrap5.ordId = objOrder.PMC_CPQ_SAPOrderNumber__c;
            String jsonString5 = JSON.serialize(paramsWrap5);
            result7 = PMC_CPQ_FPDMassUpdateController.getOPDetails(jsonString5);
            }
            catch(Exception e){
                PMC_ErrorLogClass.processException(e);
            }
            
            String result1 = PMC_CPQ_FPDMassUpdateController.getOPDetails(jsonString);
            String result2 = PMC_CPQ_FPDMassUpdateController.getOPDetails(jsonString1);
            String result3 = PMC_CPQ_FPDMassUpdateController.getOPDetails(jsonString2);
            String result4 = PMC_CPQ_FPDMassUpdateController.getOPDetails(jsonString3);
            String result5 = PMC_CPQ_FPDMassUpdateController.getDefaultOrderLines();
            String result6 = PMC_CPQ_FPDMassUpdateController.getOPDetails(jsonString4);
            Assert.isNotNull(result1,'Result should not be null');
            Assert.isNotNull(result2,'Result should not be null');
            Assert.isNotNull(result3,'Result should not be null');
            Assert.isNotNull(result4,'Result should not be null');
            Assert.isNotNull(result5,'Result should not be null');
            Assert.isNotNull(result6,'Result should not be null');
            Assert.isNull(result7,'Result should be null');
        }
        Test.stopTest();
    }
}