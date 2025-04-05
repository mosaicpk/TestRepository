import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from "lightning/uiRecordApi";
import { customLabel  } from 'c/pmc_ss_customLabelUtility';
import select_actionReason from "@salesforce/label/c.PMC_SS_SelectActionReason";
import select_order from "@salesforce/label/c.PMC_SS_SearchOrder";
import select_orderItem from "@salesforce/label/c.PMC_SS_SelectOrderItem";
import select_vehicle from "@salesforce/label/c.PMC_SS_SelectVehicle";
import select_invoice from "@salesforce/label/c.PMC_SS_SelectInvoice";
import select_atFaultParty from "@salesforce/label/c.PMC_SS_SelectAtFaultParty";
import select_paymentRequestType from "@salesforce/label/c.PMC_SS_SelectPaymentRequestType";
import select_delivery from "@salesforce/label/c.PMC_SS_SelectDelivery";
import uploadDoc from '@salesforce/label/c.PMC_SS_UploadDocumentForSymbolicReturn';
import return_link from "@salesforce/label/c.PMC_SS_SAPFioriReturnLink";
import cancel_link from "@salesforce/label/c.PMC_SS_SAPFioriCancelLink";
import rebill_link from "@salesforce/label/c.PMC_SS_SAPFioriRebillLink";
import credit_link from "@salesforce/label/c.PMC_SS_SAPFioriCreditLink";
import debit_link from "@salesforce/label/c.PMC_SS_SAPFioriDebitLink";
import select_newContract from "@salesforce/label/c.PMC_SS_SelectNewContract";
import select_option from "@salesforce/label/c.PMC_SS_SelectOption";

import getOrderItems from '@salesforce/apex/PMC_SS_CaseDisputeManagementCtrl.getOrderItems';
import getDeliveryItems from '@salesforce/apex/PMC_SS_CaseDisputeManagementCtrl.getDeliveryItems';
import getContracts from '@salesforce/apex/PMC_SS_CaseDisputeManagementCtrl.getContracts';
import getPickListValues from '@salesforce/apex/PMC_SS_CaseDisputeManagementCtrl.getPickListValues';
import uploadFile from '@salesforce/apex/PMC_SS_CaseDisputeManagementCtrl.uploadFile';

import ID_FIELD from "@salesforce/schema/Case.Id";
import ORDER_FIELD from "@salesforce/schema/Case.PMC_SS_Order__c";
import ORDER_ITEM_FIELD from "@salesforce/schema/Case.PMC_SS_OrderProduct__c";
import INVOICE_FIELD from "@salesforce/schema/Case.PMC_SS_Invoice__c";
import ACTION_REASON_FIELD from "@salesforce/schema/Case.PMC_SS_ActionReason__c";
import ACCOUNT_FIELD from "@salesforce/schema/Case.AccountId";
import CONTACT_FIELD from "@salesforce/schema/Case.ContactId";
import CONTRACT_FIELD from "@salesforce/schema/Case.PMC_SS_OriginalContract__c";
import ORIGINAL_INVOICE_AMOUNT_FIELD from "@salesforce/schema/Case.PMC_SS_OriginalInvoiceAmount__c";
import INVOICE_DIIFFERENCE_FIELD from "@salesforce/schema/Case.PMC_SS_InvoiceDifference__c";
import CANCEL_AMOUNT_FIELD from "@salesforce/schema/Case.PMC_SS_CancelAmount__c";
import REBILL_AMOUNT_FIELD from "@salesforce/schema/Case.PMC_SS_RebillAmount__c";
import AT_FAULT_PARTY_FIELD from "@salesforce/schema/Case.PMC_SS_AtFaultParty__c";
import PAYMENT_REQUEST_TYPE_FIELD from "@salesforce/schema/Case.PMC_SS_PaymentRequestType__c";
import SOLD_TO_ACCOUNT_FIELD from "@salesforce/schema/Case.PMC_SS_SoldToAccount__c";
import SHIP_TO_ACCOUNT_FIELD from "@salesforce/schema/Case.PMC_SS_ShipToAccount__c";
import CREDIT_DEBIT_AMOUNT_FIELD from "@salesforce/schema/Case.PMC_SS_CreditDebitAmount__c";
import RETURN_AMOUNT_FIELD from "@salesforce/schema/Case.PMC_SS_ReturnAmount__c";
import RETURN_QUANTITY_FIELD from "@salesforce/schema/Case.PMC_SS_ReturnQuantity__c";
import PLANT_FIELD from "@salesforce/schema/Case.PMC_SS_Plant__c";
import VEHICLEID_FIELD from "@salesforce/schema/Case.PMC_SS_VehicleId__c";
import MODE_OF_TRANSPORTATION_FIELD from "@salesforce/schema/Case.PMC_SS_MOT__c";
import PGI_DATE_FIELD from "@salesforce/schema/Case.PMC_SS_PGIDate__c";
import NEW_CONTRACT_FIELD from "@salesforce/schema/Case.PMC_SS_NewContract__c";
import TON_FIELD from "@salesforce/schema/Case.PMC_SS_Ton__c";
import UOM_FIELD from "@salesforce/schema/Case.PMC_SS_UOM__c";
import SHIP_FROM_FIELD from "@salesforce/schema/Case.PMC_SS_ShipFrom__c";
import SHIP_TO_FIELD from "@salesforce/schema/Case.PMC_SS_ShipTo__c";
import COMMENT_FIELD from "@salesforce/schema/Case.PMC_SS_Comment__c";
import PRODUCTID_FIELD from "@salesforce/schema/Case.ProductId";
import SHIPMENT_DATE_FIELD from "@salesforce/schema/Case.PMC_SS_ShipmentDate__c";
import DELIVERY_FIELD from "@salesforce/schema/Case.PMC_SS_Delivery__c";
import DOLLAR_AMOUNT_FIELD from "@salesforce/schema/Case.PMC_SS_DollarAmount__c";

