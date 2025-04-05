public class PMC_IntellitransShipmentBatchUpdate implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable  {

   
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([ select Id,PMC_BOL__c, PMC_BOLNUMBER__c, PMC_COMMENTS__c, PMC_CPQ_CurrentCoordinates__c, PMC_CPQ_CurrentCoordinates__Latitude__s, PMC_CPQ_CurrentCoordinates__Longitude__s, PMC_CPQ_SAPDeliveryID__c, PMC_CPQ_Shipment_PO__c, PMC_CPQ_ShipmentNumber__c, PMC_CURRENTCARRIER__c, PMC_CURRENTLOCATION__c, PMC_CUSTORDERNO__c, PMC_DELIVERYNUMBER__c, PMC_DESTINATIONCARRIER__c, PMC_DESTINATIONMM__c, PMC_EQUIPMENTID__c, PMC_ETA__c, PMC_FLEETTOWNAME__c, PMC_LATESTINTERNALCOMMENT__c, PMC_LATESTTRIPSIGHTINGID__c, PMC_PONUMBER__c, PMC_SHIPMENTNUMBER_CNTORDER__c, PMC_SIGHTINGDESTINATION__c, PMC_SIGHTINGLOADOREMPTY__c,PMC_Deliveries_Updated__c  from PMC_Shipment_Data__c where PMC_CUSTORDERNO__c != null and PMC_EQUIPMENTID__c !=null and PMC_Deliveries_Updated__c = FALSE ]);
    }

    public void execute(SchedulableContext objSchedulableContext){
        
        Database.executeBatch(new PMC_IntellitransShipmentBatchUpdate(), 200);
    }

    public void execute(Database.BatchableContext BC, List<PMC_Shipment_Data__c> scope) {
        // Maps to hold 
        Map<String, PMC_Shipment_Data__c> IntellitransmapPO = new Map<String, PMC_Shipment_Data__c>();
        Map<String, PMC_Shipment_Data__c> IntellitransmapVID = new Map<String, PMC_Shipment_Data__c>();
         Map<String, PMC_Shipment_Data__c> IntellitransmapConcat = new Map<String, PMC_Shipment_Data__c>();
        
        // Populate the maps with Itelli trans
        for (PMC_Shipment_Data__c ls : scope) {
            if (ls.PMC_CUSTORDERNO__c != null) {
                IntellitransmapPO.put(ls.PMC_CUSTORDERNO__c, ls);
            }
            if (ls.PMC_EQUIPMENTID__c != null) {
                IntellitransmapVID.put(ls.PMC_EQUIPMENTID__c, ls);
            }
            IntellitransmapConcat.put(ls.PMC_CUSTORDERNO__c+ls.PMC_EQUIPMENTID__c,ls);
        }

       
        List<shipment> shiplst = [select id,PMC_CPQ_Order__r.PMC_CPQ_SAPOrderNumber__c,PMC_CPQ_SAPDeliveryID__c,PMC_CPQ_ETA__c,PMC_CPQ_PO__c,PMC_CPQ_VehicleID__c,PMC_CPQ_CurrentCarrier__c,PMC_CPQ_Carrier__c,PMC_CPQ_TowName__c,PMC_CPQ_CurrentLocation__c,PMC_CPQ_CurrentCoordinates__Latitude__s, PMC_CPQ_CurrentCoordinates__Longitude__s 


  from shipment where PMC_CPQ_Order__r.PMC_CPQ_SAPOrderNumber__c  IN :IntellitransmapPO.keySet() 
                                          OR PMC_CPQ_VehicleID__c IN :IntellitransmapVID.keySet()];
                                          
                                          list<PMC_Shipment_Data__c> lstUpdateProcessedRecords = new list<PMC_Shipment_Data__c>();

        

        for (shipment ship : shiplst) {
            PMC_Shipment_Data__c matchedIntellitrans;
          

            
            if (IntellitransmapPO.containsKey(ship.PMC_CPQ_Order__r.PMC_CPQ_SAPOrderNumber__c) && IntellitransmapVID.containsKey(ship.PMC_CPQ_VehicleID__c)) {
                if(IntellitransmapConcat.containsKey(ship.PMC_CPQ_Order__r.PMC_CPQ_SAPOrderNumber__c+ship.PMC_CPQ_VehicleID__c)){
                    matchedIntellitrans = IntellitransmapConcat.get(ship.PMC_CPQ_Order__r.PMC_CPQ_SAPOrderNumber__c+ship.PMC_CPQ_VehicleID__c);
                    PMC_Shipment_Data__c IntelliTrans = new PMC_Shipment_Data__c(Id = matchedIntellitrans.Id, PMC_Deliveries_Updated__c = True);
                    lstUpdateProcessedRecords.add(IntelliTrans);
                }
                
            }
            
            if (matchedIntellitrans != null) {
                //ship.Id = matchedIntellitrans.Id;
                //ship.PMC_CPQ_SAPDeliveryID__c = matchedIntellitrans.PMC_CPQ_SAPDeliveryID__c;
               if(matchedIntellitrans.PMC_ETA__c!=null){
                	Date currentDate = matchedIntellitrans.PMC_ETA__c.date();
                	ship.PMC_CPQ_ETA__c = date.valueof(currentDate);
                }
                //ship.PMC_CPQ_PO__c = matchedIntellitrans.PMC_CPQ_SAPDeliveryID__c;
                //ship.PMC_CPQ_VehicleID__c = matchedIntellitrans.PMC_CPQ_SAPDeliveryID__c;
                ship.PMC_CPQ_CurrentCarrier__c = matchedIntellitrans.PMC_CURRENTCARRIER__c;
                //ship.PMC_CPQ_Carrier__c = matchedIntellitrans.PMC_CPQ_SAPDeliveryID__c;
                ship.PMC_CPQ_TowName__c = matchedIntellitrans.PMC_FLEETTOWNAME__c;
                ship.PMC_CPQ_CurrentLocation__c = matchedIntellitrans.PMC_CURRENTLOCATION__c;
                ship.PMC_CPQ_Carrier__c = matchedIntellitrans.PMC_DESTINATIONCARRIER__c;
                ship.PMC_CPQ_CurrentCoordinates__Latitude__s = matchedIntellitrans.PMC_CPQ_CurrentCoordinates__Latitude__s;
                ship.PMC_CPQ_CurrentCoordinates__Longitude__s = matchedIntellitrans.PMC_CPQ_CurrentCoordinates__Longitude__s;
               
            }
        }


        // Perform the update
        if (!shiplst.isEmpty()) {
            map<id,shipment> mp1 = new map<id,shipment>();
            mp1.putall(shiplst);
            Database.update(mp1.values(),false);
            
        }
         if (!lstUpdateProcessedRecords.isEmpty()) {
            map<id,PMC_Shipment_Data__c> mp = new map<id,PMC_Shipment_Data__c>();
            mp.putall(lstUpdateProcessedRecords);
            Database.update(mp.values(),false);
            
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch processing finished.');
    }
}