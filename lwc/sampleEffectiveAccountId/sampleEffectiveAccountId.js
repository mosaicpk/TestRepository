import { LightningElement,wire,track } from 'lwc';
import { getSessionContext } from 'commerce/contextApi'; 
import {getNavigationMenu} from 'experience/navigationMenuApi';
import { productCategories } from 'c/pmc_dh_navMenuUtility';
import getQuoteData  from '@salesforce/apex/PMC_DH_POC.getQuoteData';
import getAccountManagerName from "@salesforce/apex/PMC_DH_AccountDetailController.getAccountManagerName";
import getNavMenu from "@salesforce/apex/PMC_DH_POC.getNavMenu";
import communityId from '@salesforce/community/Id';
import { AppContextAdapter } from 'commerce/contextApi';
import { ProductAdapter } from 'commerce/productApi';
//import getExternalProfile from '@salesforce/apex/PMC_DH_CommonSystemUtils.getExternalProfileIds';
import createNotesAttachment from '@salesforce/apex/PMC_DH_POC.createNotesAndAttachment';
import getRebatesInfoForCustomer from '@salesforce/apex/PMC_DH_POC.getRebatesInfoForCustomer';
import fetchDocumentRecords from '@salesforce/apex/PMC_DH_DocumentListViewController.fetchDocumentRecords';
export default class SampleEffectiveAccountId extends LightningElement {
 @track quoteData;
 @track accountManagerName;
  connectedCallback(){ 
  this.getMySessionInfo();

  fetchDocumentRecords({
    strEffectiveAccId: '001DT000013aaASYAY'
  }).then(result => {
      console.log('Helloooo' + result);
  }).catch(err => {
      console.log("Error in fetching document records: ", err.body.message);
  })
 // this.getMyNavigationMenu();
 // this.getProfiles();
  }
 
// }
//   getProfiles() {
//   getExternalProfile({
//     searchTerm: 'Digital Hub',
//   }).then(result => {
//       console.log('Hello Profile'+JSON.stringify(result));
//   }).catch(err => {
//     console.log("Error in Add new address: ", err.body.message);
//   })
// }

getNavMenuItems() {
  getNavMenu({
    strcommunityId: communityId
  }).then(result => {
      console.log('getNavMenu result' + result);
  }).catch(err => {
      console.log("Error in getting nav records: ", err.body.message);
  })
}
  handleNotes()
{
  createNotesAttachment().then(result => {
      console.log('Hello Profile'+JSON.stringify(result));
  }).catch(err => {
    console.log("Error in Add new address: ", err.body.message);
  })
}
  @wire(getNavigationMenu)
  navMenu({ error, data }) {
  if (data) {
      const productMenuItem = productCategories(data);
      console.log('productMenuItem',productMenuItem); 
      this.error = undefined;
  } else if (error) {
      console.log('navigationMenu',JSON.stringify(error)); 
      this.record = undefined;
  }
  }
  @wire(AppContextAdapter)
  wireAppContext({ error, data }){
    console.log('entry',JSON.stringify(data)); 
  }
  @wire(ProductAdapter)
  wireProductContext({ error, data }) {
    console.log('productInfo',JSON.stringify(data)); 
  }
  @wire(getQuoteData)
  quoteMenu({ error, data }) {
  if (data) {
         this.quoteData=data[0];
         console.log('getQuoteData',JSON.stringify(data)); 
      this.error = undefined;
  } else if (error) {
      console.log('getQuoteData',JSON.stringify(error)); 
      this.record = undefined;
  }
  }
  async getMySessionInfo(){ 
  const sessionContext = await getSessionContext(); 
  console.log(JSON.stringify(sessionContext)); 
  }
  
  @wire(getAccountManagerName,{strEffAccId:sessionStorage.getItem('EFFECTIVE_ACCOUNT_ID')})
  wiredAccountManagerName({ error, data }) {
    if (data) {
      this.accountManagerName = data;
    } else if (error) {
      console.error('Error retrieving  manager name:', error);
    }
  }
  @wire(getRebatesInfoForCustomer)
  getRebateData({ error, data })  {
    if (data) {
      console.log('rebatesdata'+JSON.stringify(data)); 
    } else if (error) {
      console.error('Error retrieving  manager name:', error);
    }
  }
  

  
}