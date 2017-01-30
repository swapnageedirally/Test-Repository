@istest(seealldata=False)
public class Test_CustomerSurveyEntryController{
    
    static testmethod void customersurevy(){    
        Account a = new Account(name='test');
        insert a;

        Milestone1_Project__c imp = new Milestone1_Project__c(account__c = a.id, partner__c=Label.ManageAffiliations_BCBSPartnerID);
        insert imp;
        
        PageReference pageRef = page.CustomSurveyEntry;
        pageRef.getParameters().put('impID', imp.id);
        pageRef.getParameters().put('surveyid', '');
        Test.setCurrentPage(pageRef);

        CustomSurveyEntryController cont = new CustomSurveyEntryController();
        
        cont.addCustomQ();
        
        cont.removeCustomQ();
        
        cont.submitResults();
        

    }
}