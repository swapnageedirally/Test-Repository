global with sharing class AccountRemoter {
	public String accountName { get; set; }
    public static List<Account> accts { get; set; }
    public AccountRemoter() { } // empty constructor
    
    @RemoteAction
    global static List<Account> getAccount(String accountName) {
    	accts = [select id, name,Partner__r.Partner_String__c,Partner__c, (select id, name from Rally_Implementations__r) from Account where Name = :accountname];
        system.debug('accts' +accts);
        return accts;
    }

}