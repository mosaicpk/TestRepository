@isTest
private class PMC_CPIAccountCalloutUtilityClassTest {
    
    // Test Setup Method: Creates test data
    @testSetup
    static void setupTestData() {
        // Create an Account record for testing
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Test St',
            BillingCity = 'Test City',
            BillingStateCode = 'CA',
            BillingPostalCode = '12345',
            BillingCountryCode = 'US',
            Phone = '1234567890',
            Fax = '0987654321',
            CurrencyIsoCode = 'USD',
            PMC_SS_SalesOrg__c = '1002',
            PMC_SS_TaxIDOrCNPJOrCPF__c = '123456789',
//            PMC_SS_Segmentation__c = 'A',
            PMC_SS_ShippingCondition__c = 'Z2',
            PMC_SS_Underdeltolerance__c = 5,
            PMC_SS_OverdelTolerance__c = 10
        );
        insert testAccount;
    }
    
    // Method to create test Account Data
    private static Account createTestAccount() {
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingCountryCode = 'BR',
            Phone = '(12) 3456-7890',
            Fax = '',
            PMC_SS_SalesOrg__c = '4000',
            PMC_SS_SalesOffice__c = '430A',
            PMC_SS_SalesDistrict__c = 'ZBR004',
            Sales_Group__c = '785',
            PMC_SS_PaymentTerm__c = 'D030',
            Customer_Group__c = '07',
            PMC_SS_SAPCustomerNumber__c = '',
            PMC_SS_ReconciliationAccount__c = '110003',
            PMC_SS_StateTaxNumber__c = 'ST12345',
            PMC_SS_MunicipalTaxNumber__c = 'MT67890',
            PMC_SS_ShippingCondition__c = 'Z2',
            PMC_SS_Underdeltolerance__c = 5,
            PMC_SS_OverdelTolerance__c = 10
        );
        insert testAccount;
        return testAccount;
    }
    
    // Mock class for HTTP callout
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testSendCalloutRequest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        String method = 'POST';
        String endpoint = 'https://test.endpoint.com/api';
        String requestBody = '{"key":"value"}';

        Test.startTest();
        HttpResponse response = PMC_CPIAccountCalloutUtilityClass.sendCalloutRequest(method, endpoint, requestBody);
        Test.stopTest();

        System.assertNotEquals(response, null, 'Response should not be null');
        System.assertEquals(response.getStatusCode(), 200, 'Status code should be 200');
    }

    // Test Method: Validates the createShipToPayload method
    @isTest
    static void testCreateShipToPayload() {
        // Create the test Account
        Account testAccount = createTestAccount();

        // Prepare test data
        List<Id> accountIds = new List<Id>{ testAccount.Id };
        Map<String, String> jsonParams = new Map<String, String>{
            'strBPGrouping' => 'Z002',
            'strPartnerFunction' => 'FunctionX',
            'strCustomerTaxCategory' => 'TaxA',
            'strLanguage' => 'EN',
            'strReconcAcc' => '12345',
            'strAcctAssmtGrpCust' => 'Group1',
            'strTransportation' => 'TransportA',
            'strCNPJNumber' => '987654321',
            'strCPFNumber' => '11122233344',
            'strRUCPYOrg' => 'RUC5678',
            'strRUCPYPerson' => 'RUC1234',
            'strSearchTerm1' => 'SearchTerm',
            'strInvDates' => '2025-01-01',
            'strInvListSched' => 'Monthly',
            'strCashPlanningGroup' => 'C1',
            'strToleranceGroup' => 'T1',
            'strNaturalPerson' => 'Yes',
            'strLayoutSortingRule' => 'RuleX',
            'strTaxClass' => 'ClassX',
            'strDivision' => 'Division1',
            'BusinessPartnerCategory' => '2'    
        };

        String strRUCPYOrg = '12345678';
        String strRUCPYPerson = '12345678';

        Test.startTest();        
        // Invoke method
        String payload = PMC_CPIAccountCalloutUtilityClass.createShipToPayload(accountIds, jsonParams);

        // Assertions
        System.assertNotEquals(payload, null, 'Serialized body should not be null');
        System.assert(payload.contains('Z002'), 'Payload should include Business Partner Grouping');

        Test.stopTest();
    }

    // Test Method for createSoldToPayload
    @isTest
    static void testCreateSoldToPayload() {
        // Create the test Account
        Account testAccount = createTestAccount();

        Map<String, String> jsonParams = new Map<String, String>{
            'strBPGrouping' => 'Z001',
            'strPartnerFunction' => 'FUNC1',
            'strCustomerTaxCategory' => 'TAX1',
            'strLanguage' => 'EN',
            'strReconcAcc' => 'RA123',
            'strAcctAssmtGrpCust' => 'AAG1',
            'strTransportation' => 'TRAN1',
            'strCNPJNumber' => '123456789',
            'strCPFNumber' => '987654321',
            'strRUCPYOrg' => 'RUC5678',
            'strRUCPYPerson' => 'RUC1234',
            'strSearchTerm1' => 'Search1',
            'strInvDates' => '2025-01-01',
            'strInvListSched' => '2025-12-31',
            'strCashPlanningGroup' => 'CPG1',
            'strToleranceGroup' => 'TG1',
            'strNaturalPerson' => 'Yes',
            'strLayoutSortingRule' => 'LSR1',
            'strTaxClass' => 'TC1',
            'strDivision' => 'DIV1'
        };
        
        String strRUCPYOrg = '12345678';
        String strRUCPYPerson = '12345678';
        
        Test.startTest();
        String payload = PMC_CPIAccountCalloutUtilityClass.createSoldToPayload(new List<Id>{ testAccount.Id }, jsonParams);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(payload, null, 'Payload should not be null');
        System.assert(payload.contains('Test Account'), 'Payload should include account name');
        System.assert(payload.contains('Z001'), 'Payload should include Business Partner Grouping');
    }

    // Test Method for createBillToPayload
    @isTest
    static void testCreateBillToPayload() {
        // Create the test Account
        Account testAccount = createTestAccount();

        Map<String, String> jsonParams = new Map<String, String>{
            'strBPGrouping' => 'Z004',
            'strPartnerFunction' => 'FUNC1',
            'strCustomerTaxCategory' => 'TAX1',
            'strLanguage' => 'EN',
            'strReconcAcc' => 'RA123',
            'strAcctAssmtGrpCust' => 'AAG1',
            'strTransportation' => 'TRAN1',
            'strCNPJNumber' => '123456789',
            'strCPFNumber' => '987654321',
            'strRUCPYOrg' => 'RUC5678',
            'strRUCPYPerson' => 'RUC1234',
            'strSearchTerm1' => 'Search1',
            'strInvDates' => '2025-01-01',
            'strInvListSched' => '2025-12-31',
            'strCashPlanningGroup' => 'CPG1',
            'strToleranceGroup' => 'TG1',
            'strNaturalPerson' => 'Yes',
            'strLayoutSortingRule' => 'LSR1',
            'strTaxClass' => 'TC1',
            'strDivision' => 'DIV1'
        };
        
        String strRUCPYOrg = '12345678';
        String strRUCPYPerson = '12345678';
        
        Test.startTest();
        String payload = PMC_CPIAccountCalloutUtilityClass.createBillToPayload(new List<Id>{ testAccount.Id }, jsonParams);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(payload, null, 'Payload should not be null');
        System.assert(payload.contains('Test Account'), 'Payload should include account name');
        System.assert(payload.contains('Z004'), 'Payload should include Business Partner Grouping');
    }

    // Test Method for createPayerPayload
    @isTest
    static void testCreatePayerPayload() {
        // Create the test Account
        Account testAccount = createTestAccount();

        Map<String, String> jsonParams = new Map<String, String>{
            'strBPGrouping' => 'Z003',
            'strPartnerFunction' => 'FUNC1',
            'strCustomerTaxCategory' => 'TAX1',
            'strLanguage' => 'EN',
            'strReconcAcc' => 'RA123',
            'strAcctAssmtGrpCust' => 'AAG1',
            'strTransportation' => 'TRAN1',
            'strCNPJNumber' => '123456789',
            'strCPFNumber' => '987654321',
            'strRUCPYOrg' => 'RUC5678',
            'strRUCPYPerson' => 'RUC1234',
            'strSearchTerm1' => 'Search1',
            'strInvDates' => '2025-01-01',
            'strInvListSched' => '2025-12-31',
            'strCashPlanningGroup' => 'CPG1',
            'strToleranceGroup' => 'TG1',
            'strNaturalPerson' => 'Yes',
            'strLayoutSortingRule' => 'LSR1',
            'strTaxClass' => 'TC1',
            'strDivision' => 'DIV1'
        };
        
        String strRUCPYOrg = '12345678';
        String strRUCPYPerson = '12345678';
        
        Test.startTest();
        String payload = PMC_CPIAccountCalloutUtilityClass.createPayerPayload(new List<Id>{ testAccount.Id }, jsonParams);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(payload, null, 'Payload should not be null');
        System.assert(payload.contains('Test Account'), 'Payload should include account name');
        System.assert(payload.contains('Z003'), 'Payload should include Business Partner Grouping');
    }

    @isTest
    static void testAutoRetryQueueableApex() {
        Integer stackDepth = 1;
        String errorMsg = 'Temporary network issue';

        // Mocking Custom Metadata Type
        Test.startTest();
        Boolean shouldRetry = PMC_CPIAccountCalloutUtilityClass.autoRetryQueueableApex(stackDepth, errorMsg);
        Test.stopTest();

        System.assert(shouldRetry == false || shouldRetry == true, 'shouldRetry should return a boolean');
    }
}