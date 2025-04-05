public class lockcase{
    
     @InvocableMethod (label='Lock Case')

        public Static void lockCase(List<Id> lstCaseIds){
            
         for (Case objCaseToLock : [Select Id, CaseNumber from Case where id =:lstCaseIds WITH SECURITY_ENFORCED])
         {
             
            Approval.lock(objCaseToLock.id);
                     }
            

    }
        
    
}