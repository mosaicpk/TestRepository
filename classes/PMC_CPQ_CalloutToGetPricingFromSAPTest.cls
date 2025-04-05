/** @description This class is the test class to test the Apex Class which is called at the Calculate Event in 'Get Price'
 *  @author Prakhar
 *  @storynumber GDASF-6819
 */

@isTest
public class PMC_CPQ_CalloutToGetPricingFromSAPTest {
    @isTest
    static void testPostExternalPricing(){
        test.startTest();
        /*
        Account objAccTest = PMC_TestUtilityClass.createAccount('Test Account',Null);
        //objAccTest.Name = 'Test Account';
        objAccTest.PMC_SS_AccountExternalID__c = 'GDASF-6819';
        insert objAccTest;*/
        
        List<Opportunity> opp = PMC_TestUtilityClass.createOpportunity(1, Null);
        //opp.Name = 'Test Opportunity';
        opp[0].CloseDate = System.today().addDays(10);
        update opp;
        
        List<Contact> objConTest = PMC_TestUtilityClass.createContact(1, Null); 
        update objConTest;
        
        Schema.Location testLoc = new Schema.Location();
        testLoc.Name = 'Test Location';
        testLoc.PMC_CPQ_Plant__c = 'Test Plant';
        insert testLoc;
    
        List<Account> listAccount = [SELECT Id,PMC_SS_AccountExternalID__c from Account];
        listAccount[0].PMC_SS_AccountExternalID__c = 'GDASF-6819';
        update listAccount;
        
        
        List<Opportunity> lstopp = [Select id from Opportunity];
        
        List <Contact> listContacts = [SELECT Id from Contact];
        listContacts.get(0).AccountId = listAccount.get(0).Id;
        update listContacts;
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        Date dateToday = System.today();
        Date dateLater = dateToday.addDays(3);
        SBQQ__Quote__c curquote = new SBQQ__Quote__c(PMC_CPQ_ContractStart__c = dateToday,PMC_CPQ_ContractEnd__c = dateLater,PMC_CPQ_PrimaryContact__c = listContacts[0].Id,SBQQ__Account__c = listAccount[0].Id,SBQQ__Opportunity2__c
 = lstopp[0].id);
        quotes.add(curquote);
        insert curquote;
        
        
        //List<Product2> testProd = PMC_TestUtilityClass.createProduct(1, Null);
        Product2 testProd = new Product2();
        testProd.Name = 'Test Product';
        testProd.StockKeepingUnit = 'Test SKU';
        
        insert testProd;
        
        
        
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name from SBQQ__Quote__c];

        List<Product2> listProd = [Select id from Product2];
        
        List<Account> testAcnt = [Select id from Account];
        
        List<Schema.Location> locList = [Select id from Location];

        Map<String, String> testData = new Map<String, String>();
        
        testData.put('Transaction_Id', quoteList[0].Name);
        testData.put('Qline1', ('4*' + listProd[0].Id + '*PO298752897*'+locList[0].Id+'*1*2*1*TestQLId*TestPQID*KG*'+testAcnt[0].Id));
        
        String res = PMC_CPQ_CalloutToGetPricingFromSAPClass.postExternalPricing(testData);
        system.assertEquals('100', res, 'Expected response from Callout Class');
        test.stopTest();
    }
}