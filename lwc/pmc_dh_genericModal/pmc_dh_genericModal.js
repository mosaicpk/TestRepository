import { LightningElement, api } from "lwc";

export default class Pmc_dh_genericModal extends LightningElement {
  @api modalName;
  @api modalTitle;
  @api secondaryBtnLabel;
  @api primaryBtnLabel;
  @api modalWidth = "500px";
  focusRef;
  isModalShown = 'test';
  // _modalName;

  // @api
  // get modalName() {
  //   return this._modalName;
  // }

  // set modalName(value) [
  //   this._modalName = value;
  // ]

  @api
  setModalVisibility(event) {
    this.isModalShown = this.modalName;
    this.focusRef = event.target;
  }

  closeHandler() {
    this.openModal = false;
    if (this.focusRef) {
      this.focusRef.focus();
    }
  }

  secondaryBtnHandler() {
    this.dispatchEvent(new CustomEvent("secondarybtnclick"));
  }

  primaryBtnHandler() {
    this.dispatchEvent(new CustomEvent("primarybtnclick"));
  }
}