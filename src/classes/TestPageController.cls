public class TestPageController {
    public String urlStuff { get; set; }
    public String valueLat { get; set; }

    public List<Milestone1_Project__c> imps { get; set; }
    public List<dateToImp> dateList { get; set; }

    public List<Schema.FieldSetMember> getImpFields() {
        return SObjectType.Milestone1_Project__c.FieldSets.ExternalImplementationReportFields.getFields();
    }

    public TestPageController(){
        dateList = new List<dateToImp>();

        Map<Date, List<Milestone1_Project__c>> dateMap = new Map<Date,List<Milestone1_Project__c>>();

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
        IF(!queryString_imp.contains('Rally_Implementation_Start_Date__c')) {
            queryString_imp += ', Rally_Implementation_Start_Date__c';
        }
        string remove1 = '1. In the Park';
        string remove2 = '2. On Deck';

        queryString_imp += ' FROM Milestone1_Project__c where Implementation_Status__c != ' + '\'' + remove1 + '\'' + ' AND Implementation_Status__c != ' + '\'' + remove2 + '\'' + ' ORDER BY Rally_Implementation_Start_Date__c ASC NULLS LAST, Implementation_Status__c DESC';

        system.debug('QUERY IMP FIELDS ARE ' + queryString_imp);

        imps = Database.query(queryString_imp);

        system.debug('IMPS ARE ' + imps);

        for(Milestone1_Project__c m : imps){
            if(dateMap.isEmpty() || !dateMap.containsKey(m.Rally_Implementation_Start_Date__c))
                dateMap.put(m.Rally_Implementation_Start_Date__c, new List<Milestone1_Project__c>{m});
            else if(dateMap.containsKey(m.Rally_Implementation_Start_Date__c))
                dateMap.get(m.Rally_Implementation_Start_Date__c).add(m);
        }

        system.debug('DATE MAP IS ' + dateMap);

        for(date d : dateMap.keySet()){
            dateList.add( new dateToImp(d,dateMap.get(d)));
        }

        system.debug('DATE LIST IS ' + dateList);
    }

    public class dateToImp{
        public date dt                                      {get; set;}
        public List<Milestone1_Project__c> impList          {get; set;}

        public dateToImp(date DTP, List<Milestone1_Project__c> impListP){
            this.dt = DTP;
            this.impList = new List<Milestone1_Project__c>();
            this.impList.addAll(impListP);
        } 
    }
}