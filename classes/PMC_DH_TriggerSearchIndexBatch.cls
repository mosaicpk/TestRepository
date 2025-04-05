public with sharing class PMC_DH_TriggerSearchIndexBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext objBatchableContext){
        return Database.getQueryLocator([SELECT Id, Name FROM Webstore WHERE Name = 'Digital Hub']);
    }

    public void execute(Database.BatchableContext objBatchableContext, List<Webstore> objWebstore){
        String strWebstoreId = objWebstore[0].Id;
        ConnectApi.CommerceSearchIndex objResult = ConnectApi.CommerceSearchSettings.createCommerceSearchIndex(strWebstoreId);

    }

    public void finish(Database.BatchableContext objBatchableContext){
        
    }

    public void execute(SchedulableContext objSchedulableContext){
        Database.executeBatch(new PMC_DH_TriggerSearchIndexBatch());
    }

}