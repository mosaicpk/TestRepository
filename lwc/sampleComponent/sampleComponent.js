import { LightningElement } from 'lwc';
import getDocDownload from "@salesforce/apex/PMC_DH_DocumentListViewController.getDocDownload";

export default class SampleComponent extends LightningElement {
  // connectedCallback() {
  //   this.fetchDocList();
  // }

  viewDocument() {
    getDocDownload()
      .then((response) => {
        console.log('data', JSON.parse(JSON.stringify(response)));
        const blob = this.base64toBlob(JSON.parse(JSON.stringify(response)).strData, "application/pdf");
        const blobUrl = URL.createObjectURL(blob);
        this.previewDoc(blobUrl);

      }).catch((error) => {
        console.log('error', error);
      })
  }

  downloadDocument() {
    getDocDownload()
      .then((response) => {
        console.log('data', JSON.parse(JSON.stringify(response)));
        const blob = this.base64toBlob(JSON.parse(JSON.stringify(response)).strData, "application/pdf");
        const blobUrl = URL.createObjectURL(blob);
        this.downloadDoc(blobUrl);

      }).catch((error) => {
        console.log('error', error);
      })
  }

  downloadDoc(url) {
    var link = document.createElement('a');
    link.href = url;
    link.download = 'demo';
    document.body.appendChild(link);
    link.click();
    URL.revokeObjectURL(url);
  }

  previewDoc(url) {
    var link = document.createElement('a');
    link.target = '_blank';
    link.href = url;
    link.click();
  }

  base64toBlob(b64Data, contentType = "", sliceSize = 512) {
    const byteCharacters = window.atob(b64Data);
    const byteArrays = [];
    for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
      const slice = byteCharacters.slice(offset, offset + sliceSize);

      const byteNumbers = new Array(slice.length);
      for (let i = 0; i < slice.length; i++) {
        byteNumbers[i] = slice.charCodeAt(i);
      }
      const byteArray = new Uint8Array(byteNumbers);
      byteArrays.push(byteArray);
    }
    const blob = new Blob(byteArrays, { type: contentType });
    return blob;
  }
}