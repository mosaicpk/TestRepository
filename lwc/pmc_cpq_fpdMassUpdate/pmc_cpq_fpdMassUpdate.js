import {LightningElement,track,api,wire} from 'lwc';
import getOPDetails from '@salesforce/apex/PMC_CPQ_FPDMassUpdateController.getOPDetails';
import getDefaultOrderLines from '@salesforce/apex/PMC_CPQ_FPDMassUpdateController.getDefaultOrderLines';
import getPriceFromPriceFX from '@salesforce/apex/PMC_CPQ_sendFPDOrderProductsSAPClass.getPriceFromPriceFX';
import saveOPFromUI from '@salesforce/apex/PMC_CPQ_sendFPDOrderProductsSAPClass.saveOPFromUI';
import userid from "@salesforce/user/Id";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { subscribe, onError} from 'lightning/empApi';
import noOL from '@salesforce/label/c.PMC_CPQ_NoOLSelectedFPDMassUpdate';
import fapMiss from '@salesforce/label/c.PMC_CPQ_FAPMissingFPDMassUpdate';
import sendFPDError from '@salesforce/label/c.PMC_CPQ_sendFPDErrorMassUpdate';
import getFPDError from '@salesforce/label/c.PMC_CPQ_getFPDErrorMassUpdate';
import getFPDIntSuccess from '@salesforce/label/c.PMC_CPQ_GetFPDIntSuccess';
import getFPDIntFail from '@salesforce/label/c.PMC_CPQ_GetFPDIntFail';
import sendFPDIntSuccess from '@salesforce/label/c.PMC_CPQ_SendFPDIntSuccess';
import sendFPDIntFail from '@salesforce/label/c.PMC_CPQ_SendFPDIntFail';
import sendFPDPartialSuccess from '@salesforce/label/c.PMC_CPQ_SendFPDPartialSuccess';
import getFPDPartialSuccess from '@salesforce/label/c.PMC_CPQ_GetFPDPartialSuccess';
import sendFPDPriceFXURL from '@salesforce/apex/PMC_CPQ_sendFPDOrderProductsSAPClass.sendFPDPriceFXURL';  

