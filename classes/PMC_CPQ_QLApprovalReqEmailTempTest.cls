@isTest
public class PMC_CPQ_QLApprovalReqEmailTempTest {

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
            OrderItem objOrderProducts = new OrderItem();
            
            objOrderProducts.Product2Id = prod[0].id;
            objOrderProducts.OrderId = lstOrders[0].id;
            objOrderProducts.Quantity = 2;
            //objOrderProducts.PMC_CPQ_ListPrice__c = 180;
            objOrderProducts.UnitPrice = 0;
            objOrderProducts.ListPrice = 0;
            objOrderProducts.PMC_CPQ_FinalAgreedPrice__c = 1;
            objOrderProducts.PricebookEntryId = pbe.Id;
            insert objOrderProducts;
        }
    }
    
    @isTest
    static void testGetOLines() {
        // Retrieve the OrderItem created in the setup
        OrderItem testOrderItem = [SELECT Id FROM OrderItem LIMIT 1];

        // Instantiate the class to be tested
        PMC_CPQ_QLApprovalReqEmailTempClass emailTempClass = new PMC_CPQ_QLApprovalReqEmailTempClass();
        emailTempClass.orderItemId = testOrderItem.Id;

        // Call the oLines property to trigger the query
        List<OrderItem> oLines = emailTempClass.oLines;

        // Assert that the oLines list is not null and contains the expected OrderItem
        System.assertNotEquals(null, oLines, 'oLines should not be null');
        System.assertEquals(1, oLines.size(), 'oLines should contain one OrderItem');
        System.assertEquals(testOrderItem.Id, oLines[0].Id, 'The OrderItem Id should match the one created in setup');
    }

    @isTest
    static void testGetOLinesWithNullOrderItemId() {
        // Instantiate the class to be tested without setting orderItemId
        PMC_CPQ_QLApprovalReqEmailTempClass emailTempClass = new PMC_CPQ_QLApprovalReqEmailTempClass();

        // Call the oLines property to trigger the query
        List<OrderItem> oLines = emailTempClass.oLines;

        // Assert that the oLines list is null since orderItemId is not set
        System.assertEquals(null, oLines, 'oLines should be null when orderItemId is not set');
    }
}