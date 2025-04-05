import { LightningElement, track } from 'lwc';

export default class LanguageDropdown extends LightningElement {
  @track showDropdown = false;
  @track selectedLanguageOption = "EN";
  @track languageOptions = [
    { label: "English", value: "EN" },
    { label: "Portuguese", value: "PT" },
    { label: "Spanish", value: "SP" }
  ];

  changeHandler(event) {
    event.preventDefault();
    event.stopPropagation();
    this.selectedLanguageOption = event.target.dataset.id;
    this.showDropdown = false;
  }

  toggleDropdown() {
    this.showDropdown = !this.showDropdown;
  }

  handleDropdownKeyPress(event) {
    if (event.keyCode === 13) {
      this.toggleDropdown();
    } else if (event.keyCode === 9) {
      if (event.shiftKey) {
        this.showDropdown = false;
        return;
      }
      event.preventDefault();
      this.template.querySelectorAll(".lang")[0]?.focus();
      this.showDropdown = true;
    }
  }

  handleKeyPress(event) {
    event.stopPropagation();
    if (event.keyCode === 13) {
      this.changeHandler(event);
    } else if (event.keyCode === 9) {
      const langItems = this.template.querySelectorAll(".lang");
      if (
        !event.shiftKey &&
        event.target.dataset.id === langItems[langItems.length - 1].dataset.id
      ) {
        this.showDropdown = false;
      }
    }
  }
}