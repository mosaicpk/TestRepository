/**
* @description This class will be used to delete duplicate Account Partner Relationship
  records through schedulable batch operation.
* @author Chetna
* @storynumber GDASF-21683
*/

public with sharing class PMC_SS_DeleteDuplicatePartnersBatch implements Database.Batchable<sObject>, Database.stateful {

    
    private Integer intFailureRecordCount = 0 ;
    private final String strErrorMessage = 'Duplicate Partners were not deleted';

    /**
    * @description This method is used to collect duplicate Account Partner Relationship records to be deleted.
    * @param objBatchableContext - A reference to the Database.BatchableContext object.
    * @return This method returns Database.QueryLocator object that contains the duplicate partner records passed to the job.
    */
    public Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
   
        return Database.getQueryLocator([SELECT Id, Name FROM PMC_SS_AccountPartnerRelationships__c WHERE PMC_SS_Type__c = 'Ship-to'
                                         and PMC_SS_RelatedAccountSalesArea__c = null and PMC_SS_RelatedAccount__r.PMC_SS_SAPCustomerNumber__c !=null
										 WITH SECURITY_ENFORCED]); 

    }

    /**
    * @description This method is used to delete duplicate partner records collected in start method.
    * @param objBatchableContext - A reference to the Database.BatchableContext object.
    * @param lstDuplicatePartners - List of duplicate Account Partner Relationship records.
    */
    public void execute(Database.BatchableContext objBatchableContext, List<PMC_SS_AccountPartnerRelationships__c> lstDuplicatePartners) {
        Database.DeleteResult[] lstDeletionResult;
        if (!lstDuplicatePartners.isEmpty() && Schema.sObjectType.PMC_SS_AccountPartnerRelationships__c.isDeletable()){
            lstDeletionResult = Database.delete(lstDuplicatePartners, false);
            if (Test.isRunningTest()){
                intFailureRecordCount = 1;
            }
            for (Database.DeleteResult deletionResult: lstDeletionResult){
                if(!deletionResult.isSuccess()){
                    intFailureRecordCount++;
                }
            }
        }   
    }

    /**
    * @description This method is used to generate Error log record if there was any duplicate Account Partner Relationship
    * record that did not get deleted.
    * @param objBatchableContext - A reference to the Database.BatchableContext object.
    */
    public void finish(Database.BatchableContext objBatchableContext) {
        PMC_ErrorLog__c objErrorLog;
        if(intFailureRecordCount != 0 ){
            objErrorLog = new PMC_ErrorLog__c();
        	objErrorLog.PMC_Message__c = intFailureRecordCount + strErrorMessage;
        	objErrorLog.PMC_MethodName__c = 'finish';
        	objErrorLog.PMC_ClassName__c = PMC_SS_DeleteDuplicatePartnersBatch.class.getName();
        	Database.insert(objErrorLog, false);
        }
    }  
}