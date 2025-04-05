import { LightningElement, track } from 'lwc';

export default class CustomTabs extends LightningElement {
    @track tabsArray = [
        { value: 'tab1' },
        { value: 'tab2' },
        { value: 'tab3' },
        { value: 'tab4' },
        { value: 'tab5' },
    ];

    scrollDuration = 300;
    leftArrow;
    rightArrow;
    arrowMargin = 16;
    isContentLoaded = false;
    isArrowNeeded = false;
    prevDisabled = false;
    nextDisabled = false;
    mobileItemWidth;
    scrollSize = 0;
    pageRendered = false;
    activeTab = "tab1";

    connectedCallback() {
        this.tabsArray.forEach((el, i) => {
            el.id = i + 1;
            if (this.activeTab) {
                el.state = el.value === this.activeTab ? 'active' : 'inActive';
            } else {
                el.state = i === 0 ? 'active' : 'inActive';
            }
        });
        this.isContentLoaded = true;
    }

    renderedCallback() {
        if (this.pageRendered && this.isContentLoaded) return;
        if (this.getMenuSize() > this.getMenuWrapperSize()) {
            this.isArrowNeeded = true;
            this.leftArrow = this.template.querySelector(".left-arrow");
            this.rightArrow = this.template.querySelector(".right-arrow");

            this.template.querySelector(".menu").classList.add("menu-padding");
            this.template
                .querySelector('.item[data-state="active"]')
                .scrollIntoView();

            if (this.leftArrow && this.rightArrow) {
                this.pageRendered = true;
                this.handleEventListner();
            }
        }
    }

    handleEventListner() {
        this.rightArrow.addEventListener("click", () => {
            this.scrollSize = this.getNextItemWidth(true) -
                this.getMenuWrapperSize() +
                2 * this.arrowMargin;

            this.template.querySelector(".menu-wrapper").scroll({
                left: this.scrollSize,
                behavior: "smooth",
                inline: "nearest"
            });
        });

        this.leftArrow.addEventListener("click", () => {
            this.scrollSize = this.getNextItemWidth(false);

            this.template.querySelector(".menu-wrapper").scroll({
                left: this.scrollSize,
                behavior: "smooth",
                inline: "nearest"
            });
        });

        this.template
            .querySelector(".menu-wrapper")
            .addEventListener("scroll", () => {
            });
    }

    getMenuWrapperSize() {
        return this.template.querySelector(".menu-wrapper").clientWidth;
    }

    getMenuSize() {
        let width = 0;
        this.template.querySelectorAll(".item").forEach((el) => {
            width += el.clientWidth;
        });
        return width;
    }

    getMenuPosition() {
        return this.template.querySelector(".menu-wrapper").scrollLeft;
    }

    getNextItemWidth(flag) {
        const position = flag
            ? this.getMenuPosition() + this.getMenuWrapperSize()
            : this.getMenuPosition();
        let width = 0;
        let item;
        for (let el of this.template.querySelectorAll(".item")) {
            width += el.clientWidth;
            if (width >= position) {
                if (!flag) width -= el.clientWidth;
                break;
            }
            item = el;
        }
        return Math.floor(width) === Math.floor(position) ? width - item?.clientWidth : width;
    }

    handleItemClickEvent(event) {
        this.tabsArray.forEach((el) => {
            el.state = +event.target.dataset.id === el.id ? 'active' : 'inActive';
        });
        event.target.scrollIntoView();
        this.dispatchEvent(new CustomEvent('tabclick', {
            detail: {
                name: event.target.dataset.value,
            }
        }));
    }
}