import { LightningElement } from 'lwc';
import getTokenId from '@salesforce/apex/PMC_DH_IntelliTransController.getTokenId';
import getShipmentDataCallout from '@salesforce/apex/PMC_DH_IntelliTransController.getShipmentDataCallout';

export default class IntelliTransShipmentData extends LightningElement {

    shipments = [];
    paginatedShipments = [];
    shipmentsTest;
    isLoading = false;
    shipmentData = false;
    hasError = false;
    errorMessage = '';
    offset = 0;
    limit = 20;

    columns = [
        { label: 'Delivery Number', fieldName: 'DELIVERYNUMBER' },
        { label: 'Equipment ID', fieldName: 'EQUIPMENTID' },
        { label: 'ETA', fieldName: 'ETA', type: 'date' },
        { label: 'BOL', fieldName: 'BOL' },
        { label: 'BOL Number', fieldName: 'BOLNUMBER' },
        { label: 'Customer Order No', fieldName: 'CUSTORDERNO' },
        { label: 'PO Number', fieldName: 'PONUMBER' },
        { label: 'Current Carrier', fieldName: 'CURRENTCARRIER' },
        { label: 'Destination Carrier', fieldName: 'DESTINATIONCARRIER' },
        { label: 'Fleet Town Name', fieldName: 'FLEETTOWNAME' },
        { label: 'Comments', fieldName: 'COMMENTS' },
        { label: 'Current Location', fieldName: 'CURRENTLOCATION' }
    ];

    connectedCallback(){
        this.getIntellitransShipmentData();
    }

    async getIntellitransShipmentData(){
        this.isLoading = true;
        const { JSONResponse } = await getTokenId({});

        const tokenId = JSON.parse(JSONResponse);
      
        if(JSONResponse === ''){
            return;
        }
        
        const result = await getShipmentDataCallout({
            token: tokenId
        });
      
        if(result.hasError && result.JSONResponse === ''){
            this.hasError = hasError;
            this.errorMessage = message;
            return;
        }
      
        this.shipments = JSON.parse(result.JSONResponse);
        this.isLoading = false;
        this.shipmentData = true;
        this.updatePaginatedData();
    }

    updatePaginatedData() {
        const newData = this.shipments.slice(this.offset, this.offset + this.limit);
        this.paginatedShipments = [...this.paginatedShipments, ...newData];
        this.offset += this.limit;
    }

    loadMoreData() {
        this.updatePaginatedData();
    }

    
}