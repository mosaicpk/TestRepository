import { LightningElement } from 'lwc';
import getConversationHistory from "@salesforce/apex/PMC_DH_QuoteMgmtRelatedItemsClass.getConversationHistory";

export default class Pmc_dh_pocConversation extends LightningElement {

    connectedCallback() {
        this.loadAddressDetail();
      }
    
      /** Fetch Picklist Values */
      loadAddressDetail() {
        getConversationHistory({
            
            strQuoteId:'a3CDT000001T6DO2A0'

          })
            .then((response) => {
                console.log('data'+JSON.parse(JSON.stringify(response)))
                
              console.log(response);
              
              
      
            })
      }
}