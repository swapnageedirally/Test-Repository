public class SegmentationIDTriggerHandler {
	
	public static void afterInsert(Segmentation_ID__c[] newSegs) {

		system.debug('TRIGGER SIZE IN AFTER INSERT SEGMENTATION ID ' + newSegs.size());

		List<Client_Affiliation__c> updateCAs = new List<Client_Affiliation__c>();

		for(Segmentation_ID__c s : [select id,Segmentation_prefix__c,Segmentation_Suffix__c,Client_Affiliation__c, Client_Affiliation__r.Affiliation__r.Partner__r.Affiliation_Naming_Convention__c, name from Segmentation_ID__c where ID IN : newSegs]){
			if(s.Client_Affiliation__r.Affiliation__r.Partner__r.Affiliation_Naming_Convention__c == Label.SegmentationIDHandler_AdvancedNamingConvention){
				Client_Affiliation__c ca = new Client_Affiliation__c(id=s.Client_Affiliation__c);
				ca.name = s.Segmentation_Prefix__c + s.name + s.Segmentation_Suffix__c;
				updateCAs.add(ca);
			}
		}

		system.debug('DO WE UPDATE BCBS AFFILIATION NAMES - ' + updateCAs);
		
		if(!updateCAs.isEmpty())
			update updateCAs;
	}
}