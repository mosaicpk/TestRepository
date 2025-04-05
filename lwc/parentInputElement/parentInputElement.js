import { LightningElement, track } from "lwc";

export default class ParentInputElement extends LightningElement {
  @track pageObject = {};
  today;

  connectedCallback() {
    this.today = new Date().toISOString().slice(0, 10);
  }

  handleDataChange(event) {
    if (
      event.detail.value !== "undefined" &&
      event.target &&
      event.target.dataset
    ) {
      this.pageObject[event.target.dataset.id] =
        event.target.type === "text"
          ? event.detail.value.trim()
          : event.detail.value;
    }
  }
}