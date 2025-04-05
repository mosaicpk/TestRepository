import { LightningElement, api, track } from "lwc";

const inputDatePlaceholderHandler = (date, inputComponent) => {
  if (date) {
    inputComponent.classList.remove("input-date-placeholder");
  } else {
    inputComponent.classList.add("input-date-placeholder");
  }
};

const formatLabel = (str, args) => {
  if (!str) {
    return str;
  }
  return str.replace(/{(\d+)}/g, function (match, number) {
    return args[number];
  });
};

export default class InputElement extends LightningElement {
  CONSTANT = {
    EVENT_TYPE_BLUR: "onblur",
    EVENT_TYPE_CHANGE: "onchange",
    EVENT_TYPE_KEYUP: "onkeyup",
    EVENT_TYPE_FOCUS: "onfocus",
    EVENT_TYPE_KEYPRESS: "onkeypress",
    EVENT_TYPE_CHANGE_NAME: "inputdatachange",
    EVENT_TYPE_BLUR_NAME: "inputdatablur",
    EVENT_TYPE_KEYUP_NAME: "inputdatakeyup",
    EVENT_TYPE_KEYPRESS_NAME: "inputdatakeypress",
    EVENT_TYPE_FOCUS_NAME: "inputfocus"
  };
  @api className;
  @api textName;
  @api variant = "standard";
  @api textPlaceholder;
  @api isRequired = false;
  @api isReadOnly = false;
  @api isNumber = false;
  @api parentName;
  @api pattern;
  @api minLength;
  @api maxLength;
  @api minValue;
  @api maxValue;
  @api messageWhenPatternMismatch;
  @api messageWhenTooShort;
  @api messageWhenTooLong;
  @api messageWhenValueMissing;
  @api messageWhenTypeMismatch;
  @api messageWhenRangeLow;
  @api messageWhenRangeHigh;
  @api type = "text";

  _messageWhenPatternMismatch;
  _messageWhenTooShort;
  _messageWhenTooLong;
  _messageWhenValueMissing;
  _messageWhenTypeMismatch;
  _messageWhenRangeLow;
  _messageWhenRangeHigh;

  @track _errorMsg = [];
  _isDisabled = false;
  _textPlaceholder = "";
  errorClassName = "slds-form-element slds-has-error";
  _defaultValue;
  _textLabel = "";
  PlaceholderForEnter = "Enter {0}";
  MaxLengthError = "{0} can not be greater than {1}";
  MinLengthError = "{0} can not be less than {1}";
  Pattern_Mismatch_Error = "{0} does not match required pattern";
  Type_Mismatch_Error = "{0} does not match required type";
  RequiredErrorMesssageForInput = "{0} is required";
  minDateErrorMessage = "{0} can not before {1} date";
  maxDateErrorMessage = "{0} can not after {1} date";
  isRequiredCheck = false;

  @api labelParentClass;
  get _labelParentClass() {
    return this.labelParentClass
      ? this.labelParentClass + " slds-grid slds-wrap"
      : "slds-grid slds-wrap";
  }

  @api
  get isDisabled() {
    return this._isDisabled;
  }
  set isDisabled(value) {
    this._isDisabled = value;
    if (value) {
      setTimeout(() =>
        this.template.querySelector("lightning-input").reportValidity()
      );
    }
  }

  @api
  get defaultValue() {
    return this._defaultValue;
  }

  set defaultValue(value) {
    this._defaultValue = value;
  }

  @api
  get errorMsg() {
    return this._errorMsg;
  }
  set errorMsg(value) {
    if (value) {
      this._errorMsg = value;
      this.checkError();
    }
  }

  @api
  get textLabel() {
    return this._textLabel;
  }
  set textLabel(value) {
    if (value) {
      this._textLabel = value;
      this.updatePlaceholderLabel();
    }
  }

