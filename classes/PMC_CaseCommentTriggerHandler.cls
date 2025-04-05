/**
* @description This class will be used to handle all trigger operations of Case object
* @author Vedashri
* @storynumber GDASF-1941
*/
public with sharing class PMC_CaseCommentTriggerHandler extends PMC_TriggerHandler  {
    
    /**
    * These boolean variables are used to bypass the trigger operations
    */
    private static final Boolean BOOL_BYPASS_AFTER_INSERT;
    
    @testVisible
    public static Boolean boolBypassTriggerLogic = false;
    
    /**
	* These variables will hold the copy of trigger variables
	*/
    private List<CaseComment> lstNewCasesComment;
    
    /**
    * @description This static block initializes the trigger switches when the class is invoked
    */
    static{
        
        PMC_TriggerSwitches__mdt operationSwitches = PMC_TriggerSwitches__mdt.getInstance('CaseComment');
        BOOL_BYPASS_AFTER_INSERT = operationSwitches.PMC_AfterInsert__c;
        for(Profile objProfile : [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() WITH SYSTEM_MODE] ) {
            if(objProfile.Name.contains(Label.PMC_SS_DigitalHub_ProfileName))
            {
                boolBypassTriggerLogic = true;
            } 
        }
        
    }
    
    /**
    * @description Constructor method to initialize class level variables and store the trigger collections and add the max loop count of trigger
    */
 
    public PMC_CaseCommentTriggerHandler(){    
        
        //Instantiating local class variables from trigger variables
        this.lstNewCasesComment = Trigger.new;
        //Set the maximum calls allowed for the class
        this.setMaxLoopCount(8);
    }

    
    /**
    * @description This method will perform the operation for before insert trigger
    */
    
    public override void afterInsert(){
        if(BOOL_BYPASS_AFTER_INSERT  || boolBypassTriggerLogic){
            return;
        }
        //PMC_SS_CaseServiceNowUpdateCtrl.addComments(lstNewCasesComment[0].Id);
        ////PMC_CaseTriggerHelperExtension.updateCaseTypebasedOnSubject(lstNewCases);
       
        
    }
}