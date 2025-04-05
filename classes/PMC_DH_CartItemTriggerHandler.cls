/**
 * @description       : 
 * @author            : siddharth.pradhan@mosaicco.com | Digital Hub
 * @group             : 
 * @last modified on  : 08-03-2023
 * @last modified by  : siddharth.pradhan@mosaicco.com | Digital Hub
**/
public with sharing class PMC_DH_CartItemTriggerHandler extends PMC_TriggerHandler {


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
 private List<CartItem> lstNewCartItems;
 private Map<Id,CartItem> mapNewCartItems;
 private List<CartItem> lstOldCartItems;
 private Map<Id,CartItem> mapOldCartItems;
 
 
   
 
 /**
 * @description Constructor method to initialize class level variables and store the trigger collections and add the max loop count of trigger
 */

 public PMC_DH_CartItemTriggerHandler(){    
     
     //Instantiating local class variables from trigger variables
     this.lstNewCartItems = Trigger.new;
     this.mapNewCartItems = (Map<Id, CartItem>) Trigger.newMap;
     this.lstOldCartItems = Trigger.old;
     this.mapOldCartItems = (Map<Id, CartItem>) Trigger.oldMap;
     
     //Set the maximum calls allowed for the class
     this.setMaxLoopCount(8);
 }

 
 /**
 * @description 
 * @author siddharth.pradhan@mosaicco.com | Digital Hub | 08-02-2023 
 **/
 public override void afterInsert(){

     PMC_CartItemTriggerHelper.updateCartSequence(lstNewCartItems,lstOldCartItems);

 }

 public override void afterDelete(){
    if(BOOL_BYPASS_AFTER_DELETE || boolBypassTriggerLogic){
        return;
    }
    PMC_CartItemTriggerHelper.updateCartSequence(lstNewCartItems,lstOldCartItems);
}
 
  
}