public class Unlockcase {
     @InvocableMethod (label='Unlock Case')

        public Static void UnlockCase(List<Id> lstCaseIds){
            
         for (Case objCaseToLock : [Select Id, CaseNumber from Case where id =:lstCaseIds WITH SECURITY_ENFORCED])
         {
             
            Approval.Unlock(objCaseToLock.id);
  
         }

}

}