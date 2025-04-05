import { LightningElement,api,wire} from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from 'lightning/refresh';
import getObjName from'@salesforce/apex/BusinessSVCController.getObjName';
import getFCval from'@salesforce/apex/BusinessSVCController.getFCval';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
export default class PmcSSBusinessVolumeSelectionCriteriaForm extends NavigationMixin(LightningElement) {
    customerHierarchyEnable=true;
    customerEnable=true;
    materialGrpEnable=true;
    materialEnable=true;
    productHierarchyEnable=true;
    shipToEnable=true;
    isShowModal=true;
    inclExclEnable=true;
    showNew ;
    onChngeEdit = false;
    saveClicked ;
    error;
    @api recordId;
    currenObjectName;

    @wire(CurrentPageReference)
    getCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.isShowModal=true;
        getObjName({ recordIdVal: this.recordId })
		.then(result => {
            console.log('objectApiName::'+result);
            this.currenObjectName = result;
            if(this.currenObjectName == 'PMC_SS_BusinessVolumeSelectionCriteria__c'){
                this.showNew = false;
                getFCval({ recordIdVal: this.recordId })
                .then(result => {
                    console.log('resultresultresultresult: '+result);
                    if( result == '0001'){
                        this.customerEnable = false;
                    }else if(result == '0006'){
                        this.customerHierarchyEnable = false;
                    }else if(result == '0008'){
                        this.materialGrpEnable = false;
                    } else if(result == '0009'){
                this.materialEnable = false;
                    } else if(result == '0032'){
                        this.shipToEnable = false;
                    } else if(result == '0007'){
                        this.productHierarchyEnable = false;
                    }else if(result == 'StatusIncludingExcluding'){
                        this.inclExclEnable = false;
                    }
                })
                
            }else{
                this.showNew = true;
            }
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
		})
    }
   
    handleChange(event) {
         if(event.detail.value == '0001'){
            this.customerEnable = false;
            this.customerHierarchyEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="ch"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mg"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ma"]').value='';
            this.template.querySelector('lightning-input-field[data-name="sh"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ph"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ie"]').value='';
            //this.template.querySelector('lightning-input-field[data-name="so"]').value='';

        } else if(event.detail.value == '0006'){
            this.customerHierarchyEnable = false;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="cu"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mg"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ma"]').value='';
            this.template.querySelector('lightning-input-field[data-name="sh"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ph"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ie"]').value='';
            //this.template.querySelector('lightning-input-field[data-name="so"]').value='';
        }
        else if(event.detail.value == '0008'){
            this.materialGrpEnable = false;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="ch"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cu"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ma"]').value='';
            this.template.querySelector('lightning-input-field[data-name="sh"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ph"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ie"]').value='';
            //this.template.querySelector('lightning-input-field[data-name="so"]').value='';
        }
        else if(event.detail.value == '0009'){
            this.materialEnable = false;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.shipToEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="ch"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mg"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cu"]').value='';
            this.template.querySelector('lightning-input-field[data-name="sh"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ph"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ie"]').value='';
            //this.template.querySelector('lightning-input-field[data-name="so"]').value='';
        }
        else if(event.detail.value == '0032'){
            this.shipToEnable = false;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="ch"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mg"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ma"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cu"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ph"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ie"]').value='';
            //this.template.querySelector('lightning-input-field[data-name="so"]').value='';
        }
        else if(event.detail.value == '0007'){
            this.productHierarchyEnable = false;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="ch"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mg"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ma"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cu"]').value='';
            this.template.querySelector('lightning-input-field[data-name="sh"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ie"]').value='';
        }
        else if(event.detail.value == '0003'){
            this.productHierarchyEnable = true;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="ch"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mg"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ma"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cu"]').value='';
            this.template.querySelector('lightning-input-field[data-name="sh"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ph"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ie"]').value='';
        }
        else if(event.detail.value == 'StatusIncludingExcluding'){
            this.inclExclEnable=false;
            this.productHierarchyEnable = true;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.template.querySelector('lightning-input-field[data-name="ch"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mg"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ma"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cu"]').value='';
            this.template.querySelector('lightning-input-field[data-name="sh"]').value='';
            this.template.querySelector('lightning-input-field[data-name="ph"]').value='';
        }
    }


    hideModalBox() {  
        this.isShowModal = false;
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.currenObjectName,
                actionName: 'view'
            }
        })*/
        window.location.href = '/'+this.recordId;
    }

    handleChangeEdit(event) {
        this.onChngeEdit =  true;
         if(event.detail.value == '0001'){
            this.customerEnable = false;
            this.customerHierarchyEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="che"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mge"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mae"]').value='';
            this.template.querySelector('lightning-input-field[data-name="she"]').value='';
            this.template.querySelector('lightning-input-field[data-name="phe"]').value='';
            this.template.querySelector('lightning-input-field[data-name="iee"]').value='';
        } else if(event.detail.value == '0006'){
            this.customerHierarchyEnable = false;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="cue"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mge"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mae"]').value='';
            this.template.querySelector('lightning-input-field[data-name="she"]').value='';
            this.template.querySelector('lightning-input-field[data-name="phe"]').value='';
            this.template.querySelector('lightning-input-field[data-name="iee"]').value='';
        }
        else if(event.detail.value == '0008'){
            this.materialGrpEnable = false;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="che"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cue"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mae"]').value='';
            this.template.querySelector('lightning-input-field[data-name="she"]').value='';
            this.template.querySelector('lightning-input-field[data-name="phe"]').value='';
            this.template.querySelector('lightning-input-field[data-name="iee"]').value='';
        }
        else if(event.detail.value == '0009'){
            this.materialEnable = false;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.shipToEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="che"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mge"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cue"]').value='';
            this.template.querySelector('lightning-input-field[data-name="she"]').value='';
            this.template.querySelector('lightning-input-field[data-name="phe"]').value='';
            this.template.querySelector('lightning-input-field[data-name="iee"]').value='';
        }
        else if(event.detail.value == '0032'){
            this.shipToEnable = false;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.productHierarchyEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="che"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mge"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mae"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cue"]').value='';
            this.template.querySelector('lightning-input-field[data-name="phe"]').value='';
            this.template.querySelector('lightning-input-field[data-name="iee"]').value='';
        }
        else if(event.detail.value == '0007'){
            this.productHierarchyEnable = false;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="che"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mge"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mae"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cue"]').value='';
            this.template.querySelector('lightning-input-field[data-name="she"]').value='';
            this.template.querySelector('lightning-input-field[data-name="iee"]').value='';
        }
        else if(event.detail.value == '0003'){
            this.productHierarchyEnable = true;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.shipToEnable = true;
            this.inclExclEnable=true;
            this.template.querySelector('lightning-input-field[data-name="che"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mge"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mae"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cue"]').value='';
            this.template.querySelector('lightning-input-field[data-name="she"]').value='';
            this.template.querySelector('lightning-input-field[data-name="phe"]').value='';
            this.template.querySelector('lightning-input-field[data-name="iee"]').value='';
        } else if(event.detail.value == 'StatusIncludingExcluding'){
            this.inclExclEnable=false;
            this.productHierarchyEnable = true;
            this.customerHierarchyEnable = true;
            this.customerEnable = true;
            this.materialGrpEnable = true;
            this.materialEnable = true;
            this.template.querySelector('lightning-input-field[data-name="che"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mge"]').value='';
            this.template.querySelector('lightning-input-field[data-name="mae"]').value='';
            this.template.querySelector('lightning-input-field[data-name="cue"]').value='';
            this.template.querySelector('lightning-input-field[data-name="she"]').value='';
            this.template.querySelector('lightning-input-field[data-name="phe"]').value='';
        }
    }

    handleSuccess(event) {
        this.productHierarchyEnable = true;
        this.customerEnable = true;
        this.customerHierarchyEnable = true;
        this.materialGrpEnable = true;
        this.materialEnable = true;
        this.shipToEnable = true;
        this.inclExclEnable=true;
        this.onChngeEdit == false;
        if(this.currenObjectName == 'PMC_SS_BusinessVolumeSelectionCriteria__c'){
            this.showNew = false;
        }else{
            this.showNew = true;
            this.template.querySelector('lightning-input-field[data-name="cu"]').value='';
        this.template.querySelector('lightning-input-field[data-name="mg"]').value='';
        this.template.querySelector('lightning-input-field[data-name="ma"]').value='';
        this.template.querySelector('lightning-input-field[data-name="sh"]').value='';
        this.template.querySelector('lightning-input-field[data-name="ch"]').value='';
        this.template.querySelector('lightning-input-field[data-name="fc"]').value='';
        this.template.querySelector('lightning-input-field[data-name="ph"]').value='';
        this.template.querySelector('lightning-input-field[data-name="ie"]').value='';
        }
             /*this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: this.currenObjectName,
                    actionName: 'view'
                }
            });*/
            if(this.saveClicked == 'submit' || this.saveClicked == 'submitOnEdit'){
                window.location.href = '/'+this.recordId;
            }
           
    }
    
openNew(event){
    console.log('event.currentTarget.name :: '+event.target.dataset.name);
this.saveClicked = event.target.dataset.name;
}
}