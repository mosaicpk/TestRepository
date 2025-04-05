public class SendAndSaveSAPController {
	public String resultMessage { get; set; }
	public Id recordId { get; set; }

	// Constructor to initialize the resultMessage and retrieve the recordId from the URL parameters
	public SendAndSaveSAPController(ApexPages.StandardController controller) {
		// Retrieve the recordId from the URL parameters (this comes from the Quick Action context)
		recordId = ApexPages.currentPage().getParameters().get('id');
		resultMessage = ''; // Initialize result message
	}

	// Method to invoke saveOPFromUI in PMC_CPQ_FPDSENDSAPQuickAction
	public void saveOPFromUI() {
		if (recordId != null) {
			try {
				List<OrderItem> lstOP = fetchOrderItems(new List<Id>{ recordID });
				resultMessage = PMC_CPQ_sendFPDOrderProductsSAPClass.sendOrderProductsToSAP(lstOP);
			} catch (Exception e) {
				resultMessage = 'Error: ' + e.getMessage();
			}
		} else {
			resultMessage = 'No valid recordId provided.';
		}
	}

	/**
	 * @description Common method to fetch OrderItems based on a list of IDs
	 * @param idOps - List of id for which the OrderItem record is to be returned
	 * @return - the result of the SOQL query
	 */
	private static List<OrderItem> fetchOrderItems(List<Id> idOps) {
		return [
			SELECT
				id,
				ApprovalStatus__c,
				PMC_CPQ_OrderItemIntegrationMessage__c,
				SBQQ__Contract__r.PMC_CPQ_ContractNumberIdentifier__c,
				PMC_CPQ_LinePONumber__c,
				PMC_CPQ_ShipTo__r.Name,
				Order.Account.Name,
				Product2.Name,
				Quantity,
				PMC_CPQ_PricingDate__c,
				PMC_CPQ_FPDPricefromPriceFx__c,
				PMC_CPQ_FinalAgreedPrice__c,
				PMC_CPQ_OrderLineStatus__c,
				PMC_CPQ_OrderItemIntegrationStatus__c,
				Order.PMC_CPQ_SAPOrderNumber__c
			FROM OrderItem
			WHERE Id IN :idOps
			WITH SECURITY_ENFORCED
		];
	}
}