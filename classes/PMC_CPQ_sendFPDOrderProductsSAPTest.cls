/*
* This class is the test class for PMC_CPQ_sendFPDOrderProductsSAPClass.
* @author Ridhu Varshini M
* @storynumber GDASF-9421
*/
@isTest(seeAllData=false)
public with sharing class PMC_CPQ_sendFPDOrderProductsSAPTest {
    /*
* This Method will be used to setup the data for the test class execution.
*/    
    @TestSetup
    private static void testSetup(){
        List<String>lstPermissionNames = New List<String>{'PMC_SLS_Permission_Set_Group'};
        User objUserAM = PMC_CPQ_CPIRemoteCalloutUtilityTest.createCPQTestUser('Sales User',lstPermissionNames);
        List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
        User objUserAdmin = [select Id from User where LastName = 'System Administrator Test' LIMIT 1 ];
        System.runAs(objUserAdmin){ 
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
        lstOrders[0].OwnerId = objUserAM.Id;
        update lstOrders;
        List<Contract> lstContract = PMC_TestUtilityClass.createContract(lstAcct,lstOpty);
        SBQQ__Subscription__c objSub = new SBQQ__Subscription__c();
        objSub.SBQQ__Contract__c = lstContract[0].Id;
        objSub.SBQQ__Account__c = lstAcct[0].Id;
        objSub.SBQQ__Quantity__c = 1;
        objSub.SBQQ__QuoteLine__c = objQL1.Id;
        insert objSub;
        OrderItem objOP = new OrderItem(OrderId = lstOrders[0].Id, SBQQ__QuoteLine__c = objQL1.Id, SBQQ__Subscription__c =objSub.Id, Product2Id = lstProduct.get(0).Id, Quantity=1, ListPrice=100, PMC_CPQ_ListPrice__c = 100, UnitPrice = 100,PMC_CPQ_ContractType__c = 'FPD', PMC_CPQ_ShipTo__c = lstOpty.get(0).AccountId);
        insert objOP;
        }
    }
    
    /* 
* This method will be used to cover the sendOrderProductsToSAP and getPriceFromPriceFX methods of the class PMC_CPQ_sendFPDOrderProductsSAPClass.
*/   
    
    @isTest
    public static void testSendToFPD() {
        OrderItem objOP = [select Id,OrderItemNumber,Order.OrderNumber, SBQQ__Contract__r.ContractNumber, Order.PMC_CPQ_PO__c,Order.Account.Name,PMC_CPQ_ShipTo__r.Name,Quantity,Product2.Name,PMC_CPQ_PricingDate__c,ListPrice, PMC_CPQ_Discounts__c, PMC_CPQ_EstFreightPrice__c, PMC_CPQ_FPDPricefromPriceFx__c,PMC_CPQ_FinalAgreedPrice__c, PMC_CPQ_OrderLineStatus__c from OrderItem LIMIT 1];
        
        PMC_CPQ_OrderProductDetailsWrapperClass opWrapper = new PMC_CPQ_OrderProductDetailsWrapperClass();
        opWrapper.customId = objOP.Id;
        opWrapper.orderLine = objOP.OrderItemNumber;
        opWrapper.accountName = objOP.Order.Account.Name;
        opWrapper.productName = objOP.Product2.Name;
        opWrapper.quantity = objOP.Quantity;
        opWrapper.priceByDate = objOP.PMC_CPQ_PricingDate__c;
        opWrapper.fpdPrice = objOP.PMC_CPQ_FPDPricefromPriceFx__c;
        opWrapper.finalAgreedPrice = 700.5;
        opWrapper.status = objOP.PMC_CPQ_OrderLineStatus__c;
        List<PMC_CPQ_OrderProductDetailsWrapperClass> opDetailsWrapperList = new List<PMC_CPQ_OrderProductDetailsWrapperClass>();
        opDetailsWrapperList.add(opWrapper);
        User objUser = [select Id from User where LastName = 'Sales User Test' LIMIT 1 ];
         system.runAs(objUser){
        Test.startTest();
        String jsonString = JSON.serialize(opDetailsWrapperList);
        PMC_CPQ_sendFPDOrderProductsSAPClass.saveOPFromUI(jsonString);
        PMC_CPQ_sendFPDOrderProductsSAPClass.getPriceFromPriceFX(jsonString);
        String sendFPD = PMC_CPQ_sendFPDOrderProductsSAPClass.sendFPDPriceFXURL();
        Assert.isNotNull(sendFPD,'Endpoint String should not be null');
        Assert.isNotNull(opDetailsWrapperList,'opDetailsWrapperList should not be null');
        Test.stopTest();
         }
    }
}