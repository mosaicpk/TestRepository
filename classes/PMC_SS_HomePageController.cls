/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-12-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PMC_SS_HomePageController {

    /**
     * @description - Method used to fetch the knowledge articles
     * @return KnowledgeArticleList - Returns Wrapper of type Knowledge Articles
     */
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getKnowledgeArticles(){
        try {
            return [SELECT Id, ArticleNumber, Answer__c, CreatedById, 
                    PublishStatus, Question__c, Summary, Title, UrlName, PMC_SS_EndDate__c
                    FROM Knowledge__kav 
                    WHERE PublishStatus =: Label.PMC_SS_KnowledgeArticle_OnlineStatus
                    With SECURITY_ENFORCED];
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description - Method used to fetch the knowledge articles
     * @return lstWrapper - Returns Wrapper of type Knowledge Articles
     */
    @AuraEnabled(cacheable=true)
    public static List<KnowledgeArticleWrapper> getAllKnowledgeArticles(){
        String staticImageURL = URL.getSalesforceBaseUrl().toExternalForm() + PageReference.forResource('DefaultNewsAndAnnouncement').getUrl();

        try {
            List<KnowledgeArticleWrapper> lstKAWrapper = new List<KnowledgeArticleWrapper>();
            Map<Id,KnowledgeArticleWrapper> mapKAWrapper = new Map<Id,KnowledgeArticleWrapper>();
            Map<Id, Knowledge__kav> mapIdKnowledges = new Map<Id, Knowledge__kav> ([SELECT Id, ArticleNumber, Answer__c, CreatedById, 
                    PublishStatus, Question__c, Summary, Title, UrlName, CreatedDate, PMC_SS_EndDate__c,RecordType.DeveloperName
                    FROM Knowledge__kav
                    WHERE PublishStatus =: Label.PMC_SS_KnowledgeArticle_OnlineStatus And RecordType.DeveloperName =: Label.PMC_SS_KnowledgeArticle_BulletinRecordType
                    ORDER by PMC_SS_EndDate__c ASC]);
            
            List<ContentDocumentLink> lstContentDocLinks = [SELECT Id, LinkedEntityId, ContentDocumentId, 
                                                                                                  ContentDocument.LatestPublishedVersionId, 
                                                                                                  ContentDocument.LatestPublishedVersion.Title
                                                                                                  FROM ContentDocumentLink 
                                                                               					  WHERE LinkedEntityId IN: mapIdKnowledges.keySet()
                                                                                                  WITH SECURITY_ENFORCED ];

            for(ContentDocumentLink objContentDocLink : lstContentDocLinks) {
                if(mapIdKnowledges.get(objContentDocLink.LinkedEntityId) != null) {
                    KnowledgeArticleWrapper objKnowledgeWrapper = new KnowledgeArticleWrapper();
                    objKnowledgeWrapper.title = mapIdKnowledges.get(objContentDocLink.LinkedEntityId).Title;
                    objKnowledgeWrapper.description = mapIdKnowledges.get(objContentDocLink.LinkedEntityId).Summary;
                    objKnowledgeWrapper.endDate = mapIdKnowledges.get(objContentDocLink.LinkedEntityId).PMC_SS_EndDate__c;
                    objKnowledgeWrapper.publishStatus = mapIdKnowledges.get(objContentDocLink.LinkedEntityId).PublishStatus;
                    objKnowledgeWrapper.createdById = mapIdKnowledges.get(objContentDocLink.LinkedEntityId).CreatedById;
                    objKnowledgeWrapper.imageUrl = '/sfc/servlet.shepherd/version/download/' + objContentDocLink.ContentDocument.LatestPublishedVersionId;
					mapKAWrapper.put(objContentDocLink.LinkedEntityId,objKnowledgeWrapper);
                }

            }
            for(Id mapId: mapIdKnowledges.keySet()){
                if(mapKAWrapper.keySet().contains(mapId)){
                    lstKAWrapper.add(mapKAWrapper.get(mapId));
                }else{
                 KnowledgeArticleWrapper objKnowledgeWrapper = new KnowledgeArticleWrapper();
                    objKnowledgeWrapper.title = mapIdKnowledges.get(mapId).Title;
                    objKnowledgeWrapper.description = mapIdKnowledges.get(mapId).Summary;
                    objKnowledgeWrapper.endDate = mapIdKnowledges.get(mapId).PMC_SS_EndDate__c;
                    objKnowledgeWrapper.publishStatus = mapIdKnowledges.get(mapId).PublishStatus;
                    objKnowledgeWrapper.createdById = mapIdKnowledges.get(mapId).CreatedById;
                    objKnowledgeWrapper.imageUrl = staticImageURL;
					lstKAWrapper.add(objKnowledgeWrapper);
                }
            }
            return lstKAWrapper;
        } 
        catch (Exception e) {
            System.debug('Exception '+e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description - Generic Wrapper class to hold the knowledge object record 
     */
    public class KnowledgeArticleWrapper {
        /**
         * @description - holds the article title
         */
        @AuraEnabled
        public String title {get;set;}
         /**
         * @description - holds the article description
         */
        @AuraEnabled
        public String description {get;set;}
         /**
         * @description - holds the article image URL
         */
        @AuraEnabled
        public String imageUrl {get;set;}
         /**
         * @description - holds the article end date
         */
        @AuraEnabled
        public Date endDate {get;set;}
         /**
         * @description - holds the article pusblished status
         */
        @AuraEnabled
        public String publishStatus {get;set;}
         /**
         * @description - holds the created date of artile 
         */
        @AuraEnabled
        public String createdById {get;set;}
    }
}