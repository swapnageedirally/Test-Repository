@istest
public class Test_RallyOrderForm {

    @isTest(SeeAllData=true) static void testCreateRecord() {    
        
        Partner__c p = new Partner__c(name='testp',partner_string__c='testp');
        insert p;

        Account a = new Account(name='test',Partner__c = p.id);
        insert a;

        PageReference pageRef = page.RallyOrderForm;
        pageRef.getParameters().put('accID', a.id);
        pageRef.getParameters().put('pID', p.id);
        pageRef.getParameters().put('formID', Label.Test_RallyOrderForm_FormID);
        Test.setCurrentPage(pageRef);

        RallyOrderFormController cont = new RallyOrderFormController();
        
        System.assert(cont.rtn == Label.Test_RallyOrderForm_RtypeName);

        cont.impl.Rally_Implementation_Start_DateString__c = '02/07/1984';

        cont.submitResults();

        cont.goToLink();

    }

    @isTest(SeeAllData=true) static void testCreateRecord_newacct() {    
        
        Partner__c p = new Partner__c(name='Optum',partner_string__c='testp');
        insert p;

        Affiliation__c aff = new Affiliation__c(name='testCreateRecord_newacct',partner__c=p.id);
        insert aff;

        PageReference pageRef = page.RallyOrderForm;
        pageRef.getParameters().put('pID', p.id);
        pageRef.getParameters().put('formID', Label.Test_RallyOrderForm_FormID_Affils);
        Test.setCurrentPage(pageRef);

        RallyOrderFormController cont = new RallyOrderFormController();
        
        System.assert(cont.rtn == Label.Test_RallyOrderForm_RtypeName_OptumEngage);

        cont.impl.Rally_Implementation_Start_DateString__c = '02/07/1984';
        
        cont.client.name = 'testacc';

        cont.newClientAffils[0].affilID = aff.id;

        cont.submitResults();

        cont.goToLink();

    }

     @isTest(SeeAllData=true) static void testCreateRecord_newacct2() {    
        
        Partner__c p = new Partner__c(name='testp',partner_string__c='testp');
        insert p;

        Affiliation__c aff = new Affiliation__c(name='testCreateRecord_newacct',partner__c=p.id);
        insert aff;

        PageReference pageRef = page.RallyOrderForm;
        pageRef.getParameters().put('pID', p.id);
        pageRef.getParameters().put('formID', Label.Test_RallyOrderForm_FormID_Affils);
        Test.setCurrentPage(pageRef);

        RallyOrderFormController cont = new RallyOrderFormController();
        
        System.assert(cont.rtn == Label.Test_RallyOrderForm_RtypeName_OptumEngage);

        cont.impl.Rally_Implementation_Start_DateString__c = '02/07/1984';
        
        cont.client.name = 'testacc';

        cont.newClientAffils[0].affilID = aff.id;

        cont.submitResults();

        cont.goToLink();

    }
}