trigger OrderProductTestTrigger on OrderItem (after insert,after update) {
    Set<Id> orderIds = new Set<Id>();
    Set<Id> accIds = new Set<Id>();
    Set<Id> rbmIds = new Set<Id>();
    Set<Id> rbtIds = new Set<Id>();
    Map<String,Map<String,Integer>> accountidAndproductfamilyAndQuantityMap = new Map<String,Map<String,Integer>>();
    Map<String,String> rebateProgramAndAccountIdAssociation = new Map<String,String>();
    Map<String,Decimal> productfamilyAndfinalRebateAmt = new Map<String,Decimal>();
    Map<Id,List<ProgramRebateTypeBenefit>> individualIncentiveBenefitsRecordsForEachRebateProgram = new Map<Id,List<ProgramRebateTypeBenefit>>();
    Map<Id,List<ProgramRebateTypeBenefit>> portfolioIncentiveBenefitsRecordsForEachRebateProgram = new Map<Id,List<ProgramRebateTypeBenefit>>();
    for(OrderItem oi : Trigger.New) {
        orderIds.add(oi.OrderId);
    }
    for(OrderItem oi : [SELECT id,AccountId__c,Product_Family__c,Quantity FROM OrderItem WHERE orderid in :orderIds]) {
        System.debug('oi.AccountId__c'+oi);
        if(accountidAndproductfamilyAndQuantityMap.containsKey(oi.AccountId__c)){
            if(accountidAndproductfamilyAndQuantityMap.get(oi.AccountId__c).containsKey(oi.Product_Family__c)){
                Integer quantVal = Integer.valueOf(accountidAndproductfamilyAndQuantityMap.get(oi.AccountId__c).get(oi.Product_Family__c))+Integer.valueOf(oi.Quantity);
                 accountidAndproductfamilyAndQuantityMap.get(oi.AccountId__c).put(oi.Product_Family__c,quantVal);
            }else{
                accountidAndproductfamilyAndQuantityMap.get(oi.AccountId__c).put(oi.Product_Family__c,Integer.valueOf(oi.Quantity));
            }
        }else{
            Map<String,Integer> tempMap = new Map<String,Integer>();
            tempMap.put(oi.Product_Family__c,Integer.valueOf(oi.Quantity));
            accountidAndproductfamilyAndQuantityMap.put(oi.AccountId__c,tempMap);
        }
      }
    system.debug('accountidAndproductfamilyAndQuantityMap:: '+accountidAndproductfamilyAndQuantityMap);
    for(Order o :[Select AccountId from Order where id IN :orderIds]){
        accIds.add(o.AccountId);
    }
    System.debug('ccccchh:: '+accIds);
    for(RebateProgramMember rbm : [SELECT RebateProgramId,AccountId FROM RebateProgramMember where AccountId IN :accIds ]){
        rbmIds.add(rbm.RebateProgramId);
        rebateProgramAndAccountIdAssociation.put(rbm.RebateProgramId,rbm.AccountId);
    }
    
    for(ProgramRebateType prt:[SELECT name,id FROM ProgramRebateType WHERE RebateProgramId in :rbmIds]){
        rbtIds.add(prt.id);
    }
    for(ProgramRebateTypeBenefit prtb : [SELECT name,ProgramRebateType.RebateProgramId,ProgramRebateType.name,id,MinimumQualifyingValue,MaximumQualifyingValue,BenefitValue,PMC_SS_ScaleLevel__c,PMC_SS_ProductFamily__c FROM ProgramRebateTypeBenefit WHERE ProgramRebateTypeId in :rbtIds]){
        System.debug('ProgramRebateTypeBenefit:: '+prtb.ProgramRebateType.name);
        if(prtb.ProgramRebateType.name == 'Individual Incentive'){
            if(individualIncentiveBenefitsRecordsForEachRebateProgram.containsKey(prtb.ProgramRebateType.RebateProgramId)){
                individualIncentiveBenefitsRecordsForEachRebateProgram.get(prtb.ProgramRebateType.RebateProgramId).add(prtb);
            }else{
                List<ProgramRebateTypeBenefit> templist = new List<ProgramRebateTypeBenefit>{prtb};
                    individualIncentiveBenefitsRecordsForEachRebateProgram.put(prtb.ProgramRebateType.RebateProgramId, templist);
            }
        }else if(prtb.ProgramRebateType.name == 'Portfolio Incentive'){
            if(portfolioIncentiveBenefitsRecordsForEachRebateProgram.containsKey(prtb.ProgramRebateType.RebateProgramId)){
                portfolioIncentiveBenefitsRecordsForEachRebateProgram.get(prtb.ProgramRebateType.RebateProgramId).add(prtb);
            }else{
                List<ProgramRebateTypeBenefit> templist = new List<ProgramRebateTypeBenefit>{prtb};
                    portfolioIncentiveBenefitsRecordsForEachRebateProgram.put(prtb.ProgramRebateType.RebateProgramId, templist);
            }
        }
        
        
    }
    List<ProgramRebateTypeBenefit> portRecToUpdate = new List<ProgramRebateTypeBenefit>();
     List<ProgramRebateTypeBenefit> portRecToDelete = new List<ProgramRebateTypeBenefit>();
    for (Id rebateProgramIdval : individualIncentiveBenefitsRecordsForEachRebateProgram.keySet()){
        Map<Decimal,Decimal> tierMap = new Map<Decimal,Decimal>();
        Map<String,List<Decimal>> tierMaxMinRangeMap = new  Map<String,List<Decimal>>();
        // Map<Decimal,String> tierProductFamilyMap = new  Map<Decimal,String>();
        Decimal minAmt ;
         Decimal minTier;
        for( ProgramRebateTypeBenefit benefitRec : individualIncentiveBenefitsRecordsForEachRebateProgram.get(rebateProgramIdval)){
            Decimal rebateAmt= 0.0;
            
            Map<String,Integer> tempmapVal = new Map<String,Integer>();
            System.debug(accountidAndproductfamilyAndQuantityMap.get(rebateProgramAndAccountIdAssociation.get(benefitRec.ProgramRebateType.RebateProgramId)));
            tempmapVal.putAll(accountidAndproductfamilyAndQuantityMap.get(rebateProgramAndAccountIdAssociation.get(benefitRec.ProgramRebateType.RebateProgramId)));
            if(tempmapVal.containsKey(benefitRec.PMC_SS_ProductFamily__c)){
                System.debug('PMC_SS_ProductFamily__c:::'+benefitRec.PMC_SS_ProductFamily__c);
                if( Integer.valueOf(tempmapVal.get(benefitRec.PMC_SS_ProductFamily__c)) >= benefitRec.MinimumQualifyingValue && Integer.valueOf(tempmapVal.get(benefitRec.PMC_SS_ProductFamily__c)) <= benefitRec.MaximumQualifyingValue ){
                     System.debug(' tempmapVal.get(benefitRec.PMC_SS_ProductFamily__c):'+ tempmapVal.get(benefitRec.PMC_SS_ProductFamily__c)+'  '+benefitRec.BenefitValue);
                    rebateAmt = tempmapVal.get(benefitRec.PMC_SS_ProductFamily__c)*benefitRec.BenefitValue;
                    minAmt = rebateAmt;
                    minTier = benefitRec.PMC_SS_ScaleLevel__c;
                    tierMap.put(rebateAmt,benefitRec.PMC_SS_ScaleLevel__c);
                    //Map<Decimal,List<Decimal>> tierProductFamilyMaptemp = new  Map<Decimal,List<Decimal>>();
                    //tierProductFamilyMaptemp.put(benefitRec.PMC_SS_ScaleLevel__c,new List<Decimal>{benefitRec.MinimumQualifyingValue,benefitRec.MaximumQualifyingValue});
                    //tierProductFamilyMap.put(benefitRec.PMC_SS_ScaleLevel__c,benefitRec.PMC_SS_ProductFamily__c);
                    tierMaxMinRangeMap.put(benefitRec.PMC_SS_ProductFamily__c,new List<Decimal>{benefitRec.MinimumQualifyingValue,benefitRec.MaximumQualifyingValue});
                    System.debug('tierMap:::'+tierMap+'hjkl minAmt:'+minAmt);
                    System.debug('tierMaxMinRangeMap:::'+tierMaxMinRangeMap);
                }
            }
        }
      
       
        for(Decimal amt : tierMap.keySet()){
            if(amt < minAmt){
                 minTier=tierMap.get(amt);
            }
        }
       system.debug('minnnntierr:'+minTier); 
        for (ProgramRebateTypeBenefit portRec : portfolioIncentiveBenefitsRecordsForEachRebateProgram.get(rebateProgramIdval)){
            if(portRec.PMC_SS_ScaleLevel__c == minTier){
                portRec.MinimumQualifyingValue = tierMaxMinRangeMap.get(portRec.PMC_SS_ProductFamily__c).get(0);
                portRec.MaximumQualifyingValue = tierMaxMinRangeMap.get(portRec.PMC_SS_ProductFamily__c).get(1);
                portRecToUpdate.add(portRec);
            }else if(portRec.PMC_SS_ScaleLevel__c != minTier){
                if(portRec.MinimumQualifyingValue == tierMaxMinRangeMap.get(portRec.PMC_SS_ProductFamily__c).get(0)){
                    portRec.MinimumQualifyingValue = 0;
                }
                if( portRec.MaximumQualifyingValue == tierMaxMinRangeMap.get(portRec.PMC_SS_ProductFamily__c).get(1)){
                    portRec.MaximumQualifyingValue = 0;
                }
                portRecToUpdate.add(portRec);
            }
        }
    }
    
    update portRecToUpdate;
    //delete portRecToDelete;
}