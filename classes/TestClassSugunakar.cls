@isTest
public without sharing class TestClassSugunakar {
    @isTest(SeeAllData=TRUE)
    public static void testData(){
        User u= [SELECT Id,AccountId,Name,LastLoginDate from User Where isActive=TRUE  AND Name LIKE '%Alice Santos%'  Order By CreatedDate DESC LIMIT 1];
         System.debug(u);
         List<User> ss = [Select Id,Email, ContactId, Profile.Name from user
                            where Profile.Name=:PMC_DH_ConstantClass.PROFILE_NAME];
            System.debug(ss);
         System.debug(ss.size());
        System.debug(u.name);
       
        System.runAs(u){ 
            
            Map<ID,User> mapOwnerIDsWithRoleName = new Map<ID,User>([SELECT Id,UserRole.Name FROM User WHERE Id IN (SELECT PMC_DH_DealOwner__c FROM Lead)]);
System.debug('mapOwnerIDsWithRoleName'+mapOwnerIDsWithRoleName);
           List<User> objUserList = new list<User>();
            
            SObjectAccessDecision decision = Security.stripInaccessible(
                                               AccessType.READABLE,
                                               objUserList);
        // Print stripped records
         System.debug('PMC_SS_AccountPartnerRelationships__c record access: '+Schema.sObjectType.PMC_SS_AccountPartnerRelationships__c.isCreateable());
           
        for (Integer i = 0; i < objUserList.size(); i++) {
              System.debug('Insecure record access: '+objUserList[i]);
              System.debug('Secure record access: '+decision.getRecords()[i]);
            
        }
        // Print modified indexes
        System.debug('Records modified by stripInaccessible: '+decision.getModifiedIndexes());
        }

    }

 
}