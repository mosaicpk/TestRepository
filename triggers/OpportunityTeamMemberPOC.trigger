trigger OpportunityTeamMemberPOC on OpportunityTeamMember (after insert) {
    OpportunityTeamMemberTriggerHandler.afterInsert(Trigger.new);
}