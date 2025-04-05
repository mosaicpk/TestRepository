public with sharing class MassApprovalVFController {
    public List<SBAA__Approval__c> approvals { get; set; }
    public Boolean processing { get; set; }
    public Boolean redirect { get; set; }

    public MassApprovalVFController(ApexPages.StandardSetController controller) {
        this.approvals = (List<SBAA__Approval__c>) controller.getSelected();
        this.processing = true;
        this.redirect = false;

        approveSelected();
    }

    public PageReference approveSelected() {
        for (SBAA__Approval__c app : approvals) {
            app.sbaa__Status__c = 'Approved';
        }

        update approvals;
        processing = false;
        redirect = true; // ativa o redirecionamento

        return null;
    }

    public String getRedirectUrl() {
        // Exemplo: redireciona para a list view padrão do objeto
        return URL.getOrgDomainUrl().toExternalForm() + '/lightning/o/SBAA__Approval__c/list?filterName=Recent';
    }
}