/** @description This is a utility class for external callouts.
 *  @author Gideoni Silva
 *  @storynumber EIDGT-550
 */
public without sharing class PMC_CPIAccountCalloutUtilityClass implements Database.AllowsCallouts {
    

    public static String strExceptionMsg; 
    public static HttpRequest request = new HttpRequest();
	public static String strBPGrouping;
	public static String strPartnerFunction;
	public static String strCNPJNumber;
	public static String strCPFNumber;
	public static String strLanguage;
	public static String strSearchTerm1;
	public static String strSearchTerm2;
	public static String strRUCPYOrg;
	public static String strRUCPYPerson;
	public static String strDivision;
	public static String strTaxClass;
	public static String strReconcAcc;
	public static String strLayoutSortingRule;
	public static String strCashPlanningGroup;
	public static String strToleranceGroup;
	public static String strInvDates;
	public static String strInvListSched;
	public static String strAcctAssmtGrpCust;
	public static String strTransportation;
	public static String strSerializedBody;
	public static String strNaturalPerson;
	public static String strCustomerTaxCategory;
	public static String strEffectiveAccountId;
	public static String strPhone;
	public static String strFax;
	public static String strSalesOrg;
	public static String strSalesOffice;
	public static String strSalesDistrict;
    public static String strSalesGroup;
    public static String strPaymentTerm;
    public static String strCustomerGroup;
    public static Boolean boolRecordPmntHistory;
    public static Map<String, Object> mapBusinessPartner;

    /** 
     * @description This method will make a callout to CPI.
     * @param strMethod - Method for external callout. eg. GET, POST, PATCH
     * @param strCalloutEndpoint - Concatenation of named credential and specific endpoint
     * @param strSerializedBody - Account Data.
     * @return response - Http Response.
     * @return null - If no response is returned.
     */
    public static HttpResponse sendCalloutRequest(String strMethod, String strCalloutEndpoint, String strSerializedBody)
    {
        String strIntegrationSettingsRecord = 'PMC_CPQ_IntegrationAutoRetrySettings';
        Integer intTimeoutValue = Integer.valueOf(PMC_CPQ_IntegrationSettings__mdt.getInstance(strIntegrationSettingsRecord).PMC_CPQ_SettingTwoValueNumber_c__c);
        request = new HttpRequest();
        HttpResponse response;
        Http http = new Http();
        String strContentType = 'Content-Type';
        String strContentTypeValue = 'application/json;charset=UTF-8';
        try
        {          
            request.setMethod(strMethod);
            request.setHeader(strContentType,strContentTypeValue);
            request.setEndpoint(strCalloutEndpoint);
            request.setBody(strSerializedBody);
            request.setTimeout(intTimeoutValue);
            response = http.send(request); 
            return response;
        }
        catch(Exception objException)
        {
            PMC_ErrorLogClass.processException(objException);
            strExceptionMsg = objException.getMessage();
            return null;
        }
    }

     /** 
     * @description This method will create the payload for Ship-to Business Partner Creation.
     * @param lstIds - List of ids.
     * @param JSONPayloadParams - Account parameters to create JSON Payload
     * @param strSerializedBody - Account Data in JSON format for the HTTP request.
     * @return response - Http Response.
     * @return null - If no data is returned.
     * @return strSerializedBody - Serialized Http Request Body.
     */
   public static String createShipToPayload(List<Id> lstIds, Map<String, String> JSONPayloadParams)
    {
		try
        {  
			for(Id curId : lstIds){ 
				strEffectiveAccountId = curId;
			}
        
			Account objAcc = [SELECT AccountNumber,BillingAddress,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,CurrencyIsoCode,Fax,Id,Industry,MasterRecordId,Name,OwnerId,Ownership,ParentId,Phone,PMC_DH_Account_Status__c,PMC_DH_Delivery_Instruction__c,PMC_DH_Email__c,PMC_DH_isProcessed__c,PMC_DH_StreetNumber__c,PMC_SS_AccountExternalID__c,PMC_SS_AddressDistrict__c,PMC_SS_AddressNumber__c,PMC_SS_Careof__c,PMC_SS_Channel__c,PMC_SS_CompanyCode__c,PMC_SS_ContractLanguage__c,PMC_SS_CounterpartyContact2__c,PMC_SS_CounterpartyContact__c,PMC_SS_CountyCode__c,PMC_SS_CPF__c,PMC_SS_CustomerType__c,PMC_SS_Division__c,PMC_SS_GLN__c,PMC_SS_Lockbox__c,PMC_SS_MDMVerified__c,PMC_SS_MunicipalTaxNumber__c,PMC_SS_Name2__c,PMC_SS_Name4__c,PMC_SS_OverdelTolerance__c,PMC_SS_POBox__c,PMC_SS_Property_farm_name__c,PMC_SS_ReconciliationAccount__c,PMC_SS_RecordType__c,PMC_SS_RUC__c,PMC_SS_SalesOrg__c,PMC_SS_SAPCustomerNumber__c,PMC_SS_Segmentation__c,PMC_SS_ShippingCondition__c,PMC_SS_SoldToAccount__c,PMC_SS_StateRegistrationNumber__c,PMC_SS_StateTaxNumber__c,PMC_SS_TaxIDOrCNPJOrCPF__c,PMC_SS_Transportation_Zone__c,PMC_SS_Underdeltolerance__c,PMC_SS_UnitofMeasure__c,PMC_SS_Veson__c,RecordTypeId,SourceSystemIdentifier,Type FROM Account Where Id=:strEffectiveAccountId];

			Datetime dtValidFrom = Datetime.now();
			Long lValidFrom = dtValidFrom.getTime();
			String strValidFrom = dtValidFrom.format('yyyy-MM-dd\'T\'HH:mm:ss');
			strPhone = objAcc.Phone ?? '';
			strFax = objAcc.Fax ?? '';
			strSalesOrg = objAcc.PMC_SS_SalesOrg__c ?? '';
			strBPGrouping = JSONPayloadParams.get('strBPGrouping');
			strPartnerFunction = JSONPayloadParams.get('strPartnerFunction');
			strCustomerTaxCategory = JSONPayloadParams.get('strCustomerTaxCategory');
			strLanguage = JSONPayloadParams.get('strLanguage');
			strReconcAcc = JSONPayloadParams.get('strReconcAcc');
			strAcctAssmtGrpCust = JSONPayloadParams.get('strAcctAssmtGrpCust');
			strTransportation = JSONPayloadParams.get('strTransportation');
			strCNPJNumber = JSONPayloadParams.get('strCNPJNumber');
			strCPFNumber = JSONPayloadParams.get('strCPFNumber');
			strRUCPYOrg = JSONPayloadParams.get('strRUCPYOrg');
			strRUCPYPerson = JSONPayloadParams.get('strRUCPYPerson');
			strSearchTerm1 = JSONPayloadParams.get('strSearchTerm1');
			strInvDates = JSONPayloadParams.get('strInvDates');
			strInvListSched = JSONPayloadParams.get('strInvListSched');
			strCashPlanningGroup = JSONPayloadParams.get('strCashPlanningGroup');
			strToleranceGroup = JSONPayloadParams.get('strToleranceGroup');
			strNaturalPerson = JSONPayloadParams.get('strNaturalPerson');
			strLayoutSortingRule = JSONPayloadParams.get('strLayoutSortingRule');
			strTaxClass = JSONPayloadParams.get('strTaxClass');
			strDivision = JSONPayloadParams.get('strDivision');		
		
			switch on objAcc.BillingCountryCode {
				when 'BR','PY' {
					boolRecordPmntHistory = true;
				}
				when 'PE', 'US', 'CA' {
					boolRecordPmntHistory = false;
				}
			}
		
			List<Map<String, Object>> lstBusinessPartnerTax = new List<Map<String, Object>>{};
			if (!String.isBlank(strCNPJNumber)) {
				Map<String, Object> mapCNPJNumber = new Map<String, Object>{};
				mapCNPJNumber.put('BPTaxType', 'BR1');
				mapCNPJNumber.put('BPTaxNumber', strCNPJNumber);
				lstBusinessPartnerTax.add(mapCNPJNumber);
			}                     
			if (!String.isBlank(strCPFNumber)) {
				Map<String, Object> mapCPFNumber = new Map<String, Object>{};
				mapCPFNumber.put('BPTaxType', 'BR2');
				mapCPFNumber.put('BPTaxNumber', strCPFNumber);
				lstBusinessPartnerTax.add(mapCPFNumber);
			}                
			if (!String.isBlank(objAcc.PMC_SS_StateTaxNumber__c)) {
				Map<String, Object> mapStateTaxNumber = new Map<String, Object>{};
				mapStateTaxNumber.put('BPTaxType', 'BR3');
				mapStateTaxNumber.put('BPTaxNumber', objAcc.PMC_SS_StateTaxNumber__c);
				lstBusinessPartnerTax.add(mapStateTaxNumber);                    
			}
			if (!String.isBlank(objAcc.PMC_SS_MunicipalTaxNumber__c)) {
				Map<String, Object> mapMunicipalTaxNumber = new Map<String, Object>{};
				mapMunicipalTaxNumber.put('BPTaxType', 'BR4');
				mapMunicipalTaxNumber.put('BPTaxNumber', objAcc.PMC_SS_MunicipalTaxNumber__c);
				lstBusinessPartnerTax.add(mapMunicipalTaxNumber);                    
			}
			if (!String.isBlank(strRUCPYOrg)) {
				Map<String, Object> mapRUCPYOrg = new Map<String, Object>{};
				mapRUCPYOrg.put('BPTaxType', 'PY1');
				mapRUCPYOrg.put('BPTaxNumber', strRUCPYOrg);
				lstBusinessPartnerTax.add(mapRUCPYOrg);                    
			} 
			if (!String.isBlank(strRUCPYPerson)) {
				Map<String, Object> mapRUCPYPerson = new Map<String, Object>{};
				mapRUCPYPerson.put('BPTaxType', 'PY2');
				mapRUCPYPerson.put('BPTaxNumber', strRUCPYPerson);
				lstBusinessPartnerTax.add(mapRUCPYPerson);                    
			}					
			mapBusinessPartner = new Map<String, Object>{
				'BusinessPartnerCategory' => '2',
				'BusinessPartnerGrouping' => strBPGrouping,
				'NameCountry' => objAcc.BillingCountryCode,
				'Language' => strLanguage,
				'OrganizationBPName1' => objAcc.Name,
				'OrganizationBPName2' => objAcc.PMC_SS_Name2__c ?? '',
				'OrganizationBPName3' => '',
				'OrganizationBPName4' => objAcc.PMC_SS_Name4__c ?? '',
				'SearchTerm1' => strSearchTerm1.left(20),
				'SearchTerm2' => '',
				'IsNaturalPerson' => strNaturalPerson,
				'to_BuPaIndustry' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'IndustrySector' => objAcc.Industry  ?? '',
						'IndustrySystemType' => '0001', //Fixed value 00 as per requirements from EIDGT-527
						'IsStandardIndustry' => 'X' //Fixed value 00 as per requirements from EIDGT-527
					}				
				},
				'to_BusinessPartnerAddress' => new List<Map<String, Object>>{
					new Map<String,Object>{
						'CareOfName' => objAcc.PMC_SS_Careof__c  ?? '',
						'StreetName' => objAcc.BillingStreet  ?? '',
						'HouseNumber' => objAcc.PMC_SS_AddressNumber__c  ?? '',
						'PostalCode' => objAcc.BillingPostalCode  ?? '',
						'CityName' => objAcc.BillingCity  ?? '',
						'Country' => objAcc.BillingCountryCode  ?? '',
						'Region' => objAcc.BillingStateCode  ?? '',
						'District' => objAcc.PMC_SS_AddressDistrict__c  ?? '',
						'TransportZone' => strTransportation  ?? '',
						'Language' => strLanguage,
						'POBox' => objAcc.PMC_SS_POBox__c  ?? '',
						'to_EmailAddress' => new List<Map<String, Object>>{
							new Map<String,Object> {
								'EmailAddress' => objAcc.PMC_DH_Email__c  ?? ''
							}
						},
						'to_PhoneNumber'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'PhoneNumber' => strPhone.replaceAll('[^0-9]', '')
							}
						},
						'to_FaxNumber'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'FaxNumber' => strFax.replaceAll('[^0-9]', '')
							}
						},
						'to_AddressUsage'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'AddressUsage' => 'XXDEFAULT',
								'ValidityEndDate' => '9999-12-31T23:59:59'
							}
						}   
					}
				},
				'to_BusinessPartnerRole' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'BusinessPartnerRole' => 'FLCU00',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					},
					new Map<String, Object>{
						'BusinessPartnerRole' => 'FLCU01',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					}
				},
				'to_BusinessPartnerTax' => lstBusinessPartnerTax,
				'to_Customer' => new Map<String, Object>{
					'Customer' => objAcc.PMC_SS_SAPCustomerNumber__c ?? '',
					'PostingIsBlocked' => false, 
					'ExpressTrainStationName' => objAcc.Id, 
					'CustomerClassification' => objAcc.PMC_SS_Segmentation__c  ?? '',
					'to_CustomerCompany' => new List<Map<String, Object>>{
						new Map<String, Object>{
							'CompanyCode' => strSalesOrg,
							'ReconciliationAccount' => strReconcAcc ?? '', //Fixed value South America: "110003" as per requirements from EIDGT-527
							'LayoutSortingRule' => strLayoutSortingRule, 
							'APARToleranceGroup'=> strToleranceGroup ?? '', //Fixed value South America: "KRE1" as per requirements from EIDGT-527
							'RecordPaymentHistoryIndicator' => boolRecordPmntHistory, //Fixed value South America: True from EIDGT-527
							'CashPlanningGroup' => strCashPlanningGroup ?? '' //Fixed value South America: "E1" as per requirements from EIDGT-527
						}
					},
					'to_CustomerSalesArea' => new List<Map<String, Object>>{
						new Map<String, Object>{
							'SalesOrganization' => strSalesOrg,
							'DistributionChannel' => '00', //Fixed value 00 as per requirements from EIDGT-527
							'Division' => strDivision,
							'SalesOffice' => '',
							'SalesDistrict' => '',
							'SalesGroup' => '',
							'CustomerPricingProcedure' => '1', //Fixed value 00 as per SAP API A2X Mapping Table
							'ItemOrderProbabilityInPercent' => '100', //Fixed value 00 as per SAP API A2X Mapping Table
							'Currency' => objAcc.CurrencyIsoCode,
							'OrderCombinationIsAllowed' => true, //Fixed value True as per SAP API A2X Mapping Table
							'ShippingCondition' => objAcc.PMC_SS_ShippingCondition__c ?? '',
							'untto' => objAcc.PMC_SS_Underdeltolerance__c,
							'uebto' => objAcc.PMC_SS_OverdelTolerance__c,
							'InvoiceDate' => strInvDates ?? '',        
							'InvoiceListSchedule' => strInvListSched ?? '',        
							'CustomerAccountAssignmentGroup' => strAcctAssmtGrpCust ?? '',
							'to_PartnerFunction' => new List<Map<String, Object>>{
								new Map<String, Object>{
									'PartnerCounter' => '', 
									'PartnerFunction' => strPartnerFunction,
									'BPCustomerNumber' => '',
									'CustomerPartnerDescription' => '',
									'DefaultPartner' => false
								}
							},
							'to_SalesAreaTax' => new List<Map<String, Object>>{
								new Map<String, Object>{
									'DepartureCountry' => objAcc.BillingCountryCode, 
									'CustomerTaxCategory' => strCustomerTaxCategory ?? '',
									'CustomerTaxClassification' => strTaxClass ?? ''
								}
							}
						}			
					}
				}
			};
            
			if (objAcc.BillingCountryCode == 'US' || objAcc.BillingCountryCode == 'CA' || objAcc.BillingCountryCode == 'PE') {
				mapBusinessPartner.remove('to_BusinessPartnerTax');
			}	

			strSerializedBody = JSON.serializePretty(mapBusinessPartner);
			return strSerializedBody;
		}
		catch(Exception objException)
        {
            PMC_ErrorLogClass.processException(objException);
            strExceptionMsg = objException.getMessage();
            return null;
        }
		
    }                   

     /** 
     * @description This method will create the payload for Sold-to Business Partner Creation.
     * @param lstIds - List of ids.
     * @param JSONPayloadParams - Account parameters to create JSON Payload
     * @param strSerializedBody - Account Data in JSON format for the HTTP request.
     * @return response - Http Response.
     * @return null - If no data is returned.
     * @return strSerializedBody - Serialized Http Request Body.
     */
 public static String createSoldToPayload(List<Id> lstIds, Map<String, String> JSONPayloadParams)
    {
		try
        {  
			for(Id curId : lstIds){ 
				strEffectiveAccountId = curId;
			}
        
			Account objAcc = [SELECT Account_Assignment_Group__c,AccountNumber,BillingAddress,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,CurrencyIsoCode,Customer_Group__c,Fax,Id,Industry,MasterRecordId,Name,Phone,PMC_SS_PaymentTerm__c,PMC_CPQ_Region__c,PMC_DH_Account_Status__c,PMC_DH_Email__c,PMC_DH_isProcessed__c,PMC_SS_AccountExternalID__c,PMC_SS_ActionPlan__c,PMC_SS_AddressDistrict__c,PMC_SS_AddressNumber__c,PMC_SS_AgentCode__c,PMC_SS_Agent__c,PMC_SS_BillToAccount__c,PMC_SS_Careof__c,PMC_SS_Channel__c,PMC_SS_ClientCode__c,PMC_SS_CompanyCode__c,PMC_SS_ContractLanguage__c,PMC_SS_CounterpartyContact2__c,PMC_SS_CounterpartyContact__c,PMC_SS_CountyCode__c,PMC_SS_CPF__c,PMC_SS_CustomerType__c,PMC_SS_Division__c,PMC_SS_GLN__c,PMC_SS_LinkCommissionsAgent__c,PMC_SS_Lockbox__c,PMC_SS_MDMVerified__c,PMC_SS_MunicipalTaxNumber__c,PMC_SS_Name2__c,PMC_SS_Name4__c,PMC_SS_OverdelTolerance__c,PMC_SS_PayerContact__c,PMC_SS_POBox__c,PMC_SS_ReconciliationAccount__c,PMC_SS_RecordType__c,PMC_SS_RegionalManager__c,PMC_SS_RUC__c,PMC_SS_SalesDirector__c,PMC_SS_SalesDistrict__c,Sales_Group__c,PMC_SS_SalesOffice__c,PMC_SS_SalesOrg__c,PMC_SS_SalesRegion__c,PMC_SS_SAPCustomerNumber__c,PMC_SS_Segmentation__c,PMC_SS_ShippingCondition__c,PMC_SS_SoldToAccount__c,PMC_SS_StateRegistrationNumber__c,PMC_SS_StateTaxNumber__c,PMC_SS_TaxIDOrCNPJOrCPF__c,PMC_SS_Transportation_Zone__c,PMC_SS_Underdeltolerance__c,PMC_SS_Veson__c,RecordTypeId,SBQQ__TaxExempt__c,SourceSystemIdentifier,Team_Accounts_Attribute_4__c,Sales_Channel_Attribute_5__c,Country_Region_Attribute_6__c,Sales_Region_Attribute_7__c,Type FROM Account Where Id=:strEffectiveAccountId];

			Datetime dtValidFrom = Datetime.now();
			Long lValidFrom = dtValidFrom.getTime();
			String strValidFrom = dtValidFrom.format('yyyy-MM-dd\'T\'HH:mm:ss');
			strPhone = objAcc.Phone ?? '';
			strFax = objAcc.Fax ?? '';
			strSalesOrg = objAcc.PMC_SS_SalesOrg__c ?? '';
			strSalesOffice = objAcc.PMC_SS_SalesOffice__c ?? '';
			strSalesDistrict = objAcc.PMC_SS_SalesDistrict__c ?? '';
			strSalesGroup = objAcc.Sales_Group__c ?? '';
			strPaymentTerm = objAcc.PMC_SS_PaymentTerm__c ?? '';
			strCustomerGroup = objAcc.Customer_Group__c ?? '';
			strBPGrouping = JSONPayloadParams.get('strBPGrouping');
			strPartnerFunction = JSONPayloadParams.get('strPartnerFunction');
			strCustomerTaxCategory = JSONPayloadParams.get('strCustomerTaxCategory');
			strLanguage = JSONPayloadParams.get('strLanguage');
			strReconcAcc = JSONPayloadParams.get('strReconcAcc');
			strAcctAssmtGrpCust = JSONPayloadParams.get('strAcctAssmtGrpCust');
			strTransportation = JSONPayloadParams.get('strTransportation');
			strCNPJNumber = JSONPayloadParams.get('strCNPJNumber');
			strCPFNumber = JSONPayloadParams.get('strCPFNumber');
			strRUCPYOrg = JSONPayloadParams.get('strRUCPYOrg');
			strRUCPYPerson = JSONPayloadParams.get('strRUCPYPerson');
			strSearchTerm1 = JSONPayloadParams.get('strSearchTerm1');
			strInvDates = JSONPayloadParams.get('strInvDates');
			strInvListSched = JSONPayloadParams.get('strInvListSched');
			strCashPlanningGroup = JSONPayloadParams.get('strCashPlanningGroup');
			strToleranceGroup = JSONPayloadParams.get('strToleranceGroup');
			strNaturalPerson = JSONPayloadParams.get('strNaturalPerson');
			strLayoutSortingRule = JSONPayloadParams.get('strLayoutSortingRule');
			strTaxClass = JSONPayloadParams.get('strTaxClass');
			strDivision = JSONPayloadParams.get('strDivision');		

			switch on objAcc.BillingCountryCode {
				when 'BR','PY' {
					boolRecordPmntHistory = true;
				}
				when 'PE', 'US', 'CA' {
					boolRecordPmntHistory = false;
				}
			}
		
			List<Map<String, Object>> lstBusinessPartnerTax = new List<Map<String, Object>>{};
			if (!String.isBlank(strCNPJNumber)) {
				Map<String, Object> mapCNPJNumber = new Map<String, Object>{};
				mapCNPJNumber.put('BPTaxType', 'BR1');
				mapCNPJNumber.put('BPTaxNumber', strCNPJNumber);
				lstBusinessPartnerTax.add(mapCNPJNumber);
			}                     
			if (!String.isBlank(strCPFNumber)) {
				Map<String, Object> mapCPFNumber = new Map<String, Object>{};
				mapCPFNumber.put('BPTaxType', 'BR2');
				mapCPFNumber.put('BPTaxNumber', strCPFNumber);
				lstBusinessPartnerTax.add(mapCPFNumber);
			}                
			if (!String.isBlank(objAcc.PMC_SS_StateTaxNumber__c)) {
				Map<String, Object> mapStateTaxNumber = new Map<String, Object>{};
				mapStateTaxNumber.put('BPTaxType', 'BR3');
				mapStateTaxNumber.put('BPTaxNumber', objAcc.PMC_SS_StateTaxNumber__c);
				lstBusinessPartnerTax.add(mapStateTaxNumber);                    
			}
			if (!String.isBlank(objAcc.PMC_SS_MunicipalTaxNumber__c)) {
				Map<String, Object> mapMunicipalTaxNumber = new Map<String, Object>{};
				mapMunicipalTaxNumber.put('BPTaxType', 'BR4');
				mapMunicipalTaxNumber.put('BPTaxNumber', objAcc.PMC_SS_MunicipalTaxNumber__c);
				lstBusinessPartnerTax.add(mapMunicipalTaxNumber);                    
			}
			if (!String.isBlank(strRUCPYOrg)) {
				Map<String, Object> mapRUCPYOrg = new Map<String, Object>{};
				mapRUCPYOrg.put('BPTaxType', 'PY1');
				mapRUCPYOrg.put('BPTaxNumber', strRUCPYOrg);
				lstBusinessPartnerTax.add(mapRUCPYOrg);                    
			} 
			if (!String.isBlank(strRUCPYPerson)) {
				Map<String, Object> mapRUCPYPerson = new Map<String, Object>{};
				mapRUCPYPerson.put('BPTaxType', 'PY2');
				mapRUCPYPerson.put('BPTaxNumber', strRUCPYPerson);
				lstBusinessPartnerTax.add(mapRUCPYPerson);                    
			}
			
			mapBusinessPartner = new Map<String, Object>{
				'BusinessPartnerCategory' => '2', //Fixed value 2 as per requirement
				'BusinessPartnerGrouping' => strBPGrouping,
				'NameCountry' => objAcc.BillingCountryCode,
				'Language' => strLanguage,
				'OrganizationBPName1' => objAcc.Name,
				'OrganizationBPName2' => objAcc.PMC_SS_Name2__c ?? '',
				'OrganizationBPName3' => '',
				'OrganizationBPName4' => objAcc.PMC_SS_Name4__c ?? '',
				'SearchTerm1' => strSearchTerm1.left(20),
				'SearchTerm2' => '',
				'IsNaturalPerson' => strNaturalPerson,
				'to_BuPaIndustry' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'IndustrySector' => objAcc.Industry  ?? '',
						'IndustrySystemType' => '0001', //Fixed value 0001 as per requirement
						'IsStandardIndustry' => 'X' //Fixed value 00 as per requirement
					}				
				},
				'to_BusinessPartnerAddress' => new List<Map<String, Object>>{
					new Map<String,Object>{
						'CareOfName' => objAcc.PMC_SS_Careof__c  ?? '',
						'StreetName' => objAcc.BillingStreet  ?? '',
						'HouseNumber' => objAcc.PMC_SS_AddressNumber__c  ?? '',
						'PostalCode' => objAcc.BillingPostalCode  ?? '',
						'CityName' => objAcc.BillingCity  ?? '',
						'Country' => objAcc.BillingCountryCode  ?? '',
						'Region' => objAcc.BillingStateCode  ?? '',
						'District' => objAcc.PMC_SS_AddressDistrict__c  ?? '',
						'TransportZone' => strTransportation  ?? '',
						'Language' => strLanguage,
						'POBox' => objAcc.PMC_SS_POBox__c  ?? '',
						'to_EmailAddress' => new List<Map<String, Object>>{
							new Map<String,Object> {
								'EmailAddress' => objAcc.PMC_DH_Email__c  ?? ''
							}
						},
						'to_PhoneNumber'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'PhoneNumber' => strPhone.replaceAll('[^0-9]', '')
							}
						},
						'to_FaxNumber'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'FaxNumber' => strFax.replaceAll('[^0-9]', '')
							}
						},
						'to_AddressUsage'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'AddressUsage' => 'XXDEFAULT',
								'ValidityEndDate' => '9999-12-31T23:59:59'
							}
						}   
					}
				},
				'to_BusinessPartnerRole' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'BusinessPartnerRole' => 'FLCU00',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					},
					new Map<String, Object>{
						'BusinessPartnerRole' => 'FLCU01',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					},
					new Map<String, Object>{
						'BusinessPartnerRole' => 'UKM000',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					}
				},
				'to_BusinessPartnerTax' => lstBusinessPartnerTax,
				'to_Customer' => new Map<String, Object>{
					'Customer' => objAcc.PMC_SS_SAPCustomerNumber__c ?? '',
					'ExpressTrainStationName' => objAcc.Id, 
					'CustomerClassification' => objAcc.PMC_SS_Segmentation__c  ?? '',
					'katr2' => '',
					'katr4' => objAcc.Team_Accounts_Attribute_4__c ?? '',
					'katr5' => objAcc.Sales_Channel_Attribute_5__c ?? '',
					'katr6' => objAcc.Country_Region_Attribute_6__c ?? '',  
					'katr7' => objAcc.Sales_Region_Attribute_7__c ?? '',                              
					'to_CustomerCompany' => new List<Map<String, Object>>{
						new Map<String, Object>{
							'CompanyCode' => strSalesOrg, //Same value as Sales Org
							'ReconciliationAccount' => strReconcAcc,
							'LayoutSortingRule' => strLayoutSortingRule,
							'CashPlanningGroup' => strCashPlanningGroup,
							'APARToleranceGroup'=> strToleranceGroup, 
							'RecordPaymentHistoryIndicator' => boolRecordPmntHistory,
							'PaymentMethodsList' => '',
							'PaymentTerms' => strPaymentTerm
						}
					},
					'to_CustomerSalesArea' => new List<Map<String, Object>>{
						new Map<String, Object>{
							'SalesOrganization' => strSalesOrg,
							'DistributionChannel' => '00', //Fixed value 00 as per requirements from EIDGT-849
							'Division' => strDivision,
							'SalesOffice' => strSalesOffice,
							'SalesDistrict' => strSalesDistrict,
							'SalesGroup' => strSalesGroup,
							'CustomerPricingProcedure' => '1', //Fixed value 00 as per SAP API A2X Mapping Table
							'ItemOrderProbabilityInPercent' => '100', //Fixed value 00 as per SAP API A2X Mapping Table
							'Currency' => objAcc.CurrencyIsoCode,
							'OrderCombinationIsAllowed' => true, //Fixed value True as per SAP API A2X Mapping Table
							'ShippingCondition' => objAcc.PMC_SS_ShippingCondition__c ?? '',
							'InvoiceDate' => strInvDates ?? '',        
							'InvoiceListSchedule' => strInvListSched ?? '',                                      
							'CustomerAccountAssignmentGroup' => strAcctAssmtGrpCust ?? '',
							'CustomerGroup' => strCustomerGroup,
							'IncotermsLocation1' =>'',
							'IncotermsClassification' => '',
							'untto' => objAcc.PMC_SS_Underdeltolerance__c,
							'uebto' => objAcc.PMC_SS_OverdelTolerance__c,                                    
							'to_PartnerFunction' => new List<Map<String, Object>>{
								new Map<String, Object>{
									'PartnerCounter' => '', 
									'PartnerFunction' => strPartnerFunction,
									'BPCustomerNumber' => '',
									'CustomerPartnerDescription' => '',
									'DefaultPartner' => false
								}
							},
							'to_SalesAreaTax' => new List<Map<String, Object>>{
								new Map<String, Object>{
									'DepartureCountry' => objAcc.BillingCountryCode, 
									'CustomerTaxCategory' => strCustomerTaxCategory,
									'CustomerTaxClassification' => strTaxClass
								}
							}
						}			
					}
				}
			};
				
			if (objAcc.BillingCountryCode == 'US' || objAcc.BillingCountryCode == 'CA' || objAcc.BillingCountryCode == 'PE') {
				mapBusinessPartner.remove('to_BusinessPartnerTax');
			}	

			strSerializedBody = JSON.serializePretty(mapBusinessPartner);
			return strSerializedBody;
		}
		catch(Exception objException)
        {
            PMC_ErrorLogClass.processException(objException);
            strExceptionMsg = objException.getMessage();
            return null;
        }
    } 
     /** 
     * @description This method will create the payload for Bill-to Business Partner Creation.
     * @param lstIds - List of ids.
     * @param JSONPayloadParams - Account parameters to create JSON Payload
     * @param strSerializedBody - Account Data in JSON format for the HTTP request.
     * @return response - Http Response.
     * @return null - If no data is returned.
     * @return strSerializedBody - Serialized Http Request Body.
     */
    public static String createBillToPayload(List<Id> lstIds, Map<String, String> JSONPayloadParams)
    {
		try
        {  
			for(Id curId : lstIds){ 
				strEffectiveAccountId = curId;
			}
			
			Account objAcc = [SELECT Account_Assignment_Group__c,Customer_Group__c,AccountNumber,BillingAddress,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,CurrencyIsoCode,Fax,Id,Industry,MasterRecordId,Name,Phone,PMC_SS_PaymentTerm__c,PMC_CPQ_Region__c,PMC_DH_Account_Status__c,PMC_DH_Email__c,PMC_DH_isProcessed__c,PMC_SS_AddressDistrict__c,PMC_SS_AddressNumber__c,PMC_SS_BillToAccount__c,PMC_SS_Careof__c,PMC_SS_Channel__c,PMC_SS_CompanyCode__c,PMC_SS_ContractLanguage__c,PMC_SS_CPF__c,PMC_SS_CustomerType__c,PMC_SS_Division__c,PMC_SS_GLN__c,PMC_SS_Lockbox__c,PMC_SS_MDMVerified__c,PMC_SS_MunicipalTaxNumber__c,PMC_SS_Name2__c,PMC_SS_Name4__c,PMC_SS_OverdelTolerance__c,PMC_SS_PayerContact__c,PMC_SS_POBox__c,PMC_SS_ReconciliationAccount__c,PMC_SS_RecordType__c,PMC_SS_RegionalManager__c,PMC_SS_RUC__c,PMC_SS_SalesDirector__c,Sales_Group__c,PMC_SS_SalesDistrict__c,PMC_SS_SalesOffice__c,PMC_SS_SalesOrg__c,PMC_SS_SalesRegion__c,PMC_SS_SAPCustomerNumber__c,PMC_SS_Segmentation__c,PMC_SS_ShippingCondition__c,PMC_SS_SoldToAccount__c,PMC_SS_StateRegistrationNumber__c,PMC_SS_StateTaxNumber__c,PMC_SS_TaxIDOrCNPJOrCPF__c,PMC_SS_Transportation_Zone__c,PMC_SS_Underdeltolerance__c,PMC_SS_UnitofMeasure__c,PMC_SS_Veson__c,RecordTypeId,SourceSystemIdentifier,Team_Accounts_Attribute_4__c,Sales_Channel_Attribute_5__c,Country_Region_Attribute_6__c,Sales_Region_Attribute_7__c,Type FROM Account Where Id=:strEffectiveAccountId];

			Datetime dtValidFrom = Datetime.now();
			Long lValidFrom = dtValidFrom.getTime();
			String strValidFrom = dtValidFrom.format('yyyy-MM-dd\'T\'HH:mm:ss');
			strPhone = objAcc.Phone ?? '';
			strFax = objAcc.Fax ?? '';
			strSalesOrg = objAcc.PMC_SS_SalesOrg__c ?? '';
			strSalesOffice = objAcc.PMC_SS_SalesOffice__c ?? '';
			strSalesDistrict = objAcc.PMC_SS_SalesDistrict__c ?? '';
			strSalesGroup = objAcc.Sales_Group__c ?? '';
			strPaymentTerm = objAcc.PMC_SS_PaymentTerm__c ?? '';
			strCustomerGroup = objAcc.Customer_Group__c ?? '';
			strBPGrouping = JSONPayloadParams.get('strBPGrouping');
			strPartnerFunction = JSONPayloadParams.get('strPartnerFunction');
			strCustomerTaxCategory = JSONPayloadParams.get('strCustomerTaxCategory');
			strLanguage = JSONPayloadParams.get('strLanguage');
			strReconcAcc = JSONPayloadParams.get('strReconcAcc');
			strAcctAssmtGrpCust = JSONPayloadParams.get('strAcctAssmtGrpCust');
			strTransportation = JSONPayloadParams.get('strTransportation');
			strCNPJNumber = JSONPayloadParams.get('strCNPJNumber');
			strCPFNumber = JSONPayloadParams.get('strCPFNumber');
			strRUCPYOrg = JSONPayloadParams.get('strRUCPYOrg');
			strRUCPYPerson = JSONPayloadParams.get('strRUCPYPerson');
			strSearchTerm1 = JSONPayloadParams.get('strSearchTerm1');
			strInvDates = JSONPayloadParams.get('strInvDates');
			strInvListSched = JSONPayloadParams.get('strInvListSched');
			strCashPlanningGroup = JSONPayloadParams.get('strCashPlanningGroup');
			strToleranceGroup = JSONPayloadParams.get('strToleranceGroup');
			strNaturalPerson = JSONPayloadParams.get('strNaturalPerson');
			strLayoutSortingRule = JSONPayloadParams.get('strLayoutSortingRule');
			strTaxClass = JSONPayloadParams.get('strTaxClass');
			strDivision = JSONPayloadParams.get('strDivision');	

			switch on objAcc.BillingCountryCode {
				when 'BR','PY' {
					boolRecordPmntHistory = true;
				}
				when 'PE', 'US', 'CA' {
					boolRecordPmntHistory = false;
				}
			}

			List<Map<String, Object>> lstBusinessPartnerTax = new List<Map<String, Object>>{};
			if (!String.isBlank(strCNPJNumber)) {
				Map<String, Object> mapCNPJNumber = new Map<String, Object>{};
				mapCNPJNumber.put('BPTaxType', 'BR1');
				mapCNPJNumber.put('BPTaxNumber', strCNPJNumber);
				lstBusinessPartnerTax.add(mapCNPJNumber);
			}                     
			if (!String.isBlank(strCPFNumber)) {
				Map<String, Object> mapCPFNumber = new Map<String, Object>{};
				mapCPFNumber.put('BPTaxType', 'BR2');
				mapCPFNumber.put('BPTaxNumber', strCPFNumber);
				lstBusinessPartnerTax.add(mapCPFNumber);
			}                
			if (!String.isBlank(objAcc.PMC_SS_StateTaxNumber__c)) {
				Map<String, Object> mapStateTaxNumber = new Map<String, Object>{};
				mapStateTaxNumber.put('BPTaxType', 'BR3');
				mapStateTaxNumber.put('BPTaxNumber', objAcc.PMC_SS_StateTaxNumber__c);
				lstBusinessPartnerTax.add(mapStateTaxNumber);                    
			}
			if (!String.isBlank(objAcc.PMC_SS_MunicipalTaxNumber__c)) {
				Map<String, Object> mapMunicipalTaxNumber = new Map<String, Object>{};
				mapMunicipalTaxNumber.put('BPTaxType', 'BR4');
				mapMunicipalTaxNumber.put('BPTaxNumber', objAcc.PMC_SS_MunicipalTaxNumber__c);
				lstBusinessPartnerTax.add(mapMunicipalTaxNumber);                    
			}
			if (!String.isBlank(strRUCPYOrg)) {
				Map<String, Object> mapRUCPYOrg = new Map<String, Object>{};
				mapRUCPYOrg.put('BPTaxType', 'PY1');
				mapRUCPYOrg.put('BPTaxNumber', strRUCPYOrg);
				lstBusinessPartnerTax.add(mapRUCPYOrg);                    
			} 
			if (!String.isBlank(strRUCPYPerson)) {
				Map<String, Object> mapRUCPYPerson = new Map<String, Object>{};
				mapRUCPYPerson.put('BPTaxType', 'PY2');
				mapRUCPYPerson.put('BPTaxNumber', strRUCPYPerson);
				lstBusinessPartnerTax.add(mapRUCPYPerson);                    
			}					
			mapBusinessPartner = new Map<String, Object>{
				'BusinessPartnerCategory' => '2', //Fixed value 2 as per requirements
				'BusinessPartnerGrouping' => strBPGrouping,
				'NameCountry' => objAcc.BillingCountryCode,
				'Language' => strLanguage,
				'OrganizationBPName1' => objAcc.Name,
				'OrganizationBPName2' => objAcc.PMC_SS_Name2__c ?? '',
				'OrganizationBPName3' => '',
				'OrganizationBPName4' => objAcc.PMC_SS_Name4__c ?? '',
				'SearchTerm1' => strSearchTerm1.left(20),
				'SearchTerm2' => '',
				'IsNaturalPerson' => strNaturalPerson,
				'to_BuPaIndustry' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'IndustrySector' => objAcc.Industry  ?? '',
						'IndustrySystemType' => '0001', //Fixed value 00 as per requirements from EIDGT-527
						'IsStandardIndustry' => 'X' //Fixed value 00 as per requirements from EIDGT-527
					}				
				},
				'to_BusinessPartnerAddress' => new List<Map<String, Object>>{
					new Map<String,Object>{
						'CareOfName' => objAcc.PMC_SS_Careof__c  ?? '',
						'StreetName' => objAcc.BillingStreet  ?? '',
						'HouseNumber' => objAcc.PMC_SS_AddressNumber__c  ?? '',
						'PostalCode' => objAcc.BillingPostalCode  ?? '',
						'CityName' => objAcc.BillingCity  ?? '',
						'Country' => objAcc.BillingCountryCode  ?? '',
						'Region' => objAcc.BillingStateCode  ?? '',
						'District' => objAcc.PMC_SS_AddressDistrict__c  ?? '',
						'TransportZone' => strTransportation  ?? '',
						'Language' => strLanguage,
						'POBox' => objAcc.PMC_SS_POBox__c  ?? '',
						'to_EmailAddress' => new List<Map<String, Object>>{
							new Map<String,Object> {
								'EmailAddress' => objAcc.PMC_DH_Email__c  ?? ''
							}
						},
						'to_PhoneNumber'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'PhoneNumber' => strPhone.replaceAll('[^0-9]', '')
							}
						},
						'to_FaxNumber'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'FaxNumber' => strFax.replaceAll('[^0-9]', '')
							}
						},
						'to_AddressUsage'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'AddressUsage' => 'XXDEFAULT',
								'ValidityEndDate' => '9999-12-31T23:59:59'
							}
						}   
					}
				},
				'to_BusinessPartnerRole' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'BusinessPartnerRole' => 'FLCU00',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					},
					new Map<String, Object>{
						'BusinessPartnerRole' => 'FLCU01',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					},
					new Map<String, Object>{
						'BusinessPartnerRole' => 'UKM000',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					}
				},
				'to_BusinessPartnerTax' => lstBusinessPartnerTax,
				'to_Customer' => new Map<String, Object>{
					'Customer' => objAcc.PMC_SS_SAPCustomerNumber__c ?? '',
					'ExpressTrainStationName' => objAcc.Id, 
					'CustomerClassification' => objAcc.PMC_SS_Segmentation__c  ?? '',
					'katr2' => '',
					'katr4' => objAcc.Team_Accounts_Attribute_4__c ?? '',
					'katr5' => objAcc.Sales_Channel_Attribute_5__c ?? '',
					'katr6' => objAcc.Country_Region_Attribute_6__c ?? '',  
					'katr7' => objAcc.Sales_Region_Attribute_7__c ?? '',                              
					'to_CustomerCompany' => new List<Map<String, Object>>{
						new Map<String, Object>{
							'CompanyCode' => strSalesOrg, //Same value as Sales Org
							'ReconciliationAccount' => strReconcAcc,
							'LayoutSortingRule' => strLayoutSortingRule,
							'CashPlanningGroup' => strCashPlanningGroup,
							'APARToleranceGroup'=> strToleranceGroup, 
							'RecordPaymentHistoryIndicator' => boolRecordPmntHistory,
							'PaymentMethodsList' => '',
							'PaymentTerms' => strPaymentTerm
						}
					},
					'to_CustomerSalesArea' => new List<Map<String, Object>>{
						new Map<String, Object>{
							'SalesOrganization' => strSalesOrg,
							'DistributionChannel' => '00', //Fixed value 00 as per requirements from EIDGT-850
							'Division' => strDivision,
							'SalesOffice' => strSalesOffice,
							'SalesDistrict' => strSalesDistrict,
							'SalesGroup' => strSalesGroup,
							'CustomerPricingProcedure' => '1', //Fixed value 00 as per SAP API A2X Mapping Table
							'ItemOrderProbabilityInPercent' => '100', //Fixed value 00 as per SAP API A2X Mapping Table
							'Currency' => objAcc.CurrencyIsoCode,
							'OrderCombinationIsAllowed' => true, //Fixed value True as per SAP API A2X Mapping Table
							'ShippingCondition' => objAcc.PMC_SS_ShippingCondition__c ?? '',
							'InvoiceDate' => strInvDates ?? '',        
							'InvoiceListSchedule' => strInvListSched ?? '',
							'CustomerAccountAssignmentGroup' => strAcctAssmtGrpCust ?? '',
							'CustomerGroup' => strCustomerGroup,
							'untto' => objAcc.PMC_SS_Underdeltolerance__c,
							'uebto' => objAcc.PMC_SS_OverdelTolerance__c,                                    
							'to_PartnerFunction' => new List<Map<String, Object>>{
								new Map<String, Object>{
									'PartnerCounter' => '', 
									'PartnerFunction' => strPartnerFunction,
									'BPCustomerNumber' => '',
									'CustomerPartnerDescription' => '',
									'DefaultPartner' => false
								}
							},
							'to_SalesAreaTax' => new List<Map<String, Object>>{
								new Map<String, Object>{
									'DepartureCountry' => objAcc.BillingCountryCode, 
									'CustomerTaxCategory' => strCustomerTaxCategory,
									'CustomerTaxClassification' => strTaxClass
								}
							}
						}			
					}
				}
			};
			
			if (objAcc.BillingCountryCode == 'US' || objAcc.BillingCountryCode == 'CA' || objAcc.BillingCountryCode == 'PE') {
				mapBusinessPartner.remove('to_BusinessPartnerTax');
			}	

			strSerializedBody = JSON.serializePretty(mapBusinessPartner);
			return strSerializedBody;
		}
        catch(Exception objException)
        {
            PMC_ErrorLogClass.processException(objException);
            strExceptionMsg = objException.getMessage();
            return null;
        }
    } 
             
     /** 
     * @description This method will create the payload for Payer Business Partner Creation.
     * @param lstIds - List of ids.
     * @return strSerializedBody - Serialized Http Request Body.
     */
    public static String createPayerPayload(List<Id> lstIds, Map<String, String> JSONPayloadParams)
    {
        try
        {
			for(Id curId : lstIds){ 
				strEffectiveAccountId = curId;
			}
			
			Account objAcc = [SELECT Account_Assignment_Group__c,Customer_Group__c,AccountNumber,BillingAddress,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,CurrencyIsoCode,Fax,Id,Industry,MasterRecordId,Name,Phone,PMC_SS_PaymentTerm__c,PMC_CPQ_Region__c,PMC_DH_Account_Status__c,PMC_DH_Email__c,PMC_DH_isProcessed__c,PMC_SS_AddressDistrict__c,PMC_SS_AddressNumber__c,PMC_SS_BillToAccount__c,PMC_SS_Careof__c,PMC_SS_Channel__c,PMC_SS_CompanyCode__c,PMC_SS_ContractLanguage__c,PMC_SS_CPF__c,PMC_SS_CustomerType__c,PMC_SS_Division__c,PMC_SS_GLN__c,PMC_SS_Lockbox__c,PMC_SS_MDMVerified__c,PMC_SS_MunicipalTaxNumber__c,PMC_SS_Name2__c,PMC_SS_Name4__c,PMC_SS_OverdelTolerance__c,PMC_SS_PayerContact__c,PMC_SS_POBox__c,PMC_SS_ReconciliationAccount__c,PMC_SS_RecordType__c,PMC_SS_RegionalManager__c,PMC_SS_RUC__c,PMC_SS_SalesDirector__c,PMC_SS_SalesDistrict__c,Sales_Group__c,PMC_SS_SalesOffice__c,PMC_SS_SalesOrg__c,PMC_SS_SalesRegion__c,PMC_SS_SAPCustomerNumber__c,PMC_SS_Segmentation__c,PMC_SS_ShippingCondition__c,PMC_SS_SoldToAccount__c,PMC_SS_StateRegistrationNumber__c,PMC_SS_StateTaxNumber__c,PMC_SS_TaxIDOrCNPJOrCPF__c,PMC_SS_Transportation_Zone__c,PMC_SS_Underdeltolerance__c,PMC_SS_UnitofMeasure__c,PMC_SS_Veson__c,RecordTypeId,SourceSystemIdentifier,Team_Accounts_Attribute_4__c,Sales_Channel_Attribute_5__c,Country_Region_Attribute_6__c,Sales_Region_Attribute_7__c,Type FROM Account Where Id=:strEffectiveAccountId];
			
			Datetime dtValidFrom = Datetime.now();
			Long lValidFrom = dtValidFrom.getTime();
			String strValidFrom = dtValidFrom.format('yyyy-MM-dd\'T\'HH:mm:ss');
			strPhone = objAcc.Phone ?? '';
			strFax = objAcc.Fax ?? '';
			strSalesOrg = objAcc.PMC_SS_SalesOrg__c ?? '';
			strSalesOffice = objAcc.PMC_SS_SalesOffice__c ?? '';
			strSalesDistrict = objAcc.PMC_SS_SalesDistrict__c ?? '';
			strSalesGroup = objAcc.Sales_Group__c ?? '';
			strPaymentTerm = objAcc.PMC_SS_PaymentTerm__c ?? '';
			strCustomerGroup = objAcc.Customer_Group__c ?? '';
			strBPGrouping = JSONPayloadParams.get('strBPGrouping');
			strPartnerFunction = JSONPayloadParams.get('strPartnerFunction');
			strCustomerTaxCategory = JSONPayloadParams.get('strCustomerTaxCategory');
			strLanguage = JSONPayloadParams.get('strLanguage');
			strReconcAcc = JSONPayloadParams.get('strReconcAcc');
			strAcctAssmtGrpCust = JSONPayloadParams.get('strAcctAssmtGrpCust');
			strTransportation = JSONPayloadParams.get('strTransportation');
			strCNPJNumber = JSONPayloadParams.get('strCNPJNumber');
			strCPFNumber = JSONPayloadParams.get('strCPFNumber');
			strRUCPYOrg = JSONPayloadParams.get('strRUCPYOrg');
			strRUCPYPerson = JSONPayloadParams.get('strRUCPYPerson');
			strSearchTerm1 = JSONPayloadParams.get('strSearchTerm1');
			strInvDates = JSONPayloadParams.get('strInvDates');
			strInvListSched = JSONPayloadParams.get('strInvListSched');
			strCashPlanningGroup = JSONPayloadParams.get('strCashPlanningGroup');
			strToleranceGroup = JSONPayloadParams.get('strToleranceGroup');
			strNaturalPerson = JSONPayloadParams.get('strNaturalPerson');
			strLayoutSortingRule = JSONPayloadParams.get('strLayoutSortingRule');
			strTaxClass = JSONPayloadParams.get('strTaxClass');
			strDivision = JSONPayloadParams.get('strDivision');		

			switch on objAcc.BillingCountryCode {
				when 'BR','PY' {
					boolRecordPmntHistory = true;
				}
				when 'PE', 'US', 'CA' {
					boolRecordPmntHistory = false;
				}
			}

			List<Map<String, Object>> lstBusinessPartnerTax = new List<Map<String, Object>>{};
			if (!String.isBlank(strCNPJNumber)) {
				Map<String, Object> mapCNPJNumber = new Map<String, Object>{};
				mapCNPJNumber.put('BPTaxType', 'BR1');
				mapCNPJNumber.put('BPTaxNumber', strCNPJNumber);
				lstBusinessPartnerTax.add(mapCNPJNumber);
			}                     
			if (!String.isBlank(strCPFNumber)) {
				Map<String, Object> mapCPFNumber = new Map<String, Object>{};
				mapCPFNumber.put('BPTaxType', 'BR2');
				mapCPFNumber.put('BPTaxNumber', strCPFNumber);
				lstBusinessPartnerTax.add(mapCPFNumber);
			}                
			if (!String.isBlank(objAcc.PMC_SS_StateTaxNumber__c)) {
				Map<String, Object> mapStateTaxNumber = new Map<String, Object>{};
				mapStateTaxNumber.put('BPTaxType', 'BR3');
				mapStateTaxNumber.put('BPTaxNumber', objAcc.PMC_SS_StateTaxNumber__c);
				lstBusinessPartnerTax.add(mapStateTaxNumber);                    
			}
			if (!String.isBlank(objAcc.PMC_SS_MunicipalTaxNumber__c)) {
				Map<String, Object> mapMunicipalTaxNumber = new Map<String, Object>{};
				mapMunicipalTaxNumber.put('BPTaxType', 'BR4');
				mapMunicipalTaxNumber.put('BPTaxNumber', objAcc.PMC_SS_MunicipalTaxNumber__c);
				lstBusinessPartnerTax.add(mapMunicipalTaxNumber);                    
			}
			if (!String.isBlank(strRUCPYOrg)) {
				Map<String, Object> mapRUCPYOrg = new Map<String, Object>{};
				mapRUCPYOrg.put('BPTaxType', 'PY1');
				mapRUCPYOrg.put('BPTaxNumber', strRUCPYOrg);
				lstBusinessPartnerTax.add(mapRUCPYOrg);                    
			} 
			if (!String.isBlank(strRUCPYPerson)) {
				Map<String, Object> mapRUCPYPerson = new Map<String, Object>{};
				mapRUCPYPerson.put('BPTaxType', 'PY2');
				mapRUCPYPerson.put('BPTaxNumber', strRUCPYPerson);
				lstBusinessPartnerTax.add(mapRUCPYPerson);                    
			}						
			mapBusinessPartner = new Map<String, Object>{
				'BusinessPartnerCategory' => '2', //Fixed value 2 as per requirements
				'BusinessPartnerGrouping' => strBPGrouping,
				'NameCountry' => objAcc.BillingCountryCode,
				'Language' => strLanguage,
				'OrganizationBPName1' => objAcc.Name,
				'OrganizationBPName2' => objAcc.PMC_SS_Name2__c ?? '',
				'OrganizationBPName3' => '',
				'OrganizationBPName4' => objAcc.PMC_SS_Name4__c ?? '',
				'SearchTerm1' => strSearchTerm1.left(20),
				'SearchTerm2' => '',
				'IsNaturalPerson' => strNaturalPerson,
				'to_BuPaIndustry' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'IndustrySector' => objAcc.Industry  ?? '',
						'IndustrySystemType' => '0001', //Fixed value 00 as per requirements from EIDGT-851
						'IsStandardIndustry' => 'X' //Fixed value 00 as per requirements from EIDGT-851
					}				
				},
				'to_BusinessPartnerAddress' => new List<Map<String, Object>>{
					new Map<String,Object>{
						'CareOfName' => objAcc.PMC_SS_Careof__c  ?? '',
						'StreetName' => objAcc.BillingStreet  ?? '',
						'HouseNumber' => objAcc.PMC_SS_AddressNumber__c  ?? '',
						'PostalCode' => objAcc.BillingPostalCode  ?? '',
						'CityName' => objAcc.BillingCity  ?? '',
						'Country' => objAcc.BillingCountryCode  ?? '',
						'Region' => objAcc.BillingStateCode  ?? '',
						'District' => objAcc.PMC_SS_AddressDistrict__c  ?? '',
						'TransportZone' => strTransportation  ?? '',
						'Language' => strLanguage,
						'POBox' => objAcc.PMC_SS_POBox__c  ?? '',
						'to_EmailAddress' => new List<Map<String, Object>>{
							new Map<String,Object> {
								'EmailAddress' => objAcc.PMC_DH_Email__c  ?? ''
							}
						},
						'to_PhoneNumber'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'PhoneNumber' => strPhone.replaceAll('[^0-9]', '')
							}
						},
						'to_FaxNumber'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'FaxNumber' => strFax.replaceAll('[^0-9]', '')
							}
						},
						'to_AddressUsage'  => new List<Map<String, Object>>{
							new Map<String,Object> {
								'AddressUsage' => 'XXDEFAULT',
								'ValidityEndDate' => '9999-12-31T23:59:59'
							}
						}   
					}
				},
				'to_BusinessPartnerRole' => new List<Map<String, Object>>{
					new Map<String, Object>{
						'BusinessPartnerRole' => 'FLCU00',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					},
					new Map<String, Object>{
						'BusinessPartnerRole' => 'FLCU01',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					},
					new Map<String, Object>{
						'BusinessPartnerRole' => 'UKM000',
						'ValidFrom' => strValidFrom,
						'ValidTo' => '9999-12-31T23:59:59'
					}
				},
				'to_BusinessPartnerTax' => lstBusinessPartnerTax,
				'to_Customer' => new Map<String, Object>{
					'Customer' => objAcc.PMC_SS_SAPCustomerNumber__c ?? '',
					'PostingIsBlocked' => false, 
					'ExpressTrainStationName' => objAcc.Id, 
					'CustomerClassification' => objAcc.PMC_SS_Segmentation__c  ?? '',
					'katr2' => '',
					'katr4' => objAcc.Team_Accounts_Attribute_4__c ?? '',
					'katr5' => objAcc.Sales_Channel_Attribute_5__c ?? '',
					'katr6' => objAcc.Country_Region_Attribute_6__c ?? '',  
					'katr7' => objAcc.Sales_Region_Attribute_7__c ?? '',                              
					'to_CustomerCompany' => new List<Map<String, Object>>{
						new Map<String, Object>{
							'CompanyCode' => strSalesOrg, //Same value as Sales Org
							'ReconciliationAccount' => strReconcAcc,
							'LayoutSortingRule' => strLayoutSortingRule,
							'CashPlanningGroup' => strCashPlanningGroup,
							'APARToleranceGroup'=> strToleranceGroup, 
							'RecordPaymentHistoryIndicator' => boolRecordPmntHistory,
							'PaymentMethodsList' => '',
							'PaymentTerms' => strPaymentTerm,
							'Lockb' => objAcc.PMC_SS_Lockbox__c ?? '',
							'AccountingClerk' => ''
						}
					},
					'to_CustomerSalesArea' => new List<Map<String, Object>>{
						new Map<String, Object>{
							'SalesOrganization' => strSalesOrg,
							'DistributionChannel' => '00', //Fixed value 00 as per requirements from EIDGT-851
							'Division' => strDivision,
							'SalesOffice' => strSalesOffice,
							'SalesDistrict' => strSalesDistrict,
							'SalesGroup' => strSalesGroup,
							'CustomerPricingProcedure' => '1', //Fixed value 00 as per SAP API A2X Mapping Table
							'ItemOrderProbabilityInPercent' => '100', //Fixed value 00 as per SAP API A2X Mapping Table
							'Currency' => objAcc.CurrencyIsoCode,
							'OrderCombinationIsAllowed' => true, //Fixed value True as per SAP API A2X Mapping Table
							'ShippingCondition' => objAcc.PMC_SS_ShippingCondition__c ?? '',
							'InvoiceDate' => strInvDates ?? '',        
							'InvoiceListSchedule' => strInvListSched ?? '',                                      
							'CustomerAccountAssignmentGroup' => strAcctAssmtGrpCust ?? '',
							'CustomerGroup' => strCustomerGroup,
							'untto' => objAcc.PMC_SS_Underdeltolerance__c,
							'uebto' => objAcc.PMC_SS_OverdelTolerance__c,                                    
							'to_PartnerFunction' => new List<Map<String, Object>>{
								new Map<String, Object>{
									'PartnerCounter' => '', 
									'PartnerFunction' => strPartnerFunction,
									'BPCustomerNumber' => '',
									'CustomerPartnerDescription' => '',
									'DefaultPartner' => false
								}
							},
							'to_SalesAreaTax' => new List<Map<String, Object>>{
								new Map<String, Object>{
									'DepartureCountry' => objAcc.BillingCountryCode, 
									'CustomerTaxCategory' => strCustomerTaxCategory,
									'CustomerTaxClassification' => strTaxClass
								}
							}
						}			
					}
				}
			};				
			
			if (objAcc.BillingCountryCode == 'US' || objAcc.BillingCountryCode == 'CA' || objAcc.BillingCountryCode == 'PE') {
				mapBusinessPartner.remove('to_BusinessPartnerTax');
			}	

			strSerializedBody = JSON.serializePretty(mapBusinessPartner);
			return strSerializedBody;
		}
        catch(Exception objException)
        {
            PMC_ErrorLogClass.processException(objException);
            strExceptionMsg = objException.getMessage();
            return null;
        }
    } 
    

     /** 
     * @description This method will determine if auto retrigger is needed for queueable apex.
     * @param intStackDepth - Stack depth of queueable apex.
     * @param strErrorMsg - Error Message
     * @return true - If Auto-Retrigger is needed.
     * @return false - If Auto-Retrigger is not needed.
     */
    public static Boolean autoRetryQueueableApex(Integer intStackDepth, String strErrorMsg)
    {
        String strIntegrationAutoRetrySettingsLabel = 'PMC_CPQ_IntegrationAutoRetrySettings';
        PMC_CPQ_IntegrationSettings__mdt strIntegrationAutoRetrySettings = PMC_CPQ_IntegrationSettings__mdt.getInstance(strIntegrationAutoRetrySettingsLabel);
        String strIntegrationMsgCSV = strIntegrationAutoRetrySettings.PMC_CPQ_SettingValueLongTextArea__c;
        
        Integer intIntegrationRetryCount = Integer.valueOf(strIntegrationAutoRetrySettings.PMC_CPQ_SettingValueNumber__c);
        List<String> lstStringErrorMessages = strIntegrationMsgCSV.split('&');
        
        if(intStackDepth <= intIntegrationRetryCount && lstStringErrorMessages.contains(strErrorMsg))
        {
            return true;  
        }
        return false;
    }
}