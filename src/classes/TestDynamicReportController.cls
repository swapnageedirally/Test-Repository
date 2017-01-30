public class TestDynamicReportController {
    public string reportName{get; set;}
    
    public TestDynamicReportController (){
        reportName=ApexPages.currentPage().getParameters().get('ReportName');
    }
    
    @RemoteAction
    public static ResponseData getReportData(String reportName) {
        ResponseData rd = new ResponseData();
        Map<Date, List<Milestone1_Project__c>> dateMap = new Map<Date,List<Milestone1_Project__c>>();
        List<string> impStandardFieldList = new List<string>{};
        string queryString_imp = '';
        List<Schema.FieldSetMember> getImpFields = readFieldSet(ReportName, 'Milestone1_Project__c');
        for(Schema.FieldSetMember fsm: getImpFields){
            impStandardFieldList.add(fsm.getfieldPath());
        }
        // Add to set to de-dup field listing
        Set<string> fieldSetImp = new Set<string>();
        for(string s: impStandardFieldList){
            fieldSetImp.add(s.toLowerCase());
        }
        // Build SOQL query (for ContactInformation)
        rd.fieldList_imp = new List<string>(fieldSetImp);
        for (Integer i=0; i<rd.fieldList_imp.size(); i++) {
            if(i == 0) {
                    queryString_imp = 'select ' + rd.fieldList_imp[i];
            } else {
                    queryString_imp += ', ' + rd.fieldList_imp[i];
            }
        }
        if(!queryString_imp.contains('Rally_Implementation_Start_Date__c')) {
            queryString_imp += ', Rally_Implementation_Start_Date__c';
        }
        
        for(WikiReport__c wkite:[select Id, Condition__c, Query__c, Field_Name__c, Header_Value__c from WikiReport__c where Name=:reportName order by step__c Asc]){
            if(wkite.Query__c=='Where'){
                queryString_imp += ' FROM Milestone1_Project__c where '+wkite.Condition__c;  
            }
            if(wkite.Query__c=='Order By'){
                queryString_imp +=' ORDER BY '+wkite.Condition__c;
            }
        }

        List<Milestone1_Project__c> imps = Database.query(queryString_imp);

        for(Milestone1_Project__c m : imps){
            if(dateMap.isEmpty() || !dateMap.containsKey(m.Rally_Implementation_Start_Date__c))
                dateMap.put(m.Rally_Implementation_Start_Date__c, new List<Milestone1_Project__c>{m});
            else if(dateMap.containsKey(m.Rally_Implementation_Start_Date__c))
                dateMap.get(m.Rally_Implementation_Start_Date__c).add(m);
        }
        rd.dateList = new List<dateToImp>();
        for(date d : dateMap.keySet()){
            rd.dateList.add( new dateToImp(d,dateMap.get(d)));
        }


        Map<string, string> mapfieldlabel=new Map<string, string>();
        for(WikiReport__c wkite:[select Id, Condition__c, Query__c, Field_Name__c, Header_Value__c from WikiReport__c where Name=:reportName and Field_Name__c!=Null]){
            if(!mapfieldlabel.containsKey(wkite.Field_Name__c)) {
                mapfieldlabel.put(wkite.Field_Name__c, wkite.Header_Value__c);
            }  
        }   
        rd.labellist = new List<String>();
        for(Schema.FieldSetMember fsm: getImpFields){
            if(mapfieldlabel.containsKey(fsm.label)){
                rd.labellist.add(mapfieldlabel.get(fsm.label));
            }
            else {
              rd.labellist.add(fsm.label);
            }
        }
        rd.cwidth=100/rd.labellist.size();
        return rd;
    }
    
    public class ResponseData {
        public List<dateToImp> dateList{get;set;}
        public List<String> labellist{get; set;}
        public Double cwidth{get; set;}
        public List<string> fieldList_imp {get; set;}
    }
    
    public class dateToImp{
        public date dt{get;set;}
        public List<Milestone1_Project__c> impList{get;set;}

        public dateToImp(date DTP, List<Milestone1_Project__c> impListP){
            this.dt = DTP;
            this.impList = new List<Milestone1_Project__c>();
            this.impList.addAll(impListP);
        } 
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    } 
}