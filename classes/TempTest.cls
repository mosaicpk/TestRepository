@IsTest(SeeAllData=true)
public class TempTest {
	@IsTest
    public static void isContactEmailPresentTest(){
    	//System.debug(String.valueOf(PMC_DH_GetPriceResponseParsing.getPricingSummaryForQuote('a3CDT000001T5fv2AC')));
       User usr = [SELECT Id,Email, lastName, Phone FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(usr){
             PMC_DH_NewAccountOnboardingBatch batchJob=new PMC_DH_NewAccountOnboardingBatch();
            Test.startTest();
         //   Database.executeBatch(batchJob);
            Test.stopTest();
        }
    }
}