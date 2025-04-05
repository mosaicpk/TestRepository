public class PMC_SS_GetContact {
@InvocableMethod(label='GetContacts' description='it will get contact records ')
public static List<Contact> getContactRecords() {
        List<Contact> contactRecords = [SELECT Id,Phone FROM Contact];
     system.debug(contactRecords);
        return contactRecords;
     
    }
}