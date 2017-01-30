@IsTest
public class Test_CustomSurveyEntry {
    
    @IsTest(seealldata=false)
    public static void testLoad() {
        Account a = new Account(name='test');
        insert a;

        Partner__c p = new Partner__c(name='Excellus',partner_string__c='testp');
        insert p;

        Affiliation__c aa = new Affiliation__c(name='affil1',Partner__c=p.id);
        insert aa;

        Milestone1_Project__c imp = new Milestone1_Project__c(account__c = a.id, Partner__c=p.id, RecordTypeId=Label.ImplementationRecordTypeExcellus);
        insert imp;
        
        PageReference pageRef = page.customsurveyentry;
        pageRef.getParameters().put('impID', imp.id);
        Test.setCurrentPage(pageRef);

        CustomSurveyEntryController cont = new CustomSurveyEntryController();
        
        System.assert(cont.questions != null);
        System.assertEquals(0,cont.questions_custom.size());     

        cont.addCustomQ();

        System.assertEquals(1,cont.questions_custom.size());   

        cont.addCustomQ();
        cont.removeCustomQ();

        System.assertEquals(1,cont.questions_custom.size());     
        
        cont.questions[0].quest.Selected__c = true;
        cont.questions[0].question_string = 'true';
        cont.questions[0].answers = 'Possible Answers: true,blah,blaj';

        cont.submitResults();
    }
}