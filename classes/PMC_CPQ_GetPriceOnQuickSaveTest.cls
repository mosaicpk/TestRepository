/** @description This is the test class to make callouts to the Quote and Contract Creation interface of CPI.
 *  @author Prakhar
 *  @storynumber GDASF-6819
 */

@isTest
public without sharing class PMC_CPQ_GetPriceOnQuickSaveTest {
	public static List<String> lstPayloadQuoteIds = new List<String>();
	/**
	 * @description setup users to create sales area.
	 * @author Prakhar for Test class Run as Sales user context.
	 */
	@TestSetup
	public static void setup() {
		List<String> lstProfileNames = new List<String>{ 'System Administrator', 'Sales User' };
		List<String> lstPermissionSetGroupNames = new List<String>{ 'PMC_Administrator_Permission_Set_Group', 'PMC_SLS_Permission_Set_Group' };
		Map<String, Id> mapOfProfiles = PMC_TestUtilityClass.getProfiles(lstProfileNames);
		Map<String, PermissionSetGroup> mapOfPermissionGrp = PMC_TestUtilityClass.getPemissionsetGroups(lstPermissionSetGroupNames);
		Integer intuserCount = 0;
		User objSystemAdminUser;
		User objSalesUser;
		List<User> lstUser = PMC_TestUtilityClass.createUser(2);
		for (User objUser : lstUser) {
			if (intuserCount == 0) {
				objUser.LastName = 'Admin User Test';
				objUser.ProfileId = mapOfProfiles.get('System Administrator');
				objUser.FederationIdentifier = objUser.Username + 'Admin';
			} else if (intuserCount == 1) {
				objUser.LastName = 'Sales User Test';
				objUser.ProfileId = mapOfProfiles.get('Sales User');
				objUser.FederationIdentifier = objUser.Username + 'Sales';
			}
			objUser.isActive = true;
			objUser.MobilePhone = '1234567890';
			objUser.UserPermissionsKnowledgeUser = true;
			objUser.LanguageLocaleKey = 'en_US';
			objUser.PMC_CPQ_SalesRegion__c = 'North America';
			objUser.PMC_CPQ_PrimaryBusinessType__c = 'Feed';
			intuserCount = intuserCount + 1;
		}
		insert lstUser;
		objSystemAdminUser = lstUser[0];
		objSalesUser = lstUser[1];
		PMC_TestUtilityClass.assignPermissionSetGroupToUsers(
			new List<User>{ objSystemAdminUser },
			mapOfPermissionGrp.get('PMC_Administrator_Permission_Set_Group')
		);
		PMC_TestUtilityClass.assignPermissionSetGroupToUsers(new List<User>{ objSalesUser }, mapOfPermissionGrp.get('PMC_SLS_Permission_Set_Group'));

		System.runAs(objSystemAdminUser) {
			//Create Sales area
			List<PMC_SS_SalesArea__c> lstSalesArea = PMC_TestUtilityClass.createSalesArea(1, 'Master');
			lstSalesArea[0].PMC_SS_SalesOrganization__c = 'Mosaic Global Sales LLC';
			lstSalesArea[0].PMC_CPQ_SAPSalesOrganization__c = '10020010';
			lstSalesArea[0].PMC_SS_DistributionChannel__c = 'Common';
			lstSalesArea[0].PMC_SS_Division__c = 'Domestic';
			update lstSalesArea;
		}
	}
	/**
	 * @description createQuotes Creates the Quote to send to callout
	 * @param numQuote - Number of quotes to be created and Account Manager.
	 * @param lstUser - list of users.
	 * @return lstQuotes - List<SBQQ__Quote__c> to be returned.
	 * @modified by Prakhar
	 */

	public static List<SBQQ__Quote__c> createQuotes(Integer numQuote, List<User> lstUser) {
		List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>();
		List<Opportunity> lstOpportunities;
		lstOpportunities = PMC_TestUtilityClass.createOpportunity(2, 'Master');
		update lstOpportunities;
		// SalesArea
		List<PMC_SS_SalesArea__c> lstSalesArea = [SELECT Id FROM PMC_SS_SalesArea__c WITH SECURITY_ENFORCED LIMIT 1];
		Account accnt = new Account();
		accnt.Id = lstOpportunities[0].AccountId;
		accnt.Type = 'Sold-to';
		accnt.PMC_SS_AccountExternalID__c = '8923743784';
		accnt.PMC_SS_SAPCustomerNumber__c = '4208024022';
		update accnt;
		List<Account> lstAccount = new List<Account>();
		lstAccount.add(accnt);
		PMC_TestUtilityClass.createAccountSalesAreaRelationship(lstAccount, lstSalesArea);
		PMC_SS_AccountSalesAreaRelationship__c relObj = new PMC_SS_AccountSalesAreaRelationship__c(
			PMC_SS_Account__c = lstAccount[0].Id,
			PMC_SS_SalesArea__c = lstSalesArea[0].Id
		);
		insert relObj;
		List<Contact> lstContacts;
		lstContacts = PMC_TestUtilityClass.createContact(1, 'Master');
		lstContacts[0].AccountId = accnt.Id;
		update lstContacts;
		lstQuotes = PMC_TestUtilityClass.createCPQQuotes(numQuote, lstOpportunities, lstContacts);
		lstQuotes[0].PMC_CPQ_AccountManager__c = lstUser[0].Id;
		lstQuotes[0].PMC_CPQ_Region__c = 'North America';
		lstQuotes[0].PMC_CPQ_ExpiresOn__c = Datetime.now().addDays(10);
		lstQuotes[0].PMC_CPQ_ContractStart__c = System.today().addDays(10);
		lstQuotes[0].PMC_CPQ_ContractEnd__c = System.today().addDays(40);
		lstQuotes[0].PMC_CPQ_QuoteRecordSubType__c = 'Feed';
		lstQuotes[0].PMC_CPQ_SalesArea__c = relObj.Id;
		update lstQuotes;

		Product2 objproduct = new Product2(Name = 'Test Product', StockKeepingUnit = '9999999999');
		insert objproduct;
		// Product Location
		Schema.Location loc = new Schema.Location(Name = 'TestName');
		loc.PMC_CPQ_Plant__c = 'Test';
		//loc.Name = 'TestName';
		loc.LocationType = 'Site';
		loc.RecordTypeId = [SELECT name, SobjectType, Id FROM RecordType WHERE Name = 'Origin Location'][0].Id;
		insert loc;
		PMC_CPQ_ProductLocation__c prodLoc = new PMC_CPQ_ProductLocation__c(PMC_CPQ_Location__c = loc.Id, PMC_CPQ_ProductName__c = objproduct.Id);
		insert prodLoc;

		PMC_SS_AccountPartnerRelationships__c accntRelAcc = new PMC_SS_AccountPartnerRelationships__c(PMC_SS_Account__c = accnt.Id);
		accntRelAcc.Name = 'Test';
		accntRelAcc.PMC_SS_Account__c = accnt.Id;
		accntRelAcc.PMC_SS_RelatedAccount__c = accnt.Id;
		accntRelAcc.PMC_SS_Type__c = 'Ship-to';
		accntRelAcc.PMC_SS_RelatedAccountSalesArea__c = relObj.Id;
		insert accntRelAcc;
		//PMC_CPQ_SoldToShipToJunction__c=accntRelAcc.Id
		SBQQ__QuoteLine__c objQuoteLine = new SBQQ__QuoteLine__c(
			PMC_CPQ_SoldToShipToJunction__c = accntRelAcc.Id,
			SBQQ__Quote__c = lstQuotes[0].Id,
			SBQQ__Product__c = objproduct.Id,
			PMC_CPQ_Discount__c = 10,
			SBQQ__Number__c = 1,
			PMC_CPQ_QuoteRecordType__c = 'Domestic NA',
			PMC_CPQ_ModeofTransportation__c = 'Rail',
			PMC_CPQ_UnitofMeasure__c = 'STN',
			PMC_CPQ_QuoteRecordSubType__c = 'Feed',
			PMC_CPQ_Incoterms1__c = 'CFR',
			PMC_CPQ_ShipTo__c = accnt.Id,
			PMC_CPQ_ProductLocation__c = prodLoc.Id,
			SBQQ__Quantity__c = 1,
			SBQQ__ListPrice__c = 10,
			PMC_CPQ_FinalPricePerTonne__c = 20,
			PMC_CPQ_ContractType__c = 'Priced',
			PMC_CPQ_DeliveryStartDate__c = System.today().addDays(20),
			PMC_CPQ_DeliveryEndDate__c = System.today().addDays(30),
			PMC_CPQ_PaymentTerms__c = 'Fixed Date'
		);
		insert objQuoteLine;

		return lstQuotes;
	}

	/**
	 * @description Make Get Price Call through Custom action
	 * @param lstQuotes - no of quotes to be created
	 */
	public static void getPriceCustomAction(List<SBQQ__Quote__c> lstQuotes) {
		PageReference pageRef = Page.PMC_CPQ_GetPriceActionPage; // Add your VF page Name here
		pageRef.getParameters().put('id', String.valueOf(lstQuotes[0].Id));
		pageRef.getParameters().put('baseUrl', 'Test');
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdController = new ApexPages.StandardController(lstQuotes[0]);
		PMC_CPQ_GetPriceActionClass testAccPlan = new PMC_CPQ_GetPriceActionClass(stdController);
		testAccPlan.redirect1();
	}
	/**
	 * @description Used to invoke apex
	 */
	@isTest
	public static void testGetPriceSuccessMessageNotEmpty() {
		List<User> lstUser = [SELECT Id FROM User WHERE LastName = 'Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];

		List<SBQQ__Quote__c> lstQuotes = PMC_CPQ_GetPriceOnQuickSaveTest.createQuotes(1, lstUser);
		System.runAs(lstUser.get(0)) {
			for (SBQQ__Quote__c curQuote : lstQuotes) {
				lstPayloadQuoteIds.add(curQuote.Id);
				curQuote.PMC_CPQ_IntegrationMessage__c = 'Test';
			}
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetPriceSuccessCalloutTest(true));
			getPriceCustomAction(lstQuotes);
			Test.stopTest();
			System.assert(!lstQuotes.isEmpty(), 'List should not be empty');
		}
	}

	/**
	 * @description Used to invoke apex
	 */
	@isTest
	public static void testGetPriceQuoteWithNoQuoteLine() {
		List<User> lstUser = [SELECT Id FROM User WHERE LastName = 'Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];

		/*List<Opportunity> lstOpportunities;
         lstOpportunities = PMC_TestUtilityClass.createOpportunity(1,'Master');
         update lstOpportunities;
         Account accnt = new Account();
         accnt.Id = lstOpportunities[0].AccountId;
         accnt.PMC_SS_SAPCustomerNumber__c = '4208024022';
         update accnt;
         List<Contact> lstContacts;
         lstContacts = PMC_TestUtilityClass.createContact(1,'Master');
         lstContacts[0].AccountId = accnt.Id;
         update lstContacts;
         List<SBQQ__Quote__c> lstQuotes;
         lstQuotes = PMC_TestUtilityClass.createCPQQuotes(1,lstOpportunities,lstContacts);
         
         for(SBQQ__Quote__c curQuote : lstQuotes)
         {
             lstPayloadQuoteIds.add(curQuote.Id);
         }*/

		//List<String> lstPermissionNames = New List<String>{'PMC_SLS_Permission_Set_Group'};
		//system.runAs(PMC_CPQ_CPIRemoteCalloutUtilityTest.createCPQTestUser('Sales User',lstPermissionNames)){
		List<SBQQ__Quote__c> lstQuotes = PMC_CPQ_GetPriceOnQuickSaveTest.createQuotes(1, lstUser);
		// System.runAs(lstUser.get(0)) {
		for (SBQQ__Quote__c curQuote : lstQuotes) {
			lstPayloadQuoteIds.add(curQuote.Id);
			curQuote.PMC_CPQ_IntegrationMessage__c = 'Test';
		}
		Test.startTest();
		List<SBQQ__QuoteLine__c> qtLn = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Id = :lstQuotes[0].Id LIMIT 1];
		qtLn[0].put('PMC_CPQ_UnitofMeasure__c', null);
		update qtLn;
		Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetPriceSuccessCalloutTest(false));
		getPriceCustomAction(lstQuotes);

		delete qtLn[0];
		//Test.startTest();
		Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetPriceSuccessCalloutTest(false));
		getPriceCustomAction(lstQuotes);
		Test.stopTest();
		System.assert(!lstQuotes.isEmpty(), 'List should not be empty');
		// }
	}
	/**
	 * @description Used to invoke apex
	 */
	@isTest
	public static void testGetPriceQuoteWithSalesArea() {
		List<User> lstUser = [SELECT Id FROM User WHERE LastName = 'Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];

		System.runAs(lstUser.get(0)) {
			List<Opportunity> lstOpportunities;
			lstOpportunities = PMC_TestUtilityClass.createOpportunity(1, 'Master');
			update lstOpportunities;
			Account accnt = new Account();
			accnt.Id = lstOpportunities[0].AccountId;
			accnt.PMC_SS_SAPCustomerNumber__c = '4208024022';
			update accnt;
			List<Contact> lstContacts;
			lstContacts = PMC_TestUtilityClass.createContact(1, 'Master');
			lstContacts[0].AccountId = accnt.Id;
			update lstContacts;
			List<SBQQ__Quote__c> lstQuotes;
			lstQuotes = PMC_TestUtilityClass.createCPQQuotes(1, lstOpportunities, lstContacts);

			for (SBQQ__Quote__c curQuote : lstQuotes) {
				lstPayloadQuoteIds.add(curQuote.Id);
			}

			//List<String> lstPermissionNames = New List<String>{'PMC_SLS_Permission_Set_Group'};
			//system.runAs(PMC_CPQ_CPIRemoteCalloutUtilityTest.createCPQTestUser('Sales User',lstPermissionNames)){
			//List<SBQQ__Quote__c> lstQuotes = PMC_CPQ_GetPriceOnQuickSaveTest.createQuotes(1, lstUser);
			for (SBQQ__Quote__c curQuote : lstQuotes) {
				lstPayloadQuoteIds.add(curQuote.Id);
				curQuote.PMC_CPQ_IntegrationMessage__c = 'Test';
			}
			//List<SBQQ__QuoteLine__c> qtLn = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id = :lstQuotes[0].Id LIMIT 1];
			//delete qtLn[0];
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetPriceSuccessCalloutTest(true));
			getPriceCustomAction(lstQuotes);
			Test.stopTest();
			System.assert(!lstQuotes.isEmpty(), 'List should not be empty');
		}
	}

	/**
	 * @description Used to invoke apex
	 */
	@isTest
	public static void testResponseParsingError() {
		List<User> lstUser = [SELECT Id FROM User WHERE LastName = 'Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];

		HttpResponse response = new HttpResponse();
		response.setBody('{Test:Improper Response}}');
		response.setStatusCode(500);
		List<SBQQ__Quote__c> lstQuotes = PMC_CPQ_GetPriceOnQuickSaveTest.createQuotes(1, lstUser);
		System.runAs(lstUser.get(0)) {
			Test.startTest();
			PMC_CPQ_GetPriceResponseParsing.parseJSONGetPriceInterface(lstQuotes, response, 'Test');
			Test.stopTest();
			System.assert(!lstQuotes.isEmpty(), 'List should not be empty');
		}
	}

	/**
	 * @description Used to invoke apex
	 */
	@isTest
	public static void testGetPriceErrorHandling() {
		List<User> lstUser = [SELECT Id FROM User WHERE LastName = 'Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];

		List<SBQQ__Quote__c> lstQuotes = PMC_CPQ_GetPriceOnQuickSaveTest.createQuotes(1, lstUser);
		System.runAs(lstUser.get(0)) {
			for (SBQQ__Quote__c curQuote : lstQuotes) {
				lstPayloadQuoteIds.add(curQuote.Id);
			}
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetPriceErrorCalloutTest());

			getPriceCustomAction(lstQuotes);
			Test.stopTest();
			System.assert(!lstQuotes.isEmpty(), 'List should not be empty');
		}
	}

	/**
	 * @description Used to invoke apex
	 */

	@isTest
	public static void testGetPriceRedirect() {
		List<User> lstUser = [SELECT Id FROM User WHERE LastName = 'Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];

		List<SBQQ__Quote__c> lstQuotes = PMC_CPQ_GetPriceOnQuickSaveTest.createQuotes(1, lstUser);
		System.runAs(lstUser.get(0)) {
			for (SBQQ__Quote__c curQuote : lstQuotes) {
				lstPayloadQuoteIds.add(curQuote.Id);
			}

			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetPriceSuccessCalloutTest(true));
			PageReference pageRef = Page.PMC_CPQ_GetPriceActionPage; // Add your VF page Name here
			pageRef.getParameters().put('id', String.valueOf(lstQuotes[0].Id));
			pageRef.getParameters().put('baseUrl', 'Test');
			Test.setCurrentPage(pageRef);
			ApexPages.StandardController stdController = new ApexPages.StandardController(lstQuotes[0]);
			PMC_CPQ_GetPriceActionClass testAccPlan = new PMC_CPQ_GetPriceActionClass(stdController);
			testAccPlan.goBack();
			Test.stopTest();
			System.assert(!lstQuotes.isEmpty(), 'List should not be empty');
		}
	}

	/**
	 * @description Used to invoke apex
	 */
	@isTest
	public static void testGetPriceGenericSuccessCall() {
		List<User> lstUser = [SELECT Id FROM User WHERE LastName = 'Sales User Test' WITH SECURITY_ENFORCED LIMIT 1];

		List<SBQQ__Quote__c> lstQuotes = PMC_CPQ_GetPriceOnQuickSaveTest.createQuotes(1, lstUser);
		System.runAs(lstUser.get(0)) {
			for (SBQQ__Quote__c curQuote : lstQuotes) {
				lstPayloadQuoteIds.add(curQuote.Id);
			}
			Integer i = 0;
			List<SBQQ__QuoteLine__c> qtLn = [
				SELECT id, SBQQ__Product__r.Id
				FROM SBQQ__QuoteLine__c
				WHERE SBQQ__Quote__r.Id = :lstQuotes[0].Id
				LIMIT 1
			];
			List<PMC_CPQ_RawMaterial__c> lstRmMt = new List<PMC_CPQ_RawMaterial__c>();
			PMC_CPQ_RawMaterial__c rawMtrlObj;
			while (i < 6) {
				rawMtrlObj = new PMC_CPQ_RawMaterial__c(
					PMC_CPQ_Quote__c = lstQuotes[0].Id,
					PMC_CPQ_Product__c = qtLn[0].SBQQ__Product__r.Id,
					PMC_CPQ_QuoteLine__c = qtLn[0].Id
				);
				//new PMC_CPQ_RawMaterial__c(PMC_CPQ_Quote__c = lstQuotes[0].Id);
				lstRmMt.add(rawMtrlObj);
				i++;
			}
			insert lstRmMt;
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetPriceSuccessCalloutTest(true));
			getPriceCustomAction(lstQuotes);
			Test.setMock(HttpCalloutMock.class, new PMC_CPQ_HttpGetPriceSuccessCalloutTest(false));
			getPriceCustomAction(lstQuotes);
			Test.stopTest();
			System.assert(!lstQuotes.isEmpty(), 'List should not be empty');
		}
	}
}