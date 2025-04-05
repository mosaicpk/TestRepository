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
export default class HandleSaveAndSendToSAP extends LightningElement 
{

   @track selectedRows = [];
    @track fpdLines = [];

    // Existing code...

    // New function to handle "Save and Send to SAP" button click
    handleSaveAndSendToSAP() {
        // Ensure selected rows are available
        if (this.selectedRows.length === 0) {
            this.showToast('Error', 'No order lines selected', 'error');
            return;
        }

        // Ensure that the final agreed price is not null or 0 for selected rows
        let fapNull = false;
        for (let i = 0; i < this.selectedRows.length; i++) {
            if (!this.selectedRows[i].finalAgreedPrice || this.selectedRows[i].finalAgreedPrice === 0) {
                fapNull = true;
                break;
            }
        }

        if (fapNull) {
            this.showToast('Error', 'Final agreed price is missing or invalid', 'error');
            return;
        }

        // Preparing the data to be sent to SAP
        this.fpdLines = this.selectedRows.map(row => ({
            Id: row.Id,
            finalAgreedPrice: row.finalAgreedPrice,
            customId: row.customId
        }));

        // Calling Apex method to save and send to SAP
        saveOPFromUI({ lstOlines: JSON.stringify(this.fpdLines) })
            .then((result) => {
                // Handle result and show appropriate toast message
                let toastVariant = 'info';
                let title = 'Information';
                if (result.startsWith('Error')) {
                    toastVariant = 'error';
                    title = 'Error';
                }

                // Show Toast
                this.showToast(title, result, toastVariant);
            })
            .catch((error) => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    // Method to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}