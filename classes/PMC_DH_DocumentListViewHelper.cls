/**
* @description       : Helper class for fetching Document History
* @author            : @Nikhilesh
* @last modified on    10-25-2023
* @last modified by    Nikhilesh Mohanty
* @Created on        : 10-25-2023
**/

public without sharing class PMC_DH_DocumentListViewHelper {
    private static final List<String> NA_COUNTRIES = new List<String>{'United States', 'Canada'};
        private static final String BRAZIL_COUNTRY = 'Brazil';
    /**
* @description       : Class for Searching and Filtering Documents
* @author            : @Mosaic Direct Dev
* @Created on        : 10-26-2023
* @return            : String
* @param              searchParams
* @param              strEffectiveAccId
**/
 public static List<OrderItem> getDocumentSearchQuery(PMC_DH_DocumentSearchParameterWrapper searchParams, String strEffectiveAccId){
        System.debug('Entering getDocumentSearchQuery...');
        System.debug('searchParams: ' + searchParams);
        System.debug('strEffectiveAccId: ' + strEffectiveAccId);
        
        Map<String, Date> mapDateValues = getDateFilters(searchParams);
        System.debug('mapDateValues: ' + mapDateValues);
        
        Date datFromDate = mapDateValues.get('datFromDate');
        Date datToDate = mapDateValues.get('datToDate');
        System.debug('datFromDate: ' + datFromDate);
        System.debug('datToDate: ' + datToDate);
        
        String strQuery = 'SELECT Id,PMC_CPQ_LinePONumber__c, Order.OrderNumber,Order.Contract.SBQQ__Quote__r.PMC_CPQ_SAPContractReference__c,Order.Contract.SBQQ__Quote__c, Order.PMC_CPQ_SAPOrderNumber__c, Order.PMC_DH_SAPOrderCreatedDate__c,';
        strQuery += ' (SELECT Id, PMC_CPQ_Invoice__r.PMC_CPQ_InvoiceNumber__c, PMC_CPQ_Invoice__r.Nota_Fiscal_Number__c, PMC_CPQ_Invoice__r.PMC_DH_SAPInvoiceCreatedDate__c,PMC_CPQ_Invoice__r.PMC_CPQ_BillingDocType__c FROM InvoiceItems__r WHERE PMC_CPQ_Invoice__r.PMC_DH_SAPInvoiceCreatedDate__c >= ' + String.valueOf(datFromDate) + ' AND PMC_CPQ_Invoice__r.PMC_DH_SAPInvoiceCreatedDate__c <= ' + String.valueOf(datToDate) + '),';
        strQuery += ' (SELECT Id, Shipment.ShipmentNumber, Shipment.PMC_CPQ_SAPDeliveryID__c, ShipmentItemNumber, ShipmentItem.PMC_CPQ_DeliveryItemID__c, Shipment.PMC_DH_SAPDeliveryCreatedDate__c, Shipment.PMC_CPQ_VehicleID__c FROM Delivery_Items__r WHERE Shipment.PMC_DH_SAPDeliveryCreatedDate__c >= ' + String.valueOf(datFromDate) + ' AND Shipment.PMC_DH_SAPDeliveryCreatedDate__c <= ' + String.valueOf(datToDate) + ')';
        strQuery += ' FROM OrderItem WHERE Order.AccountId = :strEffectiveAccId AND Order.PMC_DH_SAPOrderCreatedDate__c != null';
        strQuery += ' AND Order.PMC_DH_OrderTypeCode__c IN ';
        strQuery += Label.PMC_DH_OrderTypesForDocuments;
        System.debug('Initial strQuery: ' + strQuery);
        String InitQuery=strQuery;
        String queryRes = strQuery+' WITH SYSTEM_MODE Order BY Order.PMC_DH_SAPOrderCreatedDate__c DESC LIMIT 1001'.replace('\\', '');
        
        List<OrderItem> lstDocument = new List<OrderItem>();
        if (String.isBlank(searchParams.strSearchTerm)) {
            lstDocument = Database.query(queryRes);
        }
        Map<Id,OrderItem> finalMapFromList = new Map<Id,OrderItem>(lstDocument);
        
        
        String strSearchPattern3;
        if (String.isNotBlank(searchParams.strSearchTerm)) {
            System.debug('searchParams.strSearchTerm is not blank: ' + searchParams.strSearchTerm);
            
            String strSearchPattern = searchParams.strSearchTerm;
            System.debug('strSearchPattern: ' + strSearchPattern);
            
            List<String> lstSearchPatterns = strSearchPattern.split('_');
            System.debug('lstSearchPatterns: ' + lstSearchPatterns);
            
            String strSearchPattern1;
            String strSearchPattern2;
            
            if (lstSearchPatterns.size() > 1) {
                strSearchPattern3 = lstSearchPatterns[0];
                strSearchPattern1 = '\'%' + String.escapeSingleQuotes(lstSearchPatterns[0]) + '%\'';
                strSearchPattern2 = '\'%' + String.escapeSingleQuotes(lstSearchPatterns[1]) + '%\'';
                System.debug('strSearchPattern3: ' + strSearchPattern3);
                System.debug('strSearchPattern1: ' + strSearchPattern1);
                System.debug('strSearchPattern2: ' + strSearchPattern2);
            } else {
                strSearchPattern2 = '\'%' + String.escapeSingleQuotes(lstSearchPatterns[0]) + '%\'';
                System.debug('Single search pattern, strSearchPattern1: ' + strSearchPattern2);
            }
            
            Map<String, String> mapOfAllDocTypes = getMapOfAllDocTypes();
            System.debug('mapOfAllDocTypes: ' + mapOfAllDocTypes);
           // String strQuery1 = InitQuery+' AND (Id IN(SELECT PMC_CPQ_OrderProduct__c,,Shipment.PMC_CPQ_SAPDeliveryID__c,Shipment.PMC_CPQ_DeliveryItemID__c ,Shipment.PMC_CPQ_VehicleID__c FROM ShipmentItem WHERE Shipment.PMC_CPQ_SAPDeliveryID__c LIKE ' + strSearchPattern2 + ' OR ShipmentItem.PMC_CPQ_DeliveryItemID__c LIKE ' + strSearchPattern2 + ' OR Shipment.PMC_CPQ_VehicleID__c LIKE ' + strSearchPattern2 + '))';
             String strQuery1 = InitQuery+' AND (Id IN(SELECT PMC_CPQ_OrderProduct__c FROM ShipmentItem WHERE Shipment.PMC_CPQ_SAPDeliveryID__c LIKE ' + strSearchPattern2 + ' OR ShipmentItem.PMC_CPQ_DeliveryItemID__c LIKE ' + strSearchPattern2 + ' OR Shipment.PMC_CPQ_VehicleID__c LIKE ' + strSearchPattern2 + '))';

            String queryRes1 = strQuery1+' WITH SYSTEM_MODE Order BY Order.PMC_DH_SAPOrderCreatedDate__c DESC LIMIT 1001'.replace('\\', '');
            List<OrderItem> lstDocument1 = Database.query(queryRes1);
            Map<Id,OrderItem> MapFromList1 = new Map<Id,OrderItem>(lstDocument1);
            finalMapFromList.putAll(MapFromList1);
            strQuery1='';
            strQuery1 = InitQuery+' AND (Id IN(SELECT PMC_CPQ_OrderProduct__c FROM PMC_CPQ_InvoiceItem__c WHERE PMC_CPQ_Invoice__r.PMC_CPQ_InvoiceNumber__c LIKE ' + strSearchPattern2 + '))';
            
            String queryRes3 = strQuery1+' WITH SYSTEM_MODE Order BY Order.PMC_DH_SAPOrderCreatedDate__c DESC LIMIT 1001'.replace('\\', '');
            lstDocument = Database.query(queryRes3);
            strQuery1='';
            Map<Id,OrderItem> MapFromList2 = new Map<Id,OrderItem>(lstDocument);
            finalMapFromList.putAll(MapFromList2);
            strQuery1 =InitQuery+' AND ((Order.PMC_CPQ_SAPOrderNumber__c LIKE ' + strSearchPattern2 + ')';
            //New Change
            strQuery1 += ' OR (Order.Contract.SBQQ__Quote__r.PMC_CPQ_SAPContractReference__c LIKE '+strSearchPattern2+')';
            strQuery1 += ' OR (Order.Contract.SBQQ__Quote__r.Name LIKE '+strSearchPattern2+')';
            strQuery1 += ' OR (PMC_CPQ_LinePONumber__c LIKE '+strSearchPattern2+'))';
            
            String queryRes2 = strQuery1+' WITH SYSTEM_MODE Order BY Order.PMC_DH_SAPOrderCreatedDate__c DESC LIMIT 1001'.replace('\\', '');
            lstDocument = Database.query(queryRes2);
            strQuery1='';
            Map<Id,OrderItem> MapFromList3 = new Map<Id,OrderItem>(lstDocument);
            finalMapFromList.putAll(MapFromList3);
            
            /*  if (strSearchPattern3 == 'BillOfLading' || strSearchPattern3 == 'CertificateOfAnalysis') {
strQuery += ' AND (Id IN(SELECT PMC_CPQ_OrderProduct__c FROM ShipmentItem WHERE Shipment.PMC_CPQ_SAPDeliveryID__c LIKE ' + strSearchPattern2 + ' OR ShipmentItem.PMC_CPQ_DeliveryItemID__c LIKE ' + strSearchPattern2 + ' OR Shipment.PMC_CPQ_VehicleID__c LIKE ' + strSearchPattern2 + '))';
System.debug('Updated strQuery for BillOfLading/CertificateOfAnalysis: ' + strQuery);
} else if (strSearchPattern3 == 'CreditMemo' || strSearchPattern3 == 'DebitMemo' || strSearchPattern3 == 'Invoice' || strSearchPattern3 == 'NotaFiscal') {
strQuery += ' AND (Id IN(SELECT PMC_CPQ_OrderProduct__c FROM PMC_CPQ_InvoiceItem__c WHERE PMC_CPQ_Invoice__r.PMC_CPQ_InvoiceNumber__c LIKE ' + strSearchPattern2 + '))';

System.debug('Updated strQuery for CreditMemo/DebitMemo/Invoice/NotaFiscal: ' + strQuery);
} else {
strQuery += ' AND ((Order.PMC_CPQ_SAPOrderNumber__c LIKE ' + strSearchPattern1 + ')';
//New Change
strQuery += ' OR (Order.Contract.SBQQ__Quote__r.PMC_CPQ_SAPContractReference__c LIKE '+strSearchPattern1+')';
strQuery += ' OR (Order.Contract.SBQQ__Quote__r.Name LIKE '+strSearchPattern1+')';
strQuery += ' OR (Order.Contract.SBQQ__Quote__r.PMC_CPQ_PO__c LIKE '+strSearchPattern1+'))';
// strQuery += ' OR (Order.Contract.SBQQ__Quote__c LIKE ' + strSearchPattern1 + '))';

System.debug('Updated strQuery for default case: ' + strQuery);
}*/
        }
        Set<Id> allIds=finalMapFromList.keySet();
        
        InitQuery +='AND ID IN:allIds WITH SYSTEM_MODE Order BY Order.PMC_DH_SAPOrderCreatedDate__c DESC LIMIT 1001';
        System.debug('Final strQuery: ' + InitQuery);
        String queryResFinal = InitQuery.replace('\\', '');
        List<OrderItem> lstDocumentFinal = new List<OrderItem>();
        //lstDocument = Database.query(String.escapeSingleQuotes(queryRes).replace('\\', ''));
        // added espace single quotes in the getDocumentSearchQuery method.
        lstDocumentFinal = Database.query(queryResFinal);
        System.debug('Exiting getDocumentSearchQuery...');
        return lstDocumentFinal;
    }  
    /**
* @description       : Class for get Map of All Doc Types From Custom Metadata 
* @author            : @Mosaic Direct Dev 
* @Created on        : 10-29-2023
* @return             Map<String, String>
**/   
    
    
    public static Map<String, String> getMapOfAllDocTypes() {
        return getMapOfAllDocTypes(null); // Overloaded method called with null for default behavior
    }
    
    public static Map<String, String> getMapOfAllDocTypes(Map<String, PMC_DH_DocumentType__mdt> mockMetadata) {
        // Use mockMetadata if provided, otherwise get metadata using standard getAll()
        Map<String, PMC_DH_DocumentType__mdt> mapDocTypeMetadata = 
            (mockMetadata != null) ? mockMetadata : PMC_DH_DocumentType__mdt.getAll();
        Map<String, String> mapDocTypes = new Map<String, String>();
        
        for (PMC_DH_DocumentType__mdt mdt : mapDocTypeMetadata.values()) {
            mapDocTypes.put(mdt.DeveloperName, mdt.Label);
        }
        
        return mapDocTypes;
    }
    /**
* @description       : Class for Filtering Documents based on DocumentType
* @author            : @Mosaic Direct Dev 
* @Created on        : 10-29-2023
* @return            : String
* @param              searchParams
**/
    
    public static Map<String, Date> getDateFilters(PMC_DH_DocumentSearchParameterWrapper searchParams){
        Map<String, Date> mapValues = new Map<String,Date>();
        if (searchParams.datFromDate != null && searchParams.datToDate != null){
            mapValues.put('datFromDate',searchParams.datFromDate);
            mapValues.put('datToDate',searchParams.datToDate);
        }
        else{
            mapValues.put('datFromDate',Date.today().addMonths(-13));
            mapValues.put('datToDate',Date.today());
        }
        return mapValues;
    }
    
    /**
* @description       : Class for Searching Documents based on DocumentType
* @author            : @Mosaic Direct Dev 
* @Created on        : 10-26-2023
* @return            : List<PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper>
* @param              lstDocumentInfoWrapper
* @param              searchParams
**/
    public static List<PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper> getDocumentsbyDocType(List<PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper> lstDocumentInfoWrapper, PMC_DH_DocumentSearchParameterWrapper searchParams){
        List<PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper> lstDocumentInfo = new List<PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper>();
        if(String.isNotBlank(searchParams.documentType)){
            
            String strSearchPatternInput =searchParams.documentType;
             List<String> lstSearchPatterns = new List<String>();
            lstSearchPatterns = strSearchPatternInput.split('_');
             String strSearchPattern = lstSearchPatterns[0];
                        Map<String, PMC_DH_DocumentType__mdt> mapDocTypeMetadata = PMC_DH_DocumentType__mdt.getAll();
            

           
            Map<String, String> mapTypes=getMapOfAllDocTypes(mapDocTypeMetadata);
            
            for(PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper docInfo : lstDocumentInfoWrapper){
               
                if(docInfo.strDocumentType == mapTypes.get(strSearchPattern)){
                    lstDocumentInfo.add(docInfo);
                }    
            }
        } 
        if(lstDocumentInfo.isEmpty()){
            lstDocumentInfo.addAll(lstDocumentInfoWrapper);
        }
        return lstDocumentInfo;
    }
    
    /**
* @description       : Class for getting the list of document types
* @author            : @Mosaic Direct Dev 
* @Created on        : 10-26-2023
* @return            : List<PMC_DH_PicklistWrapper>
* @param              lstDocumentWrapper
* @param              searchParams
**/
    public static List<PMC_DH_PicklistWrapper> getDocTypes(List<PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper> lstDocumentWrapper, PMC_DH_DocumentSearchParameterWrapper searchParams){
        List<PMC_DH_PicklistWrapper> lstTotalDocTypes = new List<PMC_DH_PicklistWrapper>();
        if(String.isNotBlank(searchParams.strSearchTerm)){
            String strSearchPatternInput =searchParams.strSearchTerm;
            List<String> lstSearchPatterns = new List<String>();
            lstSearchPatterns = strSearchPatternInput.split('_');
            String strSearchPattern = lstSearchPatterns[0];
            for(PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper doctype : lstDocumentWrapper){
                PMC_DH_PicklistWrapper documentWrapper = new PMC_DH_PicklistWrapper();  
                if(doctype.strDocumentType == strSearchPattern){
                    documentWrapper.label = doctype.strDocumentType;
                    documentWrapper.value = doctype.strDocumentType;
                    lstTotalDocTypes.add(documentWrapper);           
                }
            }
        }  
        if(lstTotalDocTypes.isEmpty()){
            for(PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper doctype : lstDocumentWrapper){
                PMC_DH_PicklistWrapper documentWrapper = new PMC_DH_PicklistWrapper();  
                documentWrapper.label = doctype.strDocumentType;
                documentWrapper.value = doctype.strDocumentType;
                lstTotalDocTypes.add(documentWrapper);           
            }
        } 
        return lstTotalDocTypes;
    }
    
    
    /**
* @description       : Class for getting document type information
* @author            : @Nikhilesh
* @Created on        : 10-26-2023
* @return            : PMC_DH_DocIdentifierWrapper
* @param              mdt
* @param              invItem
**/
    public static PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper getDocTypeInfo(
        PMC_DH_DocumentType__mdt mdt, PMC_CPQ_InvoiceItem__c invItem) {
            
            PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper docIdWrapper = 
                new PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper();
            
            if (mdt != null) {
                docIdWrapper.strIdentifierType = mdt.PMC_DH_Identifier__c;
                docIdWrapper.strDocCode = mdt.PMC_DH_DocumentCode__c;
                docIdWrapper.strDocType = mdt.Label;
            }
            
            if (invItem != null && invItem.PMC_CPQ_Invoice__r != null) {
                docIdWrapper.datIdentifierDate = invItem.PMC_CPQ_Invoice__r.PMC_DH_SAPInvoiceCreatedDate__c;
                
                Map<String, String> mapIdentifierNameToValue = new Map<String, String>();
                mapIdentifierNameToValue.put(
                    mdt.PMC_DH_Identifier__c, 
                    invItem.PMC_CPQ_Invoice__r.PMC_CPQ_InvoiceNumber__c
                );
                docIdWrapper.mapIdentifier = mapIdentifierNameToValue;
            }
            system.debug('docIdWrapper'+docIdWrapper.mapIdentifier);
            return docIdWrapper;
        }
    
    /**
* @description       : Class for getting document type information
* @author            : @Nikhilesh
* @Created on        : 10-26-2023
* @return            : PMC_DH_DocIdentifierWrapper
* @param              mdt
* @param              shipmentItem
**/
    public static PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper getDocTypeInfo(PMC_DH_DocumentType__mdt mdt, ShipmentItem shipmentItem){
        PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper docIdWrapper = new PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper();
        Map<String, String> mapIdentifierNameToValue = new Map<String, String>();
        System.debug('--- Processing shipmentItem: ' + JSON.serialize(shipmentItem));
        docIdWrapper.strDocCode = mdt.PMC_DH_DocumentCode__c ; // 'BOL' / 'COA'
        docIdWrapper.strDocType = mdt.Label; 
       
        docIdWrapper.datIdentifierDate = shipmentItem.Shipment.PMC_DH_SAPDeliveryCreatedDate__c; // si.Shipment.PMC_DH_SAPDeliveryCreatedDate__c
        
        if(mdt.PMC_DH_DocumentCode__c == 'BOL'){
            docIdWrapper.strIdentifierType = mdt.PMC_DH_Identifier__c; // Delivery Number / DeliveryItemNumber
            mapIdentifierNameToValue.put(mdt.PMC_DH_Identifier__c, shipmentItem.Shipment.PMC_CPQ_SAPDeliveryID__c);
        }
        else{ // COA
            String strIdentifierType = mdt.PMC_DH_Identifier__c.split(';')[1];
            docIdWrapper.strIdentifierType = strIdentifierType; // Delivery Number;DeliveryItemNumber
            mapIdentifierNameToValue.put(mdt.PMC_DH_Identifier__c.split(';')[0], shipmentItem.Shipment.PMC_CPQ_SAPDeliveryID__c);
            mapIdentifierNameToValue.put(strIdentifierType, shipmentItem.PMC_CPQ_DeliveryItemID__c);
        }
        
        docIdWrapper.mapIdentifier = mapIdentifierNameToValue;
        return docIdWrapper;
    }
    
    /**
* @description       : Class for updating the middle map
* @author            : @Nikhilesh
* @Created on        : 10-26-2023
* @return            : Map<String, Map<String, List<DocIdentifierWrapper>>>
* @param              mapIdentifierToInnerMap
* @param              mapIdentifierToList
* @param              doc
**/
    public static Map<String, Map<String, List<PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper>>> getMiddleMap(Map<String, Map<String, List<PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper>>> mapIdentifierToInnerMap, Map<String, List<PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper>> mapIdentifierToList, PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper doc){
        String strIdentifierValue = doc.mapIdentifier.get(doc.strIdentifierType);
        if(!mapIdentifierToInnerMap.containsKey(doc.strIdentifierType)){
            mapIdentifierToInnerMap.put(doc.strIdentifierType, new Map<String, List<PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper>>{strIdentifierValue => new List<PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper>{doc}});
        }
        else{
            List<PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper> lstDocWrapper = mapIdentifierToList.get(strIdentifierValue);
            Map<String, List<PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper>> mapIdToList = new Map<String, List<PMC_DH_DocumentListViewController.PMC_DH_DocIdentifierWrapper>>{strIdentifierValue => lstDocWrapper};
                mapIdentifierToInnerMap.put(doc.strIdentifierType, mapIdToList); 
        }
        return mapIdentifierToInnerMap;
    }
    /**
* @description       : Class for getting the identifier-document type map
* @author            : @Nikhilesh
* @Created on        : 10-26-2023
* @return            : Map<String, List<String>>
* @param               lstMetadata
**/
    public static Map<String, List<String>> getIdentifierToDocTypeMap(List<PMC_DH_DocumentType__mdt> lstMetadata){
        Map<String, List<String>> mapIdentifierToDocType = new Map<String, List<String>>();
        for(PMC_DH_DocumentType__mdt mdt : lstMetaData){
            List<String> lstDocTypes;
            if(mapIdentifierToDocType.get(mdt.PMC_DH_Identifier__c) == null){
                lstDocTypes = new List<String>();
            }
            else{
                lstDocTypes = mapIdentifierToDocType.get(mdt.PMC_DH_Identifier__c);
            }
            lstDocTypes.add(mdt.DeveloperName);
            mapIdentifierToDocType.put(mdt.PMC_DH_Identifier__c, lstDocTypes);
        }
        return mapIdentifierToDocType;
    }
    
    /**
* * @description       : Wrapper for the Search Params
* * @author            : Mosaic Direct Dev 
* * @Created on        : 10-26-2023
**/
    public class PMC_DH_DocumentSearchParameterWrapper {
        /**
* * @description String searchterm
* * @return String
* */
        @AuraEnabled
        public String strSearchTerm { get; set; }
        /**
* * @description String documentType
* * @return String
* */
        @AuraEnabled
        public String documentType { get; set; }

        /**
* * @description Date of From date
* * @return Date
* */
        @AuraEnabled
        public Date datFromDate { get; set; }
        /**
* * @description Date of To date
* * @return Date
* */
        @AuraEnabled
        public  Date datToDate { get; set; }
    }
    
}