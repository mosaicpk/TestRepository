/**
 * @description       : 
 * @author            : Hemant Giri Goswami | hegoswami@deloitte.com
 * @group             : Digital Hub | MD
 * @last modified on  : 07-05-2024
 * @last modified by  : Hemant Giri Goswami | hegoswami@deloitte.com
**/
public without sharing class PMC_DH_NewNotificaitonController {

    public static List<String> lstIndividualId = new List<String>();

/**
* @description create contact point type consent record for notification preferences
* @param lstUserId
*/

public static void createNotificationPref(List<String> lstUserId){
    List<User> lstUserObjRecord= [SELECT Id, ContactId,Contact.IndividualId,Contact.FirstName,Contact.LastName, Profile.Name FROM User WHERE Id IN:lstUserId WITH SYSTEM_MODE];
    List<Individual> lstIndivd=new List<Individual>();
    List<Contact> lstContact=new List<Contact>();
    List<String> lstProfile=new List<String>();
    for(User usrInstance:lstUserObjRecord)
    {
    String strIndividId='';
    String profileName = usrInstance.Profile.Name ;//+'%';
    lstProfile.add(profileName);
    Contact con = new Contact(Id=usrInstance.ContactId);
    if(usrInstance.Contact.IndividualId==null){
        Individual ind = new Individual();
        ind.FirstName = usrInstance.Contact.FirstName;
        ind.LastName = usrInstance.Contact.LastName;
        lstIndivd.add(ind);
        con.IndividualId = ind.Id;
        strIndividId = con.IndividualId;
    }else{
        strIndividId = usrInstance.Contact.IndividualId;
    }
    lstIndividualId.add(strIndividId);
    con.HasOptedOutOfEmail = false;
    con.PMC_SS_SMSOptOut__c = false;
    con.PMC_SS_WhatsappOptOut__c = false;
    lstContact.add(con);
    
    }
    if(Schema.sObjectType.Individual.isCreateable()){
        insert lstIndivd;
    }
    if(Schema.sObjectType.Contact.isUpdateable()){
        update lstContact;
    }
    
    Map<String, DataUsePurpose> dataUseMap = new Map<String, DataUsePurpose>();
    List<DataUsePurpose> lstDataUse = [SELECT Id, Name, LegalBasis.Name FROM DataUsePurpose WITH SYSTEM_MODE];
    for(DataUsePurpose dataUse: lstDataUse){
        String mapKey = dataUse.Name + dataUse.LegalBasis.Name;
        dataUseMap.put(mapKey,dataUse);
    }
    System.debug('->'+lstProfile);
    PMC_DH_PersonaPermissionSetGroup__mdt[] lstPersonaPermissionSetGroup = PMC_DH_PersonaPermissionSetGroup__mdt.getAll().values();
    Map<String, List<PMC_DH_Preference_Notification__mdt>> mapNotifi=new  Map<String, List<PMC_DH_Preference_Notification__mdt>>();
    List<PMC_DH_Preference_Notification__mdt> lstPrefNotification = [SELECT PMC_DH_Default_Opt_In__c, PMC_DH_Notification_Type__c, PMC_DH_Notification_Sub_Type__c, PMC_DH_Profile__c, PMC_DH_Preferences__c, PMC_DH_Sequence__c FROM PMC_DH_Preference_Notification__mdt WITH SECURITY_ENFORCED];
   /*for(PMC_DH_Preference_Notification__mdt mdtInst:lstPrefNotification)
   {
	mdtInst.put()
   }*/
    System.debug('->'+lstPrefNotification);
    List<ContactPointTypeConsent> lstCPTConsent = new List<ContactPointTypeConsent>();
    for(PMC_DH_Preference_Notification__mdt prefNotif:lstPrefNotification){
        if(prefNotif.PMC_DH_Preferences__c.contains('Email')){
             buildConsentRecord(prefNotif,dataUseMap,'Email');
        }
    }
   
}

 /**
    * @description create contact point type consent record for notification preferences
    * @param prefNot
    * @param dataUseMap
    * @param notType
    * @return ContactPointTypeConsent
    */
    private static void buildConsentRecord(PMC_DH_Preference_Notification__mdt prefNot, Map<String, DataUsePurpose> dataUseMap, String notType){
         System.debug('->Entered');
        List<ContactPointTypeConsent> lstCPTConsent = new List<ContactPointTypeConsent>();
        ContactPointTypeConsent cptConsent;
        System.debug('->'+lstIndividualId); 
        for(String individualId:lstIndividualId){
        cptConsent = new ContactPointTypeConsent();
        cptConsent.Name = prefNot.PMC_DH_Notification_Sub_Type__c;
        cptConsent.PartyId = individualId;
        cptConsent.PrivacyConsentStatus = 'OptIn';
        cptConsent.ContactPointType = notType;
        String mapKey = prefNot.PMC_DH_Notification_Sub_Type__c + prefNot.PMC_DH_Notification_Type__c;
        if (dataUseMap.containsKey(mapKey)){
            cptConsent.DataUsePurposeId = dataUseMap.get(mapKey).Id;
        }
        lstCPTConsent.add(cptConsent);
    }
        if(Schema.sObjectType.ContactPointTypeConsent.isCreateable()){
        insert lstCPTConsent;
    
    }
    }

}