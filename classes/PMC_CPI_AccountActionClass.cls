/**
* @description This class will be used to make callouts to the Account Creation/Update interface of CPI - PMC_CPI_AccountCreateActionClass
* @author Gideoni Silva
* @storynumber EIDGT-965
*/
public class PMC_CPI_AccountActionClass implements Queueable, Database.AllowsCallouts {
	
    public Account EffectiveAccount;
    public List<Id> lstIds;
    public List<Object> AccountParameters;
    public Map<String, String> JSONPayloadParams;
    public String strAccountGroup;
    public String STRING_INTERFACE;
    static final String STRING_INTEGRATIONSTATUSERROR = 'Error';
    static final String STRING_NAMEDCREDENTIALS = 'callout:PMC_CPQ_NamedCredential';
    static final String STRING_METHOD = 'POST';
    static List<PMC_CPQ_TransactionLog__c> lstTransactionLogs = new List<PMC_CPQ_TransactionLog__c>();
 
    @TestVisible private static Map<String, PMC_CPQ_Integration_Endpoint__mdt> mockMetadata = new Map<String, PMC_CPQ_Integration_Endpoint__mdt>();
 
    /** 
     * @description Constructor of the class. 
     * @param lstAccounts - list of accounts sent from the flow.
     * @param lstIds - lists of ids
     */
    public PMC_CPI_AccountActionClass(Account EffectiveAccount, List<Id> lstIds, String strAccountGroup, String STRING_INTERFACE, Map<String, String> JSONPayloadParams) {
        this.EffectiveAccount = EffectiveAccount; 
        this.lstIds = lstIds;
        this.strAccountGroup = strAccountGroup;
        this.JSONPayloadParams = JSONPayloadParams;
        this.STRING_INTERFACE = STRING_INTERFACE;
    }
    /** 
     * @description This is the apex action that will be invoked from the flow.
     * @param lstAccounts - list of Accounts sent from the flow.
     */
    @InvocableMethod(label='CPI Customer Creation/Update Remote Action' description='Triggers the CPI Interface to create Business Partner records in SAP' category='Account')
    public static void postInfoToCPI(List<AccountActionRequest> AccountParameters) {
        Account EffectiveAccount = AccountParameters[0].inputAccount;
        String strAccountGroup = AccountParameters[0].strAccountGroup;
        String STRING_INTERFACE = AccountParameters[0].strEndpointName;
        
        List<Id> lstIds = new List<Id>();
        lstIds.add(EffectiveAccount.Id);
        Map<String, String> JSONPayloadParams = new Map<String, String>{
            'strBPGrouping' => AccountParameters[0].strBPGrouping,
            'strPartnerFunction' => AccountParameters[0].strPartnerFunction,
            'strCustomerTaxCategory' => AccountParameters[0].strCustomerTaxCategory,
            'strLanguage' => AccountParameters[0].strLanguage,
            'strReconcAcc' => AccountParameters[0].strReconcAcc,
            'strAcctAssmtGrpCust' => AccountParameters[0].strAcctAssmtGrpCust,
            'strTransportation' => AccountParameters[0].strTransportation,
            'strCNPJNumber' => AccountParameters[0].strCNPJNumber,
            'strCPFNumber' => AccountParameters[0].strCPFNumber,
            'strRUCPYOrg' => AccountParameters[0].strRUCPYOrg,
            'strRUCPYPerson' => AccountParameters[0].strRUCPYPerson,
            'strSearchTerm1' => AccountParameters[0].strSearchTerm1,
            'strInvDates' => AccountParameters[0].strInvDates,
            'strInvListSched' => AccountParameters[0].strInvListSched,
            'strCashPlanningGroup' => AccountParameters[0].strCashPlanningGroup,
            'strToleranceGroup' => AccountParameters[0].strToleranceGroup,
            'strNaturalPerson' => AccountParameters[0].strNaturalPerson,
            'strLayoutSortingRule' => AccountParameters[0].strLayoutSortingRule,
            'strTaxClass' => AccountParameters[0].strTaxClass,
            'strDivision' => AccountParameters[0].strDivision
        };

       	System.enqueueJob(new PMC_CPI_AccountActionClass(EffectiveAccount, lstIds, strAccountGroup, STRING_INTERFACE, JSONPayloadParams));
    }
    /** 
     * @description Makes a request to callout class.
     * @param context - Receives the context of the flow. In this case it is the list of accounts.
     */
    public void execute(QueueableContext context) {		
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(STRING_INTERFACE); 
        String strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
        String strCalloutEndpoint = STRING_NAMEDCREDENTIALS+strEndpoint;
        String strSerializedBody;

        switch on strAccountGroup {
            when 'Ship-to' {
                strSerializedBody = PMC_CPIAccountCalloutUtilityClass.createShipToPayload(lstIds,JSONPayloadParams);
            }
            when 'Sold-to' {
                strSerializedBody = PMC_CPIAccountCalloutUtilityClass.createSoldToPayload(lstIds,JSONPayloadParams);
            }
            when 'Bill-to' {
                strSerializedBody = PMC_CPIAccountCalloutUtilityClass.createBillToPayload(lstIds,JSONPayloadParams);
            }
            when 'Payer' {
                strSerializedBody = PMC_CPIAccountCalloutUtilityClass.createPayerPayload(lstIds,JSONPayloadParams);
            }
        }		

        HttpResponse response = PMC_CPIAccountCalloutUtilityClass.sendCalloutRequest(STRING_METHOD, strCalloutEndpoint, strSerializedBody);
        if(response != null && STRING_INTERFACE == 'BPCreation')
        {
            PMC_CPIAccountIntegrationClass.parseJSONAccountInterface(EffectiveAccount, response, strEndpoint);
        }
        else if(response != null && STRING_INTERFACE == 'BPModification')
        {
            PMC_CPIAccountIntegrationClass.parseXMLAccountInterface(EffectiveAccount, response, strEndpoint);
        }
        else
        {   
            Boolean boolRetry = PMC_CPIAccountCalloutUtilityClass.autoRetryQueueableApex(AsyncInfo.getCurrentQueueableStackDepth(),PMC_CPQ_CPIRemoteCalloutUtilityClass.strExceptionMsg);
            PMC_CPIAccountIntegrationClass.updateAccountExceptionStatusMsg(EffectiveAccount, strEndpoint); 
            
            if(boolRetry)
            {
                System.enqueueJob(new PMC_CPI_AccountActionClass(EffectiveAccount, lstIds, strAccountGroup, STRING_INTERFACE, JSONPayloadParams));
            } 
        }
    }

