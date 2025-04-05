/**
* @description       : Controller Class for Footer Navigation Component
* @author            : 
* @group             : 
* @last modified on  : 
* @last modified by  : | Digital Hub
**/
public with sharing class SchedulerSiteController {
    public static final string LINKS='Scheduler_Footer_Links';
    public static final string PUBLISHED_STATE ='Live';
    public static boolean throwUsersTestException = false;
    public static final String TEST_EXCEPTION_MESSAGE = 'Test Error';
    
    
    /**
* @description   : fetches NavigationMenuItems for footer
* 
* @param menuName
* @param publishedState
* 
* @return        : PMC_DH_FooterDetailsWrapper
*
* @author        : @Krishan jangir
* @date          : 04-11-2023
*/
    @AuraEnabled(cacheable=true)
    public static List<MyAccountNavItemsClass> getNavigationMenuItems() {
        String strUserId=userInfo.getUserId();
        //PMC_DH_FooterDetailsWrapper footerWrapper = new PMC_DH_FooterDetailsWrapper();
        //PMC_DH_FooterDetailsWrapper.UserDetailsClass userData = new PMC_DH_FooterDetailsWrapper.UserDetailsClass();
        List<MyAccountNavItemsClass> lstNavItems = new List<MyAccountNavItemsClass>();
        Id idNavigationLinkSetObj;
        try{
            getException();             
                idNavigationLinkSetObj = [SELECT Id FROM NavigationLinkSet WHERE DeveloperName =:LINKS].id; 
                for(NavigationMenuItem navMenuItem :[SELECT id,Label,Target,Type,Position,TargetPrefs FROM NavigationMenuItem WHERE NavigationLinkSetId =:idNavigationLinkSetObj AND Status =:PUBLISHED_STATE ORDER BY Position]){
                    MyAccountNavItemsClass navObj = new MyAccountNavItemsClass();
                    navObj.strRecId = navMenuItem.id;
                    navObj.strLabel = navMenuItem.Label;
                    navObj.intPosition = navMenuItem.Position;
                    navObj.strTarget = navMenuItem.Target;
                    navObj.strTargetPrefs = navMenuItem.TargetPrefs;
                    navObj.strType = navMenuItem.Type;
                    lstNavItems.add(navObj);
                }       
            
            //footerWrapper.userData = userData;
            //footerWrapper.myAccountNavItems =lstNavItems;
            return lstNavItems;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    private static void getException(){
        if (throwUsersTestException && Test.isRunningTest()) {
                throw new AuraHandledException(TEST_EXCEPTION_MESSAGE);
            }
       
    } 
    
    @AuraEnabled
    public List<MyAccountNavItemsClass> myAccountNavItems{get;set;} 
    /**
     * @description Wrapper class for My Account Menu
     * @author @KrishanJangir    
     */
    public class MyAccountNavItemsClass 
    {
        /**
     * @description RecordId of Navigation Menu
     * @return  String 
     */
        @AuraEnabled
        public string strRecId{get;set;}
        /**
     * @description  Label of Navigation Menu
     * @return String
     */
        @AuraEnabled
        public string strLabel{get;set;} 
         /**
     * @description  Position of Navigation Menu
     * @return String
     */
        @AuraEnabled
        public Integer intPosition{get;set;}
        /**
     * @description  Target of Navigation Menu
     * @return String
     */
        @AuraEnabled
        public string strTarget{get;set;}
        /**
     * @description  Target Prefs of Navigation Menu
     * @return String
     */
        @AuraEnabled
        public string strTargetPrefs{get;set;}
        /**
     * @description  Type of Navigation Menu
     * @return String
     */
        @AuraEnabled
        public string strType{get;set;}
    }


    
}