import { LightningElement, wire, api, track} from 'lwc';
import { CartItemsAdapter } from 'commerce/cartApi';
import { deleteItemFromCart } from 'commerce/cartApi';
import updateOrderItem from '@salesforce/apex/PMC_DH_POC.updateOrderItem';
import getSeedzResponse from '@salesforce/apex/PMC_DH_POC.getSeedzResponse';
import getSeedzBalResponse from '@salesforce/apex/PMC_DH_POC.getSeedzBalResponse'

export default class Pmc_dh_miniCartUtility extends LightningElement {
   
    @wire(CartItemsAdapter)
    CartItemsAdapterHandler(response) {
        if (response.data) {
            let cartItems = response.data.cartItems;
            cartItems.forEach(function(item){
                console.log('Item'+item);
                console.log('Item CartId'+item.cartItem.cartId);
                console.log('Item CartItem Id'+item.cartItem.cartItemId);
            });
           console.log('response data'+JSON.stringify(response.data));
        } else if (response.error) {
            console.log('response error'+JSON.stringify(response.error));
        }

    }

    handleRemoveItem(event) {
        let productSku = event.target.dataset.sku;
        this.callUpdateItemInCart(productSku);
    }

    async callUpdateItemInCart(itemId) {
        try {
            const response = await deleteItemFromCart(itemId);
            this.fetchMiniCartItems(this.effectiveAccountId);
        } catch (error) {
            this.error = JSON.parse(JSON.stringify(error));
        }

    }    
    handleUpdate(){
    updateOrderItem();
}



getResponse(){
    getSeedzResponse();

}

getSeedzBalResponse(){
    getSeedzBalResponse();
}

}