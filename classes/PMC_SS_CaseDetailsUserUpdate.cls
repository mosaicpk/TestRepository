public class PMC_SS_CaseDetailsUserUpdate {

    /**
    * @description This method will be used to populate Account and Regional Manager field on Account Updation.
    * @param mapOldCases - A map of previous version of Case records.
    * @param lstNewCases - List of updated Case records.
    */
    public static void addAccountAndRegionalManagerOnUpdate(Map<Id,Case> mapOldCases, List<Case> lstNewCases){
        
        Set<Id> setAccountIds = new Set<Id>();
        List<Case> lstCasesToUpdate = new List<Case>();
        for(Case objCase: lstNewCases) {
            if(mapOldCases.get(objCase.Id).AccountId != objCase.AccountId && objCase.AccountId != NULL){
                setAccountIds.add(objCase.AccountId);
                lstCasesToUpdate.add(objCase);
            }
        }
        if(!setAccountIds.isEmpty()) {
            Map<Id,Account> mapAccountIdAndAccount = new Map<Id,Account>([SELECT Id, OwnerId,Owner.ManagerId FROM Account WHERE ID in :setAccountIds WITH SECURITY_ENFORCED]);
            for(Case objCaseToUpdate: lstCasesToUpdate){
                if(objCaseToUpdate.AccountId != NULL && mapAccountIdAndAccount != null && mapAccountIdAndAccount.get(objCaseToUpdate.AccountId) != null) {
                    updateManagersOnCase(objCaseToUpdate,mapAccountIdAndAccount.get(objCaseToUpdate.AccountId).OwnerId,mapAccountIdAndAccount.get(objCaseToUpdate.AccountId).Owner.ManagerId);
                }
            }

        }
    }
    
    /**
    * @description This method will be used to populate Account and Regional Manager field on case creation.
    * @param lstNewCases - List of new Case records.
    */
    public static void addAccountAndRegionalManagerOnInsert(List<Case> lstNewCases) {
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();
        
        for(Case objCase: lstNewCases){
            setAccountIds.add(objCase.AccountId);
            setContactIds.add(objCase.ContactId);
        }

        Map<Id,Contact> mapContactIdAndContact = new Map<Id,Contact>();
        Map<Id,Account> mapAccountIdAndAccount = new Map<Id,Account>();
        
        if(!setContactIds.isEmpty()) {
            mapContactIdAndContact = new Map<Id,Contact>([SELECT Id, Account.OwnerId, Account.Owner.ManagerId FROM Contact WHERE Id in :setContactIds WITH SECURITY_ENFORCED]);
        }
        if(!setAccountIds.isEmpty()) {
            mapAccountIdAndAccount = new Map<Id,Account>([SELECT Id,OwnerId, Owner.ManagerId FROM Account WHERE ID in :setAccountIds WITH SECURITY_ENFORCED]);
        }

        for(Case objCaseToUpdate: lstNewCases) {

            if(objCaseToUpdate.AccountId != NULL && mapAccountIdAndAccount.containsKey(objCaseToUpdate.AccountId) ) {
                updateManagersOnCase(objCaseToUpdate,mapAccountIdAndAccount.get(objCaseToUpdate.AccountId).OwnerId,mapAccountIdAndAccount.get(objCaseToUpdate.AccountId).Owner.ManagerId);
            }
            else if(objCaseToUpdate.ContactId != NULL &&  mapContactIdAndContact.containsKey(objCaseToUpdate.ContactId) ) {
                updateManagersOnCase(objCaseToUpdate,mapContactIdAndContact.get(objCaseToUpdate.ContactId).Account.OwnerId,mapContactIdAndContact.get(objCaseToUpdate.ContactId).Account.Owner.ManagerId);
            }
        }          
    }         
    
    /**
    * @description This method will be used to populate Regional Manager field on case creation.
    * @param objCaseToUpdate - Set of Contact Id.  
    * @param idAccountManager - Account Manager or Regional Manger Update.
    * @param idRegionalManager - List of new Case records to update AM or RM.
    */
    private static void updateManagersOnCase(Case objCaseToUpdate, Id idAccountManager,Id idRegionalManager) {  
        
        if(Schema.sObjectType.Case.fields.PMC_SS_AccountManager__c.isUpdateable() ) {
            objCaseToUpdate.PMC_SS_AccountManager__c = idAccountManager;
        }
        if(Schema.sObjectType.Case.fields.PMC_SS_RegionalManager__c.isUpdateable()) {
            objCaseToUpdate.PMC_SS_RegionalManager__c = idRegionalManager;
        }
        
        
    }
    
}