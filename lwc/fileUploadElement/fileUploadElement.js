import { LightningElement, track, api } from "lwc";

const MIMES = [
  {
    type: 'jpeg',
    pattern: [0xFF, 0xD8, 0xFF],
    mask: [0xFF, 0xFF, 0xFF]
  },
  {
    type: 'jpg',
    pattern: [0xFF, 0xD8],
    mask: [0xFF, 0xFF]
  },
  {
    type: 'png',
    pattern: [0x89, 0x50, 0x4E, 0x47],
    mask: [0xFF, 0xFF, 0xFF, 0xFF]
  },
  {
    type: 'pdf',
    pattern: [0x25, 0x50, 0x44, 0x46, 0x2D],
    mask: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
  },
  {
    type: 'doc',
    pattern: [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1],
    mask: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
  },
  {
    type: 'docx',
    pattern: [0x50, 0x4B, 0x03, 0x04],
    mask: [0xFF, 0xFF, 0xFF, 0xFF]
  },
  {
    type: 'xls',
    pattern: [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1],
    mask: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
  },
  {
    type: 'xlsx',
    pattern: [0x50, 0x4B, 0x03, 0x04],
    mask: [0xFF, 0xFF, 0xFF, 0xFF]
  }
];

export default class FileUploadElement extends LightningElement {
  @api acceptedFormats = "";
  @api isMultiple;
  @api
  resetFiles() {
    this.uploadedFiles = [];
    this.filesData = [];
    this.invalidFormatFilesError = '';
    this.isWrongFormat = false;
  }
  @track uploadedFiles = [];
  @track filesData = [];
  @track mimes = [];

  isWrongFormat = false;
  loadSpinner = false;
  invalidFormatFilesError = '';
  acceptedFormatsErrorMessage = '';

  connectedCallback() {
    this.acceptedFormatsErrorMessage = this.acceptedFormats.replaceAll(".", "").toUpperCase();
  }

  handleChange(event) {
    this.handleFileUpload(event.target.files);
  }

  handleDrop(event) {
    event.preventDefault();
    event.stopPropagation();
    this.handleFileUpload(event.dataTransfer.files);
  }

  handleFileUpload(files) {
    this.invalidFormatFilesError = '';
    this.largeFiles = [];
    this.isWrongFormat = false;
    this.validateFileMIMEType(files);
  }

  uploadFilteredFiles(files) {
    let that = this;
    let tempData = [];
    for (let i = 0; i < files.length; ++i) {
      let name = files[i].name;
      let extension = name.slice(name.lastIndexOf(".") + 1);
      this.uploadedFiles.push(name);
      const file = files[i];
      that.loadSpinner = true;
      let reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = function (event) {
        let result = event.target.result;
        let base64 = result.split(",")[1];
        let fileData = {
          filename: name,
          filetype: extension,
          base64: base64
        };
        tempData.push(JSON.parse(JSON.stringify(fileData)));
        if (tempData.length === files.length) {
          that.filesData = JSON.parse(JSON.stringify(that.filesData.concat(tempData)));
          that.dispatchEvent(
            new CustomEvent("uploadcomplete", {
              detail: {
                filesData: JSON.parse(JSON.stringify(that.filesData))
              }
            })
          );
          that.loadSpinner = false;
          that.template.querySelector(`input`).value = null;
        }
      };
    }
  }

  removeRepeatedFiles(files) {
    for (let i = 0; i < files.length; ++i) {
      let name = files[i].name;
      this.uploadedFiles.forEach((el) => {
        if (el === name) {
          this.uploadedFiles.splice(this.uploadedFiles.indexOf(name), 1);
          this.filesData.splice(this.filesData.findIndex((item) => item.filename === name), 1);
        }
      });
    }
    this.uploadFilteredFiles(files);
  }

  validateFileMIMEType(files) {
    this.loadSpinner = true;
    let that = this;
    let iterations = 0;
    let filtered = [];
    for (let i = 0; i < files.length; ++i) {
      let name = files[i].name;
      let extension = name.slice(name.lastIndexOf(".") + 1);
      let reader = new FileReader();
      reader.readAsArrayBuffer(files[i]);
      reader.onloadend = function (e) {
        if (e && e.target.readyState === FileReader.DONE && !e.target.error) {
          let bytes = new Uint8Array(e.target.result);
          let mime = MIMES?.find(
            (m) => m.type === extension);
          if (that.acceptedFormats.includes(extension) && !(mime && !that.checkIfBytesSatifiesMIMEType(bytes, mime))) {
            filtered.push(files[i]);
          }
          else {
            that.isWrongFormat = true;
            if (!that.invalidFormatFilesError) {
              that.invalidFormatFilesError = `${name}`;
            }
            else {
              that.invalidFormatFilesError = `${that.invalidFormatFilesError}, ${name}`;
            }
          }
          iterations = iterations + 1;
          if (iterations === files.length) {
            if (that.isWrongFormat) {
              that.invalidFormatFilesError = `Following files could not be uploaded: ${that.invalidFormatFilesError}`;
            }
            that.loadSpinner = false;
            that.removeRepeatedFiles(filtered);
          }
        }
      }
    }
  }

  checkIfBytesSatifiesMIMEType(bytes, mime) {
    for (let i = 0, l = mime.mask.length; i < l; ++i) {
      let x = (bytes[i] & mime.mask[i]) - mime.pattern[i];
      if (x !== 0) {
        return false;
      }
    }
    return true;
  }

  handleDragOver(event) {
    event.preventDefault();
    event.stopPropagation();
  }

  handleDragEnter(event) {
    event.preventDefault();
    event.stopPropagation();
  }

  handleDragLeave(event) {
    event.preventDefault();
    event.stopPropagation();
  }
}