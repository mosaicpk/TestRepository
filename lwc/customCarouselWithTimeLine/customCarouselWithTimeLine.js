import { LightningElement, api, track } from 'lwc';
import CAROUSEL_IMAGES from '@salesforce/resourceUrl/miskiMayoGetToKnowUsCustomThirdCarouselWrapper';

export default class CustomCarouselWithTimeLine extends LightningElement {
    //@api slidesData = [];
    @track currentStartIndex = 0;

    slidesData= [
            {
                image: CAROUSEL_IMAGES + '/photo1.jpg',
                //heading:'Caption one',
                //description:'You can add description of first slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo2.jpg',
                //heading:'Caption Two',
                //description:'You can add description of second slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo3.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo4.jpg',
                //heading:'Caption Two',
                //description:'You can add description of second slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo5.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo6.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo7.jpg',
                //heading:'Caption Two',
                //description:'You can add description of second slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo8.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo9.jpg',
                //heading:'Caption Two',
                //description:'You can add description of second slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo10.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo11.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo12.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo13.jpg',
                //heading:'Caption Two',
                //description:'You can add description of second slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo14.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            },
            {
                image: CAROUSEL_IMAGES + '/photo15.jpg',
                //heading:'Caption Three',
                //description:'You can add description of third slide here'
            }
        ];
    
    get visibleSlides() {
        return this.slidesData.slice(this.currentStartIndex, this.currentStartIndex + 4);
    }

    get trackStyle() {
        return 'display: flex;';
    }

    previousSlide() {
        if (this.currentStartIndex > 0) {
            this.currentStartIndex--;
        }
    }

    nextSlide() {
        if (this.currentStartIndex + 4 < this.slidesData.length) {
            this.currentStartIndex++;
        }
    }
}