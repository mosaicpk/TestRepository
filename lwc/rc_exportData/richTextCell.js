import { LightningElement, api } from 'lwc';

export default class RichTextCell extends LightningElement {
    @api value;
    @api rowId;

    handleChange(event) {
      const chanegeEvent = new CustomEvent('richtextchange', {
        detail: {
          value: event.target.value,
          rowId: this.rowId
        }
      });
      this.dispatchEvent(chanegeEvent);
    }
}