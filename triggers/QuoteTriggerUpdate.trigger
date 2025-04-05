trigger QuoteTriggerUpdate on SBQQ__Quote__c (after insert) {
    List<Contract> contractsToUpdate = new List<Contract>();
 
    for (SBQQ__Quote__c quote : Trigger.new) {
        // Check if the Quote is related to a Contract (assuming a lookup field ContractId__c exists)
        if (quote.Contract_Blocked__c != null) {
            // Query the related Contract record
            Contract relatedContract = [
                SELECT Id, PMC_CPQ_Contract_Blocked__c FROM Contract WHERE Id = :quote.Contract_Blocked__c
                LIMIT 1
            ];
 
            // Update the Contract record based on the Quote data
            if (relatedContract != null) {
                relatedContract.PMC_CPQ_Contract_Blocked__c = true; // Example logic
                contractsToUpdate.add(relatedContract);
            }
        }
    }
 
    // Perform the update on the Contract records if necessary
    if (!contractsToUpdate.isEmpty()) {
        update contractsToUpdate;
    }

}