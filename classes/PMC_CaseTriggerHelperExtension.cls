/**
* @description This class will be used to handle all triggers on Case object.
* @storynumber GDASF-1706
*/
public with sharing class PMC_CaseTriggerHelperExtension {

    /**
    * @description This method will be used to update the isEscaCase Type based on Case Subject.
    * @param lstNewCases - List of triggering case records.
    */
    public static void updateCaseTypebasedOnSubject(List<Case> lstNewCases) {
        System.debug(LoggingLevel.FINE, 'Starting updateCaseTypebasedOnSubject method');
        
        try {
            List<Case> lstCaseFromEmail = new List<Case>();

            for(Case objCase : lstNewCases) {
                if(objCase.Origin == PMC_SS_ConstantClass.CASE_ORIGIN_EMAIL && String.isNotBlank(objCase.Subject)) {
                    lstCaseFromEmail.add(objCase);
                }
            }

            System.debug(LoggingLevel.FINE, 'Cases from Email: ' + lstCaseFromEmail);

            if(!lstCaseFromEmail.isEmpty()) {
                List<PMC_SS_CaseSubjectToType__mdt> lstCaseSubjectToType = [SELECT MasterLabel, PMC_SS_CaseType__c FROM PMC_SS_CaseSubjectToType__mdt WITH SECURITY_ENFORCED];

                for(Case objCase : lstCaseFromEmail) {
                    setCaseTypebasedOnSubject(objCase, lstCaseSubjectToType);                                       
                }
            }
        } catch(Exception objQueryException) {
            System.debug(LoggingLevel.ERROR, 'Exception in updateCaseTypebasedOnSubject: ' + objQueryException);
            PMC_ErrorLogClass.processException(objQueryException);
        }
    }

    /**
    * @description This method will be used to update the isEscaCase Type based on Case Subject.
    * @param objCase - Triggering case records.
    * @param lstCaseSubjectToType - List of case Type assignment metadata
    */
    public static void setCaseTypebasedOnSubject(Case objCase, List<PMC_SS_CaseSubjectToType__mdt> lstCaseSubjectToType) {
        System.debug(LoggingLevel.FINE, 'Starting setCaseTypebasedOnSubject method');
        
         // GSMD- 1446
         String subject = objCase.Subject != null ? objCase.Subject.toLowerCase() : '';
         String description = objCase.Description != null ? objCase.Description.toLowerCase() : '';
            // === Special phrase match logic (subject OR description) ===
         Boolean hasCadastro = subject.contains('Cadastro') || description.contains('Cadastro');
         Boolean hasMaterial = subject.contains('Material') || description.contains('Material');
         Boolean hasLimite = subject.contains('Limite') || description.contains('Limite');
         Boolean hasCredito = subject.contains('Credito') || description.contains('Credito');
         Boolean hasRenovacao = subject.contains('Renovação') || description.contains('Renovação');
         Boolean hasNota = subject.contains('Nota') || description.contains('Nota');
             // === Internal Rules ===
              if ((hasCadastro && hasMaterial) ||(hasLimite && hasCredito) ||(hasRenovacao && hasCredito)) {
                     objCase.Type = 'Internal';
              System.debug(LoggingLevel.FINE, 'Case Type set to Internal based on special phrase combination');
              return;
   }
                    // === Transaction Rule ===
                  if (hasNota && hasCredito) {
                   objCase.Type = 'Transactions';
                 System.debug(LoggingLevel.FINE, 'Case Type set to Transaction based on Nota + Credito rule');
                   return;
   }
        
       
        for(PMC_SS_CaseSubjectToType__mdt objCaseSubjectByType : lstCaseSubjectToType) {
            if(objCase.Subject.containsIgnoreCase(objCaseSubjectByType.MasterLabel)) {
                objCase.Type = objCaseSubjectByType.PMC_SS_CaseType__c;
                System.debug(LoggingLevel.FINE, 'Case Type set to: ' + objCase.Type);
                break;
            }
            //Added for GSMD-212
            Else if(objCase.Description.containsIgnoreCase(objCaseSubjectByType.MasterLabel)) {
                objCase.Type = objCaseSubjectByType.PMC_SS_CaseType__c;
                System.debug(LoggingLevel.FINE, 'Case Type set to: ' + objCase.Type);
                break;
            }
        }
        
        if(String.isBlank(objCase.Type)) {
            objCase.Type = PMC_SS_ConstantClass.CASETYPE_OTHER;
            System.debug(LoggingLevel.FINE, 'Case Type set to other as no match found');
        }
    }

    /**
    * @description This method will be used to update the isEscalated flag on cases.
    * @param mapOldCases - Map of old values of case records.
    * @param lstNewCases - List of triggering case records.
    */
    public static void updateIsEscalatedFlag(Map<Id, Case> mapOldCases, List<Case> lstNewCases) {
        System.debug(LoggingLevel.FINE, 'Starting updateIsEscalatedFlag method');
            
        for(Case objCase : lstNewCases) {
            if(mapOldCases != null) {
                if(objCase.Status == PMC_SS_ConstantClass.ESCALATED && mapOldCases.get(objCase.Id).Status != PMC_SS_ConstantClass.ESCALATED) {
                    objCase.IsEscalated = true;
                } else if(objCase.Status != PMC_SS_ConstantClass.ESCALATED && mapOldCases.get(objCase.Id).Status == PMC_SS_ConstantClass.ESCALATED) {
                    objCase.IsEscalated = false;
                }
            } else {
                objCase.IsEscalated = objCase.Status == PMC_SS_ConstantClass.ESCALATED ? true : false;
            }

            System.debug(LoggingLevel.FINE, 'Case IsEscalated set to: ' + objCase.IsEscalated);
        }
    }

    /**
    * @description This method will populate Web Email and Web Name on Case when Type is Internal and Issue Reason is Article Request
    * @param lstNewCases - List of triggering case records.
    */
    public static void updateWebEmailandWebName(List<Case> lstNewCases) {
        System.debug(LoggingLevel.FINE, 'Starting updateWebEmailandWebName method');
            
        for(Case objCase : lstNewCases) {
            if(objCase.Type == PMC_SS_ConstantClass.INTERNAL && objCase.PMC_SS_IssueReason__c == PMC_SS_ConstantClass.ARTICLE_REQUEST) {
                objCase.SuppliedEmail = UserInfo.getUserEmail();
                objCase.SuppliedName = UserInfo.getName();
                System.debug(LoggingLevel.FINE, 'Updated Case SuppliedEmail: ' + objCase.SuppliedEmail + ', SuppliedName: ' + objCase.SuppliedName);
            }
        }
    }

    /**
    * @description This method will be used to route a Case to Quality Team for inspection.
    * @param mapOldCases - A map of previous version of Case records.
    * @param lstNewCases - List of updated Case records.
    */
    public static void updateCaseOwnerBasedOnRouteToQuality(Map<Id, Case> mapOldCases, List<Case> lstNewCases) {
        System.debug(LoggingLevel.FINE, 'Starting updateCaseOwnerBasedOnRouteToQuality method');

        List<Case> lstCasesToRoute = new List<Case>();
        for(Case objCase : lstNewCases) {
            if(mapOldCases.get(objCase.Id).PMC_SS_RouteToQuality__c != true && objCase.PMC_SS_RouteToQuality__c == true) {
                lstCasesToRoute.add(objCase);
            }
        }

        System.debug(LoggingLevel.FINE, 'Cases to route to Quality: ' + lstCasesToRoute);

        if(lstCasesToRoute != null) {
            Group objQueue = [SELECT Id, Name, DeveloperName, Email, Type FROM Group WHERE Type = :PMC_SS_ConstantClass.QUEUE AND DeveloperName = :PMC_SS_ConstantClass.QUEUE_DEVNAME WITH SECURITY_ENFORCED LIMIT 1];
            for(Case objCaseToRoute : lstCasesToRoute) {
                objCaseToRoute.OwnerId = objQueue.Id;
                System.debug(LoggingLevel.FINE, 'Case Owner updated to Quality Queue: ' + objQueue.Id);
            }
        }
    }  
}