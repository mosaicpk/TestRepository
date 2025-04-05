/**
* @description This is a interface, will be used to declare PMC_ContactSelector method
* @author Sayali Shinde
*/

public interface PMC_IAccountSelector extends fflib_ISObjectSelector {
	List<Account> getAccountsById(Set<Id> setId, List<String> setIdFromContact);
}