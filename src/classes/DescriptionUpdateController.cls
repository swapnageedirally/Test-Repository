public with sharing class DescriptionUpdateController {
	public List<selectOption> SObjectList {get;set;}
	public List<Field_Info__c> fis {get;set;}
	public string selectedObj {get;set;}
	public boolean isSuccess {get;set;}

	public DescriptionUpdateController() {

		SObjectList = new List<selectOption>();
		fis = new List<Field_Info__c>();

		isSuccess = false;
		Map<String,string> tempMap = new Map<String,string>{'resource_page_promotion__c'=>'Resource Page Promotion',
		'digital_campaig_requirement__c'=>'Digital Campaign Requirement','challenge_requirement__c'=>'Challenges - Team and Private',
			'private_sweepstakes_requirement__c'=>'Private Sweepstakes Requirement'};
		for(string s : tempMap.keyset()){
		    SobjectList.add( new selectOption(s,tempMap.get(s)));
		}
	}

	public void updateDesc(){
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();

		system.debug('OBJECT NAME IS ' + UserInfo.getSessionId());

		MetadataService.CustomObject customObject = (MetadataService.CustomObject) service.readMetadata('CustomObject', new String[] { selectedObj }).getRecords()[0];

		system.debug('METADATA FIELDS ARE ' + customObject.fields);

		Map<string,string> fieldMap = new Map<string,string>();

		for(MetadataService.CustomField field : customObject.fields){
			system.debug('FIELD NAME IS ' + field.fullName);
			string descrip = field.description != null ? field.description : 'N/A';
			fieldMap.put(field.fullName, descrip);
		}

		for(string field2 : fieldMap.keyset()){
			if(fieldMap.get(field2) != 'N/A'){
				Field_Info__c fi = new Field_Info__c(name = field2, info__c = fieldMap.get(field2), Object_api_name__c = 'private_sweepstakes_requirement__c');
				fis.add(fi);
			}
		}

		List<Field_Info__c> fi_del =[select id from Field_Info__c where Object_api_name__c = :selectedObj];
		
		if(!fi_del.isEmpty())
			delete fi_del;

		if(!fis.isEmpty())
			insert fis;

		isSuccess = true;
	}
}