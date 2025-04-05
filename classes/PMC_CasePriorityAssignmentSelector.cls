/**
* @description This class will be used to handle all the PMC_SS_CasePriorityAssignment__mdt related queries.
* @author Sayali Shinde
*/

public class PMC_CasePriorityAssignmentSelector extends fflib_SObjectSelector implements PMC_ICasePriorityAssignmentSelector {

    /** 
     * @description Application Selector Factory Instance for PMC_SS_CasePriorityAssignment__mdt Object
     */
    
	public static final fflib_Application.SelectorFactory objSelector = new fflib_Application.SelectorFactory(new Map<SObjectType, Type> {
																		PMC_SS_CasePriorityAssignment__mdt.SObjectType => PMC_CasePriorityAssignmentSelector.class });
	
    
	/** 
     * @description Instance for PMC_CasePriorityAssignmentSelector
    */
    
    public static PMC_CasePriorityAssignmentSelector newInstance() {
        return (PMC_CasePriorityAssignmentSelector) objSelector.newInstance(PMC_SS_CasePriorityAssignment__mdt.SObjectType);
    }
    
    /**
     * @description This is a mandatory method of fflib Selector layer. 
     * Indicating which SObject the selector is for
     */
    
	public Schema.SObjectType getSObjectType() {
		return PMC_SS_CasePriorityAssignment__mdt.SObjectType;
	}  
    
    
    /**
     * @description This is a mandatory method of fflib Selector layer. 
     * Indicating which fields should be selected from current SObject.
     */
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			PMC_SS_CasePriorityAssignment__mdt.MasterLabel,
			PMC_SS_CasePriorityAssignment__mdt.PMC_SS_Priority__c,
            PMC_SS_CasePriorityAssignment__mdt.PMC_SS_Segmentation__c,
            PMC_SS_CasePriorityAssignment__mdt.PMC_SS_Type__c
		};
	}
    

  	/**
     * @description This method is used to retrieve all PMC_SS_CasePriorityAssignment__mdt records. 
     */   
    
    public List<PMC_SS_CasePriorityAssignment__mdt> getCasePriorityAssignmentMetadata() {
        fflib_QueryFactory objQueryFactory = newQueryFactory();
        return (List<PMC_SS_CasePriorityAssignment__mdt>) Database.query(objQueryFactory.toSOQL());    
    }
}