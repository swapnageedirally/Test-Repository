@istest
public class TestTaskTriggerHandler {
	
	@istest(seealldata=false)
	static void TestTaskTriggerHandler() {
		contact con = new contact(lastname='wayne');
		insert con;

		Case c = new case(subject='batman',Call_Id__c='isbrucewayne',contactid=con.id);
		insert c;

		task t = new task(Five9__Five9SessionId__c='isbrucewayne',activitydate=date.today(),status='Completed',priority='Normal');
		insert t;

		task t1 = [select whatid,whoid from task where id = : t.id];

		system.assert(t1.WhatId == c.id);
		system.assert(t1.WhoId == con.id);
	}
}