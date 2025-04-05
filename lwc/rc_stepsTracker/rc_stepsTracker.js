import { LightningElement, track } from 'lwc';

/**
 * A custom LWC to track the steps of quote checkout flow.
 * @alias StepsTracker
 * @extends LightningElement
 * @hideconstructor
 * @author Raghu Mothukapally
 * @example
 * <c-rc_steps-tracker></c-rc_steps-tracker>
 */

export default class Rc_stepsTracker extends LightningElement {
    @track stepIndex = 0;
    @track stepsData = [
        {
            title: 'Shipping Information',
            status: 'active',
            icon: "icontruck"
        },
        {
            title: 'Payment Information',
            status: 'pending',
            icon: "iconcash"
        },
        {
            title: 'Request Review',
            status: 'pending',
            icon: "iconfilecheck"
        },
        {
            title: 'Request Submitted',
            status: 'pending',
            icon: "iconcheck"
        }
    ];

    previousHandler() {
        this.stepIndex = this.stepIndex - 1;
        if(this.stepIndex == -1){
            this.stepIndex = 0;
        }
        if(-1 < this.stepIndex < this.stepsData.length){
            if(this.stepsData[this.stepIndex+1]){
                this.stepsData[this.stepIndex+1].status = "pending";
            }
            this.stepsData[this.stepIndex].status = "active";
            if(this.stepsData[this.stepIndex-1]){
                this.stepsData[this.stepIndex-1].status = "complete";
            }
        }
    }

    nextHandler() {
        if(this.stepIndex < this.stepsData.length){
            this.stepsData[this.stepIndex].status = "complete";
            if(this.stepsData[this.stepIndex+1]){
                this.stepsData[this.stepIndex+1].status = "active";
            }
            this.stepIndex = this.stepIndex + 1;
            if(this.stepIndex > 3){
                this.stepIndex = this.stepsData.length;
            }
        }
    }


    // mapMarkers = [{
    //         location: {
    //             // Street: '1000 5th Ave',
    //             // City: 'New York',
    //             // State: 'NY',
    //             latitude: '12.912157',
    //             longitude: '77.606340'
    //         },
    //         title: 'Museum of Fine Arts',
    //         description: 'A grand setting for one of the greatest collections of art, from ancient to contemporary.',
    // }];
    mapMarkers = [
        {
            value: 'L1',
            location: {
                Latitude: '-24.67737721250085', 
                Longitude: '-48.057520418214736',
            },
            title: 'Mosaic Fertilizantes',
            description: 'https://mosaicco.com.br/',
        },
        {
            value: 'L2',
            location: {
                Latitude: '15.928391819243', 
                Longitude: '47.62680078134358'
            },
            title: 'Yemen',
            description: 'It shares maritime borders with Eritrea, Djibouti and Somalia.',
        },
        {
            value: 'L3',
            location: {
                Latitude: '4.5198039961296335', 
                Longitude: '114.6070344365419'
            },
            title: 'Brunei',
            description: 'Surrounded by Malaysia and the South China Sea',
        },
    ];
    zoomLevel = 1;
    listView = 'visible';

    selectedMarkerValue = 'L1';


    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;

        // // response
        // mapMarkers[0].location.Latitude = response.Latitude;
        // mapMarkers[0].location.Longitude = response.Longitude;
    }
    
}