export default class Pmc_ss_caseDisputeManagement extends NavigationMixin(LightningElement) {

    quickActionAPIName = "";

    cancelSelected = false;
    rebillSelected = false;

    validatedData = true;
    
    @track screenTitle = "";

    @track isLoading = false;

    @track orderItems = [];
    @track deliveryItems = [];
    @track invoices = [];
    @track deliveries = [];
    @track contracts = [];
    
    @track atFaultParty = [];
    @track paymentReqType = [];

    @track objOrderDetailsWrapper = {};

    @track invoiceDifference = 0.0;
    @track originalInvoiceAmt = 0.0;
    @track returnAmount = 0.0;
    @track cancelAmount = 0.0;
    @track rebillAmount = 0.0;
    @track dollarAmount = 0.0;

    @track productName = '';

    @track objDelivery= {};
    @track objContact = {};

    @track plantId;
    @track shipToAccountName;
    @track modeOfTransportation;
    @track pgiDate;
    @track deliveryQty;
    @track deliveryUoM;
    @track vehicleId;

    @track orderItemId;

    @track filter = '';
    @track recordId = '';
    @track fileData;
    @track actionReasonValues = [];
    @track shipToAccount;
    @track mapOfOrderItemShipTo = [];


    fields = {};

    /**
   * Custom Label Details
   */
    @track labels = {
        select_actionReason,
        select_order,
        select_orderItem,
        select_vehicle,
        select_invoice,
        select_atFaultParty,
        select_paymentRequestType,
        select_delivery,
        select_newContract,
        uploadDoc,
        return_link,
        cancel_link,
        rebill_link,
        credit_link,
        debit_link,
        select_option
    }
    @track customLabels = customLabel;

    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference.type === "standard__quickAction") {
            let quickActionPath = currentPageReference.attributes.apiName; 
            this.quickActionAPIName = quickActionPath.split('.')[1];
        }
        this.recordId = currentPageReference.state.recordId;
        this.fields[ID_FIELD.fieldApiName] = currentPageReference.state.recordId;
    }

    connectedCallback() {

		getPickListValues({
            strObjApiName: 'Case',
            strFieldName: 'PMC_SS_AtFaultParty__c'
			}).then(data => {
                if(data) {
                    this.atFaultParty.push({
                        label: this.labels.select_option,
                        value: this.labels.select_option
                    });
                    for (var i=0; i<data.length; i++) {
                        this.atFaultParty.push({
                            label:   data[i].label,
                            value: data[i].value
                        });
                    }
                }
			}).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                      message: error.body.message,
                      variant: "error",
                    }),
                  );
            });


            getPickListValues({
				strObjApiName: 'Case',
				strFieldName: 'PMC_SS_PaymentRequestType__c'
			}).then(data => {   
                if(data) {
                    this.paymentReqType.push({
                        label: this.customLabels.PMC_SS_SelectOption,
                        value: "--- Select ---"
                    });
                    for (var i=0; i <data.length; i++) {
                        this.paymentReqType.push({
                            label:   data[i].label,
                            value: data[i].value
                        });
                    }
                }             
			}).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                      message: error.body.message,
                      variant: "error",
                    }),
                  );
			});

            getPickListValues({
				strObjApiName: 'Case',
				strFieldName: 'PMC_SS_ActionReason__c'
			}).then(data => {   
                if(data) {
                    this.actionReasonValues.push({
                        label: this.customLabels.PMC_SS_SelectOption,
                        value: "--- Select ---"
                    });
                    for (var i=0; i < data.length; i++) {

                        if(this.quickActionAPIName == 'PMC_SS_CancelRebill' && 
                        (data[i].value == 'Cancel' || data[i].value == 'Rebill')) {
                            this.screenTitle = this.customLabels.PMC_SS_CancelRebill_ScreenTitle;
                            this.actionReasonValues.push({
                                label: data[i].label,
                                value: data[i].value
                            });
                        }
                        else if(this.quickActionAPIName == 'PMC_SS_CreditDebit' && 
                        (data[i].value == 'Credit' || data[i].value == 'Debit')) {
                            this.screenTitle = this.customLabels.PMC_SS_CreditDebit_ScreenTitle;
                            this.actionReasonValues.push({
                                label: data[i].label,
                                value: data[i].value
                            });
                        }
                        else if(this.quickActionAPIName == 'PMC_SS_Return' && 
                        data[i].value == 'Return') {
                            this.screenTitle = this.customLabels.PMC_SS_Return_ScreenTitle;
                            this.actionReasonValues.push({
                                label: data[i].label,
                                value: data[i].value
                            });
                        }
                        else if(this.quickActionAPIName == 'PMC_SS_ReverseShipment' && 
                        data[i].value == 'Reverse Shipment') {
                            this.screenTitle = this.customLabels.PMC_SS_ReverseShipment_ScreenTitle;
                            this.actionReasonValues.push({
                                label: data[i].label,
                                value: data[i].value
                            });
                        }
                        
                    }
                }
                          
			}).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                      message: error.body.message,
                      variant: "error",
                    }),
                  );
			});

    }

    fileUploaded(e){
        this.fileData = e.detail;
    }

    handleOnChange(e) {
        let id = this.getRealId(e.target.id);

        if(id == 'actionReason') {
            this.fields[ACTION_REASON_FIELD.fieldApiName] = e.target.value;
            this.updateSelectedActionReason(e.target.value);
        }
        else if(id == 'order') {
            this.updateInitialParams();
            this.fetchOrderItems(e.detail);
        }
        else if(id == 'orderItem') {
            this.orderItemId = e.target.value; 
            this.fields[ORDER_ITEM_FIELD.fieldApiName] = e.target.value;
            if(this.isCreditDebitReturnAction && e.target.value != '' && e.target.value != undefined) {
                this.updatePlant(e.target.value);
            }
            if(this.isReturnReverseShipmentAction) {
                this.fetchDeliveryItemsDetails(e.target.value);
                if(this.isReverseShipmentAction) {
                    this.updateProduct(e.target.value);
                }
            }
        }
        else if(id == 'deliveryItem') {
            this.vehicleId = '';
            this.deliveryQty = '';
            this.deliveryUoM = '';
            this.updateMOTFromVehicle(e.target.value);
        }
        else if(id == 'invoice') {
            this.updateOriginalInvoiceAmount(e.target.value);
        }
        else if(id == 'atFaultParty') {
            this.fields[AT_FAULT_PARTY_FIELD.fieldApiName] = e.target.value;
        }
        else if(id == 'paymentRequestType') {
            this.fields[PAYMENT_REQUEST_TYPE_FIELD.fieldApiName] = e.target.value;
        }
        else if(id == 'cancelAmount') {
            this.cancelAmount = e.target.value;
            this.fields[CANCEL_AMOUNT_FIELD.fieldApiName] = e.target.value;
            this.calculateInvoiceDifference(e.target.value);
        }
        else if(id == 'rebillAmount') {
            this.rebillAmount = e.target.value;
            this.fields[REBILL_AMOUNT_FIELD.fieldApiName] = e.target.value;
            this.calculateInvoiceDifference(e.target.value);
        }
        else if(id == 'returnQuantity') {
            this.fields[RETURN_QUANTITY_FIELD.fieldApiName] = e.target.value;
            this.calculateReturnAmount(e.target.value);
        }
        else if(id == 'creditDebitAmount') {
            this.fields[CREDIT_DEBIT_AMOUNT_FIELD.fieldApiName] = e.target.value;
        }
        else if(id == 'delivery') {
            this.vehicleId = '';
            this.deliveryQty = '';
            this.deliveryUoM = '';
            this.updateSelectedDelivery(e.target.value);
        }
        else if(id == 'comments') {
            this.fields[COMMENT_FIELD.fieldApiName] = e.target.value;
        }
        else if(id == 'newContract') {
            this.fields[NEW_CONTRACT_FIELD.fieldApiName] = e.target.value;
        }
        else if(id == 'dollarAmount') {
            this.dollarAmount = e.target.value;
            this.fields[DOLLAR_AMOUNT_FIELD.fieldApiName] = e.target.value;
            this.calculateInvoiceDifference(e.target.value);
        }
    }

    updateInitialParams() {
        this.orderItems = [];
        this.invoices = [];
        this.deliveryItems = [];
        this.deliveries = [];
        this.contracts = [];

        this.invoiceDifference = 0.0;
        this.originalInvoiceAmt = 0.0;
        this.returnAmount = 0.0;
        this.rebillAmount = 0.0;
        this.cancelAmount = 0.0;
        this.dollarAmount = 0.0;
        
        this.objOrderDetailsWrapper = {};
        this.objContact = {};
        this.objDelivery = {};

        this.plantId = '';
        this.shipToAccountName = '';
        this.modeOfTransportation = '';
        this.pgiDate = '';
        this.deliveryQty ='';
        this.deliveryUoM ='';
        this.vehicleId = '';
        this.orderItemId = '';
        this.productName = '';

        var inputFields = this.template.querySelectorAll("lightning-input");
        inputFields.forEach(function(item){
            if(item.name == 'cancelAmount' || item.name == 'rebillAmount' || item.name == 'creditDebitAmount' || item.name == 'returnQuantity' || item.name == 'dollarAmount') {
                item.value = '';
            }
        });
    }

    updateSelectedActionReason(selectedActionReason) {

        if(selectedActionReason == 'Cancel') {
            this.cancelSelected = true;
            this.rebillSelected = false;
        }
        else if(selectedActionReason == 'Rebill') {
            this.rebillSelected = true;
            this.cancelSelected = false;
        }
    }


    updateOriginalInvoiceAmount(strInvoiceId) {

        for (var i=0; i<this.invoices.length; i++) {
            if(strInvoiceId == this.invoices[i].Id) {

                this.fields[INVOICE_FIELD.fieldApiName] = strInvoiceId;

                this.originalInvoiceAmt = this.invoices[i].PMC_CPQ_TotalInvoiceValue__c != null ? this.invoices[i].PMC_CPQ_TotalInvoiceValue__c : 0.0;
                this.fields[ORIGINAL_INVOICE_AMOUNT_FIELD.fieldApiName] = this.originalInvoiceAmt;

                if(this.isCancelRebillReverseShipmentAction) {
                    //if(this.objContact.Id != null && this.objContact.Id != undefined) {
                        //this.fields[CONTACT_FIELD.fieldApiName] = this.objContact.Id;
                    //}
                    
                    if(this.fields[ACTION_REASON_FIELD.fieldApiName] == 'Cancel' && this.cancelAmount != 0.0) {
                        this.calculateInvoiceDifference(this.cancelAmount);
                    }
                    else if(this.fields[ACTION_REASON_FIELD.fieldApiName] == 'Rebill' && this.rebillAmount != 0.0) {
                        this.calculateInvoiceDifference(this.rebillAmount);
                    }
                    else if(this.fields[ACTION_REASON_FIELD.fieldApiName] == 'Reverse Shipment' && this.dollarAmount != 0.0) {
                        this.calculateInvoiceDifference(this.dollarAmount);
                    }
                }
            }
        }
    }

    updateMOTFromVehicle(deliveryItemId) {
        for (var i=0; i<this.deliveryItems.length; i++) {
            if(deliveryItemId == this.deliveryItems[i].Id) {

                this.fields[VEHICLEID_FIELD.fieldApiName] =this.deliveryItems[i].VehicleId;
                this.vehicleId = this.deliveryItems[i].VehicleId;
                this.deliveryQty = this.deliveryItems[i].DeliveryQty;
				this.deliveryUoM = this.deliveryItems[i].DeliveryUoM;
                this.fields[TON_FIELD.fieldApiName] = this.deliveryQty;
                this.fields[UOM_FIELD.fieldApiName] = this.deliveryUoM;

                if(this.isReturnAction) {
                    this.modeOfTransportation = this.deliveryItems[i].MOT;
                    this.fields[MODE_OF_TRANSPORTATION_FIELD.fieldApiName] = this.modeOfTransportation;

                }
                if(this.deliveryItems[i].ShippedDate != null && this.deliveryItems[i].ShippedDate != undefined) {
                    this.pgiDate = this.deliveryItems[i].ShippedDate;
                    this.fields[PGI_DATE_FIELD.fieldApiName] = this.pgiDate;    
                }
            }
        }
    }

    updatePlant(orderItemId) {
        for(var i=0; i<this.orderItems.length; i++) {
            if(orderItemId == this.orderItems[i].Id) {
                this.plantId = '';
                this.fields[SHIP_TO_ACCOUNT_FIELD.fieldApiName] = '';
                this.shipToAccountName ='';
                if(this.orderItems[i].PMC_CPQ_ProductLocation__c != null) {
                    if(this.orderItems[i].PMC_CPQ_ProductLocation__r.PMC_CPQ_Location__c != null) {
                        this.plantId = this.orderItems[i].PMC_CPQ_ProductLocation__r.PMC_CPQ_Location__r.PMC_CPQ_Plant__c != null ? 
                                        this.plantId = this.orderItems[i].PMC_CPQ_ProductLocation__r.PMC_CPQ_Location__r.PMC_CPQ_Plant__c : '';
                    }
                }
                this.fields[PLANT_FIELD.fieldApiName] = this.plantId;
                if(this.orderItems[i].PMC_CPQ_ShipTo__c != null && this.orderItems[i].PMC_CPQ_ShipTo__c != undefined
                    && this.orderItems[i].PMC_CPQ_ShipTo__r.Name != null && this.orderItems[i].PMC_CPQ_ShipTo__r.Name != undefined){
                    this.fields[SHIP_TO_ACCOUNT_FIELD.fieldApiName] = this.orderItems[i].PMC_CPQ_ShipTo__c;
                    this.shipToAccountName = this.orderItems[i].PMC_CPQ_ShipTo__r.Name;
                }
            }
        }
    }

    updateProduct(orderItemId) {
        for(var i=0; i<this.orderItems.length; i++) {
            if(orderItemId == this.orderItems[i].Id) {
                this.productName = this.orderItems[i].Product2.Name;
                this.fields[PRODUCTID_FIELD.fieldApiName] = this.orderItems[i].Product2Id;
            }
        }
    }

    updateSelectedDelivery(deliveryId) {
        for(var i=0; i<this.deliveries.length; i++) {
            if(deliveryId == this.deliveries[i].Id) {
                this.objDelivery = this.deliveries[i];
                // Add Values to Field Obj
                this.fields[DELIVERY_FIELD.fieldApiName] = deliveryId;
                //this.fields[TON_FIELD.fieldApiName] = this.objDelivery.DeliveryQty;
                //this.fields[UOM_FIELD.fieldApiName] = this.objDelivery.DeliveryUoM;
                this.fields[SHIP_FROM_FIELD.fieldApiName] = this.objDelivery.ShipFromId;
                this.fields[SHIP_TO_FIELD.fieldApiName] = this.objDelivery.ShipToId;
                if(this.objDelivery.ShippedDate != null && this.objDelivery.ShippedDate != undefined) {
                    this.fields[SHIPMENT_DATE_FIELD.fieldApiName] = this.objDelivery.ShippedDate;
                }
                this.fetchDeliveryItemsDetails(this.orderItemId);
            }
        }
    }

    calculateInvoiceDifference(cancelRebillAmount) {
        if(this.originalInvoiceAmt != 0.0) {
            //this.invoiceDifference = this.originalInvoiceAmt - cancelRebillAmount;
            this.invoiceDifference = cancelRebillAmount-this.originalInvoiceAmt;
            
            this.fields[INVOICE_DIIFFERENCE_FIELD.fieldApiName] = this.invoiceDifference;
        }
    }

    calculateReturnAmount(returnQty) {
        if(this.orderItemId) {
            for(var i=0; i<this.orderItems.length; i++) {
                if(this.orderItemId == this.orderItems[i].Id) {
                    this.returnAmount = this.orderItems[i].UnitPrice != undefined ?  returnQty * this.orderItems[i].UnitPrice : 0.0;
                    this.fields[RETURN_AMOUNT_FIELD.fieldApiName] = this.returnAmount;
                }
            }
        }
    }

    calculateInvoiceDifference(cancelRebillAmount) {
        if(this.originalInvoiceAmt != 0.0) {
           // this.invoiceDifference = this.originalInvoiceAmt - cancelRebillAmount;
        this.invoiceDifference = cancelRebillAmount-this.originalInvoiceAmt;
                       this.fields[INVOICE_DIIFFERENCE_FIELD.fieldApiName] = this.invoiceDifference;
        }
    }

    calculateReturnAmount(returnQty) {
        if(this.orderItemId) {
            for(var i=0; i<this.orderItems.length; i++) {
                if(this.orderItemId == this.orderItems[i].Id) {
                    this.returnAmount = this.orderItems[i].UnitPrice != undefined ?  returnQty * this.orderItems[i].UnitPrice : 0.0;
                    this.fields[RETURN_AMOUNT_FIELD.fieldApiName] = this.returnAmount;
                }
            }
        }
    }

    /*get actionReasons() {
        if(this.quickActionAPIName == 'PMC_SS_CancelRebill') {
            this.screenTitle = this.customLabels.PMC_SS_CancelRebill_ScreenTitle;
            return ['--- Select ---','Cancel', 'Rebill'];
        }
        else if(this.quickActionAPIName == 'PMC_SS_CreditDebit') {
            this.screenTitle = this.customLabels.PMC_SS_CreditDebit_ScreenTitle;
            return ['--- Select ---','Credit', 'Debit'];
        }
        else if(this.quickActionAPIName == 'PMC_SS_Return') {
            this.screenTitle = this.customLabels.PMC_SS_Return_ScreenTitle;
            return ['--- Select ---', 'Return'];
        }
        else if(this.quickActionAPIName == 'PMC_SS_ReverseShipment') {
            this.screenTitle = this.customLabels.PMC_SS_ReverseShipment_ScreenTitle;
            return ['--- Select ---', 'Reverse Shipment'];
        }
    }*/

    get isCancelRebillAction() {
        return this.quickActionAPIName == 'PMC_SS_CancelRebill';
    }

    get isCreditDebitAction() {
        return this.quickActionAPIName == 'PMC_SS_CreditDebit';
    }

    get isReturnAction() {
        return this.quickActionAPIName == 'PMC_SS_Return';
    }

    get isReverseShipmentAction() {
        return this.quickActionAPIName == 'PMC_SS_ReverseShipment';
    }

    get isCreditDebitReturnAction() {
        return this.quickActionAPIName == 'PMC_SS_CreditDebit' || this.quickActionAPIName == 'PMC_SS_Return' ;
    }

    get isCancelRebillReturnAction() {
        return this.quickActionAPIName == 'PMC_SS_CancelRebill' || this.quickActionAPIName == 'PMC_SS_Return';
    }

    get isCancelRebillReverseShipmentAction() {
        return this.quickActionAPIName == 'PMC_SS_CancelRebill' || this.quickActionAPIName == 'PMC_SS_ReverseShipment';
    }

    get isReturnReverseShipmentAction() {
        return this.quickActionAPIName == 'PMC_SS_Return' || this.quickActionAPIName == 'PMC_SS_ReverseShipment';
    }

    fetchOrderItems(strOrderId) {
        var orderId = JSON.stringify(strOrderId).replace(/]|[[]/g, '').replaceAll("\"",'');
        this.fields[ORDER_FIELD.fieldApiName] = orderId;

        if(orderId != '' && orderId != undefined) {

            getOrderItems({strOrderId: orderId}).then(result => {

                if(result == undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                          title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                          message: error.body.message,
                          variant: "error",
                        }),
                    );
                }
                else {

                    this.objOrderDetailsWrapper = result;
                    //if(this.objOrderDetailsWrapper.objOrder.BillToContactId != null && this.objOrderDetailsWrapper.objOrder.BillToContactId != undefined) {
                        //this.objContact = { 'Id' : this.objOrderDetailsWrapper.objOrder.BillToContactId,
                                    //'Name' : this.objOrderDetailsWrapper.objOrder.BillToContact.Name
                        //            };
                    //}
                    
    
                    if(this.isCancelRebillAction || this.isReverseShipmentAction) {
                        if(this.objOrderDetailsWrapper.objAccountWrapper.idRecord != null && this.objOrderDetailsWrapper.objAccountWrapper.idRecord != undefined){
                            this.fields[ACCOUNT_FIELD.fieldApiName] = this.objOrderDetailsWrapper.objAccountWrapper.idRecord;
                        }
    
                        if(this.isCancelRebillAction) {
                            if(this.objOrderDetailsWrapper.objContractWrapper.idRecord != null && this.objOrderDetailsWrapper.objContractWrapper.idRecord != undefined){
                                this.fields[CONTRACT_FIELD.fieldApiName] = this.objOrderDetailsWrapper.objContractWrapper.idRecord;
                            }

                            if(this.objOrderDetailsWrapper.objAccountWrapper.idRecord != null && this.objOrderDetailsWrapper.objAccountWrapper.idRecord != undefined && this.objOrderDetailsWrapper.objAccountWrapper.idRecord != '') {
                                this.fetchNewContracts(this.objOrderDetailsWrapper.objAccountWrapper.idRecord);
                            }
                        }
                    }
                    else if(this.isCreditDebitAction || this.isReturnAction){
                        /*if(this.objOrderDetailsWrapper.objShipToAccountWrapper.idRecord != null && this.objOrderDetailsWrapper.objShipToAccountWrapper.idRecord != undefined){
                            this.fields[SHIP_TO_ACCOUNT_FIELD.fieldApiName] = this.objOrderDetailsWrapper.objShipToAccountWrapper.idRecord;
                        }*/

                        if(this.objOrderDetailsWrapper.objSoldToAccountWrapper.idRecord != null && this.objOrderDetailsWrapper.objSoldToAccountWrapper.idRecord != undefined){
                            this.fields[SOLD_TO_ACCOUNT_FIELD.fieldApiName] = this.objOrderDetailsWrapper.objSoldToAccountWrapper.idRecord;
                        }
                    }
    
                    this.orderItems.push({
                        'Id' : '--- Select ---',
                        'OrderItemNumber' : '--- Select ---'
                    });
    
                    for (var i=0; i<this.objOrderDetailsWrapper.lstOrderItems.length; i++) {
                        this.orderItems.push(this.objOrderDetailsWrapper.lstOrderItems[i]);
                        this.mapOfOrderItemShipTo.push(this.objOrderDetailsWrapper.lstOrderItems[i].Id,
                            this.objOrderDetailsWrapper.lstOrderItems[i].PMC_CPQ_ShipTo__c);
                    }
    
                    this.invoices.push({
                        'Id' : '--- Select ---',
                        'Name' : '--- Select ---'
                    });
    
                    for (var i=0; i<this.objOrderDetailsWrapper.lstInvoices.length; i++) {
                        this.invoices.push(this.objOrderDetailsWrapper.lstInvoices[i]);
                    }

                    if(this.isReverseShipmentAction) {

                        this.deliveries.push({
                            'Id' : '--- Select ---',
                            'ShipmentNumber' : '--- Select ---',
                            //'DeliveryQty' : '--- Select ---',
                            //'DeliveryUoM' : '--- Select ---',
                            'ShipFromId' : '--- Select ---',
                            'ShipFrom' : '--- Select ---',
                            'ShipToId' : '--- Select ---',
                            'ShipTo' : '--- Select ---',
                            'ShippedDate' : '--- Select ---',
                            'VehicleId' : '--- Select ---'
                        });
    
                        for (var i=0; i<this.objOrderDetailsWrapper.lstDeliveries.length; i++) {
                            this.deliveries.push({
                                'Id' : this.objOrderDetailsWrapper.lstDeliveries[i].Id,
                                'ShipmentNumber' : this.objOrderDetailsWrapper.lstDeliveries[i].ShipmentNumber,
                                //'DeliveryQty' :  this.objOrderDetailsWrapper.lstDeliveries[i].PMC_CPQ_DeliveryQuantity__c,
                                //'DeliveryUoM' :  this.objOrderDetailsWrapper.lstDeliveries[i].PMC_CPQ_UoMUnitofMeasure__c,
                                'ShipFromId' :  this.objOrderDetailsWrapper.lstDeliveries[i].PMC_CPQ_OriginLocation__c,
                                'ShipFrom' :  this.objOrderDetailsWrapper.lstDeliveries[i].PMC_CPQ_OriginLocation__c != null && this.objOrderDetailsWrapper.lstDeliveries[i].PMC_CPQ_OriginLocation__c != undefined ? this.objOrderDetailsWrapper.lstDeliveries[i].PMC_CPQ_OriginLocation__r.Name : '',
                                'ShipToId' :  this.objOrderDetailsWrapper.lstDeliveries[i].DestinationLocationId,
                                'ShipTo' :  this.objOrderDetailsWrapper.lstDeliveries[i].DestinationLocationId != null && this.objOrderDetailsWrapper.lstDeliveries[i].DestinationLocationId != undefined ? this.objOrderDetailsWrapper.lstDeliveries[i].DestinationLocation.Name : '',
                                'ShippedDate' :  this.objOrderDetailsWrapper.lstDeliveries[i].PMC_CPQ_ShippedDate__c,
                                'VehicleId' :  this.objOrderDetailsWrapper.lstDeliveries[i].PMC_CPQ_VehicleID__c
                            });
                        }
                    }
                }
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                      message: error.body.message,
                      variant: "error",
                    }),
                  );
            });
        }
    }

    fetchNewContracts(strAccountId) {
        getContracts({strAccountId: strAccountId}).then(result => {
            if(result == undefined) {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                      message: error.body.message,
                      variant: "error",
                    }),
                  );
            }
            else {
                this.contracts = [];

                this.contracts.push({
                    'Id' : '--- Select ---',
                    'ContractNumber' : '--- Select ---'
                });

                for (var i=0; i<result.length; i++) {

                    if(this.objOrderDetailsWrapper.objContractWrapper.idRecord != result[i].Id) {
                        this.contracts.push({
                            'Id' : result[i].Id,
                            'ContractNumber' : result[i].ContractNumber
                        });
                    }
                }
            }
            
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                  message: error.body.message,
                  variant: "error",
                }),
              );
        });
    }

    fetchDeliveryItemsDetails(strOrderItemId){
        getDeliveryItems({strOrderItemId: strOrderItemId}).then(result => {
            if(result == undefined) {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                      message: error.body.message,
                      variant: "error",
                    }),
                  );
            }
            else {
                this.deliveryItems = [];

                this.deliveryItems.push({
                    'Id' : '--- Select ---',
                    'VehicleId' : '',
                    'MOT' : '--- Select ---',
                    'ShippedDate' : '--- Select ---',
                    'DeliveryQty' : '--- Select ---',
                    'DeliveryUoM' : '--- Select ---',
                    'ShipmentId' : '--- Select ---',
                    'ShipmentItemNumber' : '--- Select ---'
                });

                if(this.isReverseShipmentAction && this.objDelivery.Id != '') {
                    for (var i=0; i<result.length; i++) {
                        if(result[i].ShipmentId == this.objDelivery.Id){
                            this.deliveryItems.push({
                                'Id' : result[i].Id,
                                'VehicleId' : result[i].PMC_CPQ_VehicleID__c,
                                'MOT' : result[i].PMC_CPQ_ModeofTransportation__c,
                                'ShippedDate' : result[i].PMC_CPQ_ShippedDate__c,
                                'DeliveryQty' : result[i].PMC_CPQ_DeliveryQuantity__c,
                                'DeliveryUoM' : result[i].PMC_CPQ_UnitofMeasure__c,
                                'ShipmentId' : result[i].ShipmentId,
                                'ShipmentItemNumber' : result[i].ShipmentItemNumber,
                            });
                        }
                    }  
                }
                else {
                    for (var i=0; i<result.length; i++) {
                        this.deliveryItems.push({
                            'Id' : result[i].Id,
                            'VehicleId' : result[i].PMC_CPQ_VehicleID__c,
                            'MOT' : result[i].PMC_CPQ_ModeofTransportation__c,
                            'ShippedDate' : result[i].PMC_CPQ_ShippedDate__c,
                            'DeliveryQty' : result[i].PMC_CPQ_DeliveryQuantity__c,
                            'DeliveryUoM' : result[i].PMC_CPQ_UnitofMeasure__c,
                            'ShipmentId' : result[i].ShipmentId,
                            'ShipmentItemNumber' : result[i].ShipmentItemNumber,
                        });
                    }
                }
            }
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: this.customLabels.PMC_SS_FailedtoFetchData_ErrorMessage,
                  message: error.body.message,
                  variant: "error",
                }),
              );
        });
    }

    saveAction() {

        if(this.validateFields()) {
            this.isLoading = true;

            const recordInput = {
                fields: this.fields
            };

            updateRecord(recordInput).then(result => {
                if(result != undefined) {

                    if(this.fileData != null && this.fileData != undefined) {

                        if(this.fileData.base64 != null && this.fileData.filename != null && this.fileData.recordId != null && this.isReverseShipmentAction) {
                            uploadFile({ strBase64 : this.fileData.base64, strFilename : this.fileData.filename, strRecordId: this.fileData.recordId }).then(result=>{
        
                                    this.isLoading = false;
    
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: this.customLabels.PMC_SS_Success_MessageLabel,
                                            message: this.customLabels.PMC_SS_Caseupdated_MessageLabel,
                                            variant: "success",
                                        }),
                                    );
        
                                    this.closeAction();
                            });
                        }
                    }
                    else {
                        this.isLoading = false;
    
                        this.dispatchEvent(
                            new ShowToastEvent({
                              title: this.customLabels.PMC_SS_Success_MessageLabel,
                              message: this.customLabels.PMC_SS_Caseupdated_MessageLabel,
                              variant: "success",
                            }),
                          );
    
                          this.closeAction();
                    }
                }
            })
            .catch(error => {
                console.log('Error --> ' + JSON.stringify(error.body));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.customLabels.PMC_SS_FailedtoUpdateRecord_ErrorMessage,
                        message: error.body.message,
                        variant: "error",
                    }),
                );
            });
        }
    }

    validateFields() {

        var validationSuccess = true;
        var firstElement;

        let actionReasonElement = this.template.querySelector('select[data-name="actionReason"]');
        actionReasonElement.setCustomValidity('');
        actionReasonElement.reportValidity();

        if(actionReasonElement.value == '--- Select ---') {
            actionReasonElement.setCustomValidity('Select Option');
            actionReasonElement.reportValidity();
            validationSuccess = false;
        }

        if(!firstElement && !validationSuccess) {
            firstElement = actionReasonElement;
        }

        if(validationSuccess) {  
            if(!this.template.querySelector(".mandatory").validateFields()) {
                validationSuccess = false;
            }
        }

        if(validationSuccess) {
            
            var selectFields = this.template.querySelectorAll("select");
            selectFields.forEach(function(item){

                item.setCustomValidity('');
                item.reportValidity();

                if(validationSuccess) {
                    
                    if(item.name == 'orderItem' || item.name == 'vehicle' || item.name == 'delivery') { //|| item.name == 'invoice'

                        if(item.value == '' || item.value == '--- Select ---') {
                            item.setCustomValidity('Select Option');
                            item.reportValidity();
                            validationSuccess = false;
                        }
                    } 
                }

                if(!firstElement && !validationSuccess) {
                    firstElement = item;
                }
            });
        }


        if(validationSuccess) {
            var inputFields = this.template.querySelectorAll("lightning-input");
            inputFields.forEach(function(item){
                item.setCustomValidity('');
                item.reportValidity();
                if(validationSuccess) {
                    if(item.name == 'cancelAmount' || item.name == 'rebillAmount' || item.name == 'creditDebitAmount' || item.name == 'returnQuantity' || item.name == 'dollarAmount') {
                        if(item.required && item.value == '') {
                            item.setCustomValidity(item.label + ' is Required');
                            item.reportValidity();
                            validationSuccess = false;
                        }
                    }
                    
                    if(!firstElement && !validationSuccess) {
                        firstElement = item;
                    }
                }
            });
        }
        
        if(validationSuccess) {
            let atFaultPartyElement = this.template.querySelector('select[data-name="atFaultParty"]');
            atFaultPartyElement.setCustomValidity('');
            atFaultPartyElement.reportValidity();
    
            if(atFaultPartyElement.value == '--- Select ---') {
                atFaultPartyElement.setCustomValidity('Select Option');
                atFaultPartyElement.reportValidity();
                validationSuccess = false;
            }
    
            if(!firstElement && !validationSuccess) {
                firstElement = atFaultPartyElement;
            }
        }
    
        if(validationSuccess && !this.isReverseShipmentAction) {
            let paymentRequestTypeElement = this.template.querySelector('select[data-name="paymentRequestType"]');
            paymentRequestTypeElement.setCustomValidity('');
            paymentRequestTypeElement.reportValidity();
    
            if(paymentRequestTypeElement.value == '--- Select ---') {
                paymentRequestTypeElement.setCustomValidity('Select Option');
                paymentRequestTypeElement.reportValidity();
                validationSuccess = false;
            }
    
            if(!firstElement && !validationSuccess) {
                firstElement = paymentRequestTypeElement;
            }   
        }

        this.validatedData = validationSuccess;

        if(!validationSuccess && firstElement) {
            this.scrollToItem(firstElement);
            firstElement.setFocus();
        }

        return validationSuccess;
    }
    
    getRealId(id) {
        const parts = (id || "").split("-");
        parts.pop();
        return parts.join("-");
    }

    scrollToItem(item) {
        setTimeout(() => {
            if(item && item.scrollIntoView) {
                item.scrollIntoView({
                    behavior: "smooth",
                    block: "center"
                });
            }
        });
    }
    
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}