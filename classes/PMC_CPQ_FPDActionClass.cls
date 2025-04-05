/** @description Controller Class for Send Final Price to SAP on Order Detail Page
*  @creator Prakhar
*  @storynumber GDASF-12488
*/

public with sharing class PMC_CPQ_FPDActionClass implements Queueable, Database.AllowsCallouts{
    public Id orderItemId;
    public OrderItem objOrdItm = new OrderItem();
    public List<OrderItem> lstOrderPrd;
    static String strInterface = 'SendFPD';
    static final Integer INT_STATUSCODE200 = 200;
    static final Integer INT_STATUSCODE201 = 201;
    static final List<Integer> LISTINT_SUCCESSCODES = new List<Integer>{INT_STATUSCODE200,INT_STATUSCODE201};
        public boolean massFPDUI = false;
    
    /** @description Constructor of the class which is used to intialize variables using parameter.
*  @param controller : Standard Controller Object
*/
    public PMC_CPQ_FPDActionClass(ApexPages.StandardController controller){
        orderItemId = controller.getId();
        objOrdItm = (OrderItem)controller.getRecord();
    }
    /** @description Constructor of the class which is used to intialize variables using parameter.
*  @param lstOrderItmm - List of Orderitem records
*  @param massFPD - variable to identify if callout is from order detail page/mass fpd UI
*/
    public PMC_CPQ_FPDActionClass(List<OrderItem> lstOrderItmm, Boolean massFPD){
        this.lstOrderPrd = lstOrderItmm;
        this.massFPDUI = massFPD;
    }
    
    /** @description Constructor of the class which is used to intialize variables using parameter.
*  @param context : Queueable job
*/
    public void execute(QueueableContext context){
        // Make Request for FPD Interface
        try{
            PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
            String strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
            
            List<Id> lstIds = new List<Id>();
            for(OrderItem objCur: lstOrderPrd)
            {
                lstIds.add(objCur.Id);
            }  
            String request = PMC_CPQ_CPIRemoteCalloutUtilityClass.createMinimalPayload(lstIds);
            
            // Response from the FPD Interface
            HttpResponse response = PMC_CPQ_CPIRemoteCalloutUtilityClass.sendCalloutRequest('POST', 'callout:PMC_CPQ_NamedCredential'+strEndpoint,request);
            // Response parsing
            if(response!=null){
                if(LISTINT_SUCCESSCODES.contains(response.getStatusCode())){
                    PMC_CPQ_SendPriceFPDResponseParsing.parseSAPDetail(lstOrderPrd, response,massFPDUI);
                }else{
                    PMC_CPQ_SendPriceFPDResponseParsing.parseSAPErrorDetail(lstOrderPrd, response,massFPDUI);
                } 
            }else{   
                Boolean boolRetry = PMC_CPQ_CPIRemoteCalloutUtilityClass.autoRetryQueueableApex(AsyncInfo.getCurrentQueueableStackDepth(),PMC_CPQ_CPIRemoteCalloutUtilityClass.strExceptionMsg);
                PMC_CPQ_SendPriceFPDResponseParsing.updateLinesOnException(lstOrderPrd);
                if(massFPDUI){
                PMC_CPQ_SendPriceFPDResponseParsing.publishToFPDPlatformEvent(lstOrderPrd,'Error',strEndpoint);
                }
                if(boolRetry){System.enqueueJob(new PMC_CPQ_FPDActionClass(lstOrderPrd,massFPDUI), 1);
                             }
            }
        }catch(Exception e){
            PMC_ErrorLogClass.processException(e);
        }
        
    }
    
    /** @description Method that returns to the Order detail Page
*  @return PageReference of the Order Page
*/
    public PageReference redirect(){
        List<OrderItem> lstOrderIt = [select Id, OrderId, PMC_CPQ_FinalAgreedPrice__c,ApprovalStatus__c from OrderItem where Id = :objOrdItm.Id AND PMC_CPQ_FinalAgreedPrice__c != null];
        if(lstOrderIt.size() == 0){
            String cstmWarningLabel = System.Label.PMC_CPQ_FPDtoSAP_Error_Message;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, cstmWarningLabel));
            return null;
        }

        if(lstOrderIt.get(0).ApprovalStatus__c != 'Approved'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.PMC_CPQ_FPDtoSAPItemNotApproved));
            return null;
		}

        lstOrderIt = new List<OrderItem>();
        lstOrderIt.add(objOrdItm);
        System.enqueueJob(new PMC_CPQ_FPDActionClass(lstOrderIt,massFPDUI));
        return new PageReference('/' + orderItemId);
    }
    
    /** @description Method that sends FPD updates to SAP in bulk.
* @param lstOrderIt : List of Order Lines.
* @return null
*/
    public List<OrderItem> bulkSendFPDtoSAPRequest(List<OrderItem> lstOrderIt)
    {
        massFPDUI = true;
        System.enqueueJob(new PMC_CPQ_FPDActionClass(lstOrderIt,massFPDUI));
        return lstOrderIt;
    }
    /** @description Method that returns to the Order detail Page
*  @return PageReference of the Order Page
*/
    public PageReference goBack(){
        return new PageReference('/' + orderItemId);
    }
}