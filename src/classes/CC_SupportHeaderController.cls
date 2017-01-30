/**
	@author 7S
	@version Nov 11 2014 
*/
public without sharing class CC_SupportHeaderController {

	private String ParamClient;
    private String ParamPartner;
    private String ParamAffiliation;
    Public String DataCategoryGroupName{get;set;}
    Public String channel {get;set;}

    public Knowledge_Group__c kbg {get;set;}
    public string phoneN {get;set;}
    public string phoneS {get;set;}

	public CC_SupportHeaderController(){
		    paramClient = ApexPages.CurrentPage().getparameters().get('Client');
            paramPartner = ApexPages.CurrentPage().getparameters().get('Partner');
            paramAffiliation = ApexPages.CurrentPage().getparameters().get('Affiliation');
            channel = ApexPages.CurrentPage().getparameters().get('channel');

            DataCategoryGroupName = ApexPages.CurrentPage().getparameters().get('DataCategoryGroupName');

            if(String.isEmpty(DataCategoryGroupName)){
        			DataCategoryGroupName= CC_Util.getGroupName(paramClient,paramPartner,paramAffiliation,channel);
            }

            kbg = CC_Util.GetGroupInfo(DataCategoryGroupName);

            system.debug('kbg IS ' + kbg);

            phoneS = ((kbg.Support_Number__c != null && kbg.Support_Number__c != '') ? kbg.Support_Number__c : (kbg.Partner_Lookup__c != null ? kbg.Partner_Lookup__r.Support_Number__c : kbg.Channel__r.DNIS_Support_Number__c));

            if(phoneS != null){
                string tempP = phoneS.replace('-','').replace('(','').replace(')','').replace(' ','');
                tempP = tempP.trim();

                phoneN = 'tel:+' + tempP;
            }
            else{
                phoneS = '';
                phoneN = '';
            }

            system.debug('PHONE HREF IS ' + phoneN);
            system.debug('PHONE LABELS IS ' + phoneS);
	}
	
}