/**
* @description This class will be used to handle all the BusinessHours related queries.
* @author Sayali Shinde
*/

public class PMC_BusinessHoursSelector extends fflib_SObjectSelector implements PMC_IBusinessHoursSelector {

    /** 
     * @description Application Selector Factory Instance for BusinessHours Object
     */
    
	public static final fflib_Application.SelectorFactory objSelector = new fflib_Application.SelectorFactory(new Map<SObjectType, Type> {
																		BusinessHours.SObjectType => PMC_BusinessHoursSelector.class });
	
	
    /** 
     * @description Instance for PMC_IBusinessHoursSelector
    */
    
    public static PMC_IBusinessHoursSelector newInstance() {
        return (PMC_IBusinessHoursSelector) objSelector.newInstance(BusinessHours.SObjectType);
    }
    
    /**
     * @description This is a mandatory method of fflib Selector layer. 
     * Indicating which SObject the selector is for
     */
    
	public Schema.SObjectType getSObjectType() {
		return BusinessHours.SObjectType;
	}
    
    /**
     * @description This is a mandatory method of fflib Selector layer. 
     * Indicating which fields should be selected from current SObject.
     */
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			BusinessHours.Id,
			BusinessHours.IsDefault,
			BusinessHours.IsActive
		};
	}
    
    
     /**
     * @description This is method is used to retrieve the default Business hour. 
     * return This method will return default BusinessHour
     */
    
    public BusinessHours getDefaultBusinessHour() {
        fflib_QueryFactory objQueryFactory = newQueryFactory(true, true, true)
            												.setCondition(PMC_SS_ConstantClass.DEFAULT_BUSINESS_HOUR_CONDITION)
            												.setLimit(1);
        return (BusinessHours) Database.query(objQueryFactory.toSOQL());    
    }
}