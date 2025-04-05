import { LightningElement, track } from 'lwc';

export default class AccountDetailsMenu extends LightningElement {
    showAccountMenuOption = false;
    userName = 'Himanshu Rathore';
    accountName = 'Deloitte USI';
    @track _userAccountOptions = [
        { strLabel: 'Switch Accounts' },
        { strLabel: 'My Account' },
        { strLabel: 'Logout' },
    ];

    connectedCallback() {
        if (window.screen.width <= 1023) {
            this.showAccountMenuOption = true;
        }
    }

    /* Opens up the account menu popup on click of icon */
    userAccountClickHandler(event) {
        event?.stopPropagation();
        if (window.screen.width > 1023) {
            this.showAccountMenuOption = !this.showAccountMenuOption;
        }
    }

    accountMenuClickHandler(event) {
        event.stopPropagation();
        this.userAccountClickHandler(event);
    }

    /* Handle account menu enter key press */
    accountMenuKeydownHandler(event) {
        event.stopPropagation();
        if (event.keyCode === 13) {
            event.preventDefault();
            this.accountMenuClickHandler(event);
        } else if (event.keyCode === 9) {
            const accountMenuItem = this.template.querySelectorAll('.accounts-menu-item');
            if (!event.shiftKey && event.target.dataset.id === accountMenuItem[accountMenuItem.length - 1].dataset.id) {
                this.showAccountMenuOption = false;
            }
        }
    }

    /* Handle account icon enter key press */
    userAccountKeypressHandler(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
            this.userAccountClickHandler();
        } else if (event.keyCode === 9) {
            if (event.shiftKey) {
                this.showAccountMenuOption = false;
                return;
            }
            event.preventDefault();
            this.template.querySelectorAll('.accounts-menu-item')[0]?.focus();
            this.showAccountMenuOption = true;
        }
    }
}