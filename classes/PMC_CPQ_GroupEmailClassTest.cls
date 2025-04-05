@isTest
public class PMC_CPQ_GroupEmailClassTest {
    @isTest
    public static void testSendApprovalGroupEmail() {
        // Create test data
        Group testGroup = new Group(Name = 'Test Group');
        insert testGroup;

        User testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@test.com',
            Alias = 'johndoe',
            Username = 'johndoe123@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;

        GroupMember testGroupMember = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = testUser.Id
        );
        insert testGroupMember;

        sbaa__Approval__c testApproval = new sbaa__Approval__c(
            sbaa__Approver__c = testGroupMember.Id,
            sbaa__ApprovalStep__c=1,
            sbaa__RecordField__c='Quote__c'
            // Add any other required fields for sbaa__Approval__c
        );
        insert testApproval;
       
       
      

        List<Id> recordIds = new List<Id>{ testApproval.Id };

        // Call the method to be tested
        Test.startTest();
        PMC_CPQ_GroupEmailClass.sendApprovalGroupEmail(recordIds);
        Test.stopTest();

       
        // Add more assertions as needed
    }
}