public class CustomSettingsUtility {
     @InvocableMethod(label='Get Process Switch')
     public static List<String> getAccountNames(List<String> name) {
     	List<String> accountNames = new List<String>();
        List<PMC_ProcessSwitches__c> swtch = [select Id,PMC_BypassValidationRule__c  from PMC_ProcessSwitches__c where PMC_BypassValidationRule__c = true and  SetupOwnerId =:UserInfo.getUserId ()] ;
		system.debug(swtch);
        if(swtch.size()>0){
          	if(swtch[0].PMC_BypassValidationRule__c){
            	swtch[0].PMC_BypassValidationRule__c = false;
            	update swtch;
        
         	 }else{
           		swtch[0].PMC_BypassValidationRule__c = false;
            	update swtch;      
         	}
        }
		system.debug(swtch);
           
        return accountNames;
    }
}