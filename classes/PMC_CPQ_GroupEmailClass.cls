public without sharing class PMC_CPQ_GroupEmailClass {
    @InvocableMethod(label='send Approval Group Email2')
    public static void sendApprovalGroupEmail(List<Id> recordid) {
        // Query for the approval group members
        String groupid;
        List<Id> groupIDList = new List<Id>();
        List<sbaa__Approval__c> Groupids = [SELECT id,sbaa__Approver__r.sbaa__GroupId__c from sbaa__Approval__c WHERE id IN: recordid limit 1];
        
        if(Groupids[0].sbaa__Approver__r.sbaa__GroupId__c != null){
            groupid = Groupids[0].sbaa__Approver__r.sbaa__GroupId__c;
            groupIDList.add(groupid);
        }
        List<GroupMember> groupMembers = [SELECT GroupId,UserOrGroupId FROM GroupMember WHERE GroupId IN: groupIDList];
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
             
        // Iterate through the group members and send an email to each
        for (GroupMember groupMember : groupMembers) {
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate('00XDT000003qjWO',groupMember.UserOrGroupId , recordid[0]);
            
      		email.setTargetObjectId(groupMember.UserOrGroupId);
			email.setSaveAsActivity(false);
            emailMessages.add(email);
            
            

        }
           // Send the emails
        Messaging.sendEmail(emailMessages);
    }
}