@isTest
public class QuoteTriggerUpdateTest {
    @isTest
    static void testQuoteTrigger() {
        // Start test context
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        // Create a Contract record to be ussed in the test
        Contract testContract = new Contract(
            Name = 'Test Contract',
            Status = 'Draft',OwnerId = testUser.Id
        );
        insert testContract;
 
        // Verify the PMC_CPQ_Contract_Blocked__c field is false by default
        testContract = [SELECT Id, PMC_CPQ_Contract_Blocked__c FROM Contract WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.PMC_CPQ_Contract_Blocked__c, 'Initial value of PMC_CPQ_Contract_Blocked__c should be false.');
 
        // Create a Quote record and associate it with the Contract
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c( 
            SBQQ__Opportunity2__c = '006Ot000009JijKIAS',
            Contract_Blocked__c = testContract.Id,
            RecordTypeId = '012DT000003pPmoYAE');
        insert testQuote;
 
        // Verify that the Contract was updated by the trigger
        testContract = [SELECT Id, PMC_CPQ_Contract_Blocked__c FROM Contract WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.PMC_CPQ_Contract_Blocked__c, 'PMC_CPQ_Contract_Blocked__c should be updated to true.');
 
        // End test context
        Test.stopTest();
    }
}