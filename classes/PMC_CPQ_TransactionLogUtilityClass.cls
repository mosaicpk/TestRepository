/** @description This is a utility class for transaction logs.
 *  @author Shefali Dsouza
 *  @storynumber GDASF-2983
 */
public without sharing class PMC_CPQ_TransactionLogUtilityClass {
    
    public static List<PMC_CPQ_TransactionLog__c> lstTransactionLogs = new List<PMC_CPQ_TransactionLog__c>();
    /** 
     * @description This class is used to add a trasaction log to the list of transaction logs.
     * @param mapTransactionLogFields - Send integration fields. 
     * @return lstTransactionLogs - Add to list of transaction logs.
     */
    public static List<PMC_CPQ_TransactionLog__c> addTransactionLog(Map<String, String> mapTransactionLogFields)
    {
        PMC_CPQ_TransactionLog__c trl = new PMC_CPQ_TransactionLog__c();
        trl.PMC_CPQ_IntegrationStatus__c = mapTransactionLogFields.get('PMC_CPQ_IntegrationStatus__c');
        trl.PMC_CPQ_InterfaceURL__c = mapTransactionLogFields.get('PMC_CPQ_InterfaceURL__c');
        trl.PMC_CPQ_RequestBody__c = mapTransactionLogFields.get('PMC_CPQ_RequestBody__c');
        trl.PMC_CPQ_ResponseBody__c = mapTransactionLogFields.get('PMC_CPQ_ResponseBody__c').abbreviate(131065);
        lstTransactionLogs.add(trl);
        return lstTransactionLogs;
    }
     /** 
     * @description This class is used to insert the transaction log.
     * @param lstTransactionLogs - List of transaction logs
     */
    public static void insertTransactionLogs(List<PMC_CPQ_TransactionLog__c> lstTransactionLogs)
    {
        SObjectAccessDecision securityDecisionTrl = Security.stripInaccessible(AccessType.CREATABLE, lstTransactionLogs);
        Database.insert(securityDecisionTrl.getRecords(),false);
    }   
}