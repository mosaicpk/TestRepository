public class CustomAuthProvider extends Auth.AuthProviderPluginClass {
    private String metadataApiName = 'Client_Credentials_Auth_Provider_Setting__mdt';
    private String callbackUrl = 'https://globaldigitalacceleration--devp1.sandbox.my.salesforce.com/services/authcallback/CPI_Outbound_Integration';
    private string tokenEndpoint = 'https://development-s4hana-i2ijb4jk.authentication.us20.hana.ondemand.com/oauth/token';
    private string clientId = 'sb-f3467705-bfae-446b-9d5e-877e587c4183!b4025|it-rt-development-s4hana-i2ijb4jk!b34';
    private string clientSecret = '5b98d942-858c-4428-9143-102768bdcac8$X5rfDIWh2wVC1aM_bN5Dd4NNcRzg-4T8GtLwZH35RPw=';
    private String tokenType = 'Bearer';
    private String authProviderName = 'CPI_Outbound_Integration';
  
    public  String getCustomMetadataType() {
        return metadataApiName;
    }

   //This covers the Steps 1 to 5 of Authorisation grant flow
    public  PageReference initiate(Map<string, string> authProviderConfiguration, String stateToPropagate) {
       
        //State is needed for the flow to function
        //https://salesforce.stackexchange.com/questions/224231/salesforce-no-oauth-state-state-not-valid
        callbackUrl+= + '?state=' + stateToPropagate;

        return new PageReference(callbackUrl);
    }
 
    //From Step 6 , Pass in the client id and secret to get the access token
    public  Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state) {
               
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(tokenEndpoint);
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');

        String body = 'client_id='+clientId;
        body+='&client_secret='+clientSecret;
        body+='&grant_type=client_credentials';

        request.setBody(body);

        HttpResponse response = http.send(request);
        ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
               
        //return new Auth.AuthProviderTokenResponse(authProviderName, responseWrapper.access_token, null, state.queryParameters.get('state'));
        return new Auth.AuthProviderTokenResponse(authProviderName, responseWrapper.access_token, 'refreshToken', state.queryParameters.get('state'));
    }
    public override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {
        //custom refresh flow
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(tokenEndpoint);
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');

        String body = 'client_id='+clientId;
        body+='&client_secret='+clientSecret;
        body+='&grant_type=client_credentials';

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