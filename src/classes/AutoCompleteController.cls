/*
* Controller to implement the auto-complete feature on the Visualforce page
*/
public with sharing class AutoCompleteController {
    
    // Instance fields
    public String searchTerm {get; set;}
    public String selectedRecordId {get;set;}
    public Account selectedClientID{get;set;}
    public String errorMessage{get;set;}
    public boolean showError{get;set;}
    // Constructor
    public AutoCompleteController() {
        errorMessage = '';
        showError = false;
    }
    
    // JS Remoting action called when searching for a movie name
    @RemoteAction
    public static List<Account> getAccount(String searchString, String partnerid) {
        searchString = '%'+searchString+'%';
        List<Account> accts = [select id, name from Account where Name LIKE :searchString AND Partner__c = :partnerid];
        return accts;
    }
    
    public void getLinkStuff(){
        try{
            String searchString = '%'+searchTerm+'%';
            selectedClientID = [select id, name, (select id, name from Rally_Implementations__r) from Account where Id = :selectedRecordId And Name LIKE :searchString];
        } catch(Exception e) {
            showError = true;
            errorMessage = e.getMessage();
        }
    }
    
}