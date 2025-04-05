/**
* @description This class will be used to handle all triggers on Case object.
* @author Sayali Shinde
* @storynumber GDASF-1941
*/

public without sharing class PMC_CaseTriggerHelperFFLib {

        //Variable to cover the exception part
    @testVisible
    private static Boolean boolThrowException = false;
    
    /**
	* @description Wrapper class to hold & pass the notification related parameters.
	*/
    public class PMC_NotificationWrapper {
        
        Id idNotificationType;
        String strBody; 
        String strTitle;
        /**
		* @description This is wrapper constructor to pass notification related parameters.
		* @param idNotificationType - Custom Notification Type Id
		* @param strBody - Notification Body
		* @param strTitle - Notification Title
		*/
        public PMC_NotificationWrapper(Id idNotificationType, String strBody, String strTitle) {
            this.idNotificationType = idNotificationType;
            this.strBody = strBody; 
            this.strTitle = strTitle;
        }
    }
    
    /**
    * @description This method will be used to update the Case priority on cases.
    * @param lstNewCases - List of triggering case records.
    */
    
    public static void updateCasePriority(List<Case> lstNewCases) {
        
        try {
            
            Set<Id> setAccountIds = new Set<Id>();
            Map<Id, String> mapContactAccountIds = new Map<Id, String>();
            
            for(Case objCase : lstNewCases) {
                
                if(objCase.AccountId != null){
                    setAccountIds.add(objCase.AccountId);
                }
                else if(objCase.ContactId != null) {
                    mapContactAccountIds.put(objCase.ContactId,'');
                }
            }
            
            for(Contact objContact : PMC_ContactSelector.newInstance().getContactsById(mapContactAccountIds.keySet())) {
                mapContactAccountIds.put(objContact.Id, objContact.AccountId);
            }
            
            Map<String, Account> mapAccounts = new Map<String, Account>(PMC_AccountSelector.newInstance().getAccountsById(setAccountIds, mapContactAccountIds.values()));
            
            checkAndAssignPriorityToCase(lstNewCases, mapAccounts, mapContactAccountIds);
        }
        catch(QueryException objQueryException) {
            PMC_ErrorLogClass.processException(objQueryException);
        }
    }

    /**
    * @description This method will be used to check the case type and retrieve the corresponding Case priority on cases.
    * @param lstNewCases - List of triggering case records.
    * @param mapAccounts - Map of Account Id & Account Record
    * @param mapContactAccountIds - Map of Contact Id & associated Account Id
    */

    public static void checkAndAssignPriorityToCase(List<Case> lstNewCases, Map<String, Account> mapAccounts, Map<Id, String> mapContactAccountIds) {

        Map<String, PMC_SS_CasePriorityAssignment__mdt> mapCasePriorityAssignments = getCasePriorityAssignments();

        for(Case objCase : lstNewCases) {
            String strKey = objCase.AccountId != null && mapAccounts.containsKey(objCase.AccountId) ? objCase.Type + '_' + mapAccounts.get(objCase.AccountId).PMC_SS_Segmentation__c : 
            objCase.ContactId != null && mapAccounts.containsKey(mapContactAccountIds.get(objCase.ContactId)) ? objCase.Type + '_' + mapAccounts.get(mapContactAccountIds.get(objCase.ContactId)).PMC_SS_Segmentation__c : '';

            if(objCase.Type == PMC_SS_ConstantClass.INTERNAL_REQUEST && objCase.PMC_SS_IssueReason__c == PMC_SS_ConstantClass.ADDRESS_CREATION_UPDATE) {
                objCase.Priority = PMC_SS_ConstantClass.HIGH;
            }
            else {
                objCase.Priority = mapCasePriorityAssignments.containsKey(strKey) ? mapCasePriorityAssignments.get(strKey).PMC_SS_Priority__c : PMC_SS_ConstantClass.LOW;
            }
        } 

    }
    
    /**
    * @description This method will be used to retrieve Custom Metadata.
    * @return Map<String, PMC_SS_CasePriorityAssignment__mdt> where record's Master Label is key and record is value
    */
    
    public static Map<String, PMC_SS_CasePriorityAssignment__mdt> getCasePriorityAssignments() {
        
        Map<String, PMC_SS_CasePriorityAssignment__mdt> mapCasePriorityAssignments = new Map<String, PMC_SS_CasePriorityAssignment__mdt>();

        for(PMC_SS_CasePriorityAssignment__mdt objCasePriorityDetails : PMC_CasePriorityAssignmentSelector.newInstance().getCasePriorityAssignmentMetadata()) {
            mapCasePriorityAssignments.put(objCasePriorityDetails.MasterLabel, objCasePriorityDetails);
        }
        
        return mapCasePriorityAssignments;
    }
    

    /**
    * @description This method will be used to calculate business days post case closure.
    * @param mapOldCases - Map of old values of case records.
    * @param lstNewCases - List of triggering case records.
    */

    public static void checkBusinessDaysOnCaseReOpen(Map<Id, Case> mapOldCases, List<Case> lstNewCases) {
            
        try {
            BusinessHours objBusinessHrs = PMC_BusinessHoursSelector.newInstance().getDefaultBusinessHour();
            
            for(Case objCase : lstNewCases) {

                if(objCase.Status == PMC_SS_ConstantClass.RE_OPEN && mapOldCases.get(objCase.Id).Status == PMC_SS_ConstantClass.CLOSED) 
                {
                    validateReopenTimeFrame(objCase,mapOldCases.get(objCase.Id),objBusinessHrs);
                }
            }
        }
        catch(QueryException objQueryException) {
            PMC_ErrorLogClass.processException(objQueryException);
        }
    }

    /**
    * @description This method will be used to update the isEscalated flag on cases.
    * @param  objNewCase - Triggering case record.
    * @param  objOldCase - Old Case record values
    * @param  objBusinessHrs - Default Business Hours
    */
    public static  void validateReopenTimeFrame(Case objNewCase, Case objOldCase, BusinessHours objBusinessHrs) {
        Id idBusinessHrs = objNewCase.BusinessHoursId != null ? objNewCase.BusinessHoursId : objBusinessHrs.Id;
                                    
        DateTime dateTimeExpectedReOpenDate = BusinessHours.addGmt(idBusinessHrs, objOldCase.ClosedDate, PMC_SS_ConstantClass.RE_OPEN_DATE_FORMULA);
        
        if(System.now() > dateTimeExpectedReOpenDate || (Test.isRunningTest() && boolThrowException)) {
            objNewCase.addError(Label.PMC_SS_ReopenPeriodForClosedCase);
            return;
        }
        else if(UserInfo.getUserId() != objOldCase.OwnerId) {
            objNewCase.OwnerId = UserInfo.getUserId();
        }
    }
    
    
    /**
    * @description This method will be used to update the isEscalated flag on cases.
    * @param mapOldCases - Map of old values of case records.
    * @param lstNewCases - List of triggering case records.
    */
    
    public static void updateIsEscalatedFlag(Map<Id, Case> mapOldCases, List<Case> lstNewCases) {
            
        for(Case objCase : lstNewCases) {
            
            if(mapOldCases != null) {
               
                if(objCase.Status == PMC_SS_ConstantClass.ESCALATED && mapOldCases.get(objCase.Id).Status != PMC_SS_ConstantClass.ESCALATED) {
                    objCase.IsEscalated = true;
                }
                else if(objCase.Status != PMC_SS_ConstantClass.ESCALATED && mapOldCases.get(objCase.Id).Status == PMC_SS_ConstantClass.ESCALATED) {
                    objCase.IsEscalated = false;
                }
            }
            else {
                objCase.IsEscalated = objCase.Status == PMC_SS_ConstantClass.ESCALATED ? true : false;
            }
        }
    }
}