/** This Class is made for the purpose of POC
 */
public class CPQB_ExtPricing implements Queueable, Database.AllowsCallouts{
    public List<SBQQ__Quote__c> lstQuotes;
    
    /** 
     * @description Constructor of the class. 
     * @param lstQuotes - list of quotes sent from the flow.
     */
    public CPQB_ExtPricing(List<SBQQ__Quote__c> lstQuotes)
    {
        this.lstQuotes = lstQuotes; 
    }
    
    /** 
     * @description This is the apex action that will be invoked from the flow.
     * @param lstQuotes - list of quotes sent from the flow.
     */
    @InvocableMethod(label='Approach Three' description='Triggers the CPI Interface to create quote, quote line and contract records in SAP' category='SBQQ__Quote__c')
  	public static void postInfoToCPI(List<SBQQ__Quote__c> lstQuotes) {
        for(SBQQ__Quote__c test : lstQuotes){
            System.debug('!!?!!' + test.Id	);
        }
        System.enqueueJob(new CPQB_ExtPricing(lstQuotes));
    }
    
    /** 
     * @description Makes a request to callout class.
     * @param context - Receives the context of the flow. In this case it is the list of quotes.
     */
    public void execute(QueueableContext context)
    {
        String strInterface = 'SAPQuoteandContractCreate';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        String strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
		PMC_CPQ_ExtPricingTest.makeCalloutRequest(lstQuotes,strEndpoint);
    } 
}