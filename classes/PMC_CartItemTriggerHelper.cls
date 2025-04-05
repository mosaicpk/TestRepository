/**
 * @description       : 
 * @author            : siddharth.pradhan@mosaicco.com | Digital Hub
 * @group             : 
 * @last modified on  : 08-03-2023
 * @last modified by  : siddharth.pradhan@mosaicco.com | Digital Hub
**/
public without sharing class PMC_CartItemTriggerHelper {
 

  

    /**
    * @description 
    * @author siddharth.pradhan@mosaicco.com | Digital Hub | 08-03-2023 
    * @param mapNewCarts 
    * @param mapOldCarts 
    **/
    public static void updateCartSequence(Map<Id,WebCart> mapNewCarts,Map<Id,WebCart> mapOldCarts) {
        
        try {
			Set<Id> setCartIds=new Set<Id>();
            for(Id key : mapNewCarts.keySet()){
                if((mapOldCarts.get(key).PMC_DH_CartItem_Count__c != mapNewCarts.get(key).PMC_DH_CartItem_Count__c)){
                // update cart item sequence 
                Id cartId=mapNewCarts.get(key).Id;
                setCartIds.add(cartId);
               }
               updateSequenceOnCartItem(setCartIds);
           }
         
        }    
        catch(Exception objQueryException) {
            PMC_ErrorLogClass.processException(objQueryException);
        }
    }
    

    private static void updateSequenceOnCartItem(Set<Id> cartId) {
    	List<Id> cartIds=new List<Id>();
        cartIds.addAll(cartId);
        List<CartItem> cartItem=[SELECT ID from CartItem where CartId =:cartIds[0] WITH SECURITY_ENFORCED order by CreatedDate ];
        Integer cartSequence=1;
        for (CartItem ci : cartItem) {
            ci.PMC_DH_Number__c=cartSequence;
            cartSequence ++;
        }
        if(Schema.sObjectType.CartItem.isCreateable()&&Schema.sObjectType.CartItem.isUpdateable())
        {
            upsert cartItem;
        }
    


    }
}