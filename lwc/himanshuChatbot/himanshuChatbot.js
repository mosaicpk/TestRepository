import { LightningElement, track } from 'lwc';

export default class HimanshuChatbot extends LightningElement {
    @track chatInput = '';
    isRecording = false;

    handleKeyUp(event) {
        if (event.shiftKey && event.key === 'Enter') {
            event.preventDefault();
            return;
        }
        if (event.key === 'Enter') {
            this.sendClickHandler();
        }
    }


    recordIconClickHandler() {
        this.isRecording = true;
    }

    stopIconClickHandler() {
        this.isRecording = false;
    }

    sendClickHandler() {
        this.chatInput = this.template.querySelector('.ChatInput-input').value;
        if (this.chatInput !== null && this.chatInput !== undefined && this.chatInput !== " ") {
            console.log('this.chatInput 1', this.chatInput);

            const chatWindow = this.template.querySelector('.ChatWindow');
            const newChatItem = document.createElement('div');

            newChatItem.innerHTML = `<div c-himanshuchatbot_himanshuchatbot="" class="ChatItem ChatItem--expert"><div c-himanshuchatbot_himanshuchatbot="" class="ChatItem-meta"><div c-himanshuchatbot_himanshuchatbot="" class="ChatItem-avatar"><lightning-icon c-himanshuchatbot_himanshuchatbot="" icon-name="standard:user" class="slds-icon-standard-user slds-icon_container" title="user"><span style="--sds-c-icon-color-background: var(--slds-c-icon-color-background, rgb(16, 124, 173))" part="boundary"><lightning-primitive-icon size="small" variant="inverse"><svg class="slds-icon slds-icon_small" focusable="false" data-key="user" aria-hidden="true" viewBox="0 0 100 100" part="icon"><g><path d="M80 71.2V74c0 3.3-2.7 6-6 6H26c-3.3 0-6-2.7-6-6v-2.8c0-7.3 8.5-11.7 16.5-15.2.3-.1.5-.2.8-.4.6-.3 1.3-.3 1.9.1C42.4 57.8 46.1 59 50 59c3.9 0 7.6-1.2 10.8-3.2.6-.4 1.3-.4 1.9-.1.3.1.5.2.8.4 8 3.4 16.5 7.8 16.5 15.1z"></path><ellipse cx="50" cy="36.5" rx="14.9" ry="16.5"></ellipse></g></svg></lightning-primitive-icon><span class="slds-assistive-text">user</span></span></lightning-icon></div></div><div class="ChatItem-chatContent" c-himanshuchatbot_himanshuchatbot=""><div class="ChatItem-chatText" c-himanshuchatbot_himanshuchatbot="">${this.chatInput}</div></div></div>`;
            chatWindow.appendChild(newChatItem);
            this.template.querySelector('.ChatInput-input').value = '';

            chatWindow.scrollTop = chatWindow.scrollHeight;
        }

    }
}