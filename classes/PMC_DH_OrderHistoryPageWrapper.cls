public class PMC_DH_OrderHistoryPageWrapper {
    @AuraEnabled
    public List<PMC_DH_OrderHistoryWrapper> ETY_OUTBOUND{get;set;}
    public class PMC_DH_OrderHistoryWrapper{
        @AuraEnabled
        public string strOrderNumber{get;set;}
        @AuraEnabled
        public string strContractNumber{get;set;}
        @AuraEnabled
        public string strPONumber{get;set;}
        @AuraEnabled
        public string strProductName{get;set;}
        @AuraEnabled
        public string strShipTo{get;set;}
        @AuraEnabled
        public string strReqShipmentDate{get;set;}
        @AuraEnabled
        public Integer intQuantity{get;set;}
        @AuraEnabled
        public double doubleTotalPrice{get;set;}
        @AuraEnabled
        public string strDateCreated{get;set;} 
        @AuraEnabled
        public string strOrderItems{get;set;}
    }
    
}