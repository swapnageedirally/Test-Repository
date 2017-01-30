public class Launch_SurveyResetClass {
    public List<Milestone1_Project__c> imps { get; set; }
    

    public List<Schema.FieldSetMember> getImpFields() {
        return SObjectType.Milestone1_Project__c.FieldSets.External_Report_Launch_Survey_Reset.getFields();
    }

    public Launch_SurveyResetClass(){

        List<string> impStandardFieldList = new List<string>{'id'};
        string queryString_imp = '';

        for(Schema.FieldSetMember fsm: this.getImpFields()){
            impStandardFieldList.add(fsm.getfieldPath());
        }

        // Add to set to de-dup field listing
        Set<string> fieldSetImp = new Set<string>();
        for(string s: impStandardFieldList){
            fieldSetImp.add(s.toLowerCase());
        }
        
        // Build SOQL query (for ContactInformation)
        List<string> fieldList_imp = new List<string>(fieldSetImp);
        for (Integer i=0; i<fieldList_imp.size(); i++) {
            if(i == 0) {
                    queryString_imp = 'select ' + fieldList_imp[i];
            } else {
                    queryString_imp += ', ' + fieldList_imp[i];
            }
        }
        
        string Condition1 = [select Id, Name from Partner__c where Name='Optum'].Id;

        queryString_imp += ' FROM Milestone1_Project__c ';
        //where  Partner__c =' + '\'' + Condition1 + '\'' + ' AND Survey_Reset__c = True  ORDER BY Client_Legal_Name__c Desc'

        system.debug('QUERY IMP FIELDS ARE ' + queryString_imp);

        imps = Database.query(queryString_imp);

        system.debug('IMPS ARE ' + imps);

    }

    
}