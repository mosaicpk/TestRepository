@isTest
private class PMC_CPI_AccountCreateActionClassTest {
    
    // Test Setup Method (Creates necessary test data)
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    }

    // Test for postInfoToCPI Method
    @isTest
    static void testPostInfoToCPI() {
        // Get the test account created in @testSetup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Create AccountActionRequest instance
        PMC_CPI_AccountCreateActionClass.AccountActionRequest request = new PMC_CPI_AccountCreateActionClass.AccountActionRequest();
        request.inputAccount = testAccount;
        request.strAccountGroup = 'Ship-to';

        // Create list of request parameters
        List<PMC_CPI_AccountCreateActionClass.AccountActionRequest> requestList = new List<PMC_CPI_AccountCreateActionClass.AccountActionRequest>{ request };

        // Start test execution
        Test.startTest();
        PMC_CPI_AccountCreateActionClass.postInfoToCPI(requestList);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'], 'Queueable job should be enqueued');
    }

    // Test for Queueable execute Method (Mocking Callout)
    @isTest
    static void testExecuteQueueable() {
        // Get the test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Create List of Ids
        List<Id> lstIds = new List<Id>{ testAccount.Id };

        // Define account group
        String strAccountGroup = 'Sold-to';

        // Create instance of Queueable class
        PMC_CPI_AccountCreateActionClass queueableJob = new PMC_CPI_AccountCreateActionClass(testAccount, lstIds, strAccountGroup);

        // Mock the callout response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Execute Queueable job
        System.enqueueJob(queueableJob);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'], 'Queueable job should have been enqueued');
    }
    
    // Mock Callout Class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "success"}');
            return res;
        }
    }
}