import { LightningElement, api } from 'lwc';

const CARD_VISIBLE_CLASSES = 'fade slds-show';
const CARD_HIDDEN_CLASSES = 'fade slds-hide';
const DOT_VISIBLE_CLASSES = 'dot active';
const DOT_HIDDEN_CLASSES = 'dot';
const DEFAULT_SLIDER_TIMER = 4000;
const DEFAULT_SLIDER_WIDTH = 700;

export default class CustomCarouselWithText extends LightningElement {
    slides = [];
    slideIndex = 1;
    timer;
    textTimeout;

    @api slideTimer = DEFAULT_SLIDER_TIMER;
    @api enableAutoScroll;
    @api customWidth = DEFAULT_SLIDER_WIDTH;
    @api showFull;

    get maxWidth() {
        this.showFull = true;
        return this.showFull ? `width:100%` : `width:${Number(this.customWidth)}px`;
    }

    @api
    get slidesData() {
        return this.slides;
    }

    set slidesData(data) {
        this.slides = data.map((item, index) => {
            return index === 0
                ? {
                      ...item,
                      slideIndex: index + 1,
                      cardClasses: CARD_VISIBLE_CLASSES,
                      dotClases: DOT_VISIBLE_CLASSES,
                      showText: false
                  }
                : {
                      ...item,
                      slideIndex: index + 1,
                      cardClasses: CARD_HIDDEN_CLASSES,
                      dotClases: DOT_HIDDEN_CLASSES,
                      showText: false
                  };
        });
    }

    connectedCallback() {
        if (this.enableAutoScroll) {
            this.startAutoScroll();
        }
        this.showTextWithDelay();
    }

    disconnectedCallback() {
        if (this.enableAutoScroll) {
            window.clearInterval(this.timer);
        }
        if (this.textTimeout) {
            clearTimeout(this.textTimeout);
        }
    }

    startAutoScroll() {
        this.timer = window.setInterval(() => {
            this.slideSelectionHandler(this.slideIndex + 1);
        }, Number(this.slideTimer));
    }

    showTextWithDelay() {
        if (this.textTimeout) {
            clearTimeout(this.textTimeout);
        }
        this.textTimeout = setTimeout(() => {
            this.slides = this.slides.map((item) => {
                return this.slideIndex === item.slideIndex
                    ? { ...item, showText: true }
                    : { ...item, showText: false };
            });
        }, 1000); // It will appear 1 second after the image
    }

    currentSlide(event) {
        let slideIndex = Number(event.target.dataset.id);
        this.slideSelectionHandler(slideIndex);
    }

    backSlide() {
        let slideIndex = this.slideIndex - 1;
        this.slideSelectionHandler(slideIndex);
    }

    forwardSlide() {
        let slideIndex = this.slideIndex + 1;
        this.slideSelectionHandler(slideIndex);
    }

    slideSelectionHandler(id) {
        if (this.textTimeout) {
            clearTimeout(this.textTimeout);
        }

        if (id > this.slides.length) {
            this.slideIndex = 1;
        } else if (id < 1) {
            this.slideIndex = this.slides.length;
        } else {
            this.slideIndex = id;
        }

        this.slides = this.slides.map((item) => {
            return this.slideIndex === item.slideIndex
                ? { ...item, cardClasses: CARD_VISIBLE_CLASSES, dotClases: DOT_VISIBLE_CLASSES, showText: false }
                : { ...item, cardClasses: CARD_HIDDEN_CLASSES, dotClases: DOT_HIDDEN_CLASSES, showText: false };
        });

        this.showTextWithDelay();
    }
}