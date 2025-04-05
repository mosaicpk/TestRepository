/**
 * @description       : 
 * @author            : siddharth.pradhan@mosaicco.com | Digital Hub
 * @group             : 
 * @last modified on  : 08-03-2023
 * @last modified by  : siddharth.pradhan@mosaicco.com | Digital Hub
**/
public with sharing class PMC_DH_CartTriggerHandler extends PMC_TriggerHandler {


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
 private List<WebCart> lstNewCarts;
 private Map<Id,WebCart> mapNewCarts;
 private List<WebCart> lstOldCarts;
 private Map<Id,WebCart> mapOldCarts;
 
 
   
 
 /**
 * @description Constructor method to initialize class level variables and store the trigger collections and add the max loop count of trigger
 */

 public PMC_DH_CartTriggerHandler(){    
     
     //Instantiating local class variables from trigger variables
     this.lstNewCarts = Trigger.new;
     this.mapNewCarts = (Map<Id, WebCart>) Trigger.newMap;
     this.lstOldCarts = Trigger.old;
     this.mapOldCarts = (Map<Id, WebCart>) Trigger.oldMap;
     
     //Set the maximum calls allowed for the class
     this.setMaxLoopCount(8);
 }

 
 /**
 * @description 
 * @author siddharth.pradhan@mosaicco.com | Digital Hub | 08-02-2023 
 **/
 public override void afterUpdate(){

     PMC_CartItemTriggerHelper.updateCartSequence(mapNewCarts,mapOldCarts);

 }

 
  
}