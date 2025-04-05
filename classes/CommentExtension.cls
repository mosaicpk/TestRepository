public class CommentExtension {
    public String comment { get; set; }
    private sbaa__Approval__c approvalRequest;

    public CommentExtension(ApexPages.StandardController controller) {
        approvalRequest = (sbaa__Approval__c)controller.getRecord();
    }

     public void submitComment() {
        approvalRequest.sbaa__CommentsLong__c = comment;
        update approvalRequest;
    }
        // Additional logic or actions after submitting the comment can be added here
    
}