@istest(seealldata=false)
private class Test_EmailMessageTrigger {
	static testMethod void Test_EmailMessageTrigger() {
    	
        Account a = new Account(Name='Alex Test Account');
        insert a;

        Case c = new Case(AccountId = a.id);
        insert c; 
        
        EmailMessage e = new EmailMessage(ParentId = c.id, incoming = true, toaddress='someAddress@test.com');
        insert e;
        
        Case myCase = [SELECT to_address__c FROM Case WHERE id = :c.Id];
        System.assertEquals(myCase.to_address__c,'someAddress@test.com');
    }
}