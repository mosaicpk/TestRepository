public class UserInformationDetails {

    @AuraEnabled
    public static List<User> fetchUserInformation(){
        try{
        return [SELECT Id,User.Name,User.Phone,User.Email from User Order By CreatedDate DESC LIMIT 100];
        }Catch(Exception ex){
          throw new AuraHandledException(ex.getMessage());
        }
    }
}