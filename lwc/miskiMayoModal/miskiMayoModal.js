import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class MiskiMayoModal extends LightningModal {

    handleOkay() {
        this.close('okay');
    }
}