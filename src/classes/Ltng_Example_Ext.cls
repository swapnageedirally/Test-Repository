public class Ltng_Example_Ext {
    
    Id accountId, caseId;
    
    public Ltng_Example_Ext(ApexPages.StandardController sc){
        caseId = sc.getId();
    }
    
    public List<Case> getCases(){
        return [SELECT Id, CaseNumber, Subject FROM Case LIMIT 5];
    }

}