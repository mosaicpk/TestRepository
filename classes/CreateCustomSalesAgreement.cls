public class CreateCustomSalesAgreement {
    
    public static void createCustomSalesAgreement(Id salesAgreementId){
        //SalesAgreement sa = [Select name, account.name , StartDate, EndDate From SalesAgreement WHERE id =:salesAgreementId];
        CustomSalesAgreement__c csa = new CustomSalesAgreement__c();
        csa.SalesAgreement__c = salesAgreementId;
        insert csa;
        SalesAgreementProduct sap = [SELECT Product.PMC_CPQ_ProductFamily__c,TotalForecastedQuantity from  SalesAgreementProduct where SalesAgreementId = :salesAgreementId];
		IncentiveData__c incData =  new IncentiveData__c();
        incData.CustomSalesAgreement__c = csa.id;
        incData.Product_Family__c = sap.Product.PMC_CPQ_ProductFamily__c;
        incData.ForecastTons__c = sap.TotalForecastedQuantity;
        RebateProgram rp = [SELECT name,id from RebateProgram where PMC_SS_SalesAgreement__c = :salesAgreementId];
        List<ProgramRebateType> programRebateTypeRecs = [select id,PMC_SS_Type__c from ProgramRebateType where RebateProgramId = :rp.id];
        Set<ID> programRebateTypeIDs = new Set<Id>();
        for(ProgramRebateType prt: programRebateTypeRecs){
            programRebateTypeIDs.add(prt.id);
        }
        System.debug('programRebateTypeIDs:: '+programRebateTypeIDs);
        List<Decimal> thresholdValues = new List<Decimal>();
        Map<Decimal,Decimal> threshold_IndvIncentiveValues = new Map<Decimal,Decimal>();
        Map<Decimal,Decimal> threshold_PortfolioIncentiveValues = new Map<Decimal,Decimal>();
        List<ProgramRebateTypeBenefit> rbtb = [Select id,MinimumQualifyingValue,BenefitValue,ProgramRebateType.PMC_SS_Type__c from ProgramRebateTypeBenefit where ProgramRebateTypeId in :programRebateTypeIDs];  
        for(ProgramRebateTypeBenefit prtbrec: rbtb){
            
            if(prtbrec.ProgramRebateType.PMC_SS_Type__c == 'Individual'){
               thresholdValues.add(prtbrec.MinimumQualifyingValue);
                threshold_IndvIncentiveValues.put(prtbrec.MinimumQualifyingValue,prtbrec.BenefitValue);
            }
            if(prtbrec.ProgramRebateType.PMC_SS_Type__c == 'Portfolio'){
                threshold_PortfolioIncentiveValues.put(prtbrec.MinimumQualifyingValue,prtbrec.BenefitValue);
            } 
            
        }
        thresholdValues.sort();
        String thresholdFinal='';
        String indvIncentiveValues = '';
        String portIncentiveValues = '';
        for(Integer i = thresholdValues.size()-1 ; i>=0;i-- ){
            thresholdFinal = thresholdFinal+ '\n'+thresholdValues[i]+'+';
            indvIncentiveValues = indvIncentiveValues+'\n$'+threshold_IndvIncentiveValues.get(thresholdValues[i]);
            portIncentiveValues = portIncentiveValues+'\n$'+threshold_PortfolioIncentiveValues.get(thresholdValues[i]);
        }
        System.debug('thresholdFinal:: '+thresholdFinal);
        incData.Threshold__c = thresholdFinal;
        incData.IndividualIncentive__c = indvIncentiveValues;
        incData.PortfolioIncentives__c = portIncentiveValues;
		insert incData;    
    }
        

}