public with sharing class PMC_DH_UserInfoHelper {
    public static List<String> getCountryCode() {
        List<String> lstCountryCode = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.PMC_DH_CountryCode__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistVal : picklistValues) {
            lstCountryCode.add(picklistVal.getLabel());
        }
        return lstCountryCode;
    }
}