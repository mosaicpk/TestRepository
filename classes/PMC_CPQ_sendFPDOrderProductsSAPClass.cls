/**
* @description This class will be used to receive order products from fpdMassUpdate lightning web component and process it and send to SAP or receive
* price from PriceFX
* @storynumber GDASF-9421
*/
public with sharing class PMC_CPQ_sendFPDOrderProductsSAPClass {
    
    /**
* @description Common method to fetch OrderItems based on a list of IDs
* @param idOps - List of id for which the OrderItem record is to be returned
* @return - the result of the SOQL query
*/
    private static List<OrderItem> fetchOrderItems(List<Id> idOps) {
        return [SELECT Id, OrderItemNumber, Order.OrderNumber, SBQQ__Contract__r.PMC_CPQ_ContractNumberIdentifier__c, PMC_CPQ_LinePONumber__c, PMC_CPQ_ShipTo__r.Name, Order.Account.Name, Product2.Name, Quantity, PMC_CPQ_PricingDate__c,  PMC_CPQ_FPDPricefromPriceFx__c, PMC_CPQ_FinalAgreedPrice__c, PMC_CPQ_OrderLineStatus__c, PMC_CPQ_OrderItemIntegrationStatus__c,PMC_CPQ_OrderItemIntegrationMessage__c,Order.PMC_CPQ_SAPOrderNumber__c
                FROM OrderItem
                WHERE Id IN :idOps WITH SECURITY_ENFORCED];
    }
    
    /**
* @description This method will be used to send Order products to SAP with negotiated Final Agreed Price
* @param lstOlines - String of List of Order Products sent from LWC component
*/
    @AuraEnabled
    public static String saveOPFromUI(String lstOlines) {
        List<PMC_CPQ_OrderProductDetailsWrapperClass> params = (List<PMC_CPQ_OrderProductDetailsWrapperClass>)JSON.deserialize(lstOlines,List<PMC_CPQ_OrderProductDetailsWrapperClass>.class);
        List<Id> idOps = new List<Id>();
        for (PMC_CPQ_OrderProductDetailsWrapperClass wrapper : params) {
            idOps.add(wrapper.customId);
        }
        List<OrderItem> lstOP = fetchOrderItems(idOps);
        for (Integer i = 0; i < params.size(); i++) {
            lstOP[i].PMC_CPQ_FinalAgreedPrice__c = params[i].finalAgreedPrice;
        }
        
        try {
            if (Schema.sObjectType.OrderItem.isAccessible() &&
                Schema.sObjectType.OrderItem.isUpdateable() &&
                Schema.SObjectType.OrderItem.fields.PMC_CPQ_FinalAgreedPrice__c.isUpdateable()) {
                    update lstOP;
                }
        } catch (DmlException objException) {
            PMC_ErrorLogClass.processException(objException);
            return 'Error saving Order Products : ' + objException.getMessage();
        }
       return  sendOrderProductsToSAP(lstOP);
    }
    
    /**
* @description This method will be used to send Order products to SAP with negotiated Final Agreed Price and this function will block to send to SAP if Order products status is Under Revision and Rejected
* @param lstOP - List of Order Products
*/
    @AuraEnabled
    public static String sendOrderProductsToSAP(List<OrderItem> lstOP) {
        //GCPM-2008 - SAA Start
        PMC_CPQ_FPDActionClass objRef = new PMC_CPQ_FPDActionClass(lstOP,true);
        List<OrderItem> lstOrdItemApp = [Select id,ApprovalStatus__c,PMC_CPQ_OrderItemIntegrationMessage__c from OrderItem where ID IN :lstOP];
        List<OrderItem> lstToUpdateIntegration = new List<OrderItem>();
        String message = '';
        for(OrderItem lstOrdItem : lstOrdItemApp){
            String test = lstOrdItem.ApprovalStatus__c;
            {
                if(lstOrdItem.ApprovalStatus__c != 'Under Revision' && lstOrdItem.ApprovalStatus__c != 'Rejected')
                {
                    objRef.bulkSendFPDtoSAPRequest(lstOP);
                }
                else
                {
                    lstOrdItem.PMC_CPQ_OrderItemIntegrationMessage__c = 'Approval Require';
                    lstToUpdateIntegration.add(lstOrdItem);
                }
            }
        }
        try{
            if(!lstToUpdateIntegration.isEmpty())
            {
                update lstToUpdateIntegration;
                message = 'Some Selected Orders have been sent to PM for approval.';
            }
        }
        catch (DmlException e){
            message = 'Error Updating Order Item : ' + e.getMessage();
            PMC_ErrorLogClass.processException(e);
        }
        return message;
        
        //GCPM-2008 - SAA End
    }
    
    /**
* @description This method will be used to receive the latest price of selected order products from the Price FPD Order Line tab
* @param lstOlines - String of List of Order Products sent from LWC component
*/
    @AuraEnabled
    public static void getPriceFromPriceFX(String lstOlines) {
        List<PMC_CPQ_OrderProductDetailsWrapperClass> params = (List<PMC_CPQ_OrderProductDetailsWrapperClass>)JSON.deserialize(lstOlines,List<PMC_CPQ_OrderProductDetailsWrapperClass>.class);
        List<Id> idOps = new List<Id>();
        for (PMC_CPQ_OrderProductDetailsWrapperClass wrapper : params) {
            idOps.add(wrapper.customId);
        }
        List<OrderItem> lstOP = fetchOrderItems(idOps);
        PMC_CPQ_GetFPDController objRef1 = new PMC_CPQ_GetFPDController(lstOP,true);
        objRef1.bulkGetFPDRequest(lstOP);
    }
    
    /**
* @description This method will retrieve the interface url from the PMC_CPQ_Integration_Endpoint__mdt
* @return endpoint- the interface URL string
*/
   @AuraEnabled(cacheable = true)
    public static string sendFPDPriceFXURL(){
        String strInterface = 'SendFPD';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        String endpoint = JSON.serialize(strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c);
        return endpoint;
    }
}