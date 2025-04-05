import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['SBQQ__Quantity__c'];

export default class QuoteLineDisplay extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    quoteLine;

    @wire(getRecord, { recordId: '$quoteLineId', fields: FIELDS })
    loadQuoteLine({ error, data }) {
        if (data) {
            this.quoteLine = data;
        }
    }

    get quoteLineId() {
        return this.pageRef.state.c__quoteLineId;
    }

    get quantityDividedByFour() {
        const quantity = this.quoteLine.fields.SBQQ__Quantity__c.value;
        const dividedValues = [];

        // Divide the quantity by 4 and create an array with 4 identical values
        const dividedValue = quantity / 4;
        for (let i = 0; i < 4; i++) {
            dividedValues.push(dividedValue);
        }

        return dividedValues;
    }
}