/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-02-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PMC_SS_CaseRelatedUpdateCtrl {

    /**
     * @description - Wrapper class to hold the order related details
     */

    public class OrderDetailsWrapper {
        /**
         * @description - holds the account details
         */
        @AuraEnabled
        public ObjectDetailsWrapper objAccountWrapper{get;set;}

        /**
         * @description - holds the contract details
         */
        @AuraEnabled
        public ObjectDetailsWrapper objContractWrapper{get;set;}

        /**
         * @description - holds the ship-to account details
         */
        @AuraEnabled
        public ObjectDetailsWrapper objShipToAccountWrapper{get;set;}

        /**
         * @description - holds the sold-to account details
         */
        @AuraEnabled
        public ObjectDetailsWrapper objSoldToAccountWrapper{get;set;}
        
        /**
         * @description - holds the order object
         */
        @AuraEnabled
        public Order objOrder{get;set;}
        
        /**
         * @description - holds the list of order related order products
         */
        @AuraEnabled
        public List<OrderItem> lstOrderItems{get;set;}

        /**
         * @description - holds the list of order related order products
         */
        @AuraEnabled
        public List<PMC_CPQ_Invoice__c> lstInvoices{get;set;}
    }

    
    /**
     * @description - Generic Wrapper class to hold the object record name & id
     */
    public class ObjectDetailsWrapper {
        /**
         * @description - holds the object Id
         */
        @AuraEnabled
        public Id idRecord{get;set;}

        /**
         * @description - holds the object name
         */
        @AuraEnabled
        public String strRecordName{get;set;}

        /**
         * @description - constructor for wrapper class
         * @param idRecord - Record Id
         * @param strRecordName - Record Name
         */
        public ObjectDetailsWrapper(Id idRecord, String strRecordName) {
            this.idRecord =  idRecord;
            this.strRecordName = strRecordName;
        }
    }

    /**
     * @description - Method used to fetch the Order Details
     * @param strOrderId - Order Id
     * @return OrderDetailsWrapper - Returns Wrapper of type OrderDetailsWrapper
     */

    @AuraEnabled(cacheable=true)
    public static OrderDetailsWrapper getOrderItems(String strOrderId){
        try {
            Order objOrder = [SELECT Id, AccountId, Account.Name, ContractId, Contract.Name, Contract.ContractNumber,
                                    PMC_CPQ_ShipToAccount__c, PMC_CPQ_ShipToAccount__r.Name, PMC_CPQ_SoldToAccount__c, PMC_CPQ_SoldToAccount__r.Name,
                                    (SELECT Id, OrderItemNumber, OrderId, UnitPrice, PMC_CPQ_ProductLocation__r.PMC_CPQ_Location__r.PMC_CPQ_Plant__c FROM OrderItems),
                                    (SELECT Id, Name, PMC_CPQ_InvoiceId__c, PMC_CPQ_Contact__c, PMC_CPQ_NetInvoicedQuantity__c,
                                        PMC_CPQ_Contact__r.Name, PMC_CPQ_OriginalAmount__c, PMC_CPQ_OrderProduct__c,
                                        PMC_CPQ_RemainingAmount__c, PMC_CPQ_TotalInvoiceValue__c
                                        FROM Invoices__r
                                        WHERE PMC_CPQ_Delivery__c IN : [SELECT Id, PMC_CPQ_Order__c FROM Shipment WHERE PMC_CPQ_Order__c =: strOrderId])
                                    FROM Order                                       
                                    WHERE Id =: strOrderId 
                                    WITH SECURITY_ENFORCED];

            if(objOrder != null) {
                OrderDetailsWrapper objOrderDetailsWrapper = new OrderDetailsWrapper();
                objOrderDetailsWrapper.objOrder = objOrder;

                ObjectDetailsWrapper objAccountWrapper = new ObjectDetailsWrapper(objOrder.AccountId, objOrder.Account.Name);
                objOrderDetailsWrapper.objAccountWrapper = objAccountWrapper;

                ObjectDetailsWrapper objContractWrapper = new ObjectDetailsWrapper(objOrder.ContractId, objOrder.Contract.ContractNumber);
                objOrderDetailsWrapper.objContractWrapper = objContractWrapper;

                ObjectDetailsWrapper objShipToAccountWrapper = new ObjectDetailsWrapper(objOrder.PMC_CPQ_ShipToAccount__c, objOrder.PMC_CPQ_ShipToAccount__r.Name);
                objOrderDetailsWrapper.objShipToAccountWrapper = objShipToAccountWrapper;

                ObjectDetailsWrapper objSoldToAccountWrapper = new ObjectDetailsWrapper(objOrder.PMC_CPQ_SoldToAccount__c, objOrder.PMC_CPQ_SoldToAccount__r.Name);
                objOrderDetailsWrapper.objSoldToAccountWrapper = objSoldToAccountWrapper;

                objOrderDetailsWrapper.lstOrderItems = objOrder.OrderItems;
                objOrderDetailsWrapper.lstInvoices = objOrder.Invoices__r;

                return objOrderDetailsWrapper; 
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return null;
    }

    /**
     * @description - Method used to fetch the delivery item Details
     * @param strOrderItemId - Order Item Id
     * @return List<ShipmentItem> - Returns List of Shipment Items
     */
    @AuraEnabled(cacheable=true)
    public static List<ShipmentItem> getDeliveryItems(String strOrderItemId){
        try {
            return [SELECT Id, PMC_CPQ_OrderProduct__c, ShipmentItemNumber, PMC_CPQ_DeliveryItemName__c,  PMC_CPQ_DeliveryItemID__c,
                    /*PMC_CPQ_ModeofTransportation__c,*/ PMC_CPQ_PlantID__c, PMC_CPQ_VehicleID__c, PMC_CPQ_ShippedDate__c
                    FROM ShipmentItem                                           
                    WHERE PMC_CPQ_OrderProduct__c =: strOrderItemId 
                    WITH SECURITY_ENFORCED];            
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description - Method used to update Case Object
     * @param objCaseDetailsWrapper -Wrapper holding all case details
     * @return Case - Returns Case Object
     */
    @AuraEnabled
    public static Case updateCaseRecord(PMC_SS_CaseDetailsWrapper objCaseDetailsWrapper){
        try {
            Case objCase = [SELECT Id, PMC_SS_ActionReason__c, PMC_SS_Invoice__c, PMC_SS_Order__c,
                            PMC_SS_OrderProduct__c, PMC_SS_OriginalInvoiceAmount__c, PMC_SS_CancelAmount__c, PMC_SS_RebillAmount__c, 
                            PMC_SS_InvoiceDifference__c, AccountId, ContactId, PMC_SS_AtFaultParty__c, PMC_SS_PaymentRequestType__c,
                            PMC_SS_SoldToAccount__c, PMC_SS_ShipToAccount__c, PMC_SS_CreditDebitAmount__c, 
                            PMC_SS_Plant__c, PMC_SS_ReturnQuantity__c, PMC_SS_ReturnAmount__c, PMC_SS_MOT__c,
                            PMC_SS_VehicleId__c, PMC_SS_PGIDate__c, PMC_SS_HyperLink__c
                            FROM Case 
                            WHERE Id =: objCaseDetailsWrapper.caseId WITH SECURITY_ENFORCED LIMIT 1];
                        
            if(objCase != null) {

                objCase.PMC_SS_ActionReason__c = objCaseDetailsWrapper.actionReason;
                objCase.PMC_SS_Order__c = objCaseDetailsWrapper.orderId;
                objCase.PMC_SS_OrderProduct__c = objCaseDetailsWrapper.orderItemId;
                objCase.PMC_SS_Invoice__c = objCaseDetailsWrapper.invoiceId;
                objCase.PMC_SS_OriginalInvoiceAmount__c =  objCaseDetailsWrapper.originalInvoiceAmount;
                objCase.PMC_SS_AtFaultParty__c = objCaseDetailsWrapper.atFaultParty;
                objCase.PMC_SS_PaymentRequestType__c = objCaseDetailsWrapper.paymentRequestType;

                updateActionSpecificFields(objCaseDetailsWrapper, objCase);
            }

            if(Schema.SObjectType.Case.isUpdateable() && Case.SObjectType.getDescribe().isAccessible()) {
                update objCase;
                return objCase;    
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return null;
    }

     /**
     * @description - Method used to update Case Object details
     * @param objCaseDetailsWrapper -Wrapper holding all case details
     * @param objCase - Case object
     */
    public static void updateActionSpecificFields(PMC_SS_CaseDetailsWrapper objCaseDetailsWrapper, Case objCase) {

        if(objCaseDetailsWrapper.actionReason == PMC_SS_ConstantClass.CANCEL || objCaseDetailsWrapper.actionReason == PMC_SS_ConstantClass.REBILL){
            objCase.AccountId = objCaseDetailsWrapper.accountId;
            objCase.ContactId = objCaseDetailsWrapper.contactId;
            objCase.PMC_SS_InvoiceDifference__c = objCaseDetailsWrapper.invoiceDifference;
            updateAmountValues(objCaseDetailsWrapper, objCase);
        }
        else if(objCaseDetailsWrapper.actionReason == PMC_SS_ConstantClass.CREDIT || objCaseDetailsWrapper.actionReason == PMC_SS_ConstantClass.DEBIT) {
            objCase.PMC_SS_SoldToAccount__c = objCaseDetailsWrapper.soldToAccountId;
            objCase.PMC_SS_ShipToAccount__c = objCaseDetailsWrapper.shipToAccountId;
            objCase.PMC_SS_Plant__c = objCaseDetailsWrapper.plantId;
			objCase.PMC_SS_CreditDebitAmount__c = objCaseDetailsWrapper.creditDebitAmount;
            updateAmountValues(objCaseDetailsWrapper, objCase);
        }
        else {
            objCase.PMC_SS_SoldToAccount__c = objCaseDetailsWrapper.soldToAccountId;
            objCase.PMC_SS_ShipToAccount__c = objCaseDetailsWrapper.shipToAccountId;
            objCase.PMC_SS_Plant__c = objCaseDetailsWrapper.plantId;
            objCase.PMC_SS_MOT__c = objCaseDetailsWrapper.modeOfTransportation;
            objCase.PMC_SS_VehicleId__c = objCaseDetailsWrapper.vehicleId;
            objCase.PMC_SS_PGIDate__c = Date.valueOf(objCaseDetailsWrapper.pgiDate);
            objCase.PMC_SS_ReturnQuantity__c = objCaseDetailsWrapper.returnQuantity;
            objCase.PMC_SS_ReturnAmount__c = objCaseDetailsWrapper.returnAmount;
            objCase.PMC_SS_HyperLink__c = Label.PMC_SS_SAPFioriReturnLink;
        }
    }

     /**
     * @description - Method used to update Case Object details
     * @param objCaseDetailsWrapper -Wrapper holding all case details
     * @param objCase - Case object
     */
    public static void updateAmountValues(PMC_SS_CaseDetailsWrapper objCaseDetailsWrapper, Case objCase) {
        if(objCaseDetailsWrapper.actionReason == PMC_SS_ConstantClass.CANCEL) {
            objCase.PMC_SS_CancelAmount__c = objCaseDetailsWrapper.cancelAmount;
            objCase.PMC_SS_HyperLink__c = Label.PMC_SS_SAPFioriCancelLink;
        }
        else if(objCaseDetailsWrapper.actionReason == PMC_SS_ConstantClass.REBILL){
            objCase.PMC_SS_RebillAmount__c = objCaseDetailsWrapper.rebillAmount;
            objCase.PMC_SS_HyperLink__c = Label.PMC_SS_SAPFioriRebillLink;
        }
        else if(objCaseDetailsWrapper.actionReason == PMC_SS_ConstantClass.CREDIT){
            objCase.PMC_SS_HyperLink__c = Label.PMC_SS_SAPFioriCreditLink;
        }
        else if(objCaseDetailsWrapper.actionReason == PMC_SS_ConstantClass.DEBIT){
            objCase.PMC_SS_HyperLink__c = Label.PMC_SS_SAPFioriDebitLink;
        }
    }

     /**
     * @description - Method used to fetch picklist values Case Object details
     * @param objApiName - Object API Name
     * @param fieldName - Field Name
     * @return List<Map<String, String>> - Map with details
     */
    @AuraEnabled
    public static List<Map<String, String>> getPickListValues(String objApiName, String fieldName) {
        List<Map<String, String>> options = new List <Map<String, String>>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List <Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map < String, String > values = new Map < String, String > {
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            options.add(values);
        }
        return options;
    }
}