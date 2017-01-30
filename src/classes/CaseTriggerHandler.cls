public class CaseTriggerHandler {

    private boolean m_isExecuting = false;

    public caseTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public static void OnBeforeInsert(Case[] newCases){
		//Find related contact via their Rally Health ID and insert new contact if not found in DB
		//relate Contact back to case after insert
        Set<ID> caseRtypes = new Set<ID>();
        Set<case> emailCases = new Set<case>();
		List<String> rallyIds = new List<String>();
    	Map<String,String> existingConMap = new Map<String,String>();

	    //First exclude any cases where the contact is set
	    for (Case c: newCases) {

	    	//set info for case age in business hrs process - AMR 10/16/15
	    	c.Last_Status_Change__c = System.now();
            c.Time_With_Tier_1__c = 0;
            c.TIme_with_Tier_2__c = 0;
            c.Time_with_Optum__c = 0;
            c.Time_with_Eng_Dev__c = 0;
            c.Time_with_Client_Team__c = 0;

            if(c.origin == 'Phone')
	            c.Initial_Response_Time__c = 0;
            //End business hrs stuff

	        if (c.ContactId==null
	        	&& c.suppliedemail!=null
	        		&& c.suppliedemail!='')
	        {
	            rallyIds.add(c.suppliedemail);
	        }

            if(c.recordTypeID != null && c.Channel__c == null){
                system.debug('DO WE NEED A CHANNEL? ' + c.recordtypeid);

                caseRtypes.add(c.recordtypeid);
                emailCases.add(c);
            }
	    }

	    if(!rallyIds.isEmpty()){
		    Id rallyAcctID;
		    Set<ID> aIDs = new Set<ID>();
		    Map<String, Contact> existingRecords = new Map<String, Contact>();
		    //Do some work to find a random consumer account for use in new contact creation
		    rallyacctid = Utils.getNextAccountID();
            
		    //Now we have a nice list of all the email addresses.  Let's query on it and see how many contacts already exist.
		    List<Contact> listContacts = [Select Id,email From Contact Where email in :rallyIds];
		    Set<String> takenUserNames = new Set<String>();

		    if(!listContacts.isEmpty()){
			    for (Contact c:listContacts) {
			        takenUserNames.add(c.email);
			        existingConMap.put(c.email, c.id);
			    }
			}
		    
		    system.debug('DO WE GET HERE ' + rallyAcctID);

		    Map<String,Contact> emailToContactMap = new Map<String,Contact>();
		    List<Case> casesToUpdate = new List<Case>();

		    for (Case c: newCases) {
		        if (c.ContactId==null 
		        	&& c.suppliedemail!=null
			            && c.suppliedemail!=''
			            	&& !takenUserNames.contains(c.suppliedemail))
		        {
		            //The case was created with a null contact
		            //Let's make a contact for it
		            integer index = c.suppliedemail.indexOf('@');
		            string lastn = c.suppliedemail.substring(0,index);

	                Contact cont = new Contact(LastName=lastn,
	                                            Email=c.suppliedemail);
	                if(rallyAcctID != null)
	                	cont.accountid = rallyAcctID;
	                	
	                emailToContactMap.put(c.suppliedemail,cont);
	                casesToUpdate.add(c);
		        }
		        else if(takenUserNames.contains(c.suppliedemail)){
		        	casesToUpdate.add(c);
		        }
		    }
		    
		    List<Contact> newContacts = emailToContactMap.values();
		    insert newContacts;
		    
		    for (Case c:casesToUpdate) {

		    	if(emailToContactMap.containsKey(c.suppliedemail)){
			        Contact newContact = emailToContactMap.get(c.suppliedemail);
			        
			        c.ContactId = newContact.Id;
			    }
			    else{
			    	c.ContactId = existingConMap.get(c.suppliedemail);
			    }
		    }
		}
        if(!caseRtypes.isEmpty()){
            Map<id, id> channelMap = new Map<id,id>();
            for(Sales_Channel__c chan : [select id, Case_Record_Type_Id__c from Sales_Channel__c where Case_Record_Type_Id__c IN : caseRtypes]){
                channelMap.put(chan.Case_Record_Type_Id__c, chan.id);
            }

            for(case c : emailCases){
                if(!channelMap.isEmpty() && channelMap.containsKey(c.recordtypeid))
                    c.Channel__c = channelMap.get(c.recordtypeid);
            }
        }
    }

    public static void OnBeforeUpdate(Case[] oldCases, Map<id,case> oldCaseMap){
        //Get the stop statuses
        Map<String, String> stopStatusMap = new Map<String, String>();
        Set<string> ownerBuckets = new Set<string>();

        for (Stop_Status__c stopStatus:[Select Name, Owner_Bucket__c From Stop_Status__c]) {
            stopStatusMap.put(stopStatus.name,stopStatus.Owner_Bucket__c);
        }

        system.debug('STATUS MAP IS ' + stopStatusMap);
        //find the bucket values needed for the dynamic apex below
        Schema.DescribeFieldResult fieldResult = Stop_Status__c.Owner_Bucket__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
          ownerBuckets.add(f.getLabel());
        }       

        system.debug('ownerBuckets are ' + ownerBuckets);

        //Get the  business hours 
        BusinessHours defaultHours = [select Id from BusinessHours where name = : label.DEFAULT_Support_Business_Hours_Name];

        //Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)
        Set<String> closedStatusSet = new Set<String>();
        for (CaseStatus status:[Select MasterLabel From CaseStatus where IsClosed=true]) {
            closedStatusSet.add(status.MasterLabel);
        }

        //For any case where the status is changed, recalc the business hours in the buckets
        for (Case updatedCase:oldCases) {
            Case oldCase = oldCaseMap.get(updatedCase.Id);

            //On the off-chance that the business hours on the case are null, use the default ones instead
            Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;

            if(oldCase.OwnerId != updatedCase.OwnerId && (updatedCase.Initial_Response_Time__c == null || updatedCase.Initial_Response_Time__c == 0)) {
            	Double timesinceOpen = BusinessHours.diff(hoursToUse, updatedCase.CreatedDate, System.now())/1000;
                timesinceOpen = timesinceOpen.round();
                System.debug(timesinceOpen);
                updatedCase.Initial_Response_Time__c = timesinceOpen;
            }
            else if (oldCase.Status!=updatedCase.Status && updatedCase.Last_Status_Change__c!=null) {
                //OK, the status has changed
                if (!oldCase.IsClosed) {
                    //We only update the buckets for open cases

                    //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                    Double timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now())/1000;
                    timeSinceLastStatus = timeSinceLastStatus.round();
                    System.debug(timeSinceLastStatus);

                    //We decide which bucket to add it to based on the Status of trigger.old
                    if (stopStatusMap.containsKey(oldCase.Status)) {
                        for(string s : ownerBuckets){
                        	if(stopStatusMap.get(oldCase.Status) == s){
                                string stripped = s.replace(' ', '_').replace('/','_');
                                string tempF = 'Time_with_' + stripped + '__c';
                                decimal tempD = (decimal) updatedCase.get(tempf);
                                
                                if(tempD != null)
                                   timeSinceLastStatus += tempD;
                                
                                updatedCase.put(tempf, timeSinceLastStatus);
                            }
                        }
                    }

					if (closedStatusSet.contains(updatedCase.Status)) {
                    	updatedCase.Case_Age_In_Business_Hours__c = updatedCase.Time_With_Tier_1__c + updatedCase.TIme_with_Tier_2__c + updatedCase.Time_With_Optum__c + updatedCase.Time_with_Eng_Dev__c + updatedCase.Time_With_Client_Team__c;
					}
                }

                updatedCase.Last_Status_Change__c = System.now();
            }
        } 
    }

    public static void OnAfterInsert(Case[] newCases){
        // EXECUTE AFTER INSERT LOGIC
        List<caseComment> ccs = new List<caseComment>();

        for(case c : [select id, comments__c, is_Parent_Case__c, hashtag__c, (select id from cases) from Case where ID IN : newCases]){
            
            if(c.Comments__c != null && c.Comments__c != ''){
                caseComment cc = new caseComment(commentbody=c.comments__c, ParentID = c.id, ispublished = false);
                ccs.add(cc);                

                if(c.is_parent_case__c && !c.cases.isEmpty()){
                    for(case c2 : c.cases){
                        caseComment cc2 = new caseComment(commentbody=c.comments__c, ParentID = c2.id, ispublished = false);
                        ccs.add(cc2);                
                    }
                }
            }

            if(c.hashtag__c != null && c.hashtag__c != '' && newCases.size() == 1){
                string sText = '{' + Label.ChatterSupportGroupID + '} #' + c.hashtag__c;
                ConnectApi.FeedElement fi = ConnectApiHelper.postFeedItemWithMentions(null, c.id, sText);
            }
        }

        if(!ccs.isEmpty())
            insert ccs;
    }

    public static void OnAfterUpdate(Case[] updatedCases, Map<id, Case> oldCaseMap){

        if(!case_validator.hasAlreadyDone()){
            // AFTER UPDATE LOGIC
            List<caseComment> ccs = new List<caseComment>();
            for(case c : [select id, comments__c, is_Parent_Case__c, hashtag__c, (select id from cases) from Case where ID IN : updatedCases]){
                case oldC = oldCaseMap.get(c.id);
                if(c.Comments__c != null && c.Comments__c != '' && c.Comments__c != oldc.Comments__c){
                    caseComment cc = new caseComment(commentbody=c.comments__c, ParentID = c.id, ispublished = false);
                    ccs.add(cc);   

                    if(c.is_parent_case__c && !c.cases.isEmpty()){
                        for(case c2 : c.cases){
                            caseComment cc2 = new caseComment(commentbody=c.comments__c, ParentID = c2.id, ispublished = false);
                            ccs.add(cc2);                
                        }
                    }             
                }

                if(c.hashtag__c != null && c.hashtag__c != '' && c.hashtag__c != oldCaseMap.get(c.id).hashtag__c && updatedCases.size() == 1){
                    string sText = '{' + Label.ChatterSupportGroupID + '} #' + c.hashtag__c;
                    ConnectApi.FeedElement fi = ConnectApiHelper.postFeedItemWithMentions(null, c.id, sText);
                }
            }

            if(!ccs.isEmpty())
                insert ccs;
                
            case_validator.setAlreadyDone();        
        }
    }

    /*public void OnBeforeDelete(Case[] CasesToDelete, MapCaseMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Case[] deletedCases, MapCaseMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Case[] restoredCases){
        // AFTER UNDELETE LOGIC
    }*/

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }


}