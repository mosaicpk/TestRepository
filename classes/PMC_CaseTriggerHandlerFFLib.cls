/**
* @description This class will be used to handle all trigger operations of Case object
* @author Sayali Shinde
* @storynumber GDASF-1941
*/

public without sharing class PMC_CaseTriggerHandlerFFLib extends fflib_SObjectDomain {

    /**
    * These boolean variables are used to bypass the trigger operations
    */
    private static final Boolean BOOL_BYPASS_BEFORE_INSERT;
    private static final Boolean BOOL_BYPASS_BEFORE_UPDATE;
    private static final Boolean BOOL_BYPASS_BEFORE_DELETE;
    private static final Boolean BOOL_BYPASS_AFTER_INSERT;
    private static final Boolean BOOL_BYPASS_AFTER_UPDATE;
    private static final Boolean BOOL_BYPASS_AFTER_DELETE;
    private static final Boolean BOOL_BYPASS_AFTER_UNDELETE;
    
    @testVisible
    public static Boolean boolBypassTriggerLogic = false;
    
    /**
    * @description This static block initializes the trigger switches when the class is invoked
    */
    static{
        
        PMC_TriggerSwitches__mdt operationSwitches = PMC_TriggerSwitches__mdt.getInstance('Case');
        
        BOOL_BYPASS_BEFORE_INSERT = operationSwitches.PMC_BeforeInsert__c;
        BOOL_BYPASS_BEFORE_UPDATE = operationSwitches.PMC_BeforeUpdate__c;
        BOOL_BYPASS_BEFORE_DELETE = operationSwitches.PMC_BeforeDelete__c;
        BOOL_BYPASS_AFTER_INSERT = operationSwitches.PMC_AfterInsert__c;
        BOOL_BYPASS_AFTER_UPDATE = operationSwitches.PMC_AfterUpdate__c;
        BOOL_BYPASS_AFTER_DELETE = operationSwitches.PMC_AfterDelete__c;
        BOOL_BYPASS_AFTER_UNDELETE = operationSwitches.PMC_AfterUndelete__c;
        
    }
      
    
    /**
    * @description Constructor method to initialize class level variables and store the trigger collections and add the max loop count of trigger
    * @param lstCaseRecords list of triggering cases
    */
    
    public PMC_CaseTriggerHandlerFFLib(List<Case> lstCaseRecords) {
        super(lstCaseRecords);
    }

    /**
    * @description fflib constructor implementation
    */
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {

        /**
        * @description fflib SObjectDomain construct
        * @param lstSobjectRecords List of SObject
        * @return fflib_SObjectDomain object type
        */

        public fflib_SObjectDomain construct(List<SObject> lstSobjectRecords) {
            return new PMC_CaseTriggerHandlerFFLib(lstSobjectRecords);
        }
    }
    
    /**
    * @description This method will perform the operation for before insert trigger
    */
    
    public override void onBeforeInsert(){
        if(BOOL_BYPASS_BEFORE_INSERT  || boolBypassTriggerLogic){
            return;
        }
        
        PMC_CaseTriggerHelper.updateCasePriority(records);
        PMC_CaseTriggerHelper.updateIsEscalatedFlag(null, records);
    }
    
    
    /**
    * @description This method will perform the operation for before update trigger
    * @param mapOldRecords Map of old case records
    */

    public override void onBeforeUpdate(Map<Id,SObject> mapOldRecords){
        if(BOOL_BYPASS_BEFORE_UPDATE  || boolBypassTriggerLogic){
            return;
        }
                
        PMC_CaseTriggerHelper.checkBusinessDaysOnCaseReOpen((Map<Id, Case>) mapOldRecords, records);
        PMC_CaseTriggerHelper.updateIsEscalatedFlag((Map<Id, Case>) mapOldRecords, records);
    }
    
    /**
    * @description This method will perform the operation for after update trigger
    * @param mapOldRecords Map of old case records
    */

    public override void onAfterUpdate(Map<Id,SObject> mapOldRecords){
        if(BOOL_BYPASS_AFTER_UPDATE  || boolBypassTriggerLogic){
            return;
        }
    }
}