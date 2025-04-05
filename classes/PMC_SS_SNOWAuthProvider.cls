public with sharing class PMC_SS_SNOWAuthProvider extends Auth.AuthProviderPluginClass {
    
    private String metadataApiName = 'PMC_SS_SNOW_Authentication__mdt';
    private String callbackUrl ;
    private string tokenEndpoint;
    private string clientId;
    private string clientSecret;
    private String tokenType = 'Bearer';
    private String authProviderName;
    private String userName;
    private String password;
    private String authUrl;
    private String scope;
  
    public  String getCustomMetadataType() {
        return metadataApiName;
    }

   //This covers the Steps 1 to 5 of Authorisation grant flow
    public  PageReference initiate(Map<string, string> authProviderConfiguration, String stateToPropagate) {
       
        authUrl = authProviderConfiguration.get('Auth_UrPMC_SS_SNOW_AuthURL__cl__c'); 
        clientId = authProviderConfiguration.get('PMC_SS_SNOW_ClientID__c'); 
        scope       = authProviderConfiguration.get('Scope__c');
        //clientSecret = authProviderConfiguration.get('PMC_SS_SNOW_ClientSecret__c'); 
        String urlToRedirect = 'https://mosaictest.service-now.com/login.do?'+'scope='+scope+
                               '&state='+stateToPropagate+'&allow_signup=false';
                               
        PageReference pageRef = new PageReference(urlToRedirect);                    
        return pageRef; 
    }
 
    //From Step 6 , Pass in the client id and secret to get the access token
    public  Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state) {

        clientId = authProviderConfiguration.get('PMC_SS_SNOW_ClientID__c'); 
        clientSecret = authProviderConfiguration.get('PMC_SS_SNOW_ClientSecret__c');  
        userName = authProviderConfiguration.get('PMC_SS_SNOW_UserName__c');  
        password = authProviderConfiguration.get('PMC_SS_SNOW_Password__c');      
        tokenEndpoint   = authProviderConfiguration.get('PMC_SS_SNOW_TokenURL__c');      
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(tokenEndpoint);
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');

        String body = 'client_id='+clientId;
        body+='&client_secret='+clientSecret;
        body+='&password='+userName;
        body+='&username='+password;
        body+='&grant_type=password';

        request.setBody(body);

        HttpResponse response = http.send(request);
        ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
               
        //return new Auth.AuthProviderTokenResponse(authProviderName, responseWrapper.access_token, null, state.queryParameters.get('state'));
        return new Auth.AuthProviderTokenResponse(authProviderName, responseWrapper.access_token, 'refreshToken', state.queryParameters.get('state'));
    }
    public override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {
        //custom refresh flow
        clientId = authProviderConfiguration.get('PMC_SS_SNOW_ClientID__c'); 
        clientSecret = authProviderConfiguration.get('PMC_SS_SNOW_ClientSecret__c');  
        userName = authProviderConfiguration.get('PMC_SS_SNOW_UserName__c');  
        password = authProviderConfiguration.get('PMC_SS_SNOW_Password__c');      
        tokenEndpoint   = authProviderConfiguration.get('PMC_SS_SNOW_TokenURL__c');      
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(tokenEndpoint);
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');

        String body = 'client_id='+clientId;
        body+='&client_secret='+clientSecret;
        body+='&password='+userName;
        body+='&username='+password;
        body+='&grant_type=password';

        request.setBody(body);

        HttpResponse response = http.send(request);
        ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
       
        return new Auth.OAuthRefreshResult(responseWrapper.access_token, tokenType);
    }

   //Return fake user, client credentials auth flow is not for a user
    public Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
       
        return new Auth.UserData('fakeId', 'first', 'last', 'full', 'email', 'link', null, null, null, null, null);
    }
  
    public class ResponseWrapper {
        public String access_token;
        public String token_type;
        public String expires_in;
    }
}