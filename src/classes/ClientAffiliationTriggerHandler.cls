public class ClientAffiliationTriggerHandler {
    public static void beforeUpsert(Client_Affiliation__c[] cas) {

       
    }

    public static void AfterUpsert(Client_Affiliation__c[] cas) {

        Set<id> impls = new Set<ID>();
        List<Milestone1_Project__c> updateImps = new List<Milestone1_Project__c>();

        for(Client_Affiliation__c c : cas){
            impls.add(c.Implementation__c);
        }

        List<Milestone1_Project__c> imps = [select id,
                                                   Wellness_Coaching_Affiliations__c,
                                                   Survey_Reset_Affiliation__c,
                                                   (select id, Name,
                                                   Implementation__c,
                                                   Affiliation_Roles__c,
                                                   affiliation__r.name
                                                   from Client_Affiliations__r
                                                   where Affiliation_Roles__c
                                                   INCLUDES ('Coaching', 'Survey Reset', 'Public Communities Ineligible', 'Biometrics',  'Real Appeal', 'Quit for Life')
                                                   ORDER BY Name ASC)
                                                   FROM Milestone1_Project__c
                                                   WHERE ID IN : impls];
        
        for(Milestone1_Project__c imp : imps){
            string str;
            string str1;
            string str2;
            string str3;
            string str4;
            string str5;
            string f = '';
            string j = '';
            string i = '';
            string k = '';
            string l = '';
            string m = '';
            
            for(Client_Affiliation__c c : imp.Client_Affiliations__r){
            
              if(c.Affiliation_Roles__c.contains('Coaching')){ 
                str=c.Name.substring(0,1).trim();        
                f += 'Affiliation #' + str + ': ' + c.Affiliation__r.Name + '\n';
              }

              if(c.Affiliation_Roles__c.contains('Survey Reset')){
                 str1=c.Name.substring(0,1).trim();  
                j += 'Affiliation #' + str1+ ': ' + c.Affiliation__r.Name + '\n';
              }
              if(c.Affiliation_Roles__c.contains('Public Communities Ineligible')){
                 str2=c.Name.substring(0,1).trim();  
                i += 'Affiliation #' + str2+ ': ' + c.Affiliation__r.Name + '\n';
              }
              if(c.Affiliation_Roles__c.contains('Biometrics')){
                 str3=c.Name.substring(0,1).trim();  
                k += 'Affiliation #' + str3+ ': ' + c.Affiliation__r.Name + '\n';
              }
              if(c.Affiliation_Roles__c.contains('Real Appeal')){
                 str4=c.Name.substring(0,1).trim();  
                l += 'Affiliation #' + str4+ ': ' + c.Affiliation__r.Name + '\n';
              }
              if(c.Affiliation_Roles__c.contains('Quit for Life')){
                 str5=c.Name.substring(0,1).trim();  
                m += 'Affiliation #' + str5+ ': ' + c.Affiliation__r.Name + '\n';
              }
            }

            
              imp.Wellness_Coaching_Affiliations__c=f;
              imp.Survey_Reset_Affiliation__c=j;
              imp.Public_Communities_Ineligible_Affiliatio__c=i;
              imp.Quit_for_Life_Affiliations__c=m;
              imp.Real_Appeal_Affiliations__c=l;
              imp.Biometric_Affiliations__c=k;
             
             
            if(j != '' || f != ''|| i != ''|| m!='' || l!='' || k!='')
              updateImps.add(imp);

        }

        if(!updateImps.isEmpty())
          update updateImps;



    }
}