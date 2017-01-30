public class FileUploader 
{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    Public List<String> filelines {get;set;}
    public List<Challenge_Team__c> teamsToUpload {get;set;}

    public String recid {get;set;}

    public FileUploader (){
        recID = Apexpages.currentPage().getParameters().get('id');
        filelines = new List<String>();
    }
    
    public Pagereference ReadFile()
    {
        try{
            
            system.debug('NAME FILE BEFORE SETTING ' + nameFile);
            
            system.debug('CONTENT FILE AS BLOB ' + contentfile);
            
            nameFile=contentFile.toString();
            
            system.debug('NAME FILE IS ' + contentfile);

            filelines = nameFile.split('\n');

            teamsToUpload = new List<Challenge_Team__c>();

            system.debug('FILE LINES ARE ' + filelines);

            for (string s : fileLines)
            {
                system.debug('DO WE GET IN LOOP ' + s);
                
                String[] inputvalues = new String[]{};
                inputvalues = s.split(',');

                system.debug('INPUT VALS ARE ' + inputvalues);
                
                Challenge_Team__c FF = new Challenge_Team__c();
                FF.Challenge__c = recid;
                FF.Name__c = inputvalues[0];       
                FF.Description__c = inputvalues[1];

                teamsToUpload.add(FF);
            }
        }
        catch (Exception e){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file'+e.getMessage());
            ApexPages.addMessage(errormsg);
        }
        
        try{
            insert teamsToUpload;
        }
        catch (Exception e)
        {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
            ApexPages.addMessage(errormsg);
        }    
        PageReference p= new PageReference('/'+recid);
        p.setRedirect(true);
        return p;
    }
           
}