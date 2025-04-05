/**
* @description This class will be used to handle all the Account related queries.
* @author Sayali Shinde
*/

public class PMC_AccountSelector extends fflib_SObjectSelector implements PMC_IAccountSelector {

    /** 
     * @description Application Selector Factory Instance for Account Object
     */
    
	public static final fflib_Application.SelectorFactory objSelector = new fflib_Application.SelectorFactory(new Map<SObjectType, Type> {
																		Account.SObjectType => PMC_AccountSelector.class });
	
    
	/** 
     * @description Instance for PMC_ContactSelector
    */
    
    public static PMC_AccountSelector newInstance() {
        return (PMC_AccountSelector) objSelector.newInstance(Account.SObjectType);
    }
    
    /**
     * @description This is a mandatory method of fflib Selector layer. 
     * Indicating which SObject the selector is for
     */
    
	public Schema.SObjectType getSObjectType() {
		return Account.SObjectType;
	}  
    
    
    /**
     * @description This is a mandatory method of fflib Selector layer. 
     * Indicating which fields should be selected from current SObject.
     */
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Account.Id,
			Account.Name,
            Account.PMC_SS_Segmentation__c    
		};
	}
    
    public List<Account> getAccountsById(Set<Id> setId, List<String> setIdFromContact) {
        fflib_QueryFactory objQueryFactory = newQueryFactory().setCondition(PMC_SS_ConstantClass.ACCOUNT_ID_SEGMENTATION_CONDITION);
        return (List<Account>) Database.query(objQueryFactory.toSOQL());    
    }
}