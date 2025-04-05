import { LightningElement, api } from 'lwc';

export default class Testcomponentt extends LightningElement {
  @api label = 'Test Label';
  @api placeholder = '';
  @api errorMsg = '';
  @api isRequired = false;
  @api options = [
    { label: "label1", value: "value1" },
    { label: "label2", value: "value2" },
    { label: "label3", value: "value3" },
    { label: "label4", value: "value4" },
    { label: "label5", value: "value5" },
    { label: "searchFilter1", value: "searchFilter1" },
    { label: "searchFilter2", value: "searchFilter2" },
    { label: "searchFilter3", value: "searchFilter3" },
    { label: "searchFilter4", value: "searchFilter4" },
    { label: "searchFilter5", value: "searchFilter5" },
    { label: "option1", value: "option1" },
    { label: "option2", value: "option2" },
    { label: "option3", value: "option3" },
    { label: "option4", value: "option4" },
    { label: "option5", value: "option5" },
    { label: "option6", value: "option6" },
    { label: "option7", value: "option7" },
    { label: "option8", value: "option8" },
    { label: "option9", value: "option9" },
    { label: "option10", value: "option10" },
  ];

  hasError = false;
  isExpanded = false;
  selectedOptionValue;
  searchString;

  connectedCallback() {
    if (!this.placeholder) {
      this.placeholder = `Choose ${this.label}`;
    }
    if (!this.errorMsg) {
      this.errorMsg = `Please select a value for ${this.label}`
    }
    this.options.forEach((option, index) => {
      option.id = index;
    })
    this.filteredOptions = JSON.parse(JSON.stringify(this.options));
  }

  expandOptions() {
    this.isExpanded = !this.isExpanded;
    this.template.querySelector('.input-wrapper').classList.toggle('input-focus');
  }

  handleChange(event) {
    this.filteredOptions.forEach((option) => {
      if (option.id === +event.currentTarget.dataset.id) {
        option.checked = true;
        this.selectedOptionValue = option.value;
        this.placeholder = option.label;
      }
      else {
        option.checked = false
      }
    });
    this.options.forEach((option) => {
      if (option.id === +event.currentTarget.dataset.id) {
        option.checked = true
      }
      else {
        option.checked = false
      }
    });
    this.isExpanded = false;
  }

  handleSearch(event) {
    this.searchString = event.target.value.toLowerCase();
    if (this.searchString) {
      this.filteredOptions = this.options.filter((option) => {
        return option.label.toLowerCase().includes(this.searchString);
      });
    } else {
      this.filteredOptions = JSON.parse(JSON.stringify(this.options));
    }
  }

}