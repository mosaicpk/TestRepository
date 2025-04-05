import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/**
 * A Custom Mini Cart Modal.
 * @alias MiniCartModal
 * @description : To show added products in mini cart flyout
 * @author Himanshu Rathore <himrathore@deloitte.com>
 * @example
 * <c-mini-cart-modal></c-mini-cart-modal>
 */

export default class MiniCartModal extends NavigationMixin(LightningElement) {
    @track showCartData = false;
    showMiniCart = false;
    isSpinner = false;
    _showEmptyCart = false;
    cartId;
    cartItemsList = [
        { productName: "Freshly Brewed Coffee Venti", sku: "SKU001" },
        { productName: "Mocha Frappuccino Mini", sku: "SKU002" },
        { productName: "Chocolate Chip Cookie", sku: "SKU003" },
        { productName: "Butter Croissant", sku: "SKU004" }
    ];

    /*
     * To Toggale Mini Cart 
     */
    cartClickHandler() {
        this.showMiniCart = !this.showMiniCart;
        this.showMiniCartData();
    }

    /*
     * To Show/Open Mini Cart Data after fetchMiniCartItems Method Call
     */
    showMiniCartData() {
        this.showCartData = this.cartItemsList.length > 0 ? true : false;
        this._showEmptyCart = !this.showCartData;
        this.isSpinner = false;
    }

    /*
     * To Close Mini Cart Modal 
     */
    closeMiniCartHandler() {
        this.showMiniCart = false;
    }

    /*
     * Delete icon Key Press in Mini Cart Modal 
     */
    deleteIconKeypressHandler(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
            this.handleRemoveItem(event);
        }
    }

    /* 
     * To Remove Products from mini cart modal 
     */
    handleRemoveItem(event) {
        this.isSpinner = true;
        this.deleteProduct(event);
    }

    /* 
     * Backend method to remove product  
     */
    deleteProduct(event) {
        const index = event.target.dataset.sku;
        if (index !== undefined) {
            this.cartItemsList.splice(index, 1);
            this.cartItemsList = [...this.cartItemsList];
        }
        this.showMiniCartData();
        this.isSpinner = false;
    }

    /* 
     * To Navigate Cart Page on Btn Click
     */
    cartCheckoutHandler() {
        this.closeMiniCartHandler();
    }

}