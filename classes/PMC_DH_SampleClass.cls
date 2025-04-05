public without sharing class PMC_DH_SampleClass {
	@AuraEnabled
    public static PMC_DH_DocumentListViewWrapper getSampleRecords(){
        PMC_DH_DocumentListViewWrapper docWrapper = new PMC_DH_DocumentListViewWrapper();
        List<PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper> lstDocInfoWrapper = new List<PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper>();
        List<String> lstDocTypes = new List<String>{'Invoice', 'Credit Memo', 'Bill of Lading'};
        List<String> lstDocCodes = new List<String>{'INV', 'CRM', 'BOL'};
        for(Integer i = 0; i < 10000; i++){
			PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper docInfo = new PMC_DH_DocumentListViewWrapper.DocumentInfoWrapper();
            Integer mod = Math.mod(i,3);
            
            docInfo.strOrderNumber = '000'+mod;
            docInfo.strDocumentType = lstDocTypes[mod];
            docInfo.strDocumentName = lstDocTypes[mod] + docInfo.strOrderNumber;
            docInfo.datDocumentAddedDate = Date.today().addDays(mod);
            //docInfo.strDocumentIdentifier = 'ID-'+mod;
            String identifier = 'ID-'+mod;
            Map<String, String> mapIdentifier = new Map<String, String>();
            mapIdentifier.put('Billing Document Number',identifier);
            
            docInfo.mapDocumentIdentifier = mapIdentifier;
            docInfo.strDocumentCode = lstDocCodes[mod];
            lstDocInfoWrapper.add(docInfo);
            System.debug('>>> '+ docInfo);
        }
        docWrapper.lstDocuments = lstDocInfoWrapper;
        System.debug(lstDocInfoWrapper.size());
        return docWrapper;
    }
}