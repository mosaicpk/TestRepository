/**
* @description This class will be used call PMC_SS_DeleteDuplicatePartnersSchedule and used delete duplicate Account
  Partner Relationship records 
* @author Chetna
* @storynumber GDASF-21683
*/
public without sharing class PMC_SS_DeleteDuplicatePartnersSchedule implements Schedulable{
    /**
     * @description This method will be used call PMC_SS_DeleteDuplicatePartnersSchedule and used delete duplicate
     * Account Partner Relationship records
    * @param objScheduleContext - this object is used to track batch process 
    */
    public void execute(SchedulableContext objScheduleContext) {
       PMC_SS_DeleteDuplicatePartnersBatch objBatch = new PMC_SS_DeleteDuplicatePartnersBatch(); 
       Database.executeBatch(objBatch,200);
    }
}