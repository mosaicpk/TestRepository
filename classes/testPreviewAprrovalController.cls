public class testPreviewAprrovalController {
    private Id quoteId;
    public testPreviewAprrovalController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }
    
    public PageReference PreviewApprovals(){
        DateTime datTSubmission = system.now();
        Time timeSubmissionTime = datTSubmission.Time();
        PageReference p = new PageReference('/apex/sbaa__PreviewApprovals?Id={!SBQQ__Quote__c.Id}');
        p.setRedirect(true);
        /*if((datTSubmission.format('EEEE')=='Wednesday' && timeSubmissionTime.hour() >= 17) || datTSubmission.format('EEEE')=='Saturday' || datTSubmission.format('EEEE')=='Sunday'){
            hide = true;
            p = null;
        }
        else{
            p = new PageReference('/apex/PreviewApprovals');
            p.setRedirect(true);
        }*/
        return p;
    }
}