import { LightningElement } from 'lwc';
// import { loadStyle } from "lightning/platformResourceLoader";
// import BrandingAssets from "@salesforce/resourceUrl/pmc_brandingAssetsStaticResource";

/**
* @slot header
* @slot footer
* @slot cookie
*/

export default class PMC_DH_customThemeLWC extends LightningElement {
  layoutRendered = false;
  renderedCallback() {
    if(this.layoutRendered) {
        return;
    }
    // loadStyle(this, BrandingAssets + '/styles/style.css').then(() => {
    //     this.layoutRendered = true;
    // });
  }
}