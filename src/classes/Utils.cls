global class Utils {
	
    //UNCOMMENT FOR WEBSERVICE CALLOUT WHEN AUTHN IS READY FOR US - AMR 7.9.15
    
	/*public AdminDBJSON callAdminDB(String Username) {
        HttpRequest req = new HttpRequest();
                        
        //String apiKey = API_KEY__c.getInstance('AdminDB Key') != null ? API_KEY__c.getInstance('AdminDB Key').API_Key__c : '';
        
        String apiKey = '';

        req.setEndpoint('https://SOMEURLTOPOSTTO/SOMEENDEPOINTNONSENSE?api_key=' + apiKey + '&username=' + username);
        req.setMethod('GET');
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setCompressed(true);

        try {
            res = http.send(req);
            string jresp = res.getBody();
            
            //might have to check null here, depends on how AdminDB handles this
            AdminDBJSON myClass = AdminDBJSON.parse(jresp);

            if(myClass != null)
            	return myClass;
            else
            	return null;
            	
        } 
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            return null;
        }
    }*/

    public static Map<integer, integer> getCalendarMap(){
        Map<integer, integer> intmap = new Map<integer, integer>();
        intmap.put(1,31);
        intmap.put(2,28);
        intmap.put(4,30);
        intmap.put(5,31);
        intmap.put(6,30);
        intmap.put(7,31);
        intmap.put(8,31);
        intmap.put(9,30);
        intmap.put(10,31);
        intmap.put(11,30);
        intmap.put(12,31);
        return intmap;
    }

    public static void addSingleErrorLog(Utils.ApexError[] errorList){     
        List<System_Log__c> errors = new List<System_Log__c>();

        for(Utils.ApexError ae : errorList){
            System_Log__c errorLog = new System_Log__c();
            errorLog.recordTypeId = LABEL.DEFAULT_ERRORLOG_RECORDTYPE_ID;
            errorLog.Record_Id__c = ae.recordID;
            if(ae.recordID != null && ae.recordID != '')
                errorLog.Object_Type__c = id.ValueOf(ae.recordID).getSObjectType().getDescribe().getName();
            errorLog.Page_Process__c = ae.pageOrProcess;
            errorlog.Error_Message__c = ae.errorString;
            errorLog.User__c = ae.userId;
            errors.add(errorLog);
        }
              
        // as this method is static, we will insert the error straight away
        Database.insert(errors, false); 
        
    }

    global class ApexError{
        
        global string recordID          {get; set;}
        global String pageOrProcess          {get; set;}
        global String userId          {get; set;}
        global string errorString       {get; set;}
        global DateTime timeStamp       {get; set;}
    
    }

    public static String DateTimeToSoqlDateTime(DateTime dt) {
        // DateTime no Miliseconds formats like YYYY-MM-DDTHH:mm:SS
        return String.ValueOf(dt).Replace(' ', 'T') + 'Z';
    }

    public static String DateToSoqlDate(Date d) {
        // Date format in SOQL can't have the time
        return String.ValueOf(d).Replace(' 00:00:00', '');
    }

    //CHANNEL WORK//
    // Auto-Caching channels
    private static List<Sales_Channel__c> chans_p;
    public static List<Sales_Channel__c> Channels {
        get {
            if (chans_p == null)
                chans_p = [select Id, Name, Unapproved_Record_Type_ID__c, Approved_Record_Type_Id__c, DNIS_Formula__c,Case_Record_Type_ID__c from Sales_Channel__c];
            return chans_p;
        }
    }

    //Partner WORK//
    // Auto-Caching Partners
    private static List<Partner__c> partner_p;
    public static List<Partner__c> Partners {
        get {
            if (partner_p == null)
                partner_p = [select Id, name,Support_Number_Formula__c from Partner__c];
            return partner_p;
        }
    }


    public static Set<Id> ChannelRecordTypeIDs(String channel) {

        Set<Id> chanIds = new Set<Id>();

        // Go through every channel object
        for (Sales_Channel__c c : Channels) {
            if (c.Name.equalsIgnoreCase(channel)) {
                chanIds.add(c.Unapproved_Record_Type_Id__c);
                chanIds.add(c.Approved_Record_Type_Id__c);
            }
        }
        
        return chanIds;
    }

    public static string KnowledgeArticleName(id kavID){
        Question__Kav[] qs = database.query(CC_Constants.BASE_QUERY + ' AND ID = : kavID');
        if(!qs.isEmpty())
            return qs[0].title;
        else
            return null;
    }

    public static Set<string> findUserPermissions(string useID){
        Set<string> newSet = new Set<string>();
        //first check the actual permission sets that are prepended with "User Property"
        for(PermissionSetAssignment pe: [select PermissionSet.Name, PermissionSet.label
                                                from PermissionSetAssignment
                                                where Assignee.Id = :useId
                                                order by PermissionSet.Name]){
            
            system.debug('PERMISSION SET NAME IS ' + pe.PermissionSet.label);

            if(pe.PermissionSet.label.containsIgnoreCase('User Property')){
                string temp = pe.PermissionSet.label.Replace('User Property: ', '');
                newSet.add(temp);
            }
        }
        //check metadata property object where applicable
        for(Metadata_Property__c mp : [select id, Properties__c from Metadata_Property__c where ((Metadata_Type__c = 'Profile' AND Metadata_ID__c = : userInfo.getProfileID()) OR (Metadata_Type__c = 'Role' AND Metadata_ID__c = : userInfo.getUserRoleID()))]){
            if(mp.Properties__c != null && mp.Properties__c != ''){
                List<string> tempList = mp.Properties__c.split(';');    
                system.debug('tempList is ' + tempList);
                if(!tempList.isEmpty())
                    newset.addall(tempList);
            }
        }

        return newSet;
    }

    public static id getNextAccountID(){
        id rallyAcctID;

        for (AggregateResult a :  [select Count(ID) cnt, AccountId from Contact where Account.RecordType.Name = 'Consumer Support' GROUP BY AccountId ORDER BY Count(ID)]) {
            rallyAcctID = String.ValueOf(a.get('AccountId'));
            break;
        }

        return rallyAcctID;
    }

    public static Sales_Channel__c GetChannelFromDNIS(string dnis){
        //Get the Rally account to associate newly created Contacts to it.
        for(Sales_Channel__c sc : channels){
            if(sc.DNIS_Formula__c == dnis){
                return sc;
            }
        }
        return null;
    }

    public static Partner__c GetPartnerFromDNIS(string dnis){
        //Get the Rally account to associate newly created Contacts to it.
        for(Partner__c p : partners){
            if(p.Support_Number_Formula__c == dnis){
                return p;
            }
        }
        return null;
    }

    public static List<SelectOption> findxxOptions(string controllingValue, string step){
        List<selectOption> optionslist = new List<selectOption>();
        Set<string> setCheck = new Set<string>();
        boolean isStep1 = false;

        string query = 'select id, Controlling_field_Value__c,Dependent_field_value__c, Object_Name_for_Dependent_Picklist__c FROM Dependent_Picklist1__mdt';
        if(step == '1'){
            query += ' WHERE Step__c = 1.0 ORDER BY Controlling_field_Value__c ASC';
            isStep1 = true;
        }
        else{
            string safeString = string.escapeSingleQuotes(controllingValue);
            system.debug('SAFE STRING IS ' + safeString);
            query += ' WHERE Controlling_field_Value__c LIKE \'' + safeString +'\' ORDER BY Dependent_field_Value__c ASC';
        }

        system.debug('PICKLIST QUERY IS ' + query);

        if(isStep1 || (controllingValue != null && controllingValue != '')){

            List<Dependent_Picklist1__mdt> picks = database.query(query);

            system.debug('PICKS ARE ' + picks);

            for(Dependent_Picklist1__mdt q : picks){
                
                if(isStep1 && q.Controlling_field_value__c != null && (setCheck.isEmpty() || !setCheck.contains(q.Controlling_field_value__c))){
                    optionslist.add(new SelectOption(q.Controlling_Field_Value__c, q.Controlling_Field_Value__c));
                    setCheck.add(q.Controlling_field_value__c);
                }
                else if(!isStep1 && q.Dependent_field_Value__c != null && (setCheck.isEmpty() || !setCheck.contains(q.Dependent_field_Value__c))){
                    optionslist.add(new SelectOption(q.Dependent_field_Value__c, q.Dependent_field_Value__c));
                    setCheck.add(q.Dependent_field_Value__c);
                }
            }
        }

        return optionslist;
    }

    global static Map<string, integer> findSecondsMapFromString(string[] timeStamps){
        
        Map<string,integer> tempMap = new Map<string,integer>();

        for(string s : timeStamps){
            if(s != '')
                tempMap.put(s, findSecondsFromString(s));
        }                                                
        
        system.debug('SECONDS MAP IS  ' +tempMap); 

        return tempMap;
    }

    global static integer findSecondsFromString(string timeStamp){
        integer seconds = 0;                                                
        
        List<string> timeStamps = timeStamp.split(':');
        system.debug(timeStamps); 
        //hours                                                
        if(integer.valueOf(timeStamps[0]) > 0){
            seconds += integer.valueOf(timeStamps[0])*3600;
        } 
        //minutes
        if(integer.valueOf(timeStamps[1]) > 0){
            seconds += integer.valueOf(timeStamps[1])*60;
        }   
        //seconds                          
        if(integer.valueOf(timeStamps[2]) > 0){
            seconds += integer.valueOf(timeStamps[2]);
        }       
        system.debug('seconds ' +seconds); 

        return seconds;
    }

}