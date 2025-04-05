import { LightningElement } from 'lwc';
import CAROUSEL_IMAGES from '@salesforce/resourceUrl/miskiMayoGetToKnowUsCustomSecondCarouselWrapper';

const DEFAULT_SLIDER_TIMER = 4000;

export default class MiskiMayoGetToKnowUsCustomSecondCarouselWrapper extends LightningElement {

    showfull = true;
    slideTimer = DEFAULT_SLIDER_TIMER;
    enableAutoScroll = true;

    slides = [
            { image: CAROUSEL_IMAGES + '/photo1.jpg'},
            { image: CAROUSEL_IMAGES + '/photo2.jpg'},
            { image: CAROUSEL_IMAGES + '/photo3.jpg'},
            { image: CAROUSEL_IMAGES + '/photo4.jpg'},
            { image: CAROUSEL_IMAGES + '/photo5.jpg'}
    ];
}