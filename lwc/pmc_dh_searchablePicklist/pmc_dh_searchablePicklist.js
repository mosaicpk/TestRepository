import { LightningElement, track, api } from 'lwc';

export default class Pmc_dh_searchablePicklist extends LightningElement {
  _defaultValue;
  _dropdownOptions;
  selectedValue;
  selectedLabel;
  optionItemClass = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_term';
  @track searchTerm = '';
  @track options = [];
  @api label;
  @api picklistPlaceholder;
  @api searchPlaceholder;
  @api disableOneOption;
  searchString;

  @api
  set defaultValue(value) {
    this._defaultValue = value;
    this.selectedValue = this._defaultValue;
  }
  get defaultValue() {
    return this._defaultValue;
  }

  @api
  set dropdownOptions(data) {
    if (data) {
      this._dropdownOptions = data;
      this.options = JSON.parse(JSON.stringify(this._dropdownOptions));
      this.processOptionsData();
    }
  }
  get dropdownOptions() {
    return JSON.parse(JSON.stringify(this._dropdownOptions));
  }

  connectedCallback() {
    window.addEventListener('click', () => {
      this.hideDropdownSection();
    });
  }
  //description To select ony option by default if only one option is available
  processOptionsData() {
    /*Setting default selection if only one option available*/
    if (this.options.length === 1) {
      this.selectedValue = this.options[0].value;
      this.selectedLabel = this.options[0].label;
    } else {
      this.selectedLabel = this.picklistPlaceholder;
    }
    this.updateSelectedOption();
  }

  @api checkValidity() {
    return this.selectedValue;
  }
  //description To handle option request
  handleOptionSelect(event) {
    this.selectedValue = event.currentTarget.dataset.value;
    event.stopPropagation();
    this.updateSelectedOption();
    this.searchTerm = '';
    this.hideDropdownSection();
    this.diptchValueChangedEvent();
    this.handleClear();
  }
  //description To update selected option
  updateSelectedOption() {
    this.options.forEach((item) => {
      if (item.value === this.selectedValue) {
        item.isSelected = true;
        this.selectedLabel = item.label;
        item.class = `${this.optionItemClass} slds-has-focus`;
      } else {
        item.isSelected = false;
        item.class = this.optionItemClass;
      }
    });
  }
  //description Todispatch event to parent
  diptchValueChangedEvent() {
    const valueChangedEvent = new CustomEvent('valuechanged', {
      detail: { value: this.selectedValue, type: this.label },
    });
    this.dispatchEvent(valueChangedEvent);
  }
  // description To filter options in case of search
  filterResults(event) {
    this.searchString = event.target.value;
    const dropdownOptions = JSON.parse(JSON.stringify(this.dropdownOptions));
    if (this.searchString) {
      this.options = dropdownOptions.filter((item) =>
        item.label
          ?.toLowerCase()
          .includes(this.searchString.toLowerCase()),
      );
    } else {
      this.resetOptions();
    }
    this.updateSelectedOption();
  }

  // description To handle open and close of dropdown
  toggleDropdown(e) {
    e.stopPropagation();
    if (e.target.name !== 'type-ahead') {
      const classList = e.currentTarget.classList;
      classList.toggle('slds-is-open');
      if (!classList.contains('slds-is-open') && !this.selectedValue) {
        classList.add('show-slds-error');
      } else {
        classList.remove('show-slds-error');
      }
    }
  }
  // description To hide dropdown when option is selected and change the class of selected option

  hideDropdownSection() {
    const dropdownElm = this.template.querySelector(
      '.slds-dropdown-trigger_click',
    );
    if (dropdownElm) {
      dropdownElm.classList.remove('slds-is-open');
      if (!this.selectedValue) {
        dropdownElm.classList.add('show-slds-error');
      } else {
        dropdownElm.classList.remove('show-slds-error');
      }
    }
  }
  // description To handle clear button
  handleClear() {
    this.searchString = '';
    // if (event.target.value) {
    //   this.resetOptions();
    // }
    this.resetOptions();
    this.updateSelectedOption();
  }

  // description To handle reset
  resetOptions() {
    this.options = JSON.parse(JSON.stringify(this.dropdownOptions));
  }
  get containerClasswithDisbaleCheck() {
    return this.dropdownOptions.length === 1 && this.disableOneOption
      ? 'slds-combobox_container disabled'
      : 'slds-combobox_container';
  }
}

// @track picklistPlaceholder = "Select delivery address";
// @track searchPlaceholder = "Search";
// @track selectedOption = "";
// @track picklistOptions = [
//   {
//     label: "Select delivery address",
//     value: "",
//     isSelected: false,
//     class: ""
//   },
//   {
//     label: "Option 1",
//     value: "option1",
//     isSelected: false,
//     class: ""
//   },
//   {
//     label: "Option 2",
//     value: "option2",
//     isSelected: false,
//     class: ""
//   },
//   {
//     label: "Option 3",
//     value: "option3",
//     isSelected: false,
//     class: ""
//   }
// ];
// handleOnChange(data) {
//   console.log("handleOnChange");
//   console.log(data);
// }