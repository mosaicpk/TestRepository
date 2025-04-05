public with sharing class pmc_dh_POCHistoryHelper {
    
        @AuraEnabled
        public static List<Account> getAccountName(){
            List<Account> lstAcc=[select id,name,ShippingCountry, BillingCountry from account];
        return lstAcc;
        }
    
}