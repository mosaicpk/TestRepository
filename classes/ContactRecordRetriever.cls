public with sharing class ContactRecordRetriever {
    public static List<Contact> getContactRecords() {
        List<Contact> contactRecords = [SELECT Id, Name, Email, Phone FROM Contact];
        return contactRecords;
        
    }
    
}