const columns = [{
    label: 'Order line',
    fieldName: 'lineName',
    type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'orderLine'
        },
        target: '_blank'
    }
},
{
    label: 'Order Number',
    fieldName: 'orderNum',
    type: 'text'
},
//For US GCPM - 2396
{
    label: 'Approval Status',
    fieldName: 'approvalStatus',
    type: 'text'
},
// {label: 'SAP Order Number',    type: 'text',    fieldName: 'sapOrderNumber'},
//For US GCPM - 2121,Added the label "SAP Order Line ID"
{label: 'SAP Order Line ID',type: 'text',fieldName: 'sapOrderLineID'},
{
    label: 'Contract Number',
    fieldName: 'contractNum',
    type: 'text'
},
{
    label: 'Customer Purchase Order #',
    fieldName: 'po',
    type: 'text'
},
{
    label: 'Ship To',
    fieldName: 'shipTo',
    type: 'text'
},
{
    label: 'Account Name',
    fieldName: 'accountName',
    type: 'text'
},
{
    label: 'Product',
    type: 'text',
    fieldName: 'productName'
},
{
    label: 'Quantity',
    type: 'Number',
    fieldName: 'quantity'
},
{
    label: 'Price By Date',
    type: 'Date',
    fieldName: 'priceByDate'
},
{
    label: 'List Price',
    type: 'Currency',
    fieldName: 'fpdPrice'
},
{
    label: 'Agreed Final Price',
    type: 'Currency',
    fieldName: 'finalAgreedPrice',
    editable: true
},
{
    label: 'Status',
    type: 'text',
    fieldName: 'status'
},
{
    label: 'Integration Message',
    type: 'text',
    fieldName: 'integrationMessage'
}
];
export default class Pmc_cpq_fpdMassUpdate extends LightningElement 
{
@track selectedRows = [];
@track showConvTable = false;
@track filteredData = [];
@track isFiltersPaneOpen = false;
@track data;
@track columns = columns;
@track availableItems ;
@track error;
@track initialRecords = {};
@track filterSearchRecords = {};
@track fldsItemValues = [];
@track fpdLines = [];
@track showdefault = false;
@track accountId;
@track productId;
@track OrderId;
@track shipTo;
@track ownerId = userid;
@track searchKey = '';
@track recordCount = 0;
@track recordQuantity = 0;
@track hasNullColumn;
@track suppress = false;
copyFilterSearchRecords;
subscription = {};
@api channelName = '/event/PMC_CPQ_FPDPriceFx__e'
@track finalWrapper={};
fpdEndpointPriceFX;
fpdEndpointSAP;


handleAccountChange(event){
    if(event.target.value){
        this.accountId = event.target.value;
    }
    else
    this.accountId = null;
}
handleOwnerChange(event){
    if(event.target.value){
        this.ownerId = event.target.value;
    }
    else
    this.ownerId = null;
}
handleProductChange(event){
    if(event.target.value){
        this.productId = event.target.value;
         console.log('productID clicked!'); // Checking the Product ID
    }
    else
    this.productId = null;
}
handleShipToChange(event){
    if(event.target.value){
        this.shipTo = event.target.value;
    }
    else
    this.shipTo = null;
}
handleOrderChange(event){
    if(event.target.value){
        this.OrderId = event.target.value;
    }
    else{
        this.OrderId = null;
    }
}

//Function which calls the getDefaultOrderLines() method and returns the Order Lines owned by the Logged in user
async connectedCallback() {
    getDefaultOrderLines().then((result => {
        this.showdefault = true;
        let tempOPList = [];
        result = JSON.parse(result);
        result.forEach((record) => {
            let tempOPRec = Object.assign({}, record);
            tempOPRec.lineName = '/' + tempOPRec.customId;
            tempOPRec.Id = tempOPRec.customId;
            tempOPList.push(tempOPRec);
        });
        this.initialRecords = tempOPList;
        this.filterSearchRecords = this.initialRecords;
        const letsearch = this.filterSearchRecords.map(a => ({...a}));
        this.copyFilterSearchRecords = letsearch;
        this.error = undefined;
        this.getEndpointSAP();
    })).catch((error => {
        this.initialRecords = undefined;
        this.filterSearchRecords = this.initialRecords;
        this.error = error;
    }))
    this.handleSubscribe();
    this.registerErrorListener()
}
//Function which calls the getOPDetails() method and returns the Order Lines based on the filter value passed
handleSearchPrimary() {
    const paramsVariable = {
        acctId: this.accountId,
        userId: this.ownerId,
        prodId: this.productId,
        shipId: this.shipTo,
        ordId: this.OrderId
    };
    const paramsVarStr = JSON.stringify(paramsVariable);
    getOPDetails({paramsVar: paramsVarStr}).then((result => {
        this.showdefault = false;
        let tempOPList = [];
        result = JSON.parse(result);
        result.forEach((record) => {
            let tempOPRec = Object.assign({}, record);
            tempOPRec.lineName = '/' + tempOPRec.customId;
            tempOPRec.Id = tempOPRec.customId;
            tempOPList.push(tempOPRec);
        });
        this.availableItems = tempOPList;
        this.filterSearchRecords = this.availableItems;
        const letsearch = this.filterSearchRecords.map(a => ({...a}));
        this.copyFilterSearchRecords = letsearch;
        this.error = undefined;
    })).catch((error => {
        this.availableItems = undefined;
        this.filterSearchRecords = this.availableItems;
        this.error = error;
    }))
}

//US 2633

handleRowSelection(event) {
    console.log('Testing First Line - Event Triggered');
    this.selectedRows = event.detail.selectedRows;
    console.log('Testing Second Line - After Assigning Selected Rows:', this.selectedRows);

    // Check if any selected row has Status as "Under Revision"
    const underRevisionRecord = this.selectedRows.find(row => row.approvalStatus =='Under Revision');
    console.log('Testing Third Line -select record Under revison', underRevisionRecord);
    if (underRevisionRecord) {
        // Display an error message and stop further execution
         console.log('Error: Record is Under Revision');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Information',
                message: 'By selection an Order Line Under Approval , the Approval will be recalled',
                variant: 'info',
           
            })
        );
        console.log('Error: Record is Under Revision');
      //  this.selectedRows = []; // Clear selection
       // return; // Stop execution
    }

    this.showConvTable = this.selectedRows.length > 0;
    console.log('Show Conversation Table:', this.showConvTable);

    if (this.showConvTable) {
        this.filteredData = this.selectedRows;
        this.recordCount = this.selectedRows.length;
        console.log('Filtered Data:', JSON.stringify(this.filteredData));
        console.log('Record Count:', JSON.stringify(this.recordCount));
        this.calculateTotalSum();
        console.log('Calculated Sum:', JSON.stringify(this.calculateTotalSum()));
    } else {
        this.filteredData = [];
        console.log('No rows selected, clearing filteredData');
    }
}
// end US 2633



