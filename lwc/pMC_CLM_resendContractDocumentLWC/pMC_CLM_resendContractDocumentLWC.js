import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import SWITCH_FIELD from '@salesforce/schema/SBQQ__Quote__c.PMC_CLM_ResendContractDocument__c';

const fields = [SWITCH_FIELD];

export default class pMC_CLM_resendContractDocumentLWC extends LightningElement {
    @api recordId;
    showToastMessage = true;
    fromJS = 'XYZ';
    switchValue;

    @wire(getRecord, { recordId: '$recordId', fields })
    quote;

    get switchValueFetch() {
        console.log('!!!!!!');
        switchValue = getFieldValue(this.quote.data, SWITCH_FIELD);
        console.log('!!!!!!  ' + getFieldValue(this.quote.data, SWITCH_FIELD) );
    }

    
}
    /*getSwitchFieldValue(result){
        let oldValue = this.wiredOpprResult === null ? null : getFieldValue(this.wiredOpprResult, OPPORTUNITY_RELATED_RECORD);

        let data = result.data;
        let error = result.error;
        if (data && oldValue !== getFieldValue(data, OPPORTUNITY_RELATED_RECORD)){
          this.showSuccessToast();
        }

        this.wiredOppResult = result;
  }
    
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Opearation sucessful',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}*/