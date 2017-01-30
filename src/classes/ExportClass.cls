public with sharing class ExportClass {
public String parentRecordId;
public List<ChildObjToImp> ChildObjList { get; set; }
public Map<string,List<string>> fieldList_imp;
public Milestone1_Project__c imp{get; set;}
public Set<string> Impfieldlabel{get; set;}
	public ExportClass(ApexPages.StandardController stdController) {
        parentRecordId = stdController.getRecord().Id;
    }

    public Pagereference Export() {
        Savepoint sp = Database.setSavepoint();
        ChildObjList = new List<ChildObjToImp>();
        string queryString_impl;
        Impfieldlabel = new set<string>();

        
        try { 
        	List<string> impStandardField = new List<string>{'id'};
        	String parentObjAPIName=CloneCtrl.returnAPIObjectName(parentRecordId);

	        for(Schema.FieldSetMember fsm: this.getImpFields()){
	            impStandardField.add(fsm.getfieldPath());
	            Impfieldlabel.add(fsm.getLabel());
	        }

	        Set<string> ImpfieldSet = new Set<string>();
	        for(string s: impStandardField){
	            ImpfieldSet.add(s.toLowerCase());
	        }

	        List<string> ImpfieldList = new List<string>(ImpfieldSet);
	        for (Integer i=0; i<ImpfieldList.size(); i++) {
	            if(i == 0) {
	                    queryString_impl = 'select ' + ImpfieldList[i];
	            } else {
	                    queryString_impl += ', ' + ImpfieldList[i];
	            }
	        }

	         		querystring_impl+=' from Milestone1_Project__c where Id' +' = '+'\''+parentRecordId+'\'';

	         		imp = Database.Query(queryString_impl);


            //Getting all childs
            ChildFieldNameClass obj = CloneCtrl.getAllChildObjNames(parentObjAPIName,parentRecordId); 
            Map<String,String> objAPIobjlabel = obj.childFieldsName;
            Map<String,String> objlabelobjAPI = new Map<String, string>();
            for(string keyst: objAPIobjlabel.Keyset()){
            	string stv=objAPIobjlabel.get(keyst);
            	if(!objlabelobjAPI .containsKey(stv))
            	 objlabelobjAPI .put(stv, keyst);
            }	
           
            
            
            Map<String,String> chidlObjAPIName_FieldAPIName  = obj.chidlObjAPIName_FieldAPIName;
            for(string str: chidlObjAPIName_FieldAPIName.Keyset()){
            	List<string> impChildFieldList = new List<string>{};
            	List<string> labellist=new List<string>();
            	
            	string queryString_imp = '';
            	List<sobject> objlst=new List<sobject>();
            	Map<String, List<sobject>> ChildObjMap = new Map<String,List<sobject>>();

            	if(readFieldset('ExportPDF', str)!=Null){
            		List<Schema.FieldSetMember> schfieldset=readFieldset('ExportPDF', str).getFields();
            		system.debug('schfieldset' +schfieldset);

            		for(Schema.FieldSetMember fsm: schfieldset){
            			impChildFieldList.add(fsm.getfieldPath());
            			labellist.add(fsm.label);
        			}

        			

		        // Add to set to de-dup field listing
		        Set<string> fieldSetImp = new Set<string>();
		        for(string s: impChildFieldList){
		            fieldSetImp.add(s.toLowerCase());
		        }
		        
		        // Build SOQL query (for ContactInformation)
		        fieldList_imp = new Map<string,List<string>>();

		        for(string strit:fieldSetImp){
		        if(!fieldList_imp.containsKey(objLabelobjAPI.get(str)))
		        			fieldList_imp.put(objLabelobjAPI.get(str), new List<String>{strit});
		        else if(fieldList_imp.containsKey(objLabelobjAPI.get(str)))	
		        			fieldList_imp.get(objLabelobjAPI.get(str)).add(strit);
		        }

		           List<string> fieldList_imp2 = new List<string>(fieldSetImp);

				        
				        for (Integer i=0; i<fieldList_imp2.size(); i++) {
				            if(i == 0) {
				                    queryString_imp = 'select ' + fieldList_imp2[i];
				            } else {
				                    queryString_imp += ', ' + fieldList_imp2[i];
				            }
				        }

				        queryString_imp+= ' from '+str+' where ';
				        queryString_imp+= chidlObjAPIName_FieldAPIName.get(str)+' = '+'\''+parentRecordId+'\'';

				        objlst=Database.Query(queryString_imp);

				        	for(sobject sobj:objlst){
					            if(ChildObjMap.isEmpty() || !ChildObjMap.containsKey(objLabelobjAPI.get(str)))
					          		ChildObjMap.put(objLabelobjAPI.get(str), new List<sobject>{sobj});
					          		else if(ChildObjMap.containsKey(objLabelobjAPI.get(str)))
					          		ChildObjMap.get(objLabelobjAPI.get(str)).add(sobj);
				        	}

				        	for(string strite : ChildObjMap.keySet()){
					            ChildObjList.add( new ChildObjToImp(strite, fieldList_imp.get(strite), ChildObjMap.get(strite), labellist));
					        }

					        
					        system.debug('ChildObjList' +ChildObjList);
		            	}

		         }

            

   			return null;

   		}
	   	catch(Exception e){
	   		return null;

	   	}	
   	}

   	public static Schema.FieldSet readFieldSet(String fieldSetName, String ObjectName)
    {
    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    return fieldSetObj; 
    }

    public class ChildObjToImp{
        public string objectlabel   {get; set;}
        public List<sobject> Listchildobj  {get; set;}
        public List<string> ListchildField  {get; set;}
        public List<String> listlabelfield{get; set;}

        public ChildObjToImp(string label, List<string> lststr, List<sobject> lstobj, list<string> lstlabel){
            this.objectlabel = label;
            this.ListchildField = new List<String>();
            this.ListchildField.addall(lststr);
            this.Listchildobj  = new List<sobject>();
            this.Listchildobj.addAll(lstobj);
            this.listlabelfield = new List<String>();
            this.listlabelfield.addall(lstlabel);
        } 
    }

    public List<Schema.FieldSetMember> getImpFields() {
        return SObjectType.Milestone1_Project__c.FieldSets.ExportPDF.getFields();
    }

    
   		 	
}