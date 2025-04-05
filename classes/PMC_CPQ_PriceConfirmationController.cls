public class PMC_CPQ_PriceConfirmationController {

    public string quoteId {get;set;}

    public sbaa__Approval__c approvalRecord { 
        get {
            if (quoteId != null) { 
            	return [SELECT Id, Quote__r.PMC_CPQ_PrimaryContact__r.FirstName, OrderItem__r.SBQQ__Contract__r.ContractNumber, CreatedBy.Name, sbaa__Status__c FROM sbaa__Approval__c WHERE Quote__c = :quoteId LIMIT 1];
            } else {
                return null;
            }
        }
    }

    public List<OrderItem> itemList {
        get {
            if (quoteId != null) {
                return [SELECT Id, Order.OrderNumber, OrderItemNumber, TotalPrice, PMC_CPQ_ShipTo__r.Name FROM OrderItem WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c = :quoteId];
            } else {
                return null;
            }
        }
    }
}