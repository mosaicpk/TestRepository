public with sharing class PMC_SS_GetForecastFact {

    @AuraEnabled(cacheable=true)
    public static List<AdvAccountForecastFact> getForecast() {
        return [
            SELECT PMC_SS_CurrentSalesPlan__c, Id,Name, PMC_SS_AccountManager__c
            FROM AdvAccountForecastFact
            LIMIT 5
        ];
    }
}