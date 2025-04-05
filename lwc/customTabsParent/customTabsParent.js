import { LightningElement, track } from 'lwc';

export default class CustomTabsParent extends LightningElement {
    @track contentSelector = {tab1: true, tab2: false, tab3: false, tab4: false, tab5: false};

    tabClickHandler(event){
        Object.keys(this.contentSelector).forEach(el => {
            this.contentSelector[el] = false;
        });
        this.contentSelector[event.detail.name] = true;
    }
}