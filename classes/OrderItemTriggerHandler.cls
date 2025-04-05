/**
* @description This class will be used to handle all trigger operations of OrderItem object
* @author Raphael Soares
* @storynumber GCPM-2396 - FPD I - PM Approval Workflow and Approvers
*/
public without sharing class OrderItemTriggerHandler extends PMC_TriggerHandler  {
    
    /**
    * These boolean variables are used to bypass the trigger operations
    */
    private static final Boolean BOOL_BYPASS_AFTER_UPDATE;
    
    @testVisible
    public static Boolean boolBypassTriggerLogic = false;
    
    /**
	* These variables will hold the copy of trigger variables
	*/
    private List<OrderItem> newOrderItems;
    private Map<Id,OrderItem> oldOrderItems;
    
    /**
    * @description This static block initializes the trigger switches when the class is invoked
    */
    static{
        
        PMC_TriggerSwitches__mdt operationSwitches = PMC_TriggerSwitches__mdt.getInstance('OrderItem');
        BOOL_BYPASS_AFTER_UPDATE = operationSwitches.PMC_AfterUpdate__c;
        
    }
    
    /**
    * @description Constructor method to initialize class level variables and store the trigger collections and add the max loop count of trigger
    */

    public OrderItemTriggerHandler(){    
        
        //Instantiating local class variables from trigger variables
        this.newOrderItems = Trigger.new;
        this.oldOrderItems = (Map<Id, OrderItem>)Trigger.oldMap;
        //Set the maximum calls allowed for the class
        this.setMaxLoopCount(8);
    }
    
    public override void afterUpdate(){
        if(BOOL_BYPASS_AFTER_UPDATE  || boolBypassTriggerLogic){
            return;
        }
        Set<Id> oItemIds = new Set<Id>();
        for(OrderItem item: newOrderItems){
            if(item.ApprovalStatus__c == 'Approved' && item.ApprovalStatus__c != oldOrderItems.get(item.Id).ApprovalStatus__c){
                oItemIds.add(item.Id);
            }
        }
        if(!oItemIds.isEmpty()){
            List<OrderItem> orderItems = [SELECT Id, OrderItemNumber, Order.OrderNumber, SBQQ__Contract__r.PMC_CPQ_ContractNumberIdentifier__c, PMC_CPQ_LinePONumber__c, PMC_CPQ_ShipTo__r.Name, Order.Account.Name, Product2.Name, Quantity, PMC_CPQ_PricingDate__c,  PMC_CPQ_FPDPricefromPriceFx__c, PMC_CPQ_FinalAgreedPrice__c, PMC_CPQ_OrderLineStatus__c, PMC_CPQ_OrderItemIntegrationStatus__c,PMC_CPQ_OrderItemIntegrationMessage__c,Order.PMC_CPQ_SAPOrderNumber__c
            FROM OrderItem
            WHERE Id IN :oItemIds];
            System.enqueueJob(new PMC_CPQ_FPDActionClass(orderItems,true));
        }

    }
}