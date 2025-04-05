//This class is created by Vignesh and for testing - DO NOT USE or DELETE
public class TestVignesh {

    public TestVignesh(ApexPages.StandardController controller) {

    }

    
    Account acc = new Account();
    SBQQ__Quote__c quo = new SBQQ__Quote__c();
    List<SBQQ__QuoteLine__c> qlis = new List<SBQQ__QuoteLine__c>();
    Public String jsonString {get;set;}
    Public String gen3{get;set;}
    public TestVignesh(){
        /*acc = [select id,name,phone,billingcity,billingstate,billingpostalcode,billingcountry,
            shippingcity,shippingstate,shippingcountry,shippingpostalcode,type,website,
            PMC_SS_Division__c from Account where id ='001DT000013bKhhYAE'];
    
        jsonString = JSON.Serialize(acc);
        */
        
        //PMC_CPQ_Parent_Transaction_Id__c,
        //Removed PMC_CPQ_PO__c from the below query as a cleanup
        quo = [Select id,name,PMC_CPQ_SalesOrg__c,RecordType.Name,PMC_CPQ_PO__c,
                SBQQ__StartDate__c,SBQQ__EndDate__c,currencyISOCode from SBQQ__Quote__c where id='a3CDT000001SsZW2A0'];
        
        qlis = [Select id,name,SBQQ__Product__c,PMC_CPQ_HarvestPeriod__c,SBQQ__Quantity__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quo.id];
        
        //Generate the JSON that we are sending to the endpoint
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('Transaction_Id',quo.name);
        //if(quo.PMC_CPQ_Parent_Transaction_Id__c != null) { gen.writeStringField('Reference_Transaction_Id', quo.PMC_CPQ_Parent_Transaction_Id__c); }
        //gen.writeStringField('SALES_ORG',quo.PMC_CPQ_SalesOrg__c);
        gen.writeStringField('DIVISION',quo.Recordtype.name);
        //gen.writeStringField('PURCH_NO',quo.PMC_CPQ_PO__c);
        //gen.writeStringField('QT_VALID_F',quo.SBQQ__StartDate__c.format());
        //gen.writeStringField('QT_VALID_T',quo.SBQQ__EndDate__c.format());
        gen.writeFieldName('LineItemList');
        gen.writeStartArray();
        for(SBQQ__QuoteLine__c each: qlis) {
            gen.writeStartObject();
            gen.writeStringField('ITM_NUMBER', each.Id);
            gen.writeStringField('MATERIAL', each.SBQQ__Product__c);
            //gen.writeStringField('PURCH_NO_C', each.PMC_CPQ_HarvestPeriod__c);
            gen.writeStringField('REQ_QTY', String.valueOf(each.SBQQ__Quantity__c));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        System.debug(gen.getAsString());
        
        
        //Dynamic json generation using custom metadata
        List<Test_Vignesh__mdt> testMDT = new List<Test_Vignesh__mdt>();
        testMDT = [Select Attribute_Name__c,SF_API_Name__c from Test_Vignesh__mdt];
        
        List<Test_Vignesh_2__mdt> testMDT2 = new List<Test_Vignesh_2__mdt>();
        testMDT2 = [Select Attribute_Name__c,SF_API_Name__c from Test_Vignesh_2__mdt];
        
        JSONGenerator gen2 = JSON.createGenerator(false);
        gen2.writeStartObject();
        for(Test_Vignesh__mdt each: testMDT) {
        system.debug('!!!'+each.SF_API_Name__c);
            String[] fieldPath = each.SF_API_Name__c.split('\\.');
            Object referencedValue = null;            
            if (fieldPath.size() > 1) {
             // It is a reference
             SObject sobReference = quo.getSObject(fieldPath[0]);
             referencedValue = sobReference.get(fieldPath[1]);
              } else {
                 referencedValue = quo.get(fieldPath[0]);
              }
              if(referencedValue == null) {
                  referencedValue ='';
              }

            gen2.writeStringField(each.Attribute_Name__c, String.valueOf(referencedValue));
        }
        
        
        gen2.writeFieldName('LineItemList');
        gen2.writeStartArray();
        for(SBQQ__QuoteLine__c each: qlis) {
            gen2.writeStartObject();
            for(Test_Vignesh_2__mdt eachMDT: testMDT2) {
                String[] fieldPath = eachMDT.SF_API_Name__c.split('\\.');
                Object referencedValue = null;            
                if (fieldPath.size() > 1) {
                 // It is a reference
                 SObject sobReference = each.getSObject(fieldPath[0]);
                 referencedValue = sobReference.get(fieldPath[1]);
                  } else {
                     referencedValue = each.get(fieldPath[0]);
                  }
                  if(referencedValue == null) {
                      referencedValue ='';
                  }
    
                gen2.writeStringField(eachMDT.Attribute_Name__c, String.valueOf(referencedValue));
            }
            gen2.writeEndObject();
        }
        gen2.writeEndArray();
        gen2.writeEndObject();
        System.debug(gen2.getAsString());
        gen3 = gen2.getAsString();
    }

}