//Method to handle row selection from the first table
/*
handleRowSelection(event) {
    //testing 
    console.log('Testing First Line - Event Triggered');
    this.selectedRows = event.detail.selectedRows;
    console.log('Testing Second Line - After Assigning Selected Rows:', this.selectedRows);
    this.showConvTable = this.selectedRows.length > 0;
    console.log('Show Conversation Table:', this.showConvTable);
    if (this.showConvTable) {
        this.filteredData = this.selectedRows;
        this.recordCount = this.selectedRows.length;
       console.log('Filtered Data:', JSON.stringify(this.filteredData));
       console.log('Record Count:', JSON.stringify(this.recordCount));
        this.calculateTotalSum();
          console.log('calculated Sum:', JSON.stringify(this.calculateTotalSum()));
    } else {
        this.filteredData = [];
        console.log('No rows selected, clearing filteredData');
    }
}*/
//Function to calculate the total count and the quantity of the records selected from the first table
calculateTotalSum() {
    let sum = 0;
    const columnToSum = 'quantity';
    this.selectedRows.forEach((row) => {
        sum += row[columnToSum] ? parseFloat(row[columnToSum]) : 0;
    });
    this.recordQuantity = sum;
}
//Function which handles the search list of the first table
handleSearch(event) {
    this.searchKey = event.target.value.toLowerCase();
    if (this.searchKey) {
        this.filterSearchRecords = this.copyFilterSearchRecords;
        if (this.filterSearchRecords) {
            let recs = [];
            for (let rec of this.filterSearchRecords) {
                let valuesArray = Object.values(rec);
                for (let val of valuesArray) {
                    let strVal = String(val);
                    if (strVal) {
                        if (strVal.toLowerCase().includes(this.searchKey)) {
                            recs.push(rec);
                            break;
                        }
                    }
                }
            }
            this.filterSearchRecords = recs;
        }
    } else {
        this.filterSearchRecords = this.copyFilterSearchRecords;
    }
}
//Method to handle row selection from the second table                                                                
handleRowSelectionFPD(event) {
    this.selectedRows = event.detail.selectedRows;
    this.fpdLines = this.selectedRows;
}
//Method to handle inline editing of Agreed Final price column from the second table 
handleDraftValues(event){
    let draftValues = event.detail.draftValues;
    this.fldsItemValues = draftValues;
    const fldsItemValuesMap = new Map(this.fldsItemValues.map(item => [item.Id, item.finalAgreedPrice]));
    this.selectedRows.forEach(element => {
        if(fldsItemValuesMap.has(element.customId)){
            element.finalAgreedPrice = fldsItemValuesMap.get(element.customId);
        }
    });
}
//Method which makes callout to SAP on click of Save and Send to SAP button 
handleSendPriceToSAP() {
    console.log('Testing Submit and SAP Button');
    let fapNull = false;
    for (let i = 0; i < this.selectedRows.length; i++) {
        if (!this.selectedRows[i].finalAgreedPrice || this.selectedRows[i].finalAgreedPrice === 0) {
            fapNull = true;
            // Just checking the SAP BUtton is TRUE
             consol.log("SAP BUTTON CHECKING is TRUE")
            break;
        }
    }
    if (fapNull) {
        this.ShowToast('Error',fapMiss,'error');
    } else {
    saveOPFromUI({
        lstOlines: JSON.stringify(this.fpdLines)
        }).then(result => {
            if(result){
                let toastVariant = 'info';
                let title = 'Information';
                //if(this.fpdLines.length === 0){
                //this.ShowToast('Error',noOL,'error');
           // }
           if(result.startsWith('Error')){
            toastVariant = 'error';
            title = 'Error';
           }
           this.dispatchEvent(
            new ShowToastEvent({
                title : title,
                message: result,
                variant : toastVariant
            })
           );
            }
            
    })
    .catch(error => {
        //this.ShowToast('Error',sendFPDError,'error');
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message: error.body.message,
                variant : toastVariant
                })
            );

    })
    refreshApex(this.filterSearchRecords);
    refreshApex(this.filteredData);
}
}
//Function which calls the getEndpointSAP method to return the endpoint for Send Price to SAP callout
getEndpointSAP(){
    const self = this;
    sendFPDPriceFXURL().then(result => {
        self.fpdEndpointSAP = JSON.parse(result);
    }).catch(error => {
        this.error = error;
    })
}
//Method which makes callout to Price on click of Get FPD Price button 
handleGetFPD(){
    getPriceFromPriceFX({
        lstOlines: JSON.stringify(this.fpdLines)
    }).then(result => {
        if(this.fpdLines.length === 0){
            this.ShowToast('Error',noOL,'error');
        }
    }).catch(error => {
        this.ShowToast('Error',getFPDError,'error');
    })
    
    refreshApex(this.filterSearchRecords);
    refreshApex(this.filteredData);
}

