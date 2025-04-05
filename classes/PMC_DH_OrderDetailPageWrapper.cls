public class PMC_DH_OrderDetailPageWrapper {
    
    public class PMC_DH_PriceSummaryWrapper{
        public string strProductName{get;set;}
        public Integer intVolume{get;set;}
        public Double doublePricePerUnit{get;set;}
        
    }
    public class PMC_DH_OrderDetailWrapper{
        @AuraEnabled 
        public string strCustomerName{get;set;}
        @AuraEnabled
        public string strOrderPlacedBy{get;set;}
        @AuraEnabled
        public string strSalesChannel{get;set;}
        @AuraEnabled
        public string strPlacedDate{get;set;}
        @AuraEnabled
        public string strStatus{get;set;}
        @AuraEnabled
        public string strProductName{get;set;}
        @AuraEnabled
        public integer intItemNumber{get;set;}
        @AuraEnabled
        public integer intRequestedQty{get;set;}
        @AuraEnabled
        public integer intConfirmedQty{get;set;}
        @AuraEnabled
        public string strReqShipmentDate{get;set;}
        @AuraEnabled
        public string strDeliveryMode{get;set;}
        @AuraEnabled
        public string strShipTo{get;set;}
        @AuraEnabled
        public string strShipFrom{get;set;}
        @AuraEnabled
        public string strProdImageUrl{get;set;}   
        @AuraEnabled
        public List<PMC_DH_PriceSummaryWrapper> PriceSummaryWrapper{get;set;}
    }
}