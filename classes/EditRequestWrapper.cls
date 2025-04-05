/**
* @description        
* @author             gosubramani@deloitte.com | Digital Hub
* @group              
* @last modified on   10-27-2023
* @last modified by   gosubramani@deloitte.com | Digital Hub
**/
   
    public class EditRequestWrapper{
        @AuraEnabled
        public editWrapper editRequestWrapper{get;set;}
        public class editWrapper{
        /**
* * @description strOrderLineId
* * @return string
* */

        @AuraEnabled
        public string strOrderLineId{get;set;}
            /**
* * @description strReqQty
* * @return string
* */
    
        @AuraEnabled
        public string strReqQty{get;set;}
            /**
* * @description strReqShipmentDate
* * @return string
* */
    
        @AuraEnabled
        public string strReqShipmentDate{get;set;}
            /**
* * @description responseData
* * @return responseData
* */
    
        @AuraEnabled
        public string responseData{get;set;}
    }
    }