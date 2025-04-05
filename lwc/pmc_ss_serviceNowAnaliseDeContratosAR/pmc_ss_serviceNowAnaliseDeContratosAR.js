import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import getAccountRelatedDetails from '@salesforce/apex/PMC_SS_CaseServiceNowUpdateCtrl.getAccountRelatedDetails';

export default class Pmc_ss_serviceNowAnaliseDeContratosAR extends NavigationMixin(LightningElement) {

    @api fieldset = [];
    @api recordid = '';

    @track companies = [];
    @track requestTypes = [];
    @track contracts = [];
    @track orders = [];

    @track manager = '';
    @track name = '';
    @track company = '';
    @track requestType = '';

    @track depositOnBehalf;
    @track contractsAdded;

    @track isLoading = false;

    connectedCallback() {
        console.log('INside AnaliseDe --> recordid ' + this.recordid);
        console.log('INside AnaliseDe --> fieldset ' + this.fieldset);
    }

    /*@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if(data) {
            console.log('**Data --> ' + JSON.stringify(data));

            if(data.fields.AccountId.value) {
                this.fetchOrdersAndContracts(data.fields.AccountId.value);
            }
            
            if(data.fields.CreatedBy.displayValue) {
                this.manager = data.fields.CreatedBy.displayValue;
            }

            if(data.fields.Contact.displayValue) {
                this.name = data.fields.Contact.displayValue;
            }

            if(data.fields.PMC_SS_SNOW_Company__c.value) {
                this.company = data.fields.PMC_SS_SNOW_Company__c.value;

                if(this.companies.length > 0 && this.company != null && this.company != '') {
                    for(var i=0; i<this.companies.length; i++) {
                        if(this.company == this.companies[i]) {
                            this.template.querySelector('[name="company"]').selectedIndex = i;
                        }
                    }
                }
            }

            if(data.fields.PMC_SS_SNOW_RequestType__c.value) {
                this.requestType = data.fields.PMC_SS_SNOW_RequestType__c.value;
            }

            if(data.fields.PMC_SS_SNOW_DepositOnBehalfOfTP__c.value) {
                this.depositOnBehalf = data.fields.PMC_SS_SNOW_DepositOnBehalfOfTP__c.value;
            }

            if(data.fields.PMC_SS_SNOW_ContractsAdded__c.value) {
                this.contractsAdded = data.fields.PMC_SS_SNOW_ContractsAdded__c.value;
            }


        }
        else if(error) {

        }
    }

    connectedCallback() {

        getPickListValues({
            strObjApiName: 'Case',
            strFieldName: 'PMC_SS_SNOW_Company__c'
        }).then(data => {
                if(data) {
                    this.companies.push({
                        label: "--- Select ---",
                        value: "--- Select ---"
                    });
                    for (var i=0; i<data.length; i++) {
                        this.companies.push({
                            label:   data[i].label,
                            value: data[i].value
                        });
                    }
                }
        }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Error in fetching data",
                      message: error.body.message,
                      variant: "error",
                    }),
                  );
        });

    
    getPickListValues({
            strObjApiName: 'Case',
            strFieldName: 'PMC_SS_SNOW_RequestType__c'
        }).then(data => {
                if(data) {
                    this.requestTypes.push({
                        label: "--- Select ---",
                        value: "--- Select ---"
                    });
                    for (var i=0; i<data.length; i++) {
                        this.requestTypes.push({
                            label:   data[i].label,
                            value: data[i].value
                        });
                    }
                }
        }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Error in fetching data",
                      message: error.body.message,
                      variant: "error",
                    }),
                  );
        });      

    }

    handleOnChange(e) {
        let id = this.getRealId(e.target.id);


        if(id == 'requestType') {
            this.requestType = e.target.value;
        }
        else if(id == 'company') {

        }
        else if(id == 'order') {

        }
        else if(id == 'depositOnBehalf') {

        }
        else if(id == 'contractsAdded') {

        }
    }

    fetchOrdersAndContracts(strAccountId) {

        getAccountRelatedDetails({strAccountId: strAccountId}).then(result => {
            if(result != undefined && result != null) {
                console.log('Account Details --> ' + JSON.stringify(result));

                this.orders.push({
                    'Id' : '--- Select ---',
                    'OrderNumber' : '--- Select ---'
                });

                for(var i=0; i<result.Orders.length; i++) {
                    this.orders.push({
                        'Id' : result.Orders[i].Id,
                        'OrderNumber' : result.Orders[i].OrderNumber
                    });
                }

                this.contracts.push({
                    'Id' : '--- Select ---',
                    'ContractNumber' : '--- Select ---'
                });

                for(var i=0; i<result.Contracts.length; i++) {
                    this.contracts.push({
                        'Id' : result.Contracts[i].Id,
                        'ContractNumber' : result.Contracts[i].ContractNumber
                    });
                }
            }
            else {

            }
        }).catch(error => {

        });
    }

    getRealId(id) {
        const parts = (id || "").split("-");
        parts.pop();
        return parts.join("-");
    }*/
}