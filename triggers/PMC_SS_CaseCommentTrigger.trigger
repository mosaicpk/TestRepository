/**
 * @description This trigger is created on Case Comment object.
 * @author Vedashri
 * @storynumber GDASF-1941
 */

trigger PMC_SS_CaseCommentTrigger on CaseComment (after insert) {
    //new PMC_CaseCommentTriggerHandler().run();
}