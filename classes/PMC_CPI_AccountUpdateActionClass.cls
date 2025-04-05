/** @description This class will be used to make callouts to the Account Creation interface of CPI. 
 *  @author Gideoni Silva
 *  @storynumber EIDGT-965
 */
public class PMC_CPI_AccountUpdateActionClass implements Queueable, Database.AllowsCallouts{
    public Account EffectiveAccount;
    public List<Id> lstIds;
    public Map<String, String> JSONPayloadParams;
    public String strAccountGroup;    
    static final String STRING_INTEGRATIONSTATUSERROR = 'Error';
    static final String STRING_INTERFACE = 'BPModification';
    static final String STRING_NAMEDCREDENTIALS = 'callout:PMC_CPQ_NamedCredential';
    static final String STRING_METHOD = 'POST';
    static List<PMC_CPQ_TransactionLog__c> lstTransactionLogs = new List<PMC_CPQ_TransactionLog__c>();
    
    /** 
     * @description Constructor of the class. 
     * @param lstAccounts - list of accounts sent from the flow.
     * @param lstIds - lists of ids
     */
    public PMC_CPI_AccountUpdateActionClass(Account EffectiveAccount, List<Id> lstIds, String strAccountGroup, Map<String, String> JSONPayloadParams)
    {
        this.EffectiveAccount = EffectiveAccount; 
        this.lstIds = lstIds;
        this.strAccountGroup = strAccountGroup;
    }
    /** 
     * @description This is the apex action that will be invoked from the flow.
     * @param lstAccounts - list of Accounts sent from the flow.
     */
    @InvocableMethod(label='CPI Account Update Remote Action' description='Triggers the CPI Interface to modify Account record data in SAP' category='Account')
    public static void postInfoToCPI(List<AccountActionRequest> AccountParameters) {
        Account EffectiveAccount = AccountParameters[0].inputAccount;
        String strAccountGroup = AccountParameters[0].strAccountGroup;
        List<Id> lstIds = new List<Id>();
        lstIds.add(EffectiveAccount.Id);
        Map<String, String> JSONPayloadParams = new Map<String, String>{};
        JSONPayloadParams.put('strCustomerTaxCategory', AccountParameters[0].strCustomerTaxCategory);

       System.enqueueJob(new PMC_CPI_AccountUpdateActionClass(EffectiveAccount, lstIds, strAccountGroup, JSONPayloadParams));
    }

    /** 
     * @description Makes a request to callout class.
     * @param context - Receives the context of the flow. In this case it is the list of accounts.
     */
    public void execute(QueueableContext context)
    { 
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(STRING_INTERFACE); 
        String strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
        String strCalloutEndpoint = STRING_NAMEDCREDENTIALS+strEndpoint;
        String strSerializedBody;
		
        switch on strAccountGroup {
            when 'Ship-to' {
                strSerializedBody = PMC_CPIAccountCalloutUtilityClass.createShipToPayload(lstIds,JSONPayloadParams);
            }
            when 'Sold-to' {
                strSerializedBody = PMC_CPIAccountCalloutUtilityClass.createSoldToPayload(lstIds);
            }
            when 'Bill-to' {
                strSerializedBody = PMC_CPIAccountCalloutUtilityClass.createBillToPayload(lstIds);
            }
            when 'Payer' {
                strSerializedBody = PMC_CPIAccountCalloutUtilityClass.createPayerPayload(lstIds);
            }
        }	
        
        HttpResponse response = PMC_CPIAccountCalloutUtilityClass.sendCalloutRequest(STRING_METHOD, strCalloutEndpoint, strSerializedBody);
        if(response != null)
        {
            PMC_CPIAccountIntegrationClass.parseJSONAccountInterface(EffectiveAccount, response, strEndpoint);
        }
        else
        {   
            Boolean boolRetry = PMC_CPIAccountCalloutUtilityClass.autoRetryQueueableApex(AsyncInfo.getCurrentQueueableStackDepth(),PMC_CPQ_CPIRemoteCalloutUtilityClass.strExceptionMsg);
            PMC_CPIAccountIntegrationClass.updateAccountExceptionStatusMsg(EffectiveAccount, strEndpoint); 
            
            if(boolRetry)
            {
       			System.enqueueJob(new PMC_CPI_AccountUpdateActionClass(EffectiveAccount, lstIds, strAccountGroup, JSONPayloadParams));
            } 
        }
    }
    
    public class AccountActionRequest {
        @InvocableVariable(required=true)
        public Account inputAccount;
    
        @InvocableVariable(required=true)
        public String strAccountGroup;
        
        @InvocableVariable(required=false)
        public String strCustomerTaxCategory;  
	}  
}