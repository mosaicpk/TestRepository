import { LightningElement } from 'lwc';
import getOrderDetails from "@salesforce/apex/PMC_DH_RequestedOrderDetails.getOrderDetails";
import communityId from "@salesforce/community/Id";

export default class Sample_requestedOrderDetail extends LightningElement {


    connectedCallback() {
          this.fetchOrderDetails();
      }
    
    fetchOrderDetails() {
        this.communityId = communityId;
        if (sessionStorage.getItem("EFFECTIVE_ACCOUNT_ID")) {
          this.effectiveAccountId = sessionStorage.getItem("EFFECTIVE_ACCOUNT_ID");
        }
        getOrderDetails({
          strCommunityId: this.communityId,
          strEffectiveAccountId: this.effectiveAccountId,
          responseDetails: ''
        })
          .then((data) => {
            this.orderDetails = JSON.parse(JSON.stringify(data));
            console.log('_dataSid',this.orderDetails);
           });
    }
}