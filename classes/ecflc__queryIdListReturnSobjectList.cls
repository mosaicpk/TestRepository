/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class queryIdListReturnSobjectList {
    global queryIdListReturnSobjectList() {

    }
    @InvocableMethod(label='Get Records WHERE Id is IN List')
    global static List<ecflc.queryIdListReturnSobjectList.outputs> getRecords(List<ecflc.queryIdListReturnSobjectList.inputs> inputList) {
        return null;
    }
global class inputs {
    @InvocableVariable(label='Text Collection Variable (Ids Only)' required=false)
    global List<String> idCollection;
    global inputs() {

    }
}
global class outputs {
    @InvocableVariable(label='Record Collection Variable' required=false)
    global List<SObject> sObjectCollection;
    global outputs() {

    }
}
}
