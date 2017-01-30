public class ManageAffiliationRelationshipsController {

    public SelectOption[] selectedAffiliation { get; set; }
    public SelectOption[] allAffiliation { get; set; }
    
    public string message { get; set; }
    public string recID { get; set; }
    public string impID { get; set; }
    public string sObjName { get; set; }

    public List<sObject> newObjects {get;set;}

    public Set<string> initialAffils {get;set;}

    public Map<string,string> affilMap {get;set;}    
    public Map<string,string> initialMap {get;set;}    

    public ManageAffiliationRelationshipsController() {

        impID = Apexpages.currentPage().getParameters().get('impID');
        recID = Apexpages.currentPage().getParameters().get('recID');
        sObjName = Utils_Implementation.findObjectNameFromRecordIdPrefix(recID);

        initialAffils = new Set<string>();
        affilMap = new Map<string,string>();
        initialMap = new Map<string,string>();

        Set<String> joinFields = Schema.SObjectType.Affiliation_Join__c.fields.getMap().keySet();
        for(string s : joinFields){
            system.debug('JOIN FIELDS ARE ' + s);
        }

        system.debug('SOBJECT NAME IS ' + sObjName);

        Set<string> recs = new Set<String>{recID};

        if(joinFields.contains(sObjName)){

            String queryString = 'select Id, Client_Affiliation__c, Affiliation_Display_Name__c,Client_Affiliation__r.affiliation__c, Client_affiliation__r.name, Client_affiliation__r.createdDate,' + sObjName;
            queryString += ' from Affiliation_Join__c WHERE ' + sObjName + ' IN : recs AND Client_affiliation__r.Implementation__c = \'' + impID +'\' ORDER BY Client_affiliation__r.affiliation__r.createdDate';
            
            system.debug('QUERY  IS ' + queryString);

            newObjects = database.query(queryString);

            for(sObject sobj : newObjects){
                initialAffils.add(string.valueOf(sobj.get('Affiliation_Display_Name__c')));
                initialMap.put(string.valueOf(sobj.get('Affiliation_Display_Name__c')), string.valueOf(sobj.get('id')));
            }

            system.debug('INITIAL AFFILIATION JOINS ARE ' + initialAffils);

            selectedAffiliation = new List<SelectOption>();

            List<Client_Affiliation__c> cas = [select id, Affiliation__c, Affiliation__r.name from Client_Affiliation__c WHERE Implementation__c = :impID];

            Set<ID> clientAffilIDs = new Set<ID>();

            for(Client_Affiliation__c c : cas){
                affilMap.put(c.Affiliation__r.name, c.id);
                clientAffilIDs.add(c.Affiliation__c);
            }

            system.debug('Affilitation Map is ' + affilMap);
            
            List<Affiliation__c> affiliations = [SELECT Name, Id, Affiliation_String__c FROM Affiliation__c where  ID IN :clientAffilIDs];   

            allAffiliation = new List<SelectOption>();
            for ( Affiliation__c c : affiliations ) {
                if(initialAffils.isEmpty() || !initialAffils.contains(c.name))
                    allAffiliation.add(new SelectOption(c.Id, c.Name));
                else if(initialAffils.contains(c.name))
                    selectedAffiliation.add(new SelectOption(c.id, c.name));
            }
        }
        else{
            message = Label.ManageAffiliationRelationship_Message;
            return;
        }
    }

    public PageReference cancel(){
        PageReference pg = new PageReference('/'+recID);
        pg.setRedirect(true);
        return pg;
    }

    public PageReference save() {

        Set<string> deleteAffils = new Set<String>();

        system.debug('ALL NON SELECTED AFFILIATIONS ' + allAffiliation);

        for ( SelectOption so : allAffiliation ) {
            system.debug('ARE WE DELETING ' + so.getLabel());

            if(!initialAffils.isEmpty() && initialAffils.contains(so.getLabel())){
                system.debug('DO WE FIND A DELETE ROW ' + initialMap.get(so.getLabel()));
                deleteAffils.add(initialMap.get(so.getLabel()));
            }
        }

        for ( SelectOption so : selectedAffiliation ) {
            if(initialAffils.isEmpty() || (!initialAffils.isEmpty() && !initialAffils.contains(so.getLabel()))){
                Sobject o = Utils_Implementation.getsObjectType('Affiliation_Join__c').newSObject();
                o.put('Client_Affiliation__c', affilMap.get(so.getLabel()));
                o.put(sObjName, recID);
                newObjects.add(o);
            }
        }

        if(!newObjects.isEmpty())
            upsert newObjects;
        
        if(!deleteAffils.isEmpty()){

            List<Affiliation_Join__c> caDel = [select Id from Affiliation_Join__c where ID IN : deleteAffils];
            delete caDel;
        }
        
        PageReference pg = new PageReference('/'+recID);
        pg.setRedirect(true);
        return pg;       
    }
}