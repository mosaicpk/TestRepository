import { LightningElement, wire,track,api } from 'lwc';
import testapex from "@salesforce/apex/PMC_DH_POC.getconsent";
import getRecentContracts from "@salesforce/apex/PMC_DH_HomePageController.getRecentContracts";
//import getconsent from '@salesforce/apex/PMC_DH_POC.getconsent';


const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Industry', fieldName: 'Industry' },
    { label: 'Type', fieldName: 'Type' }
];

export default class pmc_dh_pocConsent extends LightningElement {
    columns = columns;
    @api acc;
    @track accountData;
    
    connectedCallback() {
        this.strLocale = sessionStorage.getItem("userRegion");
        if (sessionStorage.getItem("EFFECTIVE_ACCOUNT_ID")) {
          this.acc = sessionStorage.getItem("EFFECTIVE_ACCOUNT_ID");
          console.log("hi-->"+this.acc);
        }
      }
      
      fetchdetails(){
        getRecentContracts({
            strEffectiveAccountId:sessionStorage.getItem("EFFECTIVE_ACCOUNT_ID")
        })
        .then((data)=>
        {
            if (data) {
                this.accountData = JSON.parse(JSON.stringify(data));
                console.log("hi-->"+data);
            } 
        })
}


    connectedCallback(){
        this.fetchdetails()
    }
}