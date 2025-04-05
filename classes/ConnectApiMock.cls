public class ConnectApiMock implements HttpCalloutMock {
    ConnectApi.ExternalManagedAccountCollectionOutput mockResponse;

    ConnectApiMock(ConnectApi.ExternalManagedAccountCollectionOutput mockResponse) {
        this.mockResponse = mockResponse;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(mockResponse));
        response.setStatusCode(200);
        return response;
    }
}