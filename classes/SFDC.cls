public with sharing class SFDC {
    Public Account createAccount(String name){
        Account a= new Account();
        a.Name = name;
        insert a;
        return a;
        } 
}