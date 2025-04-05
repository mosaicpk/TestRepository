public with sharing class ResponseUtils {
    public ResponseUtils(){} 

    private class Toast{
        @AuraEnabled public String title;
        @AuraEnabled public String message;
        @AuraEnabled public String variant;

        public Toast(
            String title,
            String message,
            String variant
        ){
            this.title = title;
            this.message = message;
            this.variant = variant;
        }
    }

    public class Response{
        @AuraEnabled public Boolean hasError;
        @AuraEnabled public Boolean businessError;
        @AuraEnabled public String message;
        @AuraEnabled public String JSONResponse;
        @AuraEnabled public Toast toast;

        public Response(
            Boolean businessError,
            String Message,
            String response
        ){
            this.hasError = businessError;
            this.businessError = businessError;
            this.message = message;
            this.JSONResponse = response;
            this.fillToast();
        }

        public Response(Exception error){
            this.hasError = true;
            this.businessError = false;
            this.message = error.getMessage();
            this.JSONResponse = '';
            this.fillToast();
        }

        private void fillToast(){
            if(!this.hasError){
                this.toast = new Toast(System.label.ResponseUtils_SuccessMessage, this.message, 'success');
            }
            else if(this.businessError){
                this.toast = new Toast(System.label.ResponseUtils_AlertMessage, this.message, 'warning');
            }
            else{
                this.toast = new Toast(System.label.ResponseUtils_ErrorMessage, this.message, 'error');
            }
        }
    }
}