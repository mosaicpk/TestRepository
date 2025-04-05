public class OpportunityTeamMemberTriggerHandler {
    public static void afterInsert(List<OpportunityTeamMember> newMembers) {
        /* POC purpose only can be deleted later CPQ- shashank
        List<Id> opportunityIds = new List<Id>();
        for (OpportunityTeamMember member : newMembers) {
            opportunityIds.add(member.OpportunityId);
        }
        
        List<SBQQ__Quote__c> quotesToUpdate = [SELECT Id,SBQQ__Opportunity2__c,ownerid  FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c  IN :opportunityIds];
        List<OpportunityShare> opportunityShares = new List<OpportunityShare>();
        
        for (SBQQ__Quote__c quote : quotesToUpdate) {
            OpportunityShare share = new OpportunityShare();
            quoteshare share2 = new quoteshare();
            share.OpportunityId = quote.SBQQ__Opportunity2__c ;
            share.UserOrGroupId = quote.OwnerId;
            share.OpportunityAccessLevel = 'Edit';
            opportunityShares.add(share);
        }
        insert opportunityShares; */
    }
}