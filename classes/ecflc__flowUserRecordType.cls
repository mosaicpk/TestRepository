/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class flowUserRecordType {
    global flowUserRecordType() {

    }
    @InvocableMethod(label='Get Available Record Types' description='Send in the Object Name and receive a list of Record Types available to the User')
    global static List<ecflc.flowUserRecordType.getRecordTypeResult> getRecordTypes(List<ecflc.flowUserRecordType.getRecordTypeRequest> SObjectName) {
        return null;
    }
global class getRecordTypeRequest {
    @InvocableVariable(label='Enter Object API Name - Example - Account or Custom_Object__c' required=true)
    global String sObjString;
    global getRecordTypeRequest() {

    }
}
global class getRecordTypeResult {
    @InvocableVariable(label='Default Record Type Id' required=false)
    global String rtDefault;
    @InvocableVariable(label='Record Type List' required=false)
    global List<RecordType> rtList;
    @InvocableVariable(label='Object' required=false)
    global String sObj;
    global getRecordTypeResult() {

    }
}
}
