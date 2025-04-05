import { LightningElement,wire,api } from 'lwc';
import { getSessionContext } from 'commerce/contextApi';
import getContactList from '@salesforce/apex/PMC_DH_AccountSwitcherController.getContactList';
//import LightningModal from 'lightning/modal';


export default class Pmc_dh_myaccountswitcher extends LightningElement {
  @api modalHeader;
  showModal = true;
  @wire(getContactList)
  contacts;
  handleCloseModal() {
    this.showModal = false;
  }

  handleOpenModal() {
    this.showModal = true;
  }
    clickedButtonLabel;
    connectedCallback(){
        this.getMySessionInfo()
        }
        
    async getMySessionInfo(){
    const sessionContext = await getSessionContext();
    console.log(JSON.stringify(sessionContext));
    let effaccountId=sessionStorage.getItem('EFFECTIVE_ACCOUNT_ID');
    console.log('EFFECTIVE_ACCOUNT_ID'+effaccountId);
    sessionStorage.setItem('EFFECTIVE_ACCOUNT_ID','001DT000013aaB1YAI')
    console.log('EFFECTIVE_ACCOUNT_ID2'+effaccountId);
    }
    

    handleDelegatedAccounts(){
        console.log(JSON.stringify(this.contacts.data));
        }

}