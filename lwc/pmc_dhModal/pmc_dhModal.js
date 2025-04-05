import { LightningElement,api } from 'lwc';

export default class Pmc_dhModal extends LightningElement {

    @api modalHeader;
    @api showModal = false;
  
    closeModal() {
      this.showModal = false;
      console.log('close modal');
    }
  
    openModal() {
      this.showModal = true;
      console.log('open modal');
}
}