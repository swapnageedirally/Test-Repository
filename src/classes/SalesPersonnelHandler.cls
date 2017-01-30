public class SalesPersonnelHandler {

	public static void UpdateActiveDirector(Sales_Personnel__c[] sps, Map<id, Sales_Personnel__c> spMap) {
		
		List<Sales_Channel__c> updateSCs = new List<Sales_Channel__c>();
		List<Sales_Personnel__c> updateSPs = new List<Sales_Personnel__c>();
		List<ID> salesChannelIDs = new List<ID>();

		for(Sales_Personnel__c sp : sps){
			
			system.debug('PERSONNEL ROLE IS ' + sp.Role__c);

			if(sp.Active__c && sp.Role__c.contains('Director') && (trigger.isInsert || (trigger.isUpdate && !spMap.get(sp.id).Active__c))){
				Sales_Channel__c sc = new Sales_Channel__c();
				sc.id = sp.Sales_Channel__c;
				sc.Sales_Director__c = sp.User__c;
				updateSCs.add(sc);
				salesChannelIDs.add(sp.Sales_Channel__c);
			}

			if(!updateSCs.isEmpty()){
				update updateSCs;

				for(Sales_Personnel__c sp1 : [select id, Active__c from Sales_Personnel__c where Role__c LIKE '%Director%' AND Sales_Channel__c IN : salesChannelIDs AND Active__c = true AND ID NOT IN : trigger.new]){
					sp1.Active__c = false;
					updateSPs.add(sp1);
				}

				if(!updateSPs.isEmpty())
					update updateSPs;
			}
		}
	}
}