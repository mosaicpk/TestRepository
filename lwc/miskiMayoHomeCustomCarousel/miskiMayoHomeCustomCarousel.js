import { LightningElement } from 'lwc';
import CAROUSEL_IMAGES from '@salesforce/resourceUrl/miskMayoHome';

const DEFAULT_SLIDER_TIMER = 4000;

export default class MiskiMayoHomeCustomCarousel extends LightningElement {

    showfull = true;
    slideTimer = DEFAULT_SLIDER_TIMER;
    enableAutoScroll = true;

    slides = [
            { image: CAROUSEL_IMAGES + '/photo1.jpg'},
            { image: CAROUSEL_IMAGES + '/photo2.jpg'},
            { image: CAROUSEL_IMAGES + '/photo3.jpg'}
        ];
    
    // slides= [
    //     {
    //         image: CAROUSEL_IMAGES + '/photo1.jpg'
    //         //heading:'',
    //         //description:''
    //     },
    //     {
    //         image: CAROUSEL_IMAGES + '/photo2.jpg'
    //         //heading:'Caption Two',
    //         //description:'You can add description of second slide here'
    //     },
    //     {
    //         image: CAROUSEL_IMAGES + '/photo3.jpg'
    //         //heading:'Caption Three',
    //         //description:'You can add description of third slide here'
    //     }
    // ];
}