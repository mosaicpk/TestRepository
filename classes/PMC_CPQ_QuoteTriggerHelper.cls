/**
* @description This class will be used to handle all triggers on Quote (SBQQ__Quote__c) object.
* @author Lalit Sharma
* @storynumber : GDASF-8944
*/
public with sharing class PMC_CPQ_QuoteTriggerHelper {
    
    //This takes all available Quote fields from the required object. 
      Private static Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.SBQQ__Quote__c.fields.getMap(); 
    //This hold the profile Name of the current context user
      Private static String profileName;
    //This hold boolean to cover exception from test class
    @TestVisible private static Boolean testException= false;
    /**
* @description This method will be used to validate during primmary field updation of Expired Quote records.
* @param lstTriggeringNewQuotes - List of Quotes that trigger the validation method.
* @param mapTriggeringOldQuote - Map datatype of list of Quotes that triggered the validation method's old value.
*/
    public static void validateQuoteExpiration(List<SBQQ__Quote__c> lstTriggeringNewQuotes, Map<Id, SBQQ__Quote__c> mapTriggeringOldQuote){
        
        try{
            exceptionCheckvalidateQuoteExpiration();
            //Get the logged in user profile Name
            Id profileId=userinfo.getProfileId();
            profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            //Get the Quote fields to bypass below error message logic
            Map<String,String> mapBypassFieldForExpirationValidation = new Map<String,String>();
            for(String str : System.Label.PMC_CPQ_BypassFieldForQuoteExpirationValidation.split(';')){
                mapBypassFieldForExpirationValidation.put(str, str);
            }

            
            for(SBQQ__Quote__c objQuote : lstTriggeringNewQuotes){
                
                validateQuoteValuesChange(objQuote,mapTriggeringOldQuote,mapBypassFieldForExpirationValidation);
                
            }
        } catch (QueryException objQueryException) {
            PMC_ErrorLogClass.processException(objQueryException);
        }      
   }
   /**
* @description This method is used to check Exception triggered from test class to cover Query Exception on method validateQuoteExpiration
*/ 
    private static void exceptionCheckvalidateQuoteExpiration(){
        if(testException){
                throw new QueryException();
            }
    }
   /**
* @description This method is used to Validate the expired quote value change conditions.
  @param objQuote - current quote object of iteration to compare values.
  @param mapTriggeringOldQuote - Map list of old values of quotes.
  @param mapBypassFieldForExpirationValidation - Map list of fields should be bypassed for validation error.
*/  
    
    private static void validateQuoteValuesChange(SBQQ__Quote__c objQuote,Map<Id,SBQQ__Quote__c>mapTriggeringOldQuote,Map<String,String> mapBypassFieldForExpirationValidation ){
        
        if(mapTriggeringOldQuote.get(objQuote.Id).get('PMC_CPQ_FlowVRByPassToggle__c')!=objQuote.get('PMC_CPQ_FlowVRByPassToggle__c')){
            	return;
                }
                if( mapTriggeringOldQuote.get(objQuote.Id).get('SBQQ__Status__c')=='Expired' ){
                    for (String str : schemaFieldMap.keyset()) { 
                        
                        //Condition to check profile and dymanic Quote fields to throw the exception 
                        if(profileName != 'System Administrator' && str != mapBypassFieldForExpirationValidation.get(str) && objQuote.get(str) != mapTriggeringOldQuote.get(objQuote.Id).get(str)){ 
                            //Throw exception to user about Expiration validation Message
                            objQuote.addError(System.Label.PMC_CPQ_QuoteExpirationValidationMessage);
          
                        }
                        
                        
                    } 
                }
    }

    /**
    * @description This method is used to clear the SAP Original Contract field while clonning a Quote when this field has a value.
    @param newQuotes - Map list of new values of quotes.
    */  
    public static void clearLegacyQuoteIdWhileClonning(List<SBQQ__Quote__c> newQuotes){
        for(SBQQ__Quote__c quoteRecord: newQuotes){
            if(quoteRecord.PMC_CPQ_IsCloned__c){
                quoteRecord.PMC_CPQ_LegacyQuoteID__c = null;
            }
        }
    }
}