public without sharing class PMC_CPQ_GenerateContract {
    @AuraEnabled(cacheable=true)
    public static String generateContract(String quoteId) {
        System.debug('Received Quote ID : ' + quoteId);
        // Query Quote and related Quote Lines with Incoterms
        List<SBQQ__Quote__c> quotes = [ 
            SELECT Id, Name, PMC_CPQ_ContractShippingInstructions__c, PMC_CLM_Region__c, PMC_CPQ_ContractLanguage__c,
            (SELECT Id, PMC_CPQ_Incoterms1__c 
             FROM SBQQ__LineItems__r 
             WHERE PMC_CPQ_Incoterms1__c = 'CIF' 
             LIMIT 1)
            FROM SBQQ__Quote__c  
            WHERE Id = :quoteId  
            LIMIT 1
        ];
                System.debug('Queries Executed : ' + quotes.size());

        if(quotes.isEmpty()){
            throw buildException('Quote not found or access denied.');
            
        }
        SBQQ__Quote__c quote = quotes[0];
        
        // Check 1: Validate CIF lines and Shipping Instructions
        if (!quote.SBQQ__LineItems__r.isEmpty() && String.isBlank(quote.PMC_CPQ_ContractShippingInstructions__c)) {
            throw buildException(System.Label.pmc_shipping_ins);
        }
        // Check 2: Region and Language validation
        if (quote.PMC_CLM_Region__c?.toLowerCase() != 'brazil') {
            
            throw buildException('Contract generation is only available for Brazil region.');
        }
        return getContractUrl(quote);
    }

    // Helper method to build URL
    private static String getContractUrl(SBQQ__Quote__c quote) {
        String aid = EnvironmentChecker.getValueBySandboxAlias('31298', new Map<String,String> {
            'devp1' => '98018',
            'qa' => '116096',
            'uat' => '102552'
        });
        
        return String.format(
            'https://uatna11.springcm.com/atlas/doclauncher/OneClickDocGen?' +
            'aid={0}&config=Brazil Contrato {1}&eos[0].Id={2}&eos[0].System=Salesforce' +
            '&eos[0].Type=SBQQ__Quote__c&eos[0].Name={3}&eos[0].ScmPath=/Salesforce/Quote/',
            new List<String> {
                aid,
                quote.PMC_CPQ_ContractLanguage__c,
                quote.Id,
                EncodingUtil.urlEncode(quote.Name, 'UTF-8')
            }
        );
           
    }

    private static Exception buildException(String msg) {
        if(Test.isRunningTest()) {
            return new CustomException(msg);
        } else {
            return new AuraHandledException(msg);
        }
    }
}