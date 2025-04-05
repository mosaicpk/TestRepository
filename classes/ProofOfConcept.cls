public without sharing class ProofOfConcept {

  // comment
  @AuraEnabled
  public static List<Case> getCaseList(){
    List<Case> lstCases = new List<Case>();
    try {
        lstCases=[Select Id,CaseNumber,CreatedDate,Subject from Case];
        return lstCases;
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
  }
   
}