// Handles subscribe button click
handleSubscribe() {
    const self = this;
    const messageCallback = function (response) {
        var obj = JSON.parse(JSON.stringify(response));
        const index = self.filteredData.findIndex(item => item.Id === obj.data.payload.PMC_CPQ_OrderItemId__c);
        if (index !== -1) {
        self.filteredData = [...self.filteredData]; 
        self.filteredData[index].listPrice = obj.data.payload.PMC_CPQ_FPDPrice__c;
        self.filteredData[index].fpdPrice = obj.data.payload.PMC_CPQ_FPDPrice__c;
        self.filteredData[index].integrationMessage = obj.data.payload.PMC_CPQ_IntegrationStatusMessage__c;
        }
        //check Get FPD status
        if(!obj.data.payload.PMC_CPQ_InterfaceURL__c.includes(self.fpdEndpointSAP)){
            if (obj.data.payload.PMC_CPQ_OrderLineIntegrationStatus__c === 'Success') {
                self.ShowToast('Success', getFPDIntSuccess, 'Success');
            }
            else if(obj.data.payload.PMC_CPQ_OrderLineIntegrationStatus__c === 'Partial Success'){
                self.ShowToast('Partial Success', getFPDPartialSuccess , 'warning');
            }else {
                self.ShowToast('Error', getFPDIntFail, 'Error');
            }
        }
        //check Send FPD status
        if(obj.data.payload.PMC_CPQ_InterfaceURL__c.includes(self.fpdEndpointSAP)){
            if (obj.data.payload.PMC_CPQ_OrderLineIntegrationStatus__c === 'Success') {
                self.ShowToast('Success', sendFPDIntSuccess, 'Success');
            }
            else if(obj.data.payload.PMC_CPQ_OrderLineIntegrationStatus__c === 'Partial Success'){
                self.ShowToast('Partial Success', sendFPDPartialSuccess , 'warning');
            }else {
                self.ShowToast('Error', sendFPDIntFail, 'Error');
            }
        }
    };

    subscribe(this.channelName, -1, messageCallback).then(response => {
        console.log('Subscription request sent to: ', JSON.stringify(response.channel));
        this.subscription = response;
    });
}
//Method to show toast messages for various scenarios
ShowToast(title, message, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(evt);
}

registerErrorListener() {
    onError(error => {
        console.log('Received error from server: ', JSON.stringify(error));
    });
}

togglePanel() {
    let leftPanel = this.template.querySelector("div[data-my-id=leftPanel]");
    let rightPanel = this.template.querySelector("div[data-my-id=rightPanel]");
    if (leftPanel.classList.contains('slds-is-open')) {
        leftPanel.classList.remove("slds-is-open");
        leftPanel.classList.remove("open-panel");
        leftPanel.classList.add("slds-is-closed");
        leftPanel.classList.add("close-panel");
        rightPanel.classList.add("expand-panel");
        rightPanel.classList.remove("collapse-panel");
    } else {
        leftPanel.classList.add("slds-is-open");
        leftPanel.classList.add("open-panel");
        leftPanel.classList.remove("slds-is-closed");
        leftPanel.classList.remove("close-panel");
        rightPanel.classList.remove("expand-panel");
        rightPanel.classList.add("collapse-panel");
    }
    this.isFiltersPaneOpen = !this.isFiltersPaneOpen;
    this.adjustRightPanelWidth(this.isFiltersPaneOpen);
}
refreshUserData(evt) {
    const buttonIcon = evt.target.querySelector('.slds-button__icon');
    buttonIcon.classList.add('refreshRotate');
    setTimeout(() => {
        buttonIcon.classList.remove('refreshRotate');
    }, 1000);
}
adjustRightPanelWidth(isOpen) {
    const rightPanel = this.template.querySelector('.right-panel');
    if (isOpen) {
        rightPanel.style.width = '82.5%';
    } else {
        rightPanel.style.width = '100%';
    }
}
}