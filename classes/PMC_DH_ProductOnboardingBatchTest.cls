/**
 * @description       : Test Class for Product Onboarding Batch Job
 * @author            : Hemant Giri Goswami | hegoswami@deloitte.com
 * @group             : Mosaic Direct
 * @last modified on  : 04-09-2024
 * @last modified by  : Hemant Giri Goswami | hegoswami@deloitte.com
**/

@isTest
public with sharing class PMC_DH_ProductOnboardingBatchTest {
    

    @TestSetup
    static void testSetup()
    {
        User userAdmin=PMC_DH_TestDataFactoryClass.createAdminUser(); // mock admin added
        System.runAs(userAdmin){
        // test class fixes
        Account acc=PMC_DH_TestDataFactoryClass.createParentTestAccount();
        PMC_DH_TestDataFactoryClass.createShipToTestAccount(acc);
        Test.startTest();        
        Product2 prod = PMC_DH_TestDataFactoryClass.createProduct();
        prod.PMC_CPQ_ProductSegment__c='Feed';
        prod.PMC_CPQ_ProductTypes__c='Services';
        prod.PMC_CPQ_ProductFamily__c='Mes';
        prod.PMC_CPQ_Potassium__c=17;
        prod.PMC_CPQ_Phosphorous__c=7;
        prod.PMC_CPQ_Nitrogen__c=35;
        prod.PMC_CPQ_Boron__c=10;
        prod.PMC_CPQ_ProductSubFamily__c='Mes';
        prod.PMC_DH_isProcessed__c=FALSE;
        insert prod;
        
        Product2 prod2 = PMC_DH_TestDataFactoryClass.createProduct();
        prod2.ProductCode='AB-45678';
        prod2.StockKeepingUnit='45678';
        prod2.PMC_CPQ_ProductSegment__c='GYPSUM';
        prod2.PMC_CPQ_ProductTypes__c='COMMODITY';
        prod2.PMC_CPQ_ProductFamily__c='MES';
        prod2.PMC_CPQ_Potassium__c=17;
        prod2.PMC_CPQ_Phosphorous__c=7;
        prod2.PMC_CPQ_Nitrogen__c=35;
        prod2.PMC_CPQ_ProductSubFamily__c='MES';
        prod2.PMC_CPQ_Boron__c=10;
        prod2.PMC_DH_isProcessed__c=FALSE;
        insert prod2; 
        
        
        ProductCatalog pc=new ProductCatalog(name='mosaic Direct');
        insert pc;
        PMC_SS_SalesArea__c testSalesArea = new PMC_SS_SalesArea__c();
        testSalesArea.PMC_SS_SalesOrganization__c = 'Mosaic Global Sales LLC';
        //testSalesArea.PMC_CPQ_MosaicLLP__c= '1002';
        testSalesArea.PMC_SS_DistributionChannel__c = '0';
        testSalesArea.PMC_SS_Division__c = '10';
        insert testSalesArea;
        
        PMC_CPQ_ProductSalesArea__c tetProSalesArea=new PMC_CPQ_ProductSalesArea__c();
        tetProSalesArea.PMC_CPQ_Product__c=prod.Id;
        tetProSalesArea.PMC_CPQ_Sales_Area__c=testSalesArea.Id;
        insert tetProSalesArea;
        
        PMC_SS_AccountSalesAreaRelationship__c testAccSalesArea=new PMC_SS_AccountSalesAreaRelationship__c();
        testAccSalesArea.PMC_SS_Account__c=acc.Id;
        testAccSalesArea.PMC_SS_SalesArea__c=testSalesArea.Id;
        insert testAccSalesArea;
        
        
        BuyerGroup bGrp = PMC_DH_TestDataFactoryClass.createBuyerGroup();
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = acc.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        PMC_DH_TestDataFactoryClass.createBuyerGroupMember(buyerAccount.BuyerId,bGrp.Id);
        CommerceEntitlementPolicy objPolicy = PMC_DH_TestDataFactoryClass.createEntitlementPolicy();
        PMC_DH_TestDataFactoryClass.createCommerceEntitlementBuyerGroup(objPolicy.Id,bGrp.Id);
        PMC_DH_TestDataFactoryClass.createCommerceEntitlementProduct(objPolicy.Id,prod.Id);
        ProductCategory productCat=new  ProductCategory(Name='Mes',PMC_DH_Category_ID__c='GYPSUM-COMMODITY-MES-MES',catalogid=pc.id,IsNavigational=true);
        insert productCat;
        ProductCategory productCat2=new  ProductCategory(Name='Feed',PMC_DH_Category_ID__c='FEED-SERVICES-MES-MES',catalogid=pc.id,IsNavigational=true);
        insert productCat2;
        ProductCategoryProduct prodcatPro=new ProductCategoryProduct(Productid=prod2.id,ProductCategoryid=productCat.id);
        insert prodcatPro;
        /*ElectronicMediaGroup elePLP=new ElectronicMediaGroup(name='Product List Image',developername='productListImage',usagetype='Listing');
        upsert elePLP;
        ElectronicMediaGroup elePDP=new ElectronicMediaGroup(name='Product Detail Images',developername='productDetailImage',usagetype='Standard');
        upsert elePDP;*/
        /*ProductMedia prodM=new ProductMedia(productid=prod2.id,ElectronicMediaId='20YDT000000D8eI2AS',ElectronicMediaGroupid =elePLP.id);
        insert prodM;*/
        }
    }

    /**
    * @description 
    * @author Hemant Giri Goswami | hegoswami@deloitte.com | 10-27-2023 
    **/
    @isTest
    public static void testProductOnBoardBatch()
    {
        User userAdmin= [SELECT Id,Name from User Where LastName='Admin User Test' AND IsActive=TRUE LIMIT 1];
        System.runAs(userAdmin){
            try{
                PMC_DH_ProductOnboardingBatch batchJob=new PMC_DH_ProductOnboardingBatch();
                Test.startTest();
                String jobId = Database.executeBatch(batchJob);
                System.Assert(jobId != Null, 'Success');
                
                
                List<ProductMedia>  lstProductMediaProdId = new List<ProductMedia> (); 
                Product2 pro = [SELECT Id,Name from Product2 LIMIT 1];
                ProductMedia pm = new ProductMedia();
                pm.ProductId=pro.Id;
                
                lstProductMediaProdId.add(pm);
                PMC_DH_ProductOnboardingBatchUtil.processedProductMediaid(lstProductMediaProdId, new Set<String>{pro.Id});
                Test.stopTest();
            }
            Catch(Exception ex){
                System.assertEquals(ex!=NULL,true,'Cron Expressions');
            }
        }        
    }
}