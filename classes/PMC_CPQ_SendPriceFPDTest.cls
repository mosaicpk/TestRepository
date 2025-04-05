/** @description Test Class for Send Final Price to SAP on Order Detail Page
*  @creator Prakhar
*  @storynumber GDASF-12490
*/
@isTest
public with sharing class PMC_CPQ_SendPriceFPDTest {
    public static List <String> lstPayloadOrderIds = new List<String> ();
    public static List <String> lstPayloadOrderLineIds = new List<String> ();
    
    @testSetup  
    private static void setup()
    {
        List<String>lstPermissionNames = New List<String>{'PMC_SLS_Permission_Set_Group'};
        User objUserAM = PMC_CPQ_CPIRemoteCalloutUtilityTest.createCPQTestUser('Sales User',lstPermissionNames);
    
        List<Order> lstOrders = PMC_CPQ_OrderIntegrationTest.createOrders(1);
        User objSystemAdminUser = [select Id from User where LastName = 'System Administrator Test' LIMIT 1 ];
        
        System.runAs(objSystemAdminUser){ 
            //Account acc=PMC_DH_TestDataFactoryClass.createParentTestAccount();
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
            lstOrders[0].OwnerId = objUserAM.Id;
            lstOrders[0].PMC_CPQ_IsFPD__c = true;
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
            objOrderProducts.ListPrice = 0;
            objOrderProducts.UnitPrice = 5;
            objOrderProducts.PMC_CPQ_ListPrice__c = 10;
            objOrderProducts.PMC_CPQ_FPDPricefromPriceFx__c = 11;
            objOrderProducts.PMC_CPQ_FinalAgreedPrice__c = 12;
            objOrderProducts.PricebookEntryId = pbe.Id;
            insert objOrderProducts;
        }
    }
    
    @isTest
    public static void testSendPriceFPDSuccess(){
        List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, PMC_CPQ_FPDPricefromPriceFx__c, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PricebookEntryId from OrderItem];
            for(OrderItem objItem : lstOrderLines)
            {
                lstPayloadOrderLineIds.add(objItem.Id);
            }
        
        User objUserAM = [select Id from User where LastName = 'Sales User Test' LIMIT 1 ];
        System.runAs(objUserAM){ 
            //List<Order> lstOrders = [select id, Name, AccountId, EffectiveDate, Status, Pricebook2Id from order];
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpSendFPDSuccess(lstOrderLines[0].Id));
            
            PageReference pageRef = Page.PMC_CPQ_SendFPD; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
            PMC_CPQ_FPDActionClass controllerFPD = new PMC_CPQ_FPDActionClass(stdController);
            controllerFPD.redirect();
            
            Test.stopTest();
            System.assert(!lstOrderLines.isEmpty(), 'List should not be empty'); 
        }
    }
    @isTest
    public static void testSendPriceFPDGoBack(){
        List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, PMC_CPQ_FPDPricefromPriceFx__c, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PricebookEntryId from OrderItem];
            for(OrderItem objItem : lstOrderLines)
            {
                lstPayloadOrderLineIds.add(objItem.Id);
            }
        
        User objUserAM = [select Id from User where LastName = 'Sales User Test' LIMIT 1 ];
        System.runAs(objUserAM){ 
            //List<Order> lstOrders = [select id, Name, AccountId, EffectiveDate, Status, Pricebook2Id from order];
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpSendFPDSuccess(lstOrderLines[0].Id));
            
            PageReference pageRef = Page.PMC_CPQ_SendFPD; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
            PMC_CPQ_FPDActionClass controllerFPD = new PMC_CPQ_FPDActionClass(stdController);
            controllerFPD.goBack();
            
            Test.stopTest();
            System.assert(!lstOrderLines.isEmpty(), 'List should not be empty'); 
        }
    }
    @isTest
    public static void testSendPriceFPDError(){
        List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, PMC_CPQ_FPDPricefromPriceFx__c, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PricebookEntryId from OrderItem];
            for(OrderItem objItem : lstOrderLines)
            {
                lstPayloadOrderLineIds.add(objItem.Id);
            }
        
        User objUserAM = [select Id from User where LastName = 'Sales User Test' LIMIT 1 ];
        System.runAs(objUserAM){ 
            //List<Order> lstOrders = [select id, Name, AccountId, EffectiveDate, Status, Pricebook2Id from order];
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpSendFPDError());
            
            PageReference pageRef = Page.PMC_CPQ_SendFPD; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
            PMC_CPQ_FPDActionClass controllerFPD = new PMC_CPQ_FPDActionClass(stdController);
            controllerFPD.redirect();
            
            Test.stopTest();
            System.assert(!lstOrderLines.isEmpty(), 'List should not be empty'); 
        }
    }
    @isTest
    public static void testSendPriceException(){
        List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, PMC_CPQ_FPDPricefromPriceFx__c, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PricebookEntryId from OrderItem];
            for(OrderItem objItem : lstOrderLines)
            {
                lstPayloadOrderLineIds.add(objItem.Id);
            }
        
        User objUserAM = [select Id from User where LastName = 'Sales User Test' LIMIT 1 ];
        System.runAs(objUserAM){ 
            //List<Order> lstOrders = [select id, Name, AccountId, EffectiveDate, Status, Pricebook2Id from order];
            
            Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpNullResponse());
            Test.setMock(HttpCalloutMock.class, null);
            
            PageReference pageRef = Page.PMC_CPQ_SendFPD; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
            PMC_CPQ_FPDActionClass controllerFPD = new PMC_CPQ_FPDActionClass(stdController);
            controllerFPD.redirect();
            
            Test.stopTest();
            System.assert(!lstOrderLines.isEmpty(), 'List should not be empty'); 
        }
    }
    @isTest
    public static void testBulkSendFPDRequest(){
        List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, PMC_CPQ_FPDPricefromPriceFx__c, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PricebookEntryId from OrderItem];
            for(OrderItem objItem : lstOrderLines)
            {
                lstPayloadOrderLineIds.add(objItem.Id);
            }
        
        User objUserAM = [select Id from User where LastName = 'Sales User Test' LIMIT 1 ];
        System.runAs(objUserAM){ 
            //List<Order> lstOrders = [select id, Name, AccountId, EffectiveDate, Status, Pricebook2Id from order];
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpSendFPDSuccess(lstOrderLines[0].Id));
            Boolean fpdUI = true;
            PMC_CPQ_FPDActionClass objRef = new PMC_CPQ_FPDActionClass(lstOrderLines,fpdUI);
            objRef.bulkSendFPDtoSAPRequest(lstOrderLines);
            
            Test.stopTest();
            System.assert(!lstOrderLines.isEmpty(), 'List should not be empty'); 
        }
    }
    @isTest
    public static void testSendPriceFPDWarning(){
        List<OrderItem> lstOrderLines = [select id, Product2Id, OrderId, Quantity, ListPrice, PMC_CPQ_FPDPricefromPriceFx__c, UnitPrice, PMC_CPQ_FinalAgreedPrice__c,PricebookEntryId from OrderItem];
            for(OrderItem objItem : lstOrderLines)
            {
                objItem.put('PMC_CPQ_FinalAgreedPrice__c', null);
                lstPayloadOrderLineIds.add(objItem.Id);
            }
        update lstOrderLines;
        
        User objUserAM = [select Id from User where LastName = 'Sales User Test' LIMIT 1 ];
        System.runAs(objUserAM){ 
            //List<Order> lstOrders = [select id, Name, AccountId, EffectiveDate, Status, Pricebook2Id from order];
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpSendFPDSuccess(lstOrderLines[0].Id));
            
            PageReference pageRef = Page.PMC_CPQ_SendFPD; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(lstOrderLines[0].Id));
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(lstOrderLines[0]);
            PMC_CPQ_FPDActionClass controllerFPD = new PMC_CPQ_FPDActionClass(stdController);
            controllerFPD.redirect();
            
            Test.stopTest();
            System.assert(!lstOrderLines.isEmpty(), 'List should not be empty'); 
        }
    }
}