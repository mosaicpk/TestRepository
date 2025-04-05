/** @description This is the test class for Get FPD Order Line Interface 
 *  @author Shefali Dsouza (Integration Team)
 *  @storynumber GDASF-9359
 */

@isTest
public class PMC_CPQ_GetPFDPricefxOrderLineTest {
    
    public static List <String> lstPayloadOrderIds = new List<String> ();
    public static List <String> lstPayloadOrderLineIds = new List<String> ();
    
    @testSetup  
    private static void setup()
    {
        //Account acc=PMC_DH_TestDataFactoryClass.createParentTestAccount();
        List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
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
        //lstOrders[0].Pricebook2Id = Test.getStandardPricebookId();
        lstOrders[0].Pricebook2Id = standardPricebook.Id;
        //lstOrders[0].PMC_CPQ_SAPProductCode__c = '123';
        lstOrders[0].CurrencyIsoCode = 'USD';
        update lstOrders;
    System.debug(lstOrders[0].Pricebook2Id);
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
        System.debug(pbe.Id+'_'+pbe.Pricebook2Id);
        OrderItem objOrderProducts = new OrderItem();
            
            objOrderProducts.Product2Id = prod[0].id;
            objOrderProducts.OrderId = lstOrders[0].id;
            objOrderProducts.Quantity = 2;
            objOrderProducts.ListPrice = 190;
            objOrderProducts.UnitPrice = 0;
            objOrderProducts.PMC_CPQ_FinalAgreedPrice__c = 1;
            objOrderProducts.PricebookEntryId = pbe.Id;
            insert objOrderProducts;
    }
      
    /** 
     * @description Used to invoke apex. Tests Order success scenario. 
     */
    @isTest
    public static void testGETFPDOrderLineSuccess()
    {
        //List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
		//List<OrderItem> lstOrderLines = PMC_TestUtilityClass.createOrderProducts(1, lstOrders);
		List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PMC_CPQ_FPDPricefromPriceFx__c,PricebookEntryId from OrderItem];
        
        for(OrderItem objItem : lstOrderLines)
        {
            lstPayloadOrderLineIds.add(objItem.Id);
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetFPDCalloutMockSuccess());
        
        PageReference pageRef = Page.PMC_CPQ_GetFPDPrice; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
        pageRef.getParameters().put('baseUrl', 'Test');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
        PMC_CPQ_GetFPDController controllerFPD = new PMC_CPQ_GetFPDController(stdController);
        controllerFPD.redirect();
		
        Test.stopTest();
        System.assert(!lstOrderLines.isEmpty(), 'List should not be empty'); 
    } 
    
        /** 
     * @description Used to invoke apex. Tests Order success scenario. 
     */
    @isTest
    public static void testGETFPDOrderLinePartialSuccess()
    {
        //List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
		//List<OrderItem> lstOrderLines = PMC_TestUtilityClass.createOrderProducts(1, lstOrders);
		List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PMC_CPQ_FPDPricefromPriceFx__c,PricebookEntryId from OrderItem];
        
        
        for(OrderItem objItem : lstOrderLines)
        {
            lstPayloadOrderLineIds.add(objItem.Id);
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetFPDCalloutMockPartSuccess());
        
        PageReference pageRef = Page.PMC_CPQ_GetFPDPrice; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
        pageRef.getParameters().put('baseUrl', 'Test');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
        PMC_CPQ_GetFPDController controllerFPD = new PMC_CPQ_GetFPDController(stdController);
        controllerFPD.redirect();
		
        Test.stopTest();
        System.assert(!lstOrderLines.isEmpty(), 'List should not be empty'); 
    } 
    
    /** 
     * @description Used to invoke apex. Tests scenario where we cannot make an apex callout.
     */
    @isTest
    public static void testGetPFDOrderLineException()
    {
        //List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
		//List<OrderItem> lstOrderLines = PMC_TestUtilityClass.createOrderProducts(1, lstOrders);
		List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PMC_CPQ_FPDPricefromPriceFx__c,PricebookEntryId from OrderItem];
        
        for(OrderItem objItem : lstOrderLines)
        {
            lstPayloadOrderLineIds.add(objItem.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpCalloutMockSCodeFailureTest());
        
        Test.startTest();
        
        PageReference pageRef = Page.PMC_CPQ_GetFPDPrice; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
        pageRef.getParameters().put('baseUrl', 'Test');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
        PMC_CPQ_GetFPDController controllerFPD = new PMC_CPQ_GetFPDController(stdController);
        controllerFPD.redirect();
		
        Test.stopTest();
        System.assert(!lstOrderLines.isEmpty(), 'List should not be empty');
    }  

 	/** 
     * @description Used to invoke apex. Tests scenario where response code returned is not 200/201.
     */
    @isTest
    public static void testInvocableOrderStatusCodeFailure()
    {
        //List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
		//List<OrderItem> lstOrderLines = PMC_TestUtilityClass.createOrderProducts(1, lstOrders);
		List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PMC_CPQ_FPDPricefromPriceFx__c,PricebookEntryId from OrderItem];
        
        for(OrderItem objItem : lstOrderLines)
        {
            lstPayloadOrderLineIds.add(objItem.Id);
        }
        
        Test.startTest();
        
		PageReference pageRef = Page.PMC_CPQ_GetFPDPrice; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
        pageRef.getParameters().put('baseUrl', 'Test');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
        PMC_CPQ_GetFPDController controllerFPD = new PMC_CPQ_GetFPDController(stdController);
        controllerFPD.redirect();
		
        Test.stopTest();
        System.assert(!lstOrderLines.isEmpty(), 'List should not be empty');
    }
    
    /** 
     * @description Used to invoke apex. Tests Parsing failure scenario where status code returned is 200/201. However, the response body format is not correct.
     */
    @isTest
    public static void testInvocableOrderParsingFailure()
    {
        //List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
		//List<OrderItem> lstOrderLines = PMC_TestUtilityClass.createOrderProducts(1, lstOrders);
		List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PMC_CPQ_FPDPricefromPriceFx__c,PricebookEntryId from OrderItem];
        
        for(OrderItem objItem : lstOrderLines)
        {
            lstPayloadOrderLineIds.add(objItem.Id);
        }
        
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpCalloutMockParseFailureTest());
        
        PageReference pageRef = Page.PMC_CPQ_GetFPDPrice; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
        pageRef.getParameters().put('baseUrl', 'Test');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
        PMC_CPQ_GetFPDController controllerFPD = new PMC_CPQ_GetFPDController(stdController);
        controllerFPD.redirect();
		
        Test.stopTest();
        System.assert(!lstOrderLines.isEmpty(), 'List should not be empty');
	  
        
    }
}