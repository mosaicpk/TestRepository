import { LightningElement, wire } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import USER_ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';

export default class Pmc_dh_abstractUtil extends LightningElement {
    effectiveAccountId;
    @wire(getRecord, { recordId: Id, fields: [USER_ACCOUNT_FIELD] })

    currentUserInfo({ error, data }) {
      if (data) {
        this.effectiveAccountId = data.fields.AccountId.value;
      } else if (error) {
        this.error = error;
      }
    }

    getEffectiveAccount() {
        return this.effectiveAccountId;
    }
}