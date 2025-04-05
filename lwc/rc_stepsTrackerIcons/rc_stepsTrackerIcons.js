import { LightningElement, track, api } from 'lwc';

import PMC_BrandingAssetsStaticResource from "@salesforce/resourceUrl/pmc_brandingStaticResource";

import iconCashTemplate from "./assets/template/iconCashTemplate.html";
import iconTruckTemplate from "./assets/template/iconTruckTemplate.html";
import iconFileCheckTemplate from "./assets/template/iconFileCheckTemplate.html";
import iconCheckTemplate from "./assets/template/iconCheckTemplate.html";
import iconTruckActiveTemplate from "./assets/template/iconTruckActiveTemplate.html";
import iconCashActiveTemplate from "./assets/template/iconCashActiveTemplate.html";
import iconFileCheckActiveTemplate from "./assets/template/iconFileCheckActiveTemplate.html";
import iconCheckActiveTemplate from "./assets/template/iconCheckActiveTemplate.html";
import iconRingTemplate from "./assets/template/iconRingTemplate.html";
import iconDiscTemplate from "./assets/template/iconDiscTemplate.html";
import iconCheckSolidTemplate from "./assets/template/iconCheckSolidTemplate.html";

/**
 * A custom LWC for containing icon templates used in quote checkout flow.
 * @alias StepsTrackerIcons
 * @extends LightningElement
 * @hideconstructor
 * @author Raghu Mothukapally
 * @example
 * <c-steps-tracker-icons></c-steps-tracker-icons>
 */

export default class Rc_stepsTrackerIcons extends LightningElement {
    @api icon = '';
    @api statusIcon = false;
    @api status = '';
    
    @track iconUrlObj = {
        iconCash: `${PMC_BrandingAssetsStaticResource}/icons/icon-cash.svg`,
        iconTruck: `${PMC_BrandingAssetsStaticResource}/icons/icon-truck.svg`,
        iconCheck: `${PMC_BrandingAssetsStaticResource}/icons/icon-circle-check.svg`,
        iconFileCheck: `${PMC_BrandingAssetsStaticResource}/icons/icon-file-check.svg`,
        iconCashActive: `${PMC_BrandingAssetsStaticResource}/icons/icon-cash-active.svg`,
        iconTruckActive: `${PMC_BrandingAssetsStaticResource}/icons/icon-truck-active.svg`,
        iconCheckActive: `${PMC_BrandingAssetsStaticResource}/icons/icon-circle-check-active.svg`,
        iconFileCheckActive: `${PMC_BrandingAssetsStaticResource}/icons/icon-file-check-active.svg`,
        iconCheckSolid: `${PMC_BrandingAssetsStaticResource}/icons/icon-circle-check-solid.svg`,
        iconRing: `${PMC_BrandingAssetsStaticResource}/icons/icon-ring.svg`,
        iconDisc: `${PMC_BrandingAssetsStaticResource}/icons/icon-disc.svg`,
    };
    
    /**
     * Returning icon template according to api values passed from parent
     */
    render() {
        if (this.statusIcon){
            switch (this.status) {
                case "complete": return iconCheckSolidTemplate;
                case "active": return iconRingTemplate;
                case "pending": return iconDiscTemplate;
                default: break;
            }
        } else {
            switch (this.icon) {
                case "icontruck": return this.status === 'active' ? iconTruckActiveTemplate : iconTruckTemplate;                
                case "iconcash": return this.status === 'active' ? iconCashActiveTemplate : iconCashTemplate;
                case "iconfilecheck": return this.status === 'active' ? iconFileCheckActiveTemplate : iconFileCheckTemplate;
                case "iconcheck": return this.status === 'active' ? iconCheckActiveTemplate : iconCheckTemplate;
                default: break;
            }
        }
    }
}