  @api
  reportValidity() {
    const allValid = [
      ...this.template.querySelectorAll('[data-name="' + this.parentName + '"]')
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.value = inputCmp.value?.trim();
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    return allValid;
  }

  @api
  reportErrorValidity() {
    this.template
      .querySelector('[data-name="' + this.parentName + '"]')
      .classList.add("slds-has-error");
  }

  @api
  removeReportErrorValidity() {
    let selectEl = this.template.querySelector(
      '[data-name="' + this.parentName + '"]'
    );
    if (selectEl.classList.contains("slds-has-error")) {
      selectEl.classList.remove("slds-has-error");
    }
  }

  @api
  checkValidity() {
    return this.parentName
      ? this.template
          .querySelector(`[data-name=${this.parentName}]`)
          ?.checkValidity()
      : true;
  }

  @api
  resetInput() {
    const inputEl = this.template.querySelector(
      '[data-name="' + this.parentName + '"]'
    );
    inputEl.value = null;
    this.isRequiredCheck = false;
    setTimeout(() => {
      inputEl.reportValidity();
      this.isRequiredCheck = this.isRequired;
    });
  }

  @api
  updateIsRequired() {
    this.isRequiredCheck = this.isRequired;
  }

  @api
  resetValue(value) {
    const inputEl = this.template.querySelector(
      '[data-name="' + this.parentName + '"]'
    );
    inputEl.value = value;
  }

  connectedCallback() {
    this.isRequiredCheck = this.isRequired;
    if (!this.messageWhenTooLong) {
      this._messageWhenTooLong = formatLabel(this.MaxLengthError, [
        this.textLabel,
        this.maxLength
      ]);
    } else {
      this._messageWhenTooLong = this.messageWhenTooLong;
    }
    if (!this.messageWhenTooShort) {
      this._messageWhenTooShort = formatLabel(this.MinLengthError, [
        this.textLabel,
        this.minLength
      ]);
    } else {
      this._messageWhenTooShort = this.messageWhenTooShort;
    }
    if (!this.messageWhenPatternMismatch) {
      this._messageWhenPatternMismatch = formatLabel(
        this.Pattern_Mismatch_Error,
        [this.textLabel]
      );
    } else {
      this._messageWhenPatternMismatch = this.messageWhenPatternMismatch;
    }
    if (!this.messageWhenTypeMismatch) {
      this._messageWhenTypeMismatch = formatLabel(this.Type_Mismatch_Error, [
        this.textLabel
      ]);
    } else {
      this._messageWhenTypeMismatch = this.messageWhenTypeMismatch;
    }
    if (!this.messageWhenValueMissing) {
      this._messageWhenValueMissing = formatLabel(
        this.RequiredErrorMesssageForInput,
        [this.textLabel]
      );
    } else {
      this._messageWhenValueMissing = this.messageWhenValueMissing;
    }
    if (!this.messageWhenRangeLow) {
      console.log('minValue', this.minValue)
      this._messageWhenRangeLow = formatLabel(this.minDateErrorMessage, [
        this.textLabel,
        this.minValue
      ]);
    } else {
      console.log('minValue1', this.minValue)
      this._messageWhenRangeLow = this.messageWhenRangeLow;
    }
    if (!this.messageWhenRangeHigh) {
      this._messageWhenRangeHigh = formatLabel(this.maxDateErrorMessage, [
        this.textLabel,
        this.minValue
      ]);
    } else {
      this._messageWhenRangeHigh = this.messageWhenRangeHigh;
    }
    this.updatePlaceholderLabel();
  }

  renderedCallback() {
    if (this.type === "date") {
      inputDatePlaceholderHandler(
        this.defaultValue,
        this.template.querySelector("lightning-input")
      );
    }
  }

  updatePlaceholderLabel() {
    if (!this.textPlaceholder) {
      this._textPlaceholder = formatLabel(this.PlaceholderForEnter, [
        this._textLabel?.toLowerCase()
      ]);
    } else if (this.textPlaceholder && this.textPlaceholder.length) {
      this._textPlaceholder = this.textPlaceholder;
    }
  }

  handleBlur(event) {
    this.reportValidity();
    this.handleEvent(event, this.CONSTANT.EVENT_TYPE_BLUR);
  }

  handleChange(event) {
    this.handleEvent(event, this.CONSTANT.EVENT_TYPE_CHANGE);
  }

  handleKeyup(event) {
    if (this.isNumber) {
      event.target.value = event.target.value.replace(/[^0-9]/g, "");
    }
    this.handleEvent(event, this.CONSTANT.EVENT_TYPE_KEYUP);
  }

  handleFocus(event) {
    this.handleEvent(event, this.CONSTANT.EVENT_TYPE_FOCUS);
  }

  handleKeyPress(event) {
    this.handleEvent(event, this.CONSTANT.EVENT_TYPE_KEYPRESS);
  }

  handleEvent(event, eventType) {
    let eventName;
    switch (eventType) {
      case this.CONSTANT.EVENT_TYPE_CHANGE:
        eventName = this.CONSTANT.EVENT_TYPE_CHANGE_NAME;
        break;
      case this.CONSTANT.EVENT_TYPE_BLUR:
        eventName = this.CONSTANT.EVENT_TYPE_BLUR_NAME;
        break;
      case this.CONSTANT.EVENT_TYPE_KEYUP:
        eventName = this.CONSTANT.EVENT_TYPE_KEYUP_NAME;
        break;
      case this.CONSTANT.EVENT_TYPE_KEYPRESS:
        eventName = this.CONSTANT.EVENT_TYPE_KEYPRESS_NAME;
        break;
      case this.CONSTANT.EVENT_TYPE_FOCUS:
        eventName = this.CONSTANT.EVENT_TYPE_FOCUS_NAME;
        break;
      default:
        eventName = this.CONSTANT.EVENT_TYPE_CHANGE_NAME;
    }
    this.dispatchEvent(
      new CustomEvent(eventName, {
        detail: {
          name: event.target.dataset.name,
          value: event.target.value,
          oldvalue: event.target.dataset.value,
          keyCode: event.keyCode
        }
      })
    );
  }

  checkError() {
    let inputCmp = this.template.querySelector("lightning-input");
    this._errorMsg.length > 0
      ? inputCmp.setCustomValidity(this._errorMsg[0])
      : inputCmp?.setCustomValidity("");
    inputCmp?.reportValidity();
  }

  @api
  focus() {
    const inputField = this.template.querySelector("lightning-input");
    if (inputField) {
      inputField.focus();
    }
  }
}