@istest
public class Test_RallyRequirements {

    @isTest(SeeAllData=true) static void testCreateRecord() {    
        Account a = new Account(name='test');
        insert a;

        Partner__c p = new Partner__c(name='testp',partner_string__c='testp');
        insert p;

        Affiliation__c aa = new Affiliation__c(name='affil1',Partner__c=p.id);
        insert aa;

        Milestone1_Project__c imp = new Milestone1_Project__c(account__c = a.id, Partner__c=p.id);
        insert imp;

        Rally_Requirement_FS_Mapping__mdt fsMap = [select id, label, form_id__c from Rally_Requirement_FS_Mapping__mdt where field_set_name__c = 'DHP_External_Fields'];
        
        system.debug('FORM ID IN TEST IS ' + fsMap);

        PageReference pageRef = page.RallyRequirements;
        pageRef.getParameters().put('impID', imp.id);
        pageRef.getParameters().put('formID', fsMap.form_id__c);
        Test.setCurrentPage(pageRef);

        RequirementFormController2 cont = new RequirementFormController2();
        
        System.assert(cont.objName == 'dhp_promotion__c');

        cont.addRecord();
        cont.removeRecord();

        cont.submitResults();

        cont.goToLink();

    }

    @isTest(SeeAllData=true) static void testCreateRecordRtype() {    
        Account a = new Account(name='test');
        insert a;

        Partner__c p = new Partner__c(name='testp',partner_string__c='testp');
        insert p;

        Affiliation__c aa = new Affiliation__c(name='affil1',Partner__c=p.id);
        insert aa;

        Milestone1_Project__c imp = new Milestone1_Project__c(account__c = a.id, Partner__c=p.id);
        insert imp;

        Rally_Requirement_FS_Mapping__mdt fsMap = [select id, label, form_id__c from Rally_Requirement_FS_Mapping__mdt where field_set_name__c = 'RallyRequirements_CustomLinks'];
        
        system.debug('FORM ID IN TEST IS ' + fsMap);
        
        PageReference pageRef = page.RallyRequirements;
        pageRef.getParameters().put('impID', imp.id);
        pageRef.getParameters().put('formID', fsMap.form_id__c);
        Test.setCurrentPage(pageRef);

        RequirementFormController2 cont = new RequirementFormController2();
        
        System.assert(cont.objName == 'dhp_resource_program__c');
        System.assert(cont.hasRtypes == true);

        cont.submitResults();

    }
}