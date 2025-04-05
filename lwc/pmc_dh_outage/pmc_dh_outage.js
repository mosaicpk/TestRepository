import { LightningElement, track } from 'lwc';
import PMC_BrandingAssetsStaticResource from "@salesforce/resourceUrl/pmc_brandingStaticResource";

import pmc_outagePage_heading from '@salesforce/label/c.pmc_outagePage_heading';
import pmc_outagePage_description from '@salesforce/label/c.pmc_outagePage_description';

export default class Pmc_dh_outage extends LightningElement {
  mosaicLogoUrl;
  @track labels = {
    pmc_outagePage_heading,
    pmc_outagePage_description
  }

  /**
   * Lifecycle Hook
   */
  connectedCallback() {
    this.mosaicLogoUrl = `${PMC_BrandingAssetsStaticResource}/images/logo-mosaic.png`
  }
}