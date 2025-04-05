/** 
* @description Controller class for editing Requested orders
* @author Mosaic Direct Dev
* Created On       :2023-Oct-19
**/
public class PMC_DH_RequestedOrderEditController {

    public static final String ORDER_EDIT_SUCCESS_MODULE = 'OrderEdit';
    public static final String STRING_INTEGRATIONSTATUSERROR = 'Error'; 
    public static final String STRING_INTEGRATIONSTATUSSUCCESS = 'Success';
    
    /*************************************************************************
* @method Name  : getUpdatedDetails
* @description  : Method to return updated order details for requested order
* @param         editRequestWrapper
* @author        Mosaic Direct Dev 
* @return        String 
*****************************************************************************/
    @AuraEnabled
    public static String getUpdatedDetails(EditRequestWrapper editRequestWrapper){
        HTTPResponse response;
        String responseBody;
        PMC_DH_OrderEditWrapper ordWrapper = new PMC_DH_OrderEditWrapper();
        PMC_DH_OrderEditWrapper.PMC_DH_RequestWrapper ordResponseWrapper = new PMC_DH_OrderEditWrapper.PMC_DH_RequestWrapper();        
        PMC_DH_OrderEditResponseWrapper resultWrapper = new PMC_DH_OrderEditResponseWrapper();
        Set<Integer> successStatCode = new Set<Integer>{200,201,202};
        try{
            response = PMC_DH_OrderSchedulingService.updateSchedulingRequest(editRequestWrapper);
            if(successStatCode.contains(response.getStatusCode())){
                responseBody = (String)response.getBody();
                ordWrapper = (PMC_DH_OrderEditWrapper)JSON.deserialize(responseBody,PMC_DH_OrderEditWrapper.class);
                ordResponseWrapper = ordWrapper.lstResultData;
                resultWrapper.strMessage = STRING_INTEGRATIONSTATUSSUCCESS;
                resultWrapper.strQty = ordResponseWrapper.strCustomerReqQty;
                resultWrapper.strReqId = ordResponseWrapper.strReqId;
                resultWrapper.strShipmentDate = ordResponseWrapper.strReqDelDat;
            }
            else{
                resultWrapper.strMessage = STRING_INTEGRATIONSTATUSERROR;
            }
            resultWrapper.statusCodeMessage = PMC_DH_DigitalHubB2BUtils.getMessageForStatusCode(PMC_DH_ConstantClass.SUCCESS_STATUS_CODE, ORDER_EDIT_SUCCESS_MODULE);
        }
        catch(Exception ex){
            resultWrapper.statusCodeMessage = PMC_DH_DigitalHubB2BUtils.getMessageForStatusCode(PMC_DH_ConstantClass.TECHNICAL_ERR_STATUS_CODE, PMC_DH_ConstantClass.ALL);
            PMC_ErrorLogClass.processException(ex);
        }
        return JSON.serialize(resultWrapper);
    }
    /**
* @description        
* @author              Mosaic Direct Dev 
* @group              
* @last modified on   10-27-2023
* @last modified by    Mosaic Direct Dev 
**/
   
    public class EditRequestWrapper{
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