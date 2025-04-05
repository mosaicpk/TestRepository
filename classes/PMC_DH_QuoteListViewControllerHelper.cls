/**
* @description       : Helper class for controller for fetching Quote History
* @author            : @Rohan Undale
* @Created on        : 09-15-2023
**/
public without sharing class PMC_DH_QuoteListViewControllerHelper {

    /**
    * @description getStatus
    * @author Hemant Giri Goswami | hegoswami@deloitte.com | 12-09-2023 
    * @param strStatus 
    * @return String 
    **/
    public static String getStatus(String strStatus)
    {   String strResult='';
        if(strStatus=='Under Review By Account Manager')
        {
            strResult=System.label.pmc_quoteDetailsFlow_statusUnderReviewByAccountManager;
        }
        else if(strStatus=='Submitted')
        {
            strResult=System.label.pmc_quoteDetailsFlow_statusSubmitted;
        }
        else if(strStatus=='Inactive')
        {
            strResult=System.label.PMC_DH_InactiveStatus;
        }
        else if(strStatus=='Accepted')
        {
            strResult=System.label.pmc_quoteDetailsFlow_accepted;
        }
        else if(strStatus=='placed')
        {
            strResult=System.label.pmc_orderDetails_statusPlaced;
        }
        else if(strStatus=='partially shipped')
        {
            strResult=System.label.pmc_orderStatus_partiallyShipped;
        }
        return strResult;
    }
}