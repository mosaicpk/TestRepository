/**
* @File Name : PmccpqfpdMassUpdateQuickAction.cls
* @Description :
* @Author : Kaushik  Gohain
* @Last Modified By :
* @Last Modified On : March 25, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 25, 2025 |   | Initial Version
**/

public with sharing class PmccpqfpdMassUpdateQuickAction{
   
	/**
	* @description This method will be used to send Order products to SAP with negotiated Final Agreed Price
	* @param lstOlines - String of List of Order Products sent from LWC component
	*/
    @AuraEnabled
    public static String saveOPFromUI(String recordId) {
        List<Id> idOps = new List<Id>();
        idOps.add(recordId);
        List<OrderItem> lstOP = fetchOrderItems(idOps);
        return  sendOrderProductsToSAP(lstOP);
    }

        /**
		* @description Common method to fetch OrderItems based on a list of IDs
		* @param idOps - List of id for which the OrderItem record is to be returned
		* @return - the result of the SOQL query
		*/
    private static List<OrderItem> fetchOrderItems(List<Id> idOps) {
        return
		 [Select id,ApprovalStatus__c,PMC_CPQ_OrderItemIntegrationMessage__c, SBQQ__Contract__r.PMC_CPQ_ContractNumberIdentifier__c,PMC_CPQ_LinePONumber__c,PMC_CPQ_ShipTo__r.Name,Order.Account.Name,
Product2.Name, Quantity, PMC_CPQ_PricingDate__c, PMC_CPQ_FPDPricefromPriceFx__c,PMC_CPQ_FinalAgreedPrice__c, PMC_CPQ_OrderLineStatus__c, PMC_CPQ_OrderItemIntegrationStatus__c,
Order.PMC_CPQ_SAPOrderNumber__c  from OrderItem 
                WHERE Id IN :idOps WITH SECURITY_ENFORCED];
    }

    /**
	* @description This method will be used to send Order products to SAP with negotiated Final Agreed Price and this function will block to send to SAP if Order products status is Under Revision and Rejected
	* @param lstOP - List of Order Products
	*/
    @AuraEnabled
    public static String sendOrderProductsToSAP(List<OrderItem> lstOP) {
        //GCPM-2008 - SAA Start
        PMC_CPQ_FPDActionClass objRef = new PMC_CPQ_FPDActionClass(lstOP,true);
        List<OrderItem> lstOrdItemApp = 
		[Select id,ApprovalStatus__c,PMC_CPQ_OrderItemIntegrationMessage__c from OrderItem where ID IN :lstOP];
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
    }
}