    public class AccountActionRequest {
        @InvocableVariable(required=true)
        public Account inputAccount;
    
        @InvocableVariable(required=true)
        public String strAccountGroup;

        @InvocableVariable(required=true)
        public String strBPGrouping;

        @InvocableVariable(required=true)
        public String strPartnerFunction;

        @InvocableVariable(required=false)
        public String strTransportation;

        @InvocableVariable(required=false)
        public String strAcctAssmtGrpCust;
        
        @InvocableVariable(required=false)
        public String strCustomerTaxCategory;  
        
        @InvocableVariable(required=true)
        public String strEndpointName;     
        
        @InvocableVariable(required=false)
        public String strLanguage;   
        
        @InvocableVariable(required=false)
        public String strReconcAcc; 
        
        @InvocableVariable(required=false)
        public String strInvDates;   
        
        @InvocableVariable(required=false)
        public String strInvListSched;  
        
        @InvocableVariable(required=false)
        public String strCashPlanningGroup;   
        
        @InvocableVariable(required=false)
        public String strToleranceGroup;   
        
        @InvocableVariable(required=false)
        public Boolean boolRecordPmntHistory;   
        
        @InvocableVariable(required=false)
        public String strNaturalPerson;
        
        @InvocableVariable(required=false)
        public String strLayoutSortingRule;
        
        @InvocableVariable(required=false)
        public String strTaxClass;
        
        @InvocableVariable(required=false)
        public String strCNPJNumber;
        
        @InvocableVariable(required=false)
        public String strCPFNumber;
        
        @InvocableVariable(required=false)
        public String strRUCPYOrg;
        
        @InvocableVariable(required=false)
        public String strRUCPYPerson;
        
        @InvocableVariable(required=false)
        public String strSearchTerm1;
        
        @InvocableVariable(required=false)
        public String strDivision;
	}
}