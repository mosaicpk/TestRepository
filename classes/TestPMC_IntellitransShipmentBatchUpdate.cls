@isTest
public class TestPMC_IntellitransShipmentBatchUpdate {
    
    @isTest
    static void testBatchUpdate() {
        // Create test records for PMC_Shipment_Data__c
        List<PMC_Shipment_Data__c> shipmentDataList = new List<PMC_Shipment_Data__c>();
        
        for (Integer i = 0; i < 5; i++) {
            shipmentDataList.add(new PMC_Shipment_Data__c(
                PMC_PONUMBER__c = 'PO' + i,
                PMC_EQUIPMENTID__c = 'EQUIP' + i,
                	
                PMC_ETA__c = Date.today().addDays(i),
                PMC_Deliveries_Updated__c = false
            ));
        }
        insert shipmentDataList;
        
        // Create test records for shipment
        List<shipment> shipmentList = new List<shipment>();
        
        for (Integer i = 0; i < 5; i++) {
            shipmentList.add(new shipment(
                PMC_CPQ_PO__c = 'PO' + i,
                PMC_CPQ_VehicleID__c = 'EQUIP' + i,
                PMC_CPQ_ETA__c = Date.today().addDays(i + 1), // different dates to verify update
                PMC_CPQ_CurrentCarrier__c = 'OldCarrier' + i,
                PMC_CPQ_TowName__c = 'OldTowName' + i,
                PMC_CPQ_CurrentLocation__c = 'OldLocation' + i,
                PMC_CPQ_Carrier__c = 'OldCarrierDest' + i,
                PMC_CPQ_CurrentCoordinates__Latitude__s = 0,
                PMC_CPQ_CurrentCoordinates__Longitude__s = 0,
                ShipToName = 'Test'
            ));
        }
        insert shipmentList;
        
        // Start the batch process
        Test.startTest();
        PMC_IntellitransShipmentBatchUpdate batch = new PMC_IntellitransShipmentBatchUpdate();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        // Verify the updates on PMC_Shipment_Data__c records
        List<PMC_Shipment_Data__c> updatedShipmentDataList = [SELECT PMC_Deliveries_Updated__c FROM PMC_Shipment_Data__c];
        
        for (PMC_Shipment_Data__c data : updatedShipmentDataList) {
            System.assertEquals(true, data.PMC_Deliveries_Updated__c, 'Expected PMC_Deliveries_Updated__c to be true');
        }
        
        // Verify the updates on shipment records
        List<shipment> updatedShipmentList = [SELECT PMC_CPQ_ETA__c, PMC_CPQ_CurrentCarrier__c, PMC_CPQ_TowName__c, PMC_CPQ_CurrentLocation__c, PMC_CPQ_Carrier__c, PMC_CPQ_CurrentCoordinates__Latitude__s, PMC_CPQ_CurrentCoordinates__Longitude__s FROM shipment];
        
        for (Integer i = 0; i < updatedShipmentList.size(); i++) {
            shipment ship = updatedShipmentList[i];
            PMC_Shipment_Data__c matchedShipmentData = shipmentDataList[i];
            
            // Validate if the values have been updated correctly
            System.assertEquals(matchedShipmentData.PMC_ETA__c, ship.PMC_CPQ_ETA__c, 'Expected PMC_CPQ_ETA__c to be updated');
            System.assertEquals(matchedShipmentData.PMC_CURRENTCARRIER__c, ship.PMC_CPQ_CurrentCarrier__c, 'Expected PMC_CPQ_CurrentCarrier__c to be updated');
            System.assertEquals(matchedShipmentData.PMC_FLEETTOWNAME__c, ship.PMC_CPQ_TowName__c, 'Expected PMC_CPQ_TowName__c to be updated');
            System.assertEquals(matchedShipmentData.PMC_CURRENTLOCATION__c, ship.PMC_CPQ_CurrentLocation__c, 'Expected PMC_CPQ_CurrentLocation__c to be updated');
            System.assertEquals(matchedShipmentData.PMC_DESTINATIONCARRIER__c, ship.PMC_CPQ_Carrier__c, 'Expected PMC_CPQ_Carrier__c to be updated');
            System.assertEquals(matchedShipmentData.PMC_CPQ_CurrentCoordinates__Latitude__s, ship.PMC_CPQ_CurrentCoordinates__Latitude__s, 'Expected PMC_CPQ_CurrentCoordinates__Latitude__s to be updated');
            System.assertEquals(matchedShipmentData.PMC_CPQ_CurrentCoordinates__Longitude__s, ship.PMC_CPQ_CurrentCoordinates__Longitude__s, 'Expected PMC_CPQ_CurrentCoordinates__Longitude__s to be updated');
        }
    }
}