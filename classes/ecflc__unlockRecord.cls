/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class unlockRecord {
    global unlockRecord() {

    }
    @InvocableMethod(label='Unlock Record')
    global static void unlockRecordInvocable(List<ecflc.unlockRecord.flowInput> fIs) {

    }
global class flowInput {
    @InvocableVariable(label='System Unlock' description='User needs Unlock Without Sharing Permission and System Unlock to be True to run unlock a record in system mode.' required=false)
    global Boolean systemUnlock;
    @InvocableVariable(label='Unlock Record Id' required=true)
    global String unlockId;
    global flowInput() {

    }
}
}
