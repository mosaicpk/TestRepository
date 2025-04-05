import { LightningElement } from 'lwc';

/**
 * A Custom Header with Search Bar and Mini Cart Page Headers 
 * @alias Reusable_header
 * @description : Page headers are used at the top of several page.
 * @author Himanshu Rathore <himrathore@deloitte.com>
 * @example
 * <c-reusable_header></<c-reusable_header>
 */

export default class Reusable_header extends LightningElement {

    navItems = [
        {option: 'Home'},
        {option: 'About'},
        {option: 'Products'},
        {option: 'Blog'},
        {option: 'News'},
        {option: 'Contact'},
    ]

    /* Open header menu items in mobile view */
    hanburgerClickHandler() {
        this.template.querySelector(".mobile-nav").classList.toggle("slds-show_large");
    }

    /* Open search in mobile view */
    notificationClickHandler() {
        this.template.querySelector(".search-bar-mobile").classList.toggle("slds-hide");
    }
}