public with sharing class PMC_DH_UpdateProductRecordsBatch implements Database.Batchable<sObject>, Schedulable, Database.stateful {
    public Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
        return Database.getQueryLocator(
            [SELECT Id, PMC_CPQ_MaterialGroup__c, PMC_CPQ_ProductFamily__c, PMC_CPQ_ProductSubFamily__c FROM Product2
             WHERE CreatedDate = TODAY and Id ='01tDT00000A2h50YAB' WITH SECURITY_ENFORCED]);          
    }
    public void execute(Database.BatchableContext objBatchableContext , List<Product2> lstProducts){
        Database.SaveResult[] lstInsertionResultPb;
        Database.SaveResult[] lstInsertionResultCategory;
            List<ProductCategoryProduct> lstProdCatProd = new List<ProductCategoryProduct>();
        List<CommerceEntitlementProduct> lstProdEntitlement = new List<CommerceEntitlementProduct>();
        List<PricebookEntry> lstPbEntries = new List<PricebookEntry>();
        Map<String, String> mapProdCat = new Map<String,String>();
        for(Product2 objProd : lstProducts){ //Checking if any of the product fields is NULL
            if(objProd.PMC_CPQ_MaterialGroup__c !=Null && objProd.PMC_CPQ_ProductFamily__c != Null && objProd.PMC_CPQ_ProductSubFamily__c!=Null){
                mapProdCat.put(objProd.Id ,
                               (objProd.PMC_CPQ_MaterialGroup__c + '-' + 
                                objProd.PMC_CPQ_ProductFamily__c+'-' + 
                                objProd.PMC_CPQ_ProductSubFamily__c).toUpperCase()
                              );
            }
            else { //If product fields are NULL removing NULL from the concatenated String value 
                String strConcatValue =(objProd.PMC_CPQ_MaterialGroup__c + '-' + 
                                        objProd.PMC_CPQ_ProductFamily__c+'-' + 
                                        objProd.PMC_CPQ_ProductSubFamily__c).toUpperCase() ;
                if(strConcatValue.contains('NULL')){
                    strConcatValue = strConcatValue.replaceAll('-NULL', '');
                    strConcatValue = strConcatValue.replaceAll('NULL-', '');
                    
                }
                mapProdCat.put(objProd.Id ,strConcatValue);
            }         
            
        }    
        // Querying for the product categories that matches the concatenated value
        List<ProductCategory> lstProdCat = [SELECT Id, Name,PMC_DH_Category_ID__c FROM ProductCategory 
                                            WHERE PMC_DH_Category_ID__c IN :mapProdCat.values() WITH SECURITY_ENFORCED];
        Map<String,String> mapCat = new Map<String,String>();
        for(ProductCategory objcat : lstProdCat ){ //Storing the PMC_DH_Category_ID__c field in key and productcategory Id in values of Map
            mapCat.put(objcat.PMC_DH_Category_ID__c, objcat.Id);
        }
        ProductCategoryProduct objpcp;
        
        for(Product2 objProd : lstProducts){ //creating productcategoryproduct record
            objpcp = new ProductCategoryProduct();
            objpcp.ProductCategoryId = mapCat.get((mapProdCat.get(objProd.Id))); //
            system.debug(mapCat.get((mapProdCat.get(objProd.Id))));
            objpcp.ProductId = objProd.Id;
            lstProdCatProd.add(objpcp);
            
        }
        if(lstProdCatProd !=Null && lstProdCatProd.size()>0){
            lstInsertionResultCategory = Database.insert(lstProdCatProd, false);
        }
        
        //Querying for the standard price book
        List<Pricebook2> objStorePb = [SELECT Id, Name FROM Pricebook2 
                                       WHERE Name = 'Standard Price Book' 
                                       WITH SECURITY_ENFORCED];
        
        PricebookEntry objPbUSD ;
        PricebookEntry objPbCAD ;
        PricebookEntry objPbBRL ;
        
        //Associating the standard price book with the product
        for(Product2 objProd : lstProducts){
            objPbUSD = new PricebookEntry();
            objPbUSD.Pricebook2Id = objStorePb[0].Id;
            objPbUSD.Product2Id = objProd.Id;
            objPbUSD.IsActive = true;
            objPbUSD.UnitPrice=0;
            objPbUSD.CurrencyIsoCode='USD';
            objPbCAD = new PricebookEntry();
            objPbCAD.Pricebook2Id = objStorePb[0].Id;
            objPbCAD.Product2Id = objProd.Id;
            objPbCAD.IsActive = true;
            objPbCAD.UnitPrice=0;
            objPbCAD.CurrencyIsoCode='CAD';
            objPbBRL = new PricebookEntry();
            objPbBRL.Pricebook2Id = objStorePb[0].Id;
            objPbBRL.Product2Id = objProd.Id;
            objPbBRL.IsActive = true;
            objPbBRL.UnitPrice=0;
            objPbBRL.CurrencyIsoCode='BRL';
            lstPbEntries.add(objPbUSD);  
            lstPbEntries.add(objPbCAD);
            lstPbEntries.add(objPbBRL);          
        }
        
        //Querying for the store price book
        webStore objwebstore =[SELECT Id, Name FROM WebStore where Name='Digital Hub'];
        List<WebStorePricebook> objWebStorePricebook =[SELECT Id, Name, WebStoreId,Pricebook2Id,IsActive 
                                                       FROM WebStorePricebook 
                                                       WHERE WebStoreId=: objwebstore.Id];
        //Associating the store price book with the product
        for(Product2 objProd : lstProducts){               
            objPbUSD = new PricebookEntry();
            objPbUSD.Pricebook2Id = objWebStorePricebook[0].Pricebook2Id;
            objPbUSD.Product2Id = objProd.Id;
            objPbUSD.IsActive = true;
            objPbUSD.UnitPrice=0;
            objPbUSD.CurrencyIsoCode='USD';
            objPbCAD = new PricebookEntry();
            objPbCAD.Pricebook2Id = objWebStorePricebook[0].Pricebook2Id;
            objPbCAD.Product2Id = objProd.Id;
            objPbCAD.IsActive = true;
            objPbCAD.UnitPrice=0;
            objPbCAD.CurrencyIsoCode='CAD';
            objPbBRL = new PricebookEntry();
            objPbBRL.Pricebook2Id = objWebStorePricebook[0].Pricebook2Id;
            objPbBRL.Product2Id = objProd.Id;
            objPbBRL.IsActive = true;
            objPbBRL.UnitPrice=0;
            objPbBRL.CurrencyIsoCode='BRL';
            lstPbEntries.add(objPbUSD);  
            lstPbEntries.add(objPbCAD);
            lstPbEntries.add(objPbBRL); 
        }
        if(lstPbEntries !=Null && lstPbEntries.size()>0){
            lstInsertionResultPb = Database.insert(lstPbEntries, false);
        }
    }
    public void finish(Database.BatchableContext objBatchableContext){
        PMC_ErrorLog__c objErrorLog = new PMC_ErrorLog__c();
        
    }
    
    public void execute(SchedulableContext objSchedulableContext){
        Database.executeBatch(new PMC_DH_UpdateProductRecordsBatch());
    }
}