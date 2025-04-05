/**
* @description This class will be used to handle all the Contact related queries.
* @author Sayali Shinde
*/

public class PMC_ContactSelector extends fflib_SObjectSelector implements PMC_IContactSelector {

    /** 
     * @description Application Selector Factory Instance for Contact Object
     */
    
	public static final fflib_Application.SelectorFactory objSelector = new fflib_Application.SelectorFactory(new Map<SObjectType, Type> {
																		Contact.SObjectType => PMC_ContactSelector.class });
	
    
	/** 
     * @description Instance for PMC_ContactSelector
    */
    
    public static PMC_ContactSelector newInstance() {
        return (PMC_ContactSelector) objSelector.newInstance(Contact.SObjectType);
    }
    
    /**
     * @description This is a mandatory method of fflib Selector layer. 
     * Indicating which SObject the selector is for
     */
    
	public Schema.SObjectType getSObjectType() {
		return Contact.SObjectType;
	}  
    
    
    /**
     * @description This is a mandatory method of fflib Selector layer. 
     * Indicating which fields should be selected from current SObject.
     */
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Contact.Id,
			Contact.AccountId
		};
	}
    
    
  	/**
     * @description This method is used to retrieve Contacts from contact ids records. 
     * @params setId Set of Contact Ids
     * Uses standard fflib selectSObjectsById method to retrieve the records by Contact ids.
     */   
    
    public List<Contact> getContactsById(Set<Id> setId) {
        return (List<Contact>) selectSObjectsById(setId);
    }
}