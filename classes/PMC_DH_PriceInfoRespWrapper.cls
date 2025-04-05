/**
* @description : Wrapper class for PMC_DH_GetPriceResponseParsing
* @author      : Krishan Jangir
* @userStory   : GDASF-6842
* @last modified on 08-02-2023
* @last modified by @krishanjangir
**/
public class PMC_DH_PriceInfoRespWrapper{
    /**
* @description Wrapper for HeaderSet
* @author @krishanjangir 
* 
**/
	public cls_HeaderSet HeaderSet;
    /**
* @description Wrapper Class for HeaderSet
* @author @krishanjangir 
* 
**/
	public class cls_HeaderSet {
        /**
* @description Wrapper  for Header
* @author @krishanjangir 
* 
**/
		public cls_Header Header;
	}
    /**
* @description Wrapper Class  for Header
* @author @krishanjangir 
* 
**/
	public class cls_Header {
        /**
* @description Price Date
* @return  String 
* 
**/
		public String PriceDate;
        /**
* @description TransId
* @return  String 
* 
**/
		public String Ztransid;
        /**
* @description validity
* @return  String 
* 
**/
		public String QtValidT;
                /**
* @description return Set
* @return  String 
* 
**/
		public String ReturnSet;
                /**
* @description validity
* @return  String
* 
**/
		public String ReqDateH;
                /**
* @description Wrapper ofPartnerSet
* @author @krishanjangir 
* 
**/
		public cls_PartnerSet PartnerSet;
        /**
* @description DistrChan
* @return  String 
* 
**/
		public String DistrChan;
        /**
* @description QtValidF
* @return  String 
* 
**/
		public String QtValidF;
        /**
* @description purchase number
* @return  String 
* 
**/
		public String PurchNoC;
        /**
* @description List of Price_CondSet
* @return  List<cls_Price_CondSet 
* 
**/
		public List<cls_Price_CondSet> Price_CondSet;
        /**
* @description Pmnttrms
* @return  String 
* 
**/
		public String Pmnttrms;
        /**
* @description Item Set
* @return  String 
* 
**/
		public cls_ItemSet ItemSet;
        /**
* @description sales org
* @return  String 
* 
**/
		public String SalesOrg;
		//public String Currency;
		/**
* @description division
* @return  String 
* 
**/
		public String Division;
        /**
* @description ZrefTransid
* @return  String 
* 
**/
		public String ZrefTransid;
        /**
* @description purchase date
* @return  String 
* 
**/
		public String PurchDate;
        /**
* @description wrapper of Raw_MaterialSet
* @author @krishanjangir 
* 
**/
		public cls_Raw_MaterialSet Raw_MaterialSet;
        /**
* @description doc type
* @return  String 
* 
**/
		public String DocType;
        /**
* @description ship condition
* @return  String 
* 
**/
		public String ShipCond;
        /**
* @description wrapper of Item_RSet
* @author @krishanjangir 
* 
**/
		public cls_Item_RSet Item_RSet;
	}
    /**
* @description wrapper class of cls_PartnerSet
* @author @krishanjangir 
* 
**/
	public class cls_PartnerSet {
         /**
* @description List of partner
* @return  List<cls_Partner> 
* 
**/
		public List<cls_Partner> Partner;
	}
    /**
* @description wrapper class of cls_Partner
* @author @krishanjangir 
* 
**/
	public class cls_Partner {
        /**
* @description Partner role
* @return  String 
* 
**/
		public String PartnRole;
        /**
* @description Ztransid
* @return  String 
* 
**/
		public String Ztransid;
        /**
* @description PartnNumb
* @return  String 
* 
**/
		public String PartnNumb;
        /**
* @description ZrefTransid
* @return  String 
* 
**/
		public String ZrefTransid;
        /**
* @description itemNumber
* @return  String 
* 
**/
		public String ItmNumber;
	}
    /**
* @description wrapper class of cls_Price_CondSet
* @author krishan
* 
**/
	public class cls_Price_CondSet {
        /**
* @description List of Price_Cond
* @return List<cls_Price_Cond>
* 
**/
		public List<cls_Price_Cond> Price_Cond;
	}
    /**
* @description wrapper class of cls_Price_Cond
* @author krishan
* 
**/
	public class cls_Price_Cond {
		public String ValidEndDate;
		public String ValidStartDate;
		public String Ztransid;
		//public String Currency;
		public String CondValue;
		public String ZrefTransid;
		public String ItmNumber;
		public String CondType;
	}
	class cls_ItemSet {
		public cls_Item[] Item;
	}
	class cls_Item {
		public String Ztransid;
		public String CondValue;
		public String ReqQty;
		public String SalesUnit;
		public String Material;
		public String Incoterms2;
		public String Incoterms1;
		public String TargetQty;
		public String Plant;
		public String PurchNoC;
		public String TargetQu;
		public String ZrefTransid;
		public String ItmNumber;
		public String CondType;
	}
	class cls_Raw_MaterialSet {
		public cls_Raw_Material Raw_Material;
	}
	class cls_Raw_Material {
		public String Ztransid;	
		public String ZrefTransid;
	}
	public class cls_Item_RSet {
		public cls_Item_R[] Item_R;
	}
	public class cls_Item_R {
		public String TaxAmount;
		public String Zpricerefresh;
		public String HgLvItem;
		public String Ztransid;
		public String NetValue;
		public String Material;
		public String ZrefTransid;
		public String ItmNumber;
		public String Zprcduedt;
	}
}