/**
 * @description       : Used to perform JSON for ServiceNow Ticket creation 
 * @author            : Vedashri
 * @last modified on  : 11-01-2023
**/

public  with sharing class PMC_SS_ServiceNowWrapper {
    private String u_customer_name;
    private String u_cod_customer;
    private String callerID ;
    private String u_request_type_paid_contracts;
    private String request_type;
    private String u_request_type; 
    private String u_customer_sap_code;
    private String u_business;
    private String u_due_date_payment;
    private String u_reason;
    private String u_program;
    private String u_abatement_contract;
    private String u_incident_number;
    private String u_email_customer_receipt;
    private String u_order_number_contract_or_invoice;
    private String u_email_client_circularisation_letter;
    private String u_initial_date_circularisation_letter;
    private String u_company_mosaic;
    private String u_client_name;
    private String u_segment_manager;
    private String u_warranty_type;
    private String u_operation_value;
    private String u_payee_name;
    private String u_type_of_warranty_cpr;
    private String u_type_of_warranty_mortage;
    private String u_payment_effective_date;
    private String u_endorsement_value;
    private String comments;
    /**
     * @description - Method used to fetch the Invoice Details related to Account Id
     * @param objCase - Case Object
     * @param strSolutionType -  Selected Soulution Type
     * @param strComments - Comments to send to ServiceNow
     */

    public PMC_SS_ServiceNowWrapper(Case objCase,String strSolutionType, String strComments){
        
        String strRequestTypeKey = label.PMC_SS_SNOW_RequestType_KeyValue;
        Map<String,String> mapRequestType = (Map<String,String>)JSON.deserialize(strRequestTypeKey, Map<String,String>.class);
        u_customer_name = objCase.Contact.Name;
        u_cod_customer = objCase.PMC_SS_SNOW_CustomerCode__c;
        u_warranty_type = objCase.PMC_SS_SNOW_WarrantyType__c;
        u_request_type_paid_contracts = request_type = u_request_type=  mapRequestType.containsKey(objCase.PMC_SS_SNOW_RequestType__c) ? mapRequestType.get(objCase.PMC_SS_SNOW_RequestType__c) :'';
        u_due_date_payment = u_payment_effective_date =  String.valueOf(objCase.PMC_SS_SNOW_ExactDateToBePaid__c);
        u_client_name = objCase.Contact.Name;
        //u_operation_value = objCase.PMC_SS_SNOW_FinancialOperationValue__c;
        u_segment_manager = objCase.PMC_SS_SNOW_SegmentManager__r.FederationIdentifier;
        //u_endorsement_value = objCase.PMC_SS_SNOW_EndorsementValue__c;
        u_payee_name = objCase.PMC_SS_SNOW_PayeeName__c;
        u_email_customer_receipt = objCase.ContactEmail;
        u_order_number_contract_or_invoice = objCase.PMC_SS_SNOW_OrderNumberorContractNumber__c;
        u_type_of_warranty_cpr = String.valueOf(objCase.PMC_SS_SNOW_CPR__c);
        u_type_of_warranty_mortage = String.valueOf(objCase.PMC_SS_SNOW_Mortage__c);
        u_customer_sap_code = objCase.PMC_SS_SAP_CustomerNumber__c;
        u_business = objCase.PMC_SS_SNOW_Business__c;
        u_reason = objCase.PMC_SS_SNOW_Reason__c;
        u_program = objCase.PMC_SS_SNOW_Program__c;
        u_abatement_contract = objCase.PMC_SS_SNOW_AbatementContractNumber__c;
        u_incident_number = objCase.CaseNumber;
       
        u_email_client_circularisation_letter = objCase.PMC_SS_SNOW_RecipientsofCirLetter__c;
        u_initial_date_circularisation_letter = String.valueOf(objCase.PMC_SS_SNOW_InitialRequestPeriod__c);
        u_company_mosaic = objCase.PMC_SS_SNOW_MosaicPayingReceivingCompany__c;
        //String strCustomerSAPCode = String.isBlank(objCase.PMC_SS_SAP_CustomerNumber__c) ? '' :objCase.PMC_SS_SAP_CustomerNumber__c;

        callerID = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() WITH SYSTEM_MODE].FederationIdentifier;
        comments = strComments;
         /*if(strSolutionType=='Release of Paid Contracts' || strSolutionType == 'Collections Portal')
        {
			
            String strContractNumber = objCase.PMC_SS_NewContract__c == null ? '':objCase.PMC_SS_NewContract__r.ContractNumber;
            Double dbContractValue = objCase.PMC_SS_NewContract__r.SBQQ__Quote__r.SBQQ__CustomerAmount__c == null ? 0:objCase.PMC_SS_NewContract__r.SBQQ__Quote__r.SBQQ__CustomerAmount__c;
            comments = 'Customer SAP Code:'+ strCustomerSAPCode+'\n Contract Number:'+strContractNumber +
                        '\n Contract Value:'+dbContractValue +'\n '+strComments;        
        }
        
       else if(strSolutionType == 'Use of Credits, Return, Receipt of Discharge and Reports')
        {
            String strInitialDate = objCase.PMC_SS_SNOW_InitialDate__c != null ? '\n Initial Date:'+ objCase.PMC_SS_SNOW_InitialDate__c : '';
            String strFinalDate = objCase.PMC_SS_SNOW_FinalDate__c != null ? '\n Final Date:'+ objCase.PMC_SS_SNOW_FinalDate__c : '';
            comments = 'Request Type:'+ objCase.PMC_SS_SNOW_RequestType__c+strInitialDate+strFinalDate+'\nCustomer SAP Code:'+ strCustomerSAPCode+'\n '+strComments;
        }
        else if(strSolutionType == 'Warranty Formalization' || strSolutionType == 'Perform Warranty' || strSolutionType == 'Debit or Credit Notes')
        {
            comments = strComments;
        }
        else if(strSolutionType == 'Customer Credit Analysis')
        {
            comments = 'Currency used in this analysis is:'+objCase.CurrencyIsoCode+'\n'+strComments;
        } 
        else if(strSolutionType == 'Circularization Letters')
        {
            String strCustomerSAPCode = String.isBlank(objCase.PMC_SS_SAP_CustomerNumber__c) ? '' :objCase.PMC_SS_SAP_CustomerNumber__c;
            comments = 'Customer SAP Code:'+ strCustomerSAPCode+'\n '+strComments;
        } */
    }
}