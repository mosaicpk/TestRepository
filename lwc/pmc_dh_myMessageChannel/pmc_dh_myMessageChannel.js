import { LightningElement } from "lwc";
import { createMessageChannel } from "lightning/messageService";

export default class Pmc_dh_myMessageChannel extends LightningElement {
  connectedCallback() {
    // Define the message channel
    this.messageChannel = createMessageChannel();
  }
}