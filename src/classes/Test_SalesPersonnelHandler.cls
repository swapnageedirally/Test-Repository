@istest
public class Test_SalesPersonnelHandler {
  
  @istest(seealldata=false)
  static void Test_SalesPersonnelHandler() {
    //Set up test data
    
    Sales_Channel__c sc=new Sales_Channel__c(Name='Engage', Approved_Record_Type_Name__c='Engage Approved', Case_Record_Type_Name__c='Engage');
    insert sc;
    
    Sales_Personnel__c sp=new Sales_Personnel__c(Active__c=True, Sales_Channel__c=sc.Id);
    Test.startTest();
    
    insert sp;
    
    Test.stopTest();
    
  }
}