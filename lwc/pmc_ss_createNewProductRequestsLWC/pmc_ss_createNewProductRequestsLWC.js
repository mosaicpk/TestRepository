import {LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import PAGE_TITLE from '@salesforce/label/c.PMC_SS_ProductRequest_PageTitleMessage';
import SUCCESS_MESSAGE from '@salesforce/label/c.PMC_SS_ProductRequest_SuccessMessage';
import ERROR_MESSAGE from '@salesforce/label/c.PMC_SS_ProductRequest_ErrorMessage';

export default class CreateNewProductRequests extends NavigationMixin(LightningElement) {
    @api recordId;
    keyIndex = 0;
    label = {
        PAGE_TITLE
    }
    @track itemList = [
        {
            id: 0
        }
    ];
    
    addRow() {
        ++this.keyIndex;
        let newItem = { id: this.keyIndex };
        this.itemList.push(newItem);
    }

    deleteRow(event) {
        if (this.itemList.length > 1) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    handleSubmit() {
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
        });
        if (isVal) {
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit();
            });
            const evt = new ShowToastEvent({
                title: 'Success!',
                message: SUCCESS_MESSAGE,
                variant: 'success'
            });
            this.dispatchEvent(evt);
            //   Navigate to the Case page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                },
            });
        } else {
            const evt = new ShowToastEvent({
                title: 'Error!',
                message: ERROR_MESSAGE,
                variant: 'error'
            });   
            this.dispatchEvent(evt);
        }
    }

   }