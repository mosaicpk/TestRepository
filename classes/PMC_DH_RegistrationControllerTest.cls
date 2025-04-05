/**
* @description : Test class for PMC_DH_RegistrationController
* @author      : Rohan Undale
* @last modified on 2023-05-15
* @last modified by Nikhilesh
**/
@isTest
public with sharing class PMC_DH_RegistrationControllerTest {
    @testSetup  static void setup()
    {
        Account acc=PMC_DH_TestDataFactoryClass.createTestAccount();
        acc.Name = 'First Test Account';
        update acc;
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Digital Hub Super Buyer' LIMIT 1];
        PMC_DH_TestDataFactoryClass.createContact(acc.Id);
        PMC_DH_TestDataFactoryClass.createTestUser(acc.Id,profile.Id);
        Account acc1=PMC_DH_TestDataFactoryClass.createTestAccount();
        acc1.ParentId = acc.Id;
        update acc1;
        //AccountTeamMember objAccountTeamMember = PMC_DH_TestDataFactoryClass.createTestAccountTeamMember(acc.Id,usr.Id);
    	Account shipToAcc = PMC_DH_TestDataFactoryClass.createShipToTestAccount(acc);
       PMC_DH_TestDataFactoryClass.createSoldToShipToAccountJunction(shipToAcc.Id, acc.Id); 
    }

    @isTest
    public static void registerUserTest(){
        
        PMC_DH_RegistrationController.PMC_DH_RegisterUserWrapper obj = new PMC_DH_RegistrationController.PMC_DH_RegisterUserWrapper();
        obj.strFirstName='ABC';
        obj.strLastName='XYZ';
        obj.strEmail='abcxyzz@mail.com';
        obj.strCountryCode='US +1';
        obj.strPhoneNumber='9876543210';
        obj.strCountry='India';
        obj.strState='Maharashtra';
        obj.strCity='Pune';
        obj.strMarketingEmailConsent='true';
        obj.strAccountNumber='Test001';
        obj.lstPreferences=new String[]{'Browse Knowledge articles','Access documents'};
        

        String str = JSON.serialize(obj);
        
        
        test.startTest();
        //Boolean result = PMC_DH_RegistrationController.registerUser(str);
        //Assert.isTrue(result,'Success');
        //System.assertEquals(true, result, 'Success');
        
        // added as part of GDASF-19642
        PMC_DH_RegistrationController.PMC_DH_UserRegistrationWrapper wrpResult = PMC_DH_RegistrationController.registerUser(str);
        Assert.isTrue(wrpResult.boolRegistrationStatus,'Success');
        System.assertEquals(true, wrpResult.boolRegistrationStatus, 'Success');
        test.stopTest();
    }
    
    @isTest
    public static void registerUserExceptionTest(){
        
        PMC_DH_RegistrationController.PMC_DH_RegisterUserWrapper obj = new PMC_DH_RegistrationController.PMC_DH_RegisterUserWrapper();
        obj.strFirstName='ABC';
        obj.strLastName='XYZ';
        obj.strEmail='abcxyzz@mail.com';
        obj.strCountryCode='US +1';
        obj.strPhoneNumber='9876543210';
        obj.strCountry='India';
        obj.strState='Maharashtra';
        obj.strCity='Pune';
        obj.strMarketingEmailConsent='true';
        obj.strAccountNumber='Test001';
        obj.lstPreferences=new String[]{'Browse Knowledge articles','Access documents'};
        

        String str = JSON.serialize(obj);
        
        
        test.startTest();
        Boolean exceptionOccurred;
		try{
            PMC_DH_DigitalHubB2BUtils.throwTestException = true;
            PMC_DH_RegistrationController.registerUser(str);
        }catch(exception e){
            exceptionOccurred=true;
        }
        System.assert(exceptionOccurred, 'An Exception was not thrown');
        test.stopTest();
    }
}