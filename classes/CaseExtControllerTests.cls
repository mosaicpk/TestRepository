@isTest
private class CaseExtControllerTests {
    
    testMethod static void testSubmit() {
        Case cse = new Case();
        insert cse;
        
        Test.startTest();
        CaseExtController con = new CaseExtController(new ApexPages.StandardController(cse));
        con.onSubmit();
        cse = [SELECT ApprovalStatus__c FROM Case WHERE Id = :cse.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', cse.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
        Case cse = new Case();
        insert cse;
        
        Test.startTest();
        CaseExtController con = new CaseExtController(new ApexPages.StandardController(cse));
        con.onRecall();
        cse = [SELECT ApprovalStatus__c FROM Case WHERE Id = :cse.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', cse.ApprovalStatus__c);
    }
}