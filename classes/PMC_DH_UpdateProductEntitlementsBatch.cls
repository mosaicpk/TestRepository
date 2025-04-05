public with sharing class PMC_DH_UpdateProductEntitlementsBatch implements Database.Batchable<sObject>, Schedulable, Database.stateful {
    public Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
        //List<String> ids = new List<String>{'a4fDT000001Fi8vYAC','a4fDT000001Fi90YAC','a4fDT000001Fi9AYAS','a4fDT000001Fi95YAC'};
        return Database.getQueryLocator(
            [SELECT Id, Name,CreatedDate, PMC_DH_SoldToAccount__c, PMC_DH_ProductFamily__c, PMC_DH_Product__c, 
             PMC_DH_isActive__c, PMC_DH_isProcessed__c, Error_Log__c, PMC_DH_Type__c from PMC_DH_EntitlementRules__c
             WHERE CreatedDate = TODAY WITH SECURITY_ENFORCED
            ]);                
    }
    public void execute(Database.BatchableContext objBatchableContext , List<PMC_DH_EntitlementRules__c> lstEntitlementRules){
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id, Set<Id>> mapBuyerGroupMembers = new Map<Id, Set<Id>>();   
        Map<Id, Set<Id>> mapEntitlementBuyerGroups = new Map<Id, Set<Id>>();  
        Map<Id,Set<Id>> mapAcctoEntPolicies = new Map<Id,Set<Id>>(); 
        Set<Id> setBuyerGroups = new Set<Id>();
        Map<Id,Set<Id>> mapProdEntPolicies = new Map<Id, Set<Id>>();
        Map<String,List<Id>> mapProdFamilies = new Map<String, List<Id>>();  
        List<String> lstProdFamily = new List<String>();
        Map<Id,Set<Id>> mapProdInFamilyToEntPolcies = new Map<Id,Set<Id>>();
        
        for(PMC_DH_EntitlementRules__c objEntRule : lstEntitlementRules){
            //getting all the account ids to fetch buyer group member records
            setAccountIds.add(objEntRule.PMC_DH_SoldToAccount__c);
            //if product family is populated, then getting all the productfamily ids
            if(objEntRule.PMC_DH_ProductFamily__c != NULL){
                lstProdFamily.add(objEntRule.PMC_DH_ProductFamily__c);
            }
        }
        //Querying all the products associated with product families obtained in the previous step
        List<Product2> lstProducts = [SELECT Id, Name,PMC_CPQ_ProductFamily__c FROM Product2 
                                      WHERE PMC_CPQ_ProductFamily__c IN :lstProdFamily WITH SECURITY_ENFORCED];
        //Creating a map of product family and all the products linked to that family
        for(Product2 objProd :lstProducts){
            if(mapProdFamilies.containsKey(objProd.PMC_CPQ_ProductFamily__c) ){
                List<String> lstValues = mapProdFamilies.get(objProd.PMC_CPQ_ProductFamily__c);
                lstValues.add(objProd.Id);
                mapProdFamilies.put(objProd.PMC_CPQ_ProductFamily__c, lstValues);
            }
            else{
                mapProdFamilies.put(objProd.PMC_CPQ_ProductFamily__c, new List<String>{objProd.Id});            
            }           
        }
        //Querying buyer group members to get the buyer group id the account is part of
        List<BuyerGroupMember> lstBuyerGroupMembers= [SELECT Id,Name, BuyerGroupId, BuyerId FROM BuyerGroupMember 
                                                      WHERE  BuyerId in: setAccountIds WITH SECURITY_ENFORCED];  
        Set<Id> setAllBuyerGroupIds = new Set<Id>();
        //Creating a map of acc and all the buyer groups it is linked to
        for(BuyerGroupMember objBuyerGroupMem : lstBuyerGroupMembers){
            if(mapBuyerGroupMembers.containsKey(objBuyerGroupMem.BuyerId)){
                Set<Id> lstValues = mapBuyerGroupMembers.get(objBuyerGroupMem.BuyerId);
                lstValues.add(objBuyerGroupMem.BuyerGroupId);
                mapBuyerGroupMembers.put(objBuyerGroupMem.BuyerId, lstValues);
            }
            mapBuyerGroupMembers.put(objBuyerGroupMem.BuyerId, new Set<Id>{objBuyerGroupMem.BuyerGroupId});
            setAllBuyerGroupIds.addAll(mapBuyerGroupMembers.get(objBuyerGroupMem.BuyerId));
        } 
        //Fetching all the entitlement policies based on the buyer group ids obtained earlier
        
        
        List<CommerceEntitlementBuyerGroup> lstEntitlementPolicies = [SELECT Id, Name, PolicyId, BuyerGroupId 
                                                                      FROM CommerceEntitlementBuyerGroup 
                                                                      WHERE BuyerGroupId IN:setAllBuyerGroupIds  WITH SECURITY_ENFORCED]; 
        //Creating a map of buyer group id and all the entitlement policies linked to them
        for(CommerceEntitlementBuyerGroup objEntitlementBuyerGroups : lstEntitlementPolicies){
            if(mapEntitlementBuyerGroups.containsKey(objEntitlementBuyerGroups.BuyerGroupId)){
                Set<Id> setValues = mapEntitlementBuyerGroups.get(objEntitlementBuyerGroups.BuyerGroupId);
                setValues.add(objEntitlementBuyerGroups.PolicyId);
                mapEntitlementBuyerGroups.put(objEntitlementBuyerGroups.BuyerGroupId, setValues);
            }
            mapEntitlementBuyerGroups.put(objEntitlementBuyerGroups.BuyerGroupId, new Set<Id>{objEntitlementBuyerGroups.PolicyId});
        } 
        Set<Id> setAllEntPolicies = new Set<Id>();
        //looping through product entitlement rule records
        for(PMC_DH_EntitlementRules__c objEntRules:lstEntitlementRules){
            //getting all the buyer groups based on the account id
            if(mapBuyerGroupMembers.containsKey(objEntRules.PMC_DH_SoldToAccount__c)){
                setBuyerGroups = mapBuyerGroupMembers.get(objEntRules.PMC_DH_SoldToAccount__c);
            }
            //looping through buyer groups and fetching all the entitlement policies reltaed to that buyer group
            for(Id strBuyerGroupId:setBuyerGroups){
                if(mapEntitlementBuyerGroups.containsKey(strBuyerGroupId)){
                    Set<Id> setEntitlementPol = mapEntitlementBuyerGroups.get(strBuyerGroupId);
                    //adding entitlement policies of multiple buyer groups linked to one account
                    //to a single list
                    setAllEntPolicies.addAll(setEntitlementPol);
                }
            }
            //creating a map of acc and all the entitlement policies
            mapAcctoEntPolicies.put(objEntRules.PMC_DH_SoldToAccount__c, setAllEntPolicies); 
            
            //if product id is present, then creating a map of product id and all the entitlement policies
            if(objEntRules.PMC_DH_Product__c != NULL && objEntRules.PMC_DH_Type__c == 'RESTRICTED'){
                if(mapProdEntPolicies.containsKey(objEntRules.PMC_DH_Product__c)){
                    Set<Id> setTempIds = mapProdEntPolicies.get(objEntRules.PMC_DH_Product__c);
                    setTempIds.addAll(setAllEntPolicies);
                    mapProdEntPolicies.put(objEntRules.PMC_DH_Product__c,setTempIds);
                }
                mapProdEntPolicies.put(objEntRules.PMC_DH_Product__c,setAllEntPolicies);
            }
            List<Id> lstallPolicyIds = new List<Id>();
            if(objEntRules.PMC_DH_ProductFamily__c != NULL && objEntRules.PMC_DH_Type__c == 'ENABLED'){
                //if product family value is present, then get list of products from family-products map
                //loop through products list and put prod id and all ent policies in a map
                if(mapProdFamilies.containsKey(objEntRules.PMC_DH_ProductFamily__c)){
                    //get all the products from that particular family
                    List<Id> lstAllProdIds = mapProdFamilies.get(objEntRules.PMC_DH_ProductFamily__c);
                    for(Id strProdId : lstAllProdIds){
                        if(mapProdInFamilyToEntPolcies.containsKey(strProdId)){
                            Set<Id> setTempIds = mapProdInFamilyToEntPolcies.get(strProdId);
                            setTempIds.addAll(setTempIds);
                            mapProdInFamilyToEntPolcies.put(strProdId, setTempIds);
                        }
                        mapProdInFamilyToEntPolcies.put(strProdId, setAllEntPolicies);
                    }
                }
            }
        }
        // Fetch all the entitlement records for products from product family 
        List<CommerceEntitlementProduct> lstCommEntProd = [SELECT Id, PolicyId, 
                                                           ProductId FROM CommerceEntitlementProduct
                                                           WHERE PolicyId IN : setAllEntPolicies AND ProductId IN :mapProdInFamilyToEntPolcies.keySet()];
        
        //loop through the CommerceEntitlementProduct list and create a map of product id and entitlement policy id
        Map<Id,Set<Id>> mapProdToExistingEntPolicies = new Map<Id,Set<Id>>();
        if(lstCommEntProd.size()>0){
            for (CommerceEntitlementProduct objEntProd : lstCommEntProd){
                if(mapProdToExistingEntPolicies.containsKey(objEntProd.ProductId)){
                    Set<Id> lstValues = mapProdToExistingEntPolicies.get(objEntProd.ProductId);
                    lstValues.add(objEntProd.PolicyId);
                    mapProdToExistingEntPolicies.put(objEntProd.ProductId, lstValues);
                }
                mapProdToExistingEntPolicies.put(objEntProd.ProductId, new Set<Id>{objEntProd.PolicyId});
            }
        }
        //compare the existing map with the above map to see if any products are missed in the entitlement policies
        Map<Id,Set<Id>> mapProdToNonExistingEntPolicies = new Map<Id,Set<Id>>();
        Set<Id> setExistingPolIds = new Set<Id>();
        Set<Id> setNonExistingPolIds = new Set<Id>();
        Set<Id> setDiffPolIds = new Set<Id>();
        
        List<CommerceEntitlementProduct> lstCommEntProdToInsert = new List<CommerceEntitlementProduct>();
        for(Id strprodId : mapProdInFamilyToEntPolcies.keySet()){
            if(mapProdToExistingEntPolicies.get(strprodId)!=Null ){
                setExistingPolIds = mapProdToExistingEntPolicies.get(strprodId);
                if(mapProdInFamilyToEntPolcies.get(strprodId)!=Null ){
                    setNonExistingPolIds = mapProdInFamilyToEntPolcies.get(strprodId);
                    setDiffPolIds.addAll(setNonExistingPolIds);
                    setDiffPolIds.removeAll(setExistingPolIds);
                    if(setDiffPolIds != Null){
                        mapProdToNonExistingEntPolicies.put(strprodId, setDiffPolIds); 
                    }
                    
                }
            }
            else{
                mapProdToNonExistingEntPolicies.put(strprodId, mapProdInFamilyToEntPolcies.get(strprodId));
            }
            
        }
        
        for(String strProdId : mapProdToNonExistingEntPolicies.keySet()){
            if(mapProdToNonExistingEntPolicies.get(strProdId)!=Null){
                for(String strPolicyId : mapProdToNonExistingEntPolicies.get(strProdId)){
                    CommerceEntitlementProduct objCommEntProd = new CommerceEntitlementProduct();
                    objCommEntProd.PolicyId = strPolicyId;
                    objCommEntProd.ProductId = strProdId;
                    lstCommEntProdToInsert.add(objCommEntProd);
                }
            }
        }
        //Query for CommerceEntitlementProduct for restricted type and product id is there
        List<CommerceEntitlementProduct> lstEntProd = [SELECT Id, PolicyId, ProductId FROM CommerceEntitlementProduct
                                                       WHERE PolicyId IN : setAllEntPolicies AND ProductId IN :mapProdEntPolicies.keySet()];
        
        Database.DeleteResult[] lstDeletionResult = Database.delete(lstEntProd, false);
        Database.SaveResult[] lstInsertionResult = Database.insert(lstCommEntProdToInsert, false); 
    } 
    public void finish(Database.BatchableContext objBatchableContext){
        Database.executeBatch(new PMC_DH_SearchIndexBatchClass());
        
    }
    
    public void execute(SchedulableContext objSchedulableContext){
        Database.executeBatch(new PMC_DH_UpdateProductEntitlementsBatch());
    }
}