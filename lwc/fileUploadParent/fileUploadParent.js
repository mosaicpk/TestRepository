import { LightningElement, track } from 'lwc';

export default class FileUploadParent extends LightningElement {
    @track filesData = [];
    acceptedFormats = '.pdf, .docx, .xls, .png, .jpeg';
    isMultiple = true;

    /**
     * Upload Event dispatched from child
     */
    handleFileUpload(event) {
        if (event.detail.filesData) {
            this.filesData = event.detail.filesData;
        }
    }
    
    clearFiles() {
        this.template.querySelector('c-file-upload-element').resetFiles();
        this.filesData = [];
    }

}