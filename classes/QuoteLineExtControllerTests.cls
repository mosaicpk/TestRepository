@isTest
private class QuoteLineExtControllerTests {
    
    testMethod static void testSubmit() {
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        insert quoteLine;
        
        Test.startTest();
        QuoteLineExtController con = new QuoteLineExtController(new ApexPages.StandardController(quoteLine));
        con.onSubmit();
        quoteLine = [SELECT ApprovalStatus__c FROM SBQQ__QuoteLine__c WHERE Id = :quoteLine.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quoteLine.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        insert quoteLine;
        
        Test.startTest();
        QuoteLineExtController con = new QuoteLineExtController(new ApexPages.StandardController(quoteLine));
        con.onRecall();
        quoteLine = [SELECT ApprovalStatus__c FROM SBQQ__QuoteLine__c WHERE Id = :quoteLine.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', quoteLine.ApprovalStatus__c);
    }
}