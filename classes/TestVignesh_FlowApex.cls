/** @description This is a class to do testing..
*  @author Vignesh
*  @storynumber XYZ
*/
public class TestVignesh_FlowApex implements Queueable, Database.AllowsCallouts{
    public List<SBQQ__QuoteLine__c> quoteLineList;

    /** 
     * @description Constructor of the class. 
     * @param quoteList - list of quote lines sent from the flow.
     */
    public TestVignesh_FlowApex(List<SBQQ__QuoteLine__c> quoteLineList)
    {
        this.quoteLineList = quoteLineList; 
    }

    /** 
     * @description This is the apex action that will be invoked from the flow.
     * @param quoteList - list of quote lines sent from the flow.
     */
    @InvocableMethod(label='Test Vignesh Remote Action' description='Updates the QLE items on quick save' category='SBQQ__QuoteLine__c')
    public static void postInfoToCPI(List<SBQQ__QuoteLine__c> quoteLineList) {
        System.enqueueJob(new TestVignesh_FlowApex(quoteLineList));
    }

    /** 
     * @description Makes updates to the qle items
     * @param context - Receives the context of the flow. In this case it is the list of quote lines.
     */
    public void execute(QueueableContext context)
    {
        List<SBQQ__QuoteLine__c> listToUpdate = new List<SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLine__c each: quoteLineList){
            SBQQ__QuoteLine__c eachQLI = new SBQQ__QuoteLine__c();
            if(each.SBQQ__Quantity__c != 0){
                eachQLI.id = each.id;
                eachQLI.SBQQ__Quantity__c = 100;
                listToUpdate.add(eachQLI);
            }
        }

        if(listToUpdate.size()>0){
            update listToUpdate;
        }
    } 
}