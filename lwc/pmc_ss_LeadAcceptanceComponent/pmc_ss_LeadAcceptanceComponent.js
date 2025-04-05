import { LightningElement, api } from 'lwc';
import acceptLead from '@salesforce/apex/PMC_SS_SalesQualifiedLeadController.acceptLead';
export default class Pmc_ss_LeadAcceptanceComponent extends LightningElement {
    strResponse;
    @api strRecId;
    @api strOwnerId;
    @api strIsAccepted;

    connectedCallback() {
        console.log('In connected call back function....');
        console.log('strRecId is '+this.strRecId+', strOwnerId is : '+this.strOwnerId+' and isAccepted is : '+this.strIsAccepted);

        acceptLead({strRecId:this.strRecId,strOwnerId:this.strOwnerId,strIsAccepted:this.strIsAccepted})
            .then(result => {
              console.log('result is : ',result);
              this.strResponse = result;
            })
            .catch(error => {
              console.log('In connected call back error....');
              this.error = error;
              console.log('Error is ' + JSON.stringify(this.error));
            });
    }
}