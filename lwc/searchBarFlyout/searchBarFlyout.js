import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/**
 * A Custom Search Flyout.
 * @alias SearchBarFlyout
 * @description : To show search items in Search Flyout. 
 * @author Himanshu Rathore <himrathore@deloitte.com>
 * @example
 * <c-search-bar-flyout></c-search-bar-flyout>
 */
const MIN_LENGTH = 3;
const DONE_TYPING_INTERVAL = 500;

export default class SearchBarFlyout extends NavigationMixin(LightningElement) {
  @track searchTerm = '';
  @track effectiveAccountId;
  @track error;
  @track _urlToForm;
  @track _isSearchFlyout = false;
  @track _searchResults = [];
  searchResultsMockData = [
    { strProductValue: 'Freshly Brewed Coffee Venti' },
    { strProductValue: 'Mocha Frappuccino Mini Coffee' },
    { strProductValue: 'Chocolate Chip Cookie' },
    { strProductValue: 'Butter Croissant' },
    { strProductValue: 'Cappuccino Coffee' },
    { strProductValue: 'Frappuccino Coffee' },
    { strProductValue: 'Black Coffee' },
    { strProductValue: 'Irish Coffee' },
    { strProductValue: 'Cold Brew' }
  ];
  @track tempSearchTerm;
  typingTimer;
  inputText = '';

  /**
  * Handle search on search icon click
  */
  handleSearchChange() {
    this.navigateToPage();
  }

  /**
  * To Navigate on global-search page, when user hits enter or click on search-icon
  */
  navigateToPage() {
    this._urlToForm = this.template.querySelector('.search').value;
    const pageRef = {
      type: 'standard__webPage',
      attributes: {
        url: `https://www.google.com/search?q=${encodeURIComponent(this._urlToForm)}`
      }
    };

    if (this._urlToForm) {
      this.clearSearchResults();
      this[NavigationMixin.Navigate](pageRef)
    }
  }

  /**
  * Searching on enter key
  */
  handleSearchTermKeyDown(event) {
    if (event.keyCode === 13) {
      this.navigateToPage();
    }
  }

/**
  * User enter first 3 characters of any product name in the search, it will auto-suggest previously searched terms in flyout
  */
  search = (event) => {
    this.inputText = event.detail.value.toLowerCase();
    clearTimeout(this.typingTimer);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.typingTimer = setTimeout(() => {
      if (this.inputText && this.inputText.length >= MIN_LENGTH) {
        this._isSearchFlyout = true;
        this._searchResults = this.searchResultsMockData.map(item => ({
          ...item,
          strProductValue: this.highlightSearchText(item.strProductValue, this.inputText)
        }));
      }
      else {
        this.clearSearchResults();
      }
    }, DONE_TYPING_INTERVAL);
  }

/**
  * make Bold text what user has searched 
  */
  highlightSearchText(itemText, searchText) {
    if (typeof itemText !== 'string' || typeof searchText !== 'string') {
      return itemText;
    }
    const index = itemText.toLowerCase().indexOf(searchText);
    if (index !== -1) {
      const start = itemText.substring(0, index);
      const match = itemText.substring(index, index + searchText.length);
      const end = itemText.substring(index + searchText.length);

      return `${start}<strong style="color: black;">${match}</strong>${end}`;
    }
    return itemText;
  }

  /**
  * To Navigate on global-search page, when user selects from search flyout
  */
  handleSearchFlyoutChange(event) {
    const selectedValue = event.target.dataset.productVal;
    const pageRef = {
      type: 'standard__webPage',
      attributes: {
        url: `https://www.google.com/search?q=${selectedValue}`
      }
    };
    if (selectedValue) {
      this.clearSearchResults();
      this[NavigationMixin.Navigate](pageRef)
    }
  }

  /**
  * To hide the search result flyout 
  */
  clearSearchResults = () => {
    this._searchResults = null;
    this._isSearchFlyout = false;
  }

  /** 
  * Key Press for Product Selection in Search Flyout
  */
  searchFlyoutKeypressHandler = (event) => {
    if (event.keyCode === 13) {
      event.preventDefault();
      this.handleSearchFlyoutChange(event);
    }
  }
}