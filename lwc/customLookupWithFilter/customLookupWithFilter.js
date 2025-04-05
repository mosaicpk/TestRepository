import { api, LightningElement, track, wire } from 'lwc';
import lookUp from '@salesforce/apex/PMC_SS_CustomLookupFieldController.searchOrder';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Case.AccountId'];

export default class CustomLookupWithFilter extends LightningElement {

    @api objName;
    @api iconName;
    @api filter = '';
    @api recordId;
    @api searchPlaceholder='Search';

    @track selectedName;
    @track records;
    @track recordsCopy;

    @track initialCallout = true;

    @track isValueSelected = false;
    @track blurTimeout;

    @track searchTerm = '';

    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('Data --> ' + data);
            if(data.fields.AccountId.value) {
                this.filter = data.fields.AccountId.value; 
                if(this.filter != '' && this.filter != null && this.filter != undefined) {
                    this.fetchOrders();
                }
            }
        } 
        else if (error) {

        }
    }

    fetchOrders() {

        lookUp({strSearchTerm: this.searchTerm, strObjectName : this.objName, strFilter : this.filter}).then(result => {

            if(result != undefined) {

                if(this.filter != '' && this.initialCallout) {
                    this.recordsCopy = result;
                    this.initialCallout = false;
                }

                this.records = result;
            }
        }).catch(error => {

        });
    }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;

        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);

        this.isValueSelected = true;

        this.selectedName = selectedName;

        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }

        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
        this.selectedName = '';
        this.searchTerm = '';

        if(this.filter != '') {
            this.records = this.recordsCopy;
        }

        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';

        const valueRemoveEvent = new CustomEvent('lookupremoved', {detail: ''});
        this.dispatchEvent(valueRemoveEvent);
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        if(this.filter != '' && this.searchTerm != '') {
            let filteredData = this.handleSearch(this.recordsCopy, this.searchTerm);
            this.records = filteredData;
        }
        else if(this.filter == '' && this.searchTerm != '') {
            console.log('No Filter');
            this.fetchOrders();
        }
    }

    handleSearch = (array, searchText) => {
        const filteredData = array.filter(order => {
            if(order.OrderNumber.includes(searchText)) {
                return order;
            }
        });
        return filteredData;
    }

    @api validateFields() {

        var orderElement = this.template.querySelector('lightning-input');

        if(orderElement) {

            orderElement.setCustomValidity('');
            orderElement.reportValidity();
        
            if(!this.isValueSelected) {
                orderElement.setCustomValidity('Select the Order to Proceed further');
                orderElement.reportValidity();
    
                this.scrollToItem(orderElement);
                orderElement.setFocus();
    
                return false;
            }
        }

        return true;
    }

    scrollToItem(item) {
        setTimeout(() => {
            if(item && item.scrollIntoView) {
                item.scrollIntoView({
                    behavior: "smooth",
                    block: "center"
                });
            }
        });
    }
}