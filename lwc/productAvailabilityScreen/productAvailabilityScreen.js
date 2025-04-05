import { LightningElement, wire, api, track } from 'lwc';
import getQuoteLines from '@salesforce/apex/RelatedQuoteLines.getQuoteLines';

import {NavigationMixin} from "lightning/navigation";

export default class ProductAvailabilityScreen extends NavigationMixin(LightningElement) {
    
    totalQuoteLineQuantity = 0;
    totalQuantityLeft = 0;
    quoteLineProductName = '';
    @api recordId;
    availabilityData = [];
    minDate = '';
    quantitySumError = ''
    maxDate = '';
    @track quoteLines = [];
    currentIndex = 0;
    quoteLineShipTo = '';
    quoteLineShipFrom = '';
    quoteLineValidityPeriod = '';
    quoteLineDeliveryInformation = '';
    quoteId = '';
    baseurl = '';

    connectedCallback(){
        this.baseurl = window.location.origin;
    }   

    @wire(getQuoteLines, { quoteLineId: '$recordId' })//, fields: ['SBQQ__QuoteLine__c.Id','SBQQ__QuoteLine__c.Name','SBQQ__QuoteLine__c.SBQQ__ProductName__c','SBQQ__QuoteLine__c.SBQQ__Quantity__c', 'SBQQ__QuoteLine__c.SBQQ__Quote__r.PMC_CPQ_ContractStart__c', 'SBQQ__QuoteLine__c.SBQQ__Quote__r.PMC_CPQ_ContractEnd__c'] })
    wiredQuoteLine({ error, data }) {
        if (data) {
            this.quoteLines = data;
            console.log("++++" + JSON.stringify(this.quoteLines));
            console.log("-------"+data.findIndex(quoteLine => quoteLine.Id === this.recordId));
            this.currentIndex = data.findIndex(quoteLine => quoteLine.Id === this.recordId);
            console.log("()()()()" + this.currentIndex);
            this.renderQuoteLineData();
            
        }
        else if (error) {
            console.error('Error fetching Quote Line data:', JSON.stringify(error));
        }
 
    }
 
 contractMonthDifference(dateFrom, dateTo) {
    const diffTime = dateTo - dateFrom;
    const diffMonths = diffTime / (1000 * 60 * 60 * 24 * 30.44);
    return Math.floor(diffMonths);
}

generateMonthRows(startDate, numMonths, quantityPerMonth) {
    const rows = [];
    for (let i = 0; i < numMonths; i++) {
        const monthDate = new Date(startDate);
        monthDate.setMonth(startDate.getMonth() + i);
        rows.push({ id: i, date: monthDate.toISOString().split('T')[0], quantity: quantityPerMonth, rowIndex: i});
    }
    return rows;
}

generate4Rows(startDate, quantityPerRow) {
    const rows = [];
    for (let i = 0; i < 4; i++) {
        const monthDate = new Date(startDate);
        monthDate.setMonth(startDate.getMonth() + i);
        rows.push({ id: i, date: monthDate.toISOString().split('T')[0], quantity: quantityPerRow, rowIndex: i });
    }
    return rows;
    }


    handleDateChange(event) {
        const selectedDate = event.target.value;
        const rowIndex = event.target.dataset.rowIndex;
    }

    handleQuantityChange(event) {
        const selectedQuantity = parseFloat(event.target.value);
        console.log("!!!!!!" + selectedQuantity);
        console.log("^^^^^" + JSON.stringify(event.target.name));
        console.log("*****" + JSON.stringify(event.currentTarget.dataset));
        const rowIndex = event.target.name;
        console.log("@@@@@@" + rowIndex);
        this.availabilityData[rowIndex].quantity = selectedQuantity;
        console.log("####" + this.availabilityData[rowIndex].quantity);
        const currentSum = this.availabilityData.reduce((sum, row) => sum + row.quantity, 0);
        console.log("$$$$$" + currentSum);
        if (currentSum > this.totalQuoteLineQuantity) {
            this.quantitySumError = 'Total quantity exceeds the Quote Line quantity';
        } else {
            this.quantitySumError = '';
        }
        this.calculateTotalQuantityLeft();
    }

    handleNextClick() {
        this.currentIndex++;
        if (this.currentIndex >= this.quoteLines.length) {
            this.currentIndex = 0;
        }
        this.renderQuoteLineData();
    }

    handlePreviousClick() {
        this.currentIndex--;
        if (this.currentIndex < 0) {
            this.currentIndex = this.quoteLines.length - 1;
        }
        this.renderQuoteLineData();
    }


    renderQuoteLineData() {
        console.log("%%%%%" + this.currentIndex);
        const currentQuoteLine = this.quoteLines[this.currentIndex];
        this.quoteId = currentQuoteLine.SBQQ__Quote__c;
        this.quoteLineProductName = currentQuoteLine.SBQQ__ProductName__c;
        const quoteLineQuantity = currentQuoteLine.SBQQ__Quantity__c;//data.fields.SBQQ__QuoteLine__c.SBQQ__Quantity__c.value;
        this.totalQuoteLineQuantity = quoteLineQuantity;
        const contractValidFrom = new Date(currentQuoteLine.SBQQ__Quote__r.PMC_CPQ_ContractStart__c);//data.fields.SBQQ__Quote__r.PMC_CPQ_ContractStart__c.value
        const contractValidTo = new Date(currentQuoteLine.SBQQ__Quote__r.PMC_CPQ_ContractEnd__c);//data.fields.SBQQ__Quote__r.PMC_CPQ_ContractEnd__c.value
        const monthDiff = this.contractMonthDifference(contractValidFrom, contractValidTo) + 1;
        this.minDate = currentQuoteLine.SBQQ__Quote__r.PMC_CPQ_ContractStart__c;
        this.maxDate = currentQuoteLine.SBQQ__Quote__r.PMC_CPQ_ContractEnd__c;
        this.quoteLineShipTo = currentQuoteLine.PMC_CPQ_ShipTo__c;
        this.quoteLineShipFrom = currentQuoteLine.PMC_CPQ_ProductLocation__r.PMC_CPQ_Address__c;
        this.quoteLineDeliveryInformation = String(currentQuoteLine.PMC_CPQ_Incoterms1__c).concat(" - ", String(currentQuoteLine.PMC_CPQ_ModeofTransportation__c));
        this.quoteLineValidityPeriod = contractValidFrom.toISOString().split('T')[0].concat(" - ", contractValidTo.toISOString().split('T')[0]);

        if (monthDiff < 4) {
            const calculatedQuantity = quoteLineQuantity / monthDiff;
            this.availabilityData = this.generateMonthRows(contractValidFrom, monthDiff, calculatedQuantity);
        } else {
            const calculatedQuantity = quoteLineQuantity / 4;
            this.availabilityData = this.generate4Rows(contractValidFrom, calculatedQuantity);
        }
    }

    calculateTotalQuantityLeft() {
        const sumRowQuantities = this.availabilityData.reduce((sum, row) => sum + row.quantity, 0);
        this.totalQuantityLeft = this.totalQuoteLineQuantity - sumRowQuantities;
    }

    handleBackToCart() {
       /* let link = this.baseurl + '/apex/sbqq__sb?scontrolCaching=1&id=' + this.quoteId 
                       + '#quote/le?qId=' + this.quoteId;
        //let link = "www.google.com"
        console.log("###########" + link);
        this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: link
        }
    });*/

    }
}