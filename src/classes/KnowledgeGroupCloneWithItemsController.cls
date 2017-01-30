public with sharing class KnowledgeGroupCloneWithItemsController {

    
    private Knowledge_group__c kgrp {get;set;}
    public Id kgrppgid{get; set;}
    // set the id of the record that is created -- ONLY USED BY THE TEST CLASS
    public ID newRecordId {get;set;}

    public KnowledgeGroupCloneWithItemsController(ApexPages.StandardController controller) {
         kgrppgid=apexpages.currentpage().getparameters().get('Id');
         system.debug('kgrppgid'+kgrppgid);
    }
    
    public pageReference cloneWithItems(){
        // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
         Knowledge_group__c newkgrp;
         
         try {

              //copy the knowledge group - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
             kgrp = [select Id, Active__c,Affiliation__c, Alex_Update__c, Apply_Defaults__c, Channel__c, Client__c, Default_Group_for_Channel__c, Default_Group_for_Partner__c, Partner__c, Partner_lookup__c, Support_Number__c, OwnerId from Knowledge_group__c where id = :kgrppgid];
             system.debug('kgrp'+kgrp);
             newkgrp = kgrp.clone(false);
             insert newkgrp;
             
             // set the id of the new po created for testing
               newRecordId = newkgrp.id;
               
             //Query over the child objects
             List<Group_Article__c> items = new List<Group_Article__c>();
             List<Group_Article__c> grpartlist=[select Active__c, Channel__c, Custom_Article_URL__c, Custom_URL__c, Group_Name__c, Is_Common_Question__c, Is_Default_Question__c, Knowledge_Article_ID__c, Knowledge_Description__c, Knowledge_Group__c, Knowledge_LastPublishedDate__c, Knowledge_Summary__c, Knowledge_Title__c from Group_Article__c where Knowledge_Group__c=:kgrp.ID and Active__c=True];
             system.debug('grpartlist'+grpartlist);
             
             if(grpartlist.size()>0){
                 for (Group_Article__c grparti : grpartlist){
                     Group_Article__c grpart=grparti.clone(false);
                     grpart.Knowledge_Group__c=newkgrp.ID;
                     items.add(grpart);
                 }
               insert items;
             }  
             }catch(Exception e){
                  // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
             }    
             
            return new PageReference('/'+newkgrp.id+'/e?retURL=%2F'+newkgrp.id);
    
    }

}