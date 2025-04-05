import { LightningElement,wire,track } from "lwc";


import strLink from '@salesforce/apex/PMC_SS_ScheduleOrderController.getLink';

import { NavigationMixin } from "lightning/navigation";


export default class Navigation extends NavigationMixin(LightningElement) {
  @track strUrl;
  @wire(strLink) strGetLink ;
  
  // Used to handle navigation to URL//
  handleNavigate() {
    strLink().then(strResult => {
      this.strUrl=strResult;
   
      const objNavigationConfig = {
        type: 'standard__webPage',
        attributes: {
            url: strResult
        }
	};
    this[NavigationMixin.Navigate](objNavigationConfig);

    }).catch();
    
  }
}