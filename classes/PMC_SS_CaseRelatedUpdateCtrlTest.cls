/**
 * @description This test class will be used to cover all the methods of PMC_SS_CaseRelatedUpdateCtrl
 * @author Sayali Shinde
 */

@isTest(seeAllData = false)
public class PMC_SS_CaseRelatedUpdateCtrlTest {

    /**
    * @description This Method will be used to setup the test data for the test class execution.
    */
    
    @testsetup
    private static void setup() {
        
        Profile objUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User objSystemAdminUser;
        if(objUserProfile != null) {
            List<User> lstUser = PMC_TestUtilityClass.createUser(1);
            for(User objUser : lstUser) {
                objUser.ProfileId = objUserProfile.Id;
                objUser.isActive = true;
            }
            
            insert lstUser;
            objSystemAdminUser = lstUser[0];
        }
        BusinessHours objBusinessHrs = [SELECT Id, Name FROM BusinessHours WHERE isDefault = True AND IsActive = True];

        Account objAccount = PMC_TestUtilityClass.createAccount('Mike Rau', 'PMC_SS_Prospect');
        Contact objContact = PMC_TestUtilityClass.createContact(1, '')[0];
        Opportunity objOpportunity =  PMC_TestUtilityClass.createOpportunity(1, '')[0];
        Contract objContract = PMC_TestUtilityClass.createContract(new List<Account>{objAccount}, new List<Opportunity>{objOpportunity})[0];
        Schema.Location objLocation = PMC_TestUtilityClass.createLocation('Test Schema.Location');
        PMC_CPQ_ProductLocation__c objProductLocation = PMC_TestUtilityClass.createProductLocation('Test Product Location', objLocation);
        
        Order objOrder = PMC_TestUtilityClass.createOrders(1, new List<Account>{objAccount})[0];
        objOrder.PMC_CPQ_ShipToAccount__c = objAccount.Id;
        objOrder.PMC_CPQ_SoldToAccount__c = objAccount.Id;
        objOrder.ContractId = objContract.Id;
		update objOrder;
        
        OrderItem objOrderItem = PMC_TestUtilityClass.createOrderProducts(1, new List<Order>{objOrder})[0];
        objOrderItem.UnitPrice = 50;
        objOrderItem.PMC_CPQ_ProductLocation__c = objProductLocation.Id;
        update objOrderItem;
        
        Shipment objShipment = PMC_TestUtilityClass.createDelivery('Test Shipment Name', objOrder);
        PMC_TestUtilityClass.createDeliveryItem(objShipment, objOrderItem);
        PMC_TestUtilityClass.createInvoice(objShipment, objOrder, objContact);
        
        Case objCase = PMC_TestUtilityClass.createCase(objBusinessHrs.Id, objAccount.Id, objSystemAdminUser.Id);
        insert objCase;
    }
    
    /**
    * @description This Method will be used to cover GetOrderItems from PMC_SS_CaseRelatedUpdateCtrl
    */
    @isTest
    private static void testGetOrderItems() {
        Test.startTest();
        
        User objUser = [SELECT Id, Name FROM User  WITH SECURITY_ENFORCED LIMIT 1];
        Order objOrder = [SELECT Id, Name FROM Order WHERE Name = 'Test Order 0' WITH SECURITY_ENFORCED LIMIT 1];
        
        if(objUser != null && objOrder != null) {
            System.runAs(objUser) {
                PMC_SS_CaseRelatedUpdateCtrl.OrderDetailsWrapper objOrderDetailsWrapper = PMC_SS_CaseRelatedUpdateCtrl.getOrderItems(objOrder.Id);
                System.assertEquals(objOrderDetailsWrapper.objOrder.Id, objOrder.Id, 'Order has been updated on Wrapper');
            }
        }
        
        Test.stopTest();
    }
    
    /**
    * @description This Method will be used to cover GetDeliveryItems from PMC_SS_CaseRelatedUpdateCtrl
    */
    @isTest
    private static void testGetDeliveryItems() {
        Test.startTest();
        
        User objUser = [SELECT Id, Name FROM User  WITH SECURITY_ENFORCED LIMIT 1];
        OrderItem objOrderItem = [SELECT Id, Order.Name FROM OrderItem WHERE Order.Name = 'Test Order 0' WITH SECURITY_ENFORCED LIMIT 1];
        
        if(objUser != null && objOrderItem != null) {
            System.runAs(objUser) {
                List<ShipmentItem> lstShipmentItems = PMC_SS_CaseRelatedUpdateCtrl.getDeliveryItems(objOrderItem.Id);
                System.assertEquals(lstShipmentItems.size(), 1, 'Shipment Item Fetched');
            }
        }
        
        Test.stopTest();
    }
    
