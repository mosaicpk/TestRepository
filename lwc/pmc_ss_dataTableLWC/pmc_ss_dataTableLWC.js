import { LightningElement ,api, wire, track} from 'lwc';
import getForecast from '@salesforce/apex/PMC_SS_GetForecastFact.getForecast';
export default class LightningDatatableLWCExample extends LightningElement {
    @track columns = [{
            label: 'Name',
            fieldName: 'Name',
            type: 'text'
        },
        {
            label: 'Sales Plan',
            fieldName: 'PMC_SS_CurrentSalesPlan__c',
            type: 'text',
            editable : true
        },
        {
            label: 'Account Manager',
            fieldName: 'PMC_SS_AccountManager__c',
            type: 'text',
            editable : true
        },
    ];
 
    @track error;
    @track forecastList ;
    @wire(getForecast)
    wiredForecasts({
        error,
        data
    }) {
        if (data) {
            this.forecastList = data;
        } else if (error) {
            this.error = error;
        }
    }
}