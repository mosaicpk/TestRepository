import {LightningElement,track,api,wire} from 'lwc';
import saveOPFromUI from '@salesforce/apex/PMC_CPQ_sendFPDOrderProductsSAPClass.saveOPFromUI';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
 
export default class PMC_CPQ_FPDSENDSAPQuickAction extends LightningElement {
	@api recordId; 

	async connectedCallback() {
		console.log('Constructor is Running here');
		console.log('this.recordId:: ', this.recordId);
		await saveOPFromUI({
	        recordId: this.recordId
	        }).then(result => { 
				console.log('result:: ', result);
	            if(result){
	                let toastVariant = 'info';
	                let title = 'Information';
	               
		           if(result.startsWith('Error')){
			            toastVariant = 'error';
			            title = 'Error';
		           }
		           this.dispatchEvent(
			            new ShowToastEvent({
			                title : title,
			                message: result,
			                variant : toastVariant
			            })
		            );
	            }
	        })
		    .catch(error => {
		        //this.ShowToast('Error',sendFPDError,'error');
		        this.dispatchEvent(
		            new ShowToastEvent({
		                title : 'Error',
		                message: error.body.message,
		                variant : toastVariant
		                })
		            );

		    })
	}

	// @api invoke() {
	// 	console.log('Method is Running now.');
	// 	saveOPFromUI({
	//         recordId: this.recordId
	//         }).then(result => { 
	// 			console.log('result:: ', result);
	//             if(result){
	//                 let toastVariant = 'info';
	//                 let title = 'Information';
	               
	// 	           if(result.startsWith('Error')){
	// 		            toastVariant = 'error';
	// 		            title = 'Error';
	// 	           }
	// 	           this.dispatchEvent(
	// 		            new ShowToastEvent({
	// 		                title : title,
	// 		                message: result,
	// 		                variant : toastVariant
	// 		            })
	// 	            );
	//             }
	//         })
	// 	    .catch(error => {
	// 	        //this.ShowToast('Error',sendFPDError,'error');
	// 	        this.dispatchEvent(
	// 	            new ShowToastEvent({
	// 	                title : 'Error',
	// 	                message: error.body.message,
	// 	                variant : toastVariant
	// 	                })
	// 	            );

	// 	    })
	// }

	//Method to show toast messages for various scenarios
	ShowToast(title, message, variant) {
	    const evt = new ShowToastEvent({
	        title: title,
	        message: message,
	        variant: variant
	    });
	    this.dispatchEvent(evt);
	}
	
}