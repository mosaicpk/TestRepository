public class nDemo {
    
    public static void met1(){
        try{
            Account a = [SELECT id from Account limit 2];
        }catch (QueryException qe){
           PMC_ErrorLogClass.processException(qe); 
        }
    }

}