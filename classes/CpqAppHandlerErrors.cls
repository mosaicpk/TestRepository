public class CpqAppHandlerErrors {
    public class CpqAppHandlerError {
        public String code;
        public String message;
        
        public CpqAppHandlerError(String code, String message) {
            this.code = code;
            this.message = message;
        }
    }
}