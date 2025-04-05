trigger PMC_CPQ_PreventDeleteQuoteline on SBQQ__QuoteLine__c (before delete) {
    for(SBQQ__QuoteLine__c ql : Trigger.old){
        if(ql.PMC_CPQ_PercentageOfQuantity__c > 0){
            ql.addError(System.Label.pmc_cpq_qty_error);
        }
    }

}