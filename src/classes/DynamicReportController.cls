public class DynamicReportController {
    public String urlStuff { get; set; }
    public String valueLat { get; set; }
    public List<string> fieldList_imp {get; set;}
    public List<String> labellist{get; set;}
    public double cwidth{get; set;}

    public List<Milestone1_Project__c> imps { get; set; }
    public List<dateToImp> dateList { get; set; }
    public string ReportName{get; set;}
   

    

    public DynamicReportController(){
        dateList = new List<dateToImp>();
        ReportName=ApexPages.currentPage().getParameters().get('ReportName');

        system.debug('Report Name' +ReportName);


        Map<Date, List<Milestone1_Project__c>> dateMap = new Map<Date,List<Milestone1_Project__c>>();

        List<string> impStandardFieldList = new List<string>{};
        string queryString_imp = '';

        List<Schema.FieldSetMember> getImpFields = readFieldSet(ReportName, 'Milestone1_Project__c');
   

        for(Schema.FieldSetMember fsm: getImpFields){
            impStandardFieldList.add(fsm.getfieldPath());
        }

        system.debug('impStandardFieldList' +impStandardFieldList);

        // Add to set to de-dup field listing
        Set<string> fieldSetImp = new Set<string>();
        for(string s: impStandardFieldList){
            fieldSetImp.add(s.toLowerCase());
        }
        
        // Build SOQL query (for ContactInformation)
        fieldList_imp = new List<string>(fieldSetImp);
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

        
        for(WikiReport__c wkite:[select Id, Condition__c, Field_Name__c, Header_Value__c from WikiReport__c where Name='ExternalImplementationReportFields' and RecordType.Name='Query']){
             if(wkite.Condition__c!=Null){
                queryString_imp += ' FROM Milestone1_Project__c where '+wkite.Condition__c;  
             }
             
        }

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

        labellist = new List<String>();

        Map<string, string> mapfieldlabel=new Map<string, string>();
        for(WikiReport__c wkite:[select Id, Field_Name__c, Header_Value__c from WikiReport__c where Name='ExternalImplementationReportFields' and RecordType.Name='Header Report']){
            if(!mapfieldlabel.containsKey(wkite.Field_Name__c)) {
                mapfieldlabel.put(wkite.Field_Name__c, wkite.Header_Value__c);
            }  
        } 

         for(Schema.FieldSetMember fsm: getImpFields){
            system.debug('fsm.label' +fsm.label);
            if(mapfieldlabel.containsKey(fsm.label)){
                labellist.add(mapfieldlabel.get(fsm.label));
            }
            else{
              labellist.add(fsm.label);
            }
        }

        cwidth=100/labellist.size();
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

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

    //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

    //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
    //system.debug('fieldSetMemberList ====>' + fieldSetMemberList);  
    return fieldSetObj.getFields(); 
    }  
}