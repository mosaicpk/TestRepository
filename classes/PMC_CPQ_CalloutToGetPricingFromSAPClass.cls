/** @description This class will be called from the Custom Script on the Calculation Event to Get Price from External Systems
 *  @author Prakhar, Vignesh
 *  @storynumber GDASF-6819
 */
@RestResource(urlMapping='/pricing/*')
global without sharing class PMC_CPQ_CalloutToGetPricingFromSAPClass {
    /** 
     * @description This method will get the SKU field value for each Product IDs and return it as a Map
     * @param PrdIds - List of Unique Product Ids in the Quote Lines at the call.
     * @return type - Map<String,String>
     */
    public static Map<String, String> getSKUFieldRelation(Set<String> prdIds){
        Map<String, String> productMap = new Map<String, String>();
        
        List<Product2> listPdts = [select id, StockKeepingUnit from Product2 where Id IN: prdIds];
        
        if(listPdts.size()>0){
            for(Product2 each: listPdts){
                if(each.StockKeepingUnit != null){
                    productMap.put(each.Id, each.stockKeepingUnit);    
                }
            }
        }
        return productMap;
    }
    /**
     * @description This method will return PMC_CPQ_Plant__c field value for each Location Object IDs and return it as a Map
     * @param locIds - List of Unique Locations in the Quote Lines at the time of call.
     * @return type - Map<String,String>
     */
   
    public static Map<String, String> getPlantFieldRelation(Set<String> locIds){
        Map<String, String> locationMap = new Map<String, String>();
        
        List<Schema.Location> listLocations = [select id, PMC_CPQ_Plant__c from Location where Id IN :locIds];
        
        if(listLocations.size()>0){
            for(Schema.Location each: listLocations){
                if(each.PMC_CPQ_Plant__c != null){
                    locationMap.put(each.Id, each.PMC_CPQ_Plant__c);    
                }
            }
        }
        return locationMap;
    }
    /** 
     * @description This method will return the PMC_SS_AccountExternalID__c field value from the Account record Id in the Ship to field in Quotelines
     * @param shiptoIds - List of Unique ShipTo field values in the Quote Lines at the time of call.
     * @return type - Map<String,String>
     */
    public static Map<String, String> getShipToFieldRelation(Set<String> shipToIds){
        Map<String, String> accountMap = new Map<String, String>();
        
        List<Account> listAccounts = [select id, PMC_SS_AccountExternalID__c from Account where Id IN :shipToIds];
        
        if(listAccounts.size()>0){
            for(Account each: listAccounts){
                if(each.PMC_SS_AccountExternalID__c != null){
                    accountMap.put(each.Id, each.PMC_SS_AccountExternalID__c);
                }
            }
        }
        return accountMap;
    }
    
    /** 
     * @description This class will make a callout to CPI.
     * @param qq - Map of Attribute Names mapped with Values at the time of call from Quote and Quote Line from the Custom Script.
     * @return type - String
     */
    @HttpPost
    global static String postExternalPricing(Map<String, String> quoteAndQuoteLinesMap) {
        System.debug('CPQB_ExtPricing | postExternalPricing');
        
        //Getting the Quote Name from Transaction Id attribute to fetch the relationship fields.
        String qname = quoteAndQuoteLinesMap.get('Transaction_Id');
        /*SBQQ__Quote__c relatedQuoteDetails = [select SBQQ__Opportunity2__r.PMC_SS_SalesArea__r.PMC_SS_SalesOrganization__c, SBQQ__Opportunity2__r.PMC_SS_SalesArea__r.PMC_SS_DistributionChannel__c from SBQQ__Quote__c where Name = :qname limit 1];

        if(relatedQuoteDetails != null){
            //quoteAndQuoteLinesMap.put('SALES_ORG', relatedQuoteDetails.SBQQ__Opportunity2__r.PMC_SS_SalesArea__r.PMC_SS_SalesOrganization__c);
            quoteAndQuoteLinesMap.put('DISTR_CHAN', relatedQuoteDetails.SBQQ__Opportunity2__r.PMC_SS_SalesArea__r.PMC_SS_DistributionChannel__c);
        }*/
      
        List<PMC_CPQ_IntegrationFieldMap__mdt> fieldmapCMD = [select MasterLabel from PMC_CPQ_IntegrationFieldMap__mdt order by MasterLabel ASC];
        List<String> lineKey = new List<String>();
        
        if(fieldmapCMD.size()>0){ 
            for(PMC_CPQ_IntegrationFieldMap__mdt obj: fieldmapCMD){
                lineKey.add(obj.MasterLabel);
            }
        }
        
        Map<string, string> QLdetails = new Map<String, String>();        
        String QLdetails1;
        List<String> QL = new List<String>();
        Set<String> productIds = new Set<String>();
        Set<String> locationIds = new Set<String>();
        Set<String> shipToIds = new Set<String>();
        
        for(String key: quoteAndQuoteLinesMap.keySet()){
            if(key.contains('Qline')){
                QLdetails1 = (String)quoteAndQuoteLinesMap.get(key);//set -> Map(productIds, stockkeepingunit)
                QLdetails1 = QLdetails1.split('\\*')[1];
                productIds.add(QLdetails1);
                
                QLdetails1 = (String)quoteAndQuoteLinesMap.get(key);//set -> Map(locationIds, Plant)
                QLdetails1 = QLdetails1.split('\\*')[3];
                if(QLdetails1 != null){
                    locationIds.add(QLdetails1);
                }
                
                QLdetails1 = (String)quoteAndQuoteLinesMap.get(key);//set -> Map(shipToIds, externalReferenceId)
                QLdetails1 = QLdetails1.split('\\*')[10];
                if(QLdetails1 != null){
                    shipToIds.add(QLdetails1);
                }
            }
        }
        
        //Call the methods to get relevant related details from Product, Location and Account objects. 
        Map<String, String> productSKUmap = getSKUFieldRelation(productIds);
        Map<String, String> locationPlantMap = getPlantFieldRelation(locationIds);
        Map<String, String> accountShipToMap = getShipToFieldRelation(shipToIds);

        List<Map<String, String>> linedetails = new List<Map<String, String>>();
        String KeyString;
        Integer i; 
        
        //JSONGENERATOR Class is used to construct the JSON request body that needs sending to CPI.       
        JSONGenerator jRequestBody = JSON.createGenerator(false);
        jRequestBody.writeStartObject();
        for(String key: quoteAndQuoteLinesMap.keySet()){
            if(key.contains('Qline')){
                //Processing for QuoteLine
                System.debug(key);
                for(i = (LineKey.size()-1); i >= 0; i--){
                    KeyString = (String)quoteAndQuoteLinesMap.get(key);
                    QL = KeyString.split('\\*');
                    if(i == 1 && (QL[i]!=null)){
                        // Product id replaced by SKU
                        QLdetails.put(LineKey[i], productSKUmap.get((String)QL[i]));
                    }else if(i == 3 && (QL[i]!=null)){
                        //Location Id replaced by Plant value.
                        QLdetails.put(LineKey[i], locationPlantMap.get((String)QL[i]));
                    }else if(i == 10 && (QL[i]!=null)){
                        //Account Id repleaced by Account Ship To External Identifier value.
                        QLdetails.put(LineKey[i], accountShipToMap.get((String)QL[i]));
                    }else{
                        QLdetails.put(LineKey[i], QL[i]);
                    }
                }
                linedetails.add(QLdetails);
                QLdetails = new Map<String, String>();
            }
            else{
                jRequestBody.writeFieldName(key);
                if(quoteAndQuoteLinesMap.get(key)==null){
                    jRequestBody.writeObject('?');
                }else{
                    jRequestBody.writeObject(quoteAndQuoteLinesMap.get(key));
                }
            }
        }
        jRequestBody.writeFieldName('LineItemList');
        jRequestBody.writeObject(linedetails);
        jRequestBody.writeEndObject();
        
        
        System.debug('Final JSON Response');
        System.debug(jRequestBody.getAsString());
        
        /*
        * @description This class will make a callout to CPI.
        * @param quoteList - List of quotes.
        * @param strEndpoint - Endpoint that the HttpRequest will hit.
        */
        
        try{
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        
        String strInterface = 'ProductsExternalPricing';
        PMC_CPQ_Integration_Endpoint__mdt strIntegrationEndpointRecord = PMC_CPQ_Integration_Endpoint__mdt.getInstance(strInterface); 
        String strEndpoint = strIntegrationEndpointRecord.PMC_CPQ_Endpoint__c;
          
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setEndpoint('callout:PMC_CPQ_NamedCredential'+strEndpoint);
        
        String strJSON = JSON.serialize(jRequestBody.getAsString());
        request.setBody(strJSON);
        
        response = http.send(request);
        System.debug('!!!Json Response!!!');
        System.debug(response);
        }
        catch(Exception e){
            System.debug(e.getMessage());            
        }
        
        //Response parsing to continue..        
        return '100';
    }
}