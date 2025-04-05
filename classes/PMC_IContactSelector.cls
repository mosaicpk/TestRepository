/**
* @description This is a interface, will be used to declare PMC_ContactSelector method
* @author Sayali Shinde
*/

public interface PMC_IContactSelector extends fflib_ISObjectSelector {
	List<Contact> getContactsById(Set<Id> setId);
}