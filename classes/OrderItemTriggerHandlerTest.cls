@isTest
public class OrderItemTriggerHandlerTest {

    @testSetup  
    static void setup(){
        List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
        User objUser = [select Id from User where LastName = 'System Administrator Test' LIMIT 1 ];
 		System.runAs(objUser){  
            List<Product2> prod = PMC_TestUtilityClass.createProduct(1,'PMC_CPQ_Brazil');
            prod[0].PMC_CPQ_SAPProductCode__c = '';
            update prod[0];
            //Instantiate the Pricebook2 record with StandardPricebookId
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            
            //Execute an update DML on the Pricebook2 record, to make IsStandard to true
            Update standardPricebook;
            
            lstOrders[0].Pricebook2Id = standardPricebook.Id;
            lstOrders[0].CurrencyIsoCode = 'USD';
            update lstOrders;
            //Create the PricebookEntry
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = prod[0].Id,
                UnitPrice = 0,
                // PMC_CPQ_ProductSKUCode__c = prod[0].PMC_CPQ_SAPProductCode__c,
                CurrencyIsoCode = lstOrders[0].CurrencyIsoCode,
                IsActive = true
            );
            Insert pbe;
            OrderItem orderItemRecord = new OrderItem();
            
            orderItemRecord.Product2Id = prod[0].id;
            orderItemRecord.OrderId = lstOrders[0].id;
            orderItemRecord.Quantity = 2;
            orderItemRecord.PMC_CPQ_ListPrice__c = 180;
            orderItemRecord.UnitPrice = 0;
            orderItemRecord.ListPrice = 0;
            orderItemRecord.PMC_CPQ_FinalAgreedPrice__c = 1;
            orderItemRecord.ApprovalStatus__c = 'Under Revision';
            orderItemRecord.PricebookEntryId = pbe.Id;
            insert orderItemRecord;
        }
    }
    
    
    @isTest
    static void testAfterUpdateApprovalStatusNotChanged() {
        // Retrieve the test OrderItem
        OrderItem testOrderItem = [SELECT Id, ApprovalStatus__c FROM OrderItem LIMIT 1];

        // Update a different field (not ApprovalStatus__c)
        testOrderItem.Quantity = 2;

        // Verify that the PMC_CPQ_FPDActionClass was not enqueued
        Test.startTest();
        update testOrderItem;
        Test.stopTest();

        // Assert that no job was enqueued
        System.assertEquals(0, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'], 'No job should have been enqueued.');
    }
    
    
    @isTest
    static void testAfterUpdateApprovalStatusChanged() {
        // Retrieve the test OrderItem
        OrderItem testOrderItem = [SELECT Id, ApprovalStatus__c FROM OrderItem WHERE ApprovalStatus__c = 'Under Revision' LIMIT 1];

        // Update the ApprovalStatus__c to 'Approved'
        testOrderItem.ApprovalStatus__c = 'Approved';

        // Verify that the PMC_CPQ_FPDActionClass was not enqueued
        Test.startTest();
        update testOrderItem;
        Test.stopTest();

        // Assert that no job was enqueued
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'], '1 job should have been enqueued.');
    }

    @isTest
    static void testAfterUpdateBypassTriggerLogic() {
        // Bypass the trigger logic
        OrderItemTriggerHandler.boolBypassTriggerLogic = true;

        // Retrieve the test OrderItem
        OrderItem testOrderItem = [SELECT Id, ApprovalStatus__c FROM OrderItem LIMIT 1];

        // Update the ApprovalStatus__c to 'Approved'
        testOrderItem.ApprovalStatus__c = 'Approved';

        // Verify that the PMC_CPQ_FPDActionClass was not enqueued
        Test.startTest();
        update testOrderItem;
        Test.stopTest();

        // Assert that no job was enqueued
        System.assertEquals(0, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'], 'No job should have been enqueued when trigger logic is bypassed.');
    }
}