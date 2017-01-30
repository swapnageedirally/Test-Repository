public class TaskTriggerHandler {
	
	public static void isBeforeInsert(Task[] tsks) {
		List<task> nextloop = new List<task>();
		List<string> callids = new List<string>();
		Map<string, case> caseMap = new Map<string,case>();

		for(task t : tsks){
			if(t.Five9__Five9SessionId__c != null && t.Five9__Five9SessionId__c != ''){
				callids.add(t.Five9__Five9SessionId__c);
				nextloop.add(t);
			}
		}

		for(case c : [select id,Call_ID__c,contactID from Case where Call_ID__c IN : callids]){
			caseMap.put(c.call_id__c, c);
		}

		for(task t : nextloop){
			if(caseMap.containsKey(t.Five9__Five9SessionId__c)){
				t.WhatId = caseMap.get(t.Five9__Five9SessionId__c).id;
				if(caseMap.get(t.Five9__Five9SessionId__c).contactID != null)
					t.WhoId = caseMap.get(t.Five9__Five9SessionId__c).contactID;
			}
		}
	}
}