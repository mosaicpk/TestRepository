public class PMC_DH_ContractWrapper {
@AuraEnabled
    public List<ContractWrapper> lstcontractWrapper {get;set;}
     public class ContractWrapper{
        /**
* @description SKU of product
* @return String
*/
        @AuraEnabled
        public string strSku{get;set;}
        /**
* @description Incoterm
* @return String   
*/
        @AuraEnabled
        public string strIncoterm{get;set;}
        /**
* @description Ship To
* @return String   
*/
        @AuraEnabled
        public string strShipTo{get;set;}
        /**
* @description Ship From
* @return String   
*/
        @AuraEnabled
        public string strShipFrom{get;set;}
        /**
* @description Mode of Transportation
* @return String   
*/
        public string strMot{get;set;}
        /**
* @description Available Quantity
* @return String   
*/
        public string strAvailableQty{get;set;}
}
    
}