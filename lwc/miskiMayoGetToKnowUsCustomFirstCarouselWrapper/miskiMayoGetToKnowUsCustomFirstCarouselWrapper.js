import { LightningElement, track } from 'lwc';
import CAROUSEL_IMAGES from '@salesforce/resourceUrl/miskiMayoGetToKnowUsCustomFirstCarouselWrapper';
import MMGetToKnowUsCustomFirstCarouselWrapper from "@salesforce/label/c.MMGetToKnowUsCustomFirstCarouselWrapper";

const DEFAULT_SLIDER_TIMER = 4000;

export default class MiskiMayoGetToKnowUsCustomFirstCarouselWrapper extends LightningElement {

    showfull = true;
    slideTimer = DEFAULT_SLIDER_TIMER;
    enableAutoScroll = true;

    @track labels = {MMGetToKnowUsCustomFirstCarouselWrapper};
    
    slides= [
        {image: CAROUSEL_IMAGES + '/photo1.jpg', heading: this.labels.MMGetToKnowUsCustomFirstCarouselWrapper},
        {image: CAROUSEL_IMAGES + '/photo2.jpg', heading:this.labels.MMGetToKnowUsCustomFirstCarouselWrapper},
        {image: CAROUSEL_IMAGES + '/photo3.jpg', heading:this.labels.MMGetToKnowUsCustomFirstCarouselWrapper}
    ];
}