    /**
    * @description This Method will be used to cover UpdateCaseRecord from PMC_SS_CaseRelatedUpdateCtrl
    */
    @isTest
    private static void testUpdateCaseRecord() {
        Test.startTest();
        
        User objUser = [SELECT Id, Name FROM User  WITH SECURITY_ENFORCED LIMIT 1];
        Case objCase = [SELECT Id, Subject, Status FROM Case WHERE Subject = 'Test Subject' WITH SECURITY_ENFORCED LIMIT 1];
        
        Account objAccount = [SELECT Id, Name FROM Account WHERE Name = 'Mike Rau' WITH SECURITY_ENFORCED LIMIT 1];
        Order objOrder = [SELECT Id, Name FROM Order WHERE Name = 'Test Order 0' WITH SECURITY_ENFORCED LIMIT 1];
        OrderItem objOrderItem = [SELECT Id, Order.Name FROM OrderItem WHERE Order.Name = 'Test Order 0' WITH SECURITY_ENFORCED LIMIT 1];
		Contract objContract = [SELECT Id, Name, AccountId FROM Contract WHERE AccountId =: objAccount.Id WITH SECURITY_ENFORCED LIMIT 1];
        Contact objContact = [SELECT Id, LastName FROM Contact WHERE LastName = 'test Doe0' WITH SECURITY_ENFORCED LIMIT 1];
        PMC_CPQ_Invoice__c objInvoice = [SELECT Id, PMC_CPQ_Order__c, PMC_CPQ_OriginalAmount__c FROM PMC_CPQ_Invoice__c WHERE PMC_CPQ_Order__c =: objOrder.Id WITH SECURITY_ENFORCED LIMIT 1];
        
        System.runAs(objUser) {
            PMC_SS_CaseDetailsWrapper objCaseDetailsWrapper = new PMC_SS_CaseDetailsWrapper();
            objCaseDetailsWrapper.caseId = objCase.Id;
            objCaseDetailsWrapper.orderId = objOrder.Id;
            objCaseDetailsWrapper.orderItemId = objOrderItem.Id;
            objCaseDetailsWrapper.invoiceId = objInvoice.Id;
            objCaseDetailsWrapper.actionReason = 'Cancel';
            objCaseDetailsWrapper.accountId = objAccount.Id;
            objCaseDetailsWrapper.contactId = objContact.Id;
            objCaseDetailsWrapper.contractId = objContract.Id;
			objCaseDetailsWrapper.originalInvoiceAmount = objInvoice.PMC_CPQ_OriginalAmount__c;
            objCaseDetailsWrapper.invoiceDifference = 900.0;
			objCaseDetailsWrapper.cancelAmount = 100.0;
            objCaseDetailsWrapper.atFaultParty = 'Service';
            objCaseDetailsWrapper.paymentRequestType = 'Wire';
            
            PMC_SS_CaseRelatedUpdateCtrl.updateCaseRecord(objCaseDetailsWrapper);
            
            objCaseDetailsWrapper.actionReason = 'Rebill';
            PMC_SS_CaseRelatedUpdateCtrl.updateCaseRecord(objCaseDetailsWrapper);

            objCaseDetailsWrapper.actionReason = 'Credit';
            objCaseDetailsWrapper.soldToAccountId = objAccount.Id;
            objCaseDetailsWrapper.shipToAccountId = objAccount.Id;
            objCaseDetailsWrapper.creditDebitAmount = 100.0;
            objCaseDetailsWrapper.plantId = 'plantId';
            PMC_SS_CaseRelatedUpdateCtrl.updateCaseRecord(objCaseDetailsWrapper);

            objCaseDetailsWrapper.actionReason = 'Debit';
            PMC_SS_CaseRelatedUpdateCtrl.updateCaseRecord(objCaseDetailsWrapper);

            objCaseDetailsWrapper.actionReason = 'Return';
			objCaseDetailsWrapper.vehicleId = 'Test 123';
            objCaseDetailsWrapper.modeOfTransportation = 'Rail';
            objCaseDetailsWrapper.pgiDate = '2023-07-31';
            Case objCaseResult4 = PMC_SS_CaseRelatedUpdateCtrl.updateCaseRecord(objCaseDetailsWrapper);

            System.assertEquals(objCaseResult4.Id, objCase.Id, 'Case Matched');
        }
        
        Test.stopTest();
    }
    
    /**
    * @description This Method will be used to cover GetPickListValues from PMC_SS_CaseRelatedUpdateCtrl
    */
    @isTest
    private static void testGetPickListValues() {
        Test.startTest();
        
        User objUser = [SELECT Id, Name FROM User  WITH SECURITY_ENFORCED LIMIT 1];
        
        System.runAs(objUser) {
            List<Map<String, String>> lstMapPicklistVal = PMC_SS_CaseRelatedUpdateCtrl.getPickListValues('Case', 'PMC_SS_PaymentRequestType__c');
            System.assertNotEquals(lstMapPicklistVal.size(), 0, 'Picklist values fetched');
        }
        
        Test.stopTest();
    }
}