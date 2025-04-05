/**
* @description This class will be used to handle all trigger operations of Quote (SBQQ_Quote__c) object
* @author Lalit Sharma
* @storynumber GDASF-8944
*/
public without sharing class PMC_CPQ_QuoteTriggerHandler extends PMC_TriggerHandler{
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
* These variables will hold the copy of trigger variables
*/
    private List<SBQQ__Quote__c> lstNewQuotes;
    private Map<Id,SBQQ__Quote__c> mapNewQuotes;
    private List<SBQQ__Quote__c> lstOldQuotes;
    private Map<Id,SBQQ__Quote__c> mapOldQuotes;
    
    
    /**
* @description This static block initializes the trigger switches when the class is invoked
*/
    static{
        
        PMC_TriggerSwitches__mdt operationSwitches = PMC_TriggerSwitches__mdt.getInstance('Quote');
        
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
*/
    public PMC_CPQ_QuoteTriggerHandler(){    
        
        //Instantiating local class variables from trigger variables
        this.lstNewQuotes = Trigger.new;
        this.mapNewQuotes = (Map<Id, SBQQ__Quote__c>) Trigger.newMap;
        this.lstOldQuotes = Trigger.old;
        this.mapOldQuotes = (Map<Id, SBQQ__Quote__c>) Trigger.oldMap;
        
        //Set the maximum calls allowed for the class
        //this.setMaxLoopCount(32);
        //GCPM-1751 - Start
        for(SBQQ__Quote__c objquote:this.lstNewQuotes){
            if(objquote.PMC_CPQ_LegacyQuoteID__c != null){
        			this.setMaxLoopCount(150);        
            }
            else
            {
                this.setMaxLoopCount(32);
            }
        }
        //GCPM-1751 - End
    }
    
    /**
    * @description This method will perform the operation for before insert trigger
    */
    public override void beforeInsert(){
        if(BOOL_BYPASS_BEFORE_INSERT  || boolBypassTriggerLogic){
            return;
        }
        // PMC_CPQ_QuoteTriggerHelper.clearLegacyQuoteIdWhileClonning(this.lstNewQuotes);
    }
    
    /**
* @description This method will perform the operation for before update trigger
*/
    public override void beforeUpdate(){
        if(BOOL_BYPASS_BEFORE_UPDATE  || boolBypassTriggerLogic){
            return;
        }
        
        
             PMC_CPQ_QuoteTriggerHelper.validateQuoteExpiration(lstNewQuotes, mapOldQuotes);
    }
    
    /**
* @description This method will perform the operation for before delete trigger
*/
    public override void beforeDelete(){
        if(BOOL_BYPASS_BEFORE_DELETE  || boolBypassTriggerLogic){
            return;
        }
       
    }
    
    /**
* @description This method will perform the operation for after insert trigger
*/
    public override void afterInsert(){
        if(BOOL_BYPASS_AFTER_INSERT  || boolBypassTriggerLogic){
            return;
        }
    }
    
    /**
* @description This method will perform the operation for after update trigger
*/
    public override void afterUpdate(){
        if(BOOL_BYPASS_AFTER_UPDATE || boolBypassTriggerLogic){
            return;
        }
        /* GSMD-384  */
       /* Set<ID> SetOfContractID=new  Set<ID>();
        for(SBQQ__Quote__c objquote:this.lstNewQuotes){
            if(objquote.SBQQ__Type__c=='Amendment' && objquote.PMC_CPQ_ContractStageName__c=='Accepted' && 
               objquote.SBQQ__MasterContract__c!=null && objquote.PMC_CPQ_ContractEnd__c!=null && objquote.PMC_CPQ_ContractStart__c!=null){
                SetOfContractID.add(objquote.SBQQ__MasterContract__c);
            }
        }
    if(SetOfContractID.size()>0){
    List<Contract> enddateupdate=new  List<Contract> ();
    for(Contract obj:[Select id,PMC_CPQ_LatestQuote__c,PMC_CPQ_LatestQuote__r.PMC_CPQ_ContractEnd__c,EndDate,
    PMC_CPQ_LatestQuote__r.PMC_CPQ_ContractStart__c ,StartDate
                        from Contract where id in:SetOfContractID]){ 
    if(obj.PMC_CPQ_LatestQuote__r.PMC_CPQ_ContractEnd__c !=obj.EndDate){
    obj.EndDate=obj.PMC_CPQ_LatestQuote__r.PMC_CPQ_ContractEnd__c;        
    }  
    if(obj.PMC_CPQ_LatestQuote__r.PMC_CPQ_ContractStart__c !=obj.StartDate){
    obj.StartDate=obj.PMC_CPQ_LatestQuote__r.PMC_CPQ_ContractStart__c ;        
    }       
    enddateupdate.add(obj);
    }
    
    if(enddateupdate.size()>0){
    update enddateupdate;
    }
    }*/
        
    }
    
    /**
* @description This method will perform the operation for after delete trigger
*/
    public override void afterDelete(){
        if(BOOL_BYPASS_AFTER_DELETE || boolBypassTriggerLogic){
            return;
        }
        
    }
    
    /**
* @description This method will perform the operation for after undelete trigger
*/
    public override void afterUndelete(){
        if(BOOL_BYPASS_AFTER_UNDELETE || boolBypassTriggerLogic){
            return;
        }        
    }
    
}