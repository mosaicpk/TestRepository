/** @description This class is the test class that provides response for Mock Http Callouts 
*  @author Humera
*  @storynumber GDASF-6862
*/

@isTest
public class PMC_DH_GetPriceCalloutTest implements HttpCalloutMock {
    /**
* @description Status
* @return String
*/
    public String strStatus{get;set;}
    /**
* @description response
* @return String
*/
    public string strRes{get;set;}
    /**
* @description Response code
* @return String
*/
    public Integer intResCode{get;set;}
    /** 
* @description This returns a static response
* @param intResCode
* @param strRes
* @param strStatus
*/
    public  PMC_DH_GetPriceCalloutTest(Integer intResCode,string strRes,String strStatus){
        this.intResCode=intResCode;
        this.strRes=strRes;
        this.strStatus=strStatus;
    }
    /** 
* @description This returns a static response
* @param request - This is the request of HTTP callout
* @return HTTPResponse - returns the response body of HTTP callout
*/
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(this.strRes);
        response.setStatusCode(this.intResCode);
        return response; 
    }
    
    
}