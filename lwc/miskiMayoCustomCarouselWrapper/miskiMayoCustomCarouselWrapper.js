import { LightningElement } from 'lwc';
import CAROUSEL_IMAGES from '@salesforce/resourceUrl/miskMayoHome';

const DEFAULT_SLIDER_TIMER = 3000

export default class MiskiMayoCustomCarouselWrapper extends LightningElement {

    showfull = true;
    slideTimer = DEFAULT_SLIDER_TIMER;
    enableAutoScroll = true;
    
    slides= [
        {
            image: CAROUSEL_IMAGES + '/photo1.jpg',
            heading:'Caption one',
            description:'You can add description of first slide here'
        },
        {
            image: CAROUSEL_IMAGES + '/photo2.jpg',
            heading:'Caption Two',
            description:'You can add description of second slide here'
        },
        {
            image: CAROUSEL_IMAGES + '/photo3.jpg',
            //heading:'Caption Three',
            //description:'You can add description of third slide here'
        }
    ];
}