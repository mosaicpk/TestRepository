/** @description This class will house utility functions for Get price.
 *  @author Prakhar
 *  @storynumber GDASF-10668
 */
public with sharing class PMC_CPQ_GetPriceUtilityClass{

    static final String STRING_INTEGRATIONSTATUSERROR = 'Error'; 
    static final String STRING_GETPRICEPREFIX = 'Get Price: ';
    
    /** 
     * @description Exit method for Error log
     * @param lstQuotes - List of Quotes
     * @param strExceptionMsg - Exception message
     */
    public static void errorLogExit(List<SBQQ__Quote__c> lstQuotes, String strExceptionMsg){
        if(strExceptionMsg!=null){
        		lstQuotes[0].PMC_CPQ_IntegrationStatus__c = STRING_INTEGRATIONSTATUSERROR;
            	lstQuotes[0].PMC_CPQ_IntegrationMessage__c = STRING_GETPRICEPREFIX + PMC_CPQ_CPIRemoteCalloutUtilityClass.strExceptionMsg;
                                                                           
            	SObjectAccessDecision securityDecisionQuote = Security.stripInaccessible(AccessType.UPDATABLE, lstQuotes);
        Database.update(securityDecisionQuote.getRecords(),false);
        }
    }
    /** 
     * @description Returns unique set of id of Quote
     * @param strVal - Object to be converted to String and hit the end point.
     * @return strProcessed - Returns String value which can be used to hit the end point.
     */
    public static String stringProcess(Object strVal){
        String strObject = JSON.serialize(strVal);
        String strProcessed = strObject.replace('\\\\','').substringAfter('"').substringBeforeLAst('"');
        strProcessed = strProcessed.replaceAll('\n','');
        strProcessed = strProcessed.replaceAll('\\\\','');
        return strProcessed;
    }
    /** 
     * @description Returns unique set of id of Quote
     * @param fieldMap - Fields fetched from External metadata.
     * @param filterString - String value which will be added for aliasing. 
     * @return queryParam - Returns String value which will be used to query the Database
     */
    public static String getQueryParam(List<PMC_CPQ_IntegrationFieldMap__mdt> fieldMap, String filterString){
        Set<String> quoteLineFieldSet = new Set<String>();
        String queryParam = '';
        Integer i = 0;
        
        for(PMC_CPQ_IntegrationFieldMap__mdt keypair: fieldMap){
            quoteLineFieldSet.add((String)keypair.PMC_CPQ_ApexAPIName__c);
        }
        for(String s: quoteLineFieldSet){
            queryParam = queryParam + s + ((filterString!=null)?(' ' + filterString + i):'') + ',';
            i++;
        }
        queryParam = queryParam + ' Id';
        return queryParam;
    }
    /** 
     * @description Make Raw material records asynchronously
     * @param rawMat - Raw Material Response Body
     * @param quoteId - Id of the quote on which Get price was done
     */
    @Future(Callout = true)
    public static void makeRawMaterialRecords(String rawMat, Id quoteId){
        List<Object> lstRawMat = (List<Object>)JSON.deserializeUntyped(rawMat);
        Map<String, SBQQ__QuoteLine__c> mapQuoteLine = getQuoteLineMap(quoteId);
        List<PMC_CPQ_RawMaterial__c> rawMtrl = [select id, PMC_CPQ_QuoteLine__r.SBQQ__Quote__c, PMC_CPQ_ProductSKU__c, PMC_CPQ_QuoteLine__r.SBQQ__Number__c from PMC_CPQ_RawMaterial__c WHERE PMC_CPQ_Quote__c =:quoteId WITH SECURITY_ENFORCED];
        Map<String, Id> mapProductSKU = new Map<String, Id>();
        Set<String> setProductSKU = new Set<String>();
        for(Object line: lstRawMat){
            setProductSKU.add(('' + ((map<String, Object>)line).get('Zzcomponent')));
        }
        List<Product2> lstProduct = [select Id, StockKeepingUnit from Product2 where StockKeepingUnit in :setProductSKU WITH SECURITY_ENFORCED];
        for(Product2 prd : lstProduct){
            mapProductSKU.put(('' + prd.StockKeepingUnit), prd.Id);
        }
        Integer diff = rawMtrl.size() - lstRawMat.size();
        map<String, String> mapRwMtrl = new map<String, String>();
        List<PMC_CPQ_IntegrationFieldMap__mdt> lstFldMap = [select PMC_CPQ_ApexAPIName__c, PMC_CPQ_AttributeKey__c, PMC_CPQ_DataType__c from PMC_CPQ_IntegrationFieldMap__mdt where PMC_CPQ_SFObject__c = 'Raw_Mat' WITH SECURITY_ENFORCED];
        for(PMC_CPQ_IntegrationFieldMap__mdt rwMtLine: lstFldMap){
                mapRwMtrl.put(rwMtLine.PMC_CPQ_AttributeKey__c, rwMtLine.PMC_CPQ_ApexAPIName__c);
        }
        rawMtrl = manangeRawMat(diff, quoteId, rawMtrl);
		PMC_CPQ_RawMaterial__c rwMt;
        String strAPIName;
            
        diff = 0;
        Map<String, Object> mapRwMat = new Map<String, Object>();
        Product2 prd = new Product2();
        for(Object line: lstRawMat){
            rwMt = rawMtrl[diff++];
            mapRwMat = (map<String, Object>)line;
            //System.debug(mapRwMat);
            //System.debug(mapQuoteLine);
            rwMt.put('PMC_CPQ_QuoteLine__c', mapQuoteLine.get('' + mapRwMat.get('ItmNumber')).Id);
            rwMt.put('PMC_CPQ_Product__c', mapProductSKU.get('' + mapRwMat.get('Zzcomponent')));
            for(PMC_CPQ_IntegrationFieldMap__mdt add: lstFldMap){
                strAPIName = mapRwMtrl.get((String)add.get('PMC_CPQ_AttributeKey__c'));
                if(add.PMC_CPQ_DataType__c == 'Decimal'){
                    rwMt.put(strAPIName, Decimal.valueOf((String)mapRwMat.get((String)add.get('PMC_CPQ_AttributeKey__c'))));
                    continue;
                }
				rwMt.put(strAPIName, mapRwMat.get((String)add.get('PMC_CPQ_AttributeKey__c')));
            }
        }
		SObjectAccessDecision securityDecisionQuoteLine = Security.stripInaccessible(AccessType.UPDATABLE, rawMtrl);
		Database.update(securityDecisionQuoteLine.getRecords(),false);
        PMC_CPQ_RawMaterialSummary.RawMaterialInfo(quoteId);

    }
    /** 
     * @description Return map of item number to Quoteline Id
     * @param quoteId - Id of the quote
     * @return mapQuoteLine - map of item number to quote line
     */
    public static map<String, SBQQ__QuoteLine__c> getQuoteLineMap(Id quoteId){
        List<SBQQ__QuoteLine__c> lstQuoteLines = [Select id, SBQQ__Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId WITH SECURITY_ENFORCED];
        Map<String, SBQQ__QuoteLine__c> mapQuoteLine = new Map<String, SBQQ__QuoteLine__c>();//map of Item_number and respective QuoteLine
        for(SBQQ__QuoteLine__c qtline: lstQuoteLines){
                mapQuoteLine.put((''+qtline.SBQQ__Number__c), qtline);
        }
        return mapQuoteLine;
    }
    /** 
     * @description Delete/Insert Raw Material records
     * @param diff - Difference between Raw materia response line and raw material on quote
     * @param quoteId - Id of the quote
     * @param rawMtrl - List of Raw Mat records
     * @return rawMtrl - map of item number to quote line
     */
    public static List<PMC_CPQ_RawMaterial__c> manangeRawMat(Integer diff, Id quoteId,List<PMC_CPQ_RawMaterial__c> rawMtrl){
        PMC_CPQ_RawMaterial__c rwMt;
        List<PMC_CPQ_RawMaterial__c> delRawMt = new List<PMC_CPQ_RawMaterial__c>();
        while(diff > 0){
				delRawMt.add(rawMtrl[(rawMtrl.size()-diff-1)]);
                rawMtrl.remove((rawMtrl.size()-diff-1));
                diff--;
            }
        if (!delRawMt.isEmpty() && Schema.sObjectType.PMC_CPQ_RawMaterial__c.isDeletable()) {
            delete delRawMt;
        }
        List<PMC_CPQ_RawMaterial__c> lstRmt = new List<PMC_CPQ_RawMaterial__c>();
		while(diff<0){
			rwMt = new PMC_CPQ_RawMaterial__c();
            rwMt.PMC_CPQ_Quote__c = quoteId;
            lstRmt.add(rwMt);
			diff++;
		}
		if(!lstRmt.isEmpty() && Schema.sObjectType.PMC_CPQ_RawMaterial__c.isCreateable()){
			Database.insert(lstRmt, false);
			rawMtrl.addAll(lstRmt);
		}
        return rawMtrl;
            }
}