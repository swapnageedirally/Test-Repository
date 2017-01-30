@isTest
private class ResourcePageCategoryTriggerHandlerTest{
  
    private static testmethod void unittest(){
  //Preparing Test data
  Milestone1_Project__c objmp=new Milestone1_Project__c();
  objmp.Name ='testimplementation';
  insert objmp;
  
  
  Resource_Page_Requirement__c objrpq=new Resource_Page_Requirement__c();
  objrpq.Implementation__c=objmp.Id;
  insert objrpq;
  
  Test.startTest();
  
  Resource_Page_Category__c objrpc= new Resource_Page_Category__c();
  objrpc.Resource_Page_Requirement__c=objrpq.Id;
  objrpc.Category_Title__c='test title';
  insert objrpc;

  Test.stopTest();

  }

}