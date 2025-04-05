/**
* @description       : Wrapper for QuoteLine Update
* @author            : @Krishan Jangir
* @group             : 
* @last modified on  : 04-25-2024
* @last modified by  : Hemant Giri Goswami | hegoswami@deloitte.com
**/
public without sharing  class PMC_DH_QuoteLineUpdateWrapper {
     /**

         * @description quote line id

         * @return String

         */
		@Auraenabled
        public String strQuoteLineItemId{get;set;}

        /**

         * @description qunatity of cart

         * @return String

         */
		@Auraenabled
        public String strQuoteLineItemQuantity{get;set;}




        /**

         * @description Ship to value from quotelineitem

         * @return String

         *

        **/

        @AuraEnabled

        public String strShipTo {get;set;}




        /**

        * @description incoterms of quotelineitem

        * @return String

        *

        **/

        @AuraEnabled

        public String strIncoterms{get;set;}




        /**

        * @description List for value label picklist

        * @return       String

        **/

        @AuraEnabled

        public String strDeliveryMode{get;set;}




        /**

        * @description List for value label picklist

        * @return       String

        **/

        @AuraEnabled

        public String strShipFrom{get;set;}




        /**

        * @description List for value label picklist

        * @return       String

        **/

        @AuraEnabled

        public String strPackType{get;set;}

    /**
     * @description UOM of Product
     * @return String  
     */
    @AuraEnabled
    public string strProductUOM{get;set;}
    // /**
    //  * @description lstQuoteLineDetails
    //  * @return List<QuoteLine>   
    //  */

    // @AuraEnabled
    // public List<PMC_DH_QuoteManagementHelper.QuoteLineWrapper> lstQuoteLineDetails{get;set;}


}