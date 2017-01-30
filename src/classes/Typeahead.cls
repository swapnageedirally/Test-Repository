// Controller class for the Force.com Typeahead component
public class Typeahead {

  @RemoteAction
  public static list<sObject> searchRecords( String queryString, String objectName, 
    list<String> fieldNames, String fieldsToSearch, String filterClause, String orderBy, Integer recordLimit ) {

    if (queryString == null) return null;

    String sQuery = String.escapeSingleQuotes( queryString );
    if (sQuery.length() == 0) return null;

    String sObjectName = (objectName == null) ? 'Contact' : String.escapeSingleQuotes( objectName );

    String sInFields = 
    	(fieldsToSearch == null || fieldsToSearch == '' || fieldsToSearch.toUpperCase() == 'ALL') ? '' : 
    		( ' IN ' + String.escapeSingleQuotes(fieldsToSearch) + ' FIELDS' );
    
    String sFields = (fieldNames == null || fieldNames.isEmpty()) ? 'Id, Name' : 
    	String.escapeSingleQuotes( String.join( fieldNames, ', ' ) );  
    
    String sOrder = ' ORDER BY ' + ( (orderBy == null || orderBy == '') ? 'Name' : String.escapeSingleQuotes(orderBy) ); 
    
    String sLimit = (recordLimit == null || recordLimit == 0 || recordLimit >= 2000) ? '' : 
    	( ' LIMIT ' + String.valueOf(recordLimit));
    
    // can't escape the filter clause
    String sWhere = (filterClause == null || filterClause == '') ? '' : 
    	( ' WHERE ' + filterClause );

    list<list<sObject>> results = Search.query(
    	'FIND \'' + sQuery + '*\'' + sInFields + 
    		' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )'
    );
    
    return results[0];
  }  

  @RemoteAction
	public static list<sObject> searchRecords( String queryString) {

	    if (queryString == null) return null;

	    String sQuery = String.escapeSingleQuotes( queryString );
	    if (sQuery.length() == 0) return null;

	    String Name = 'Affiliation__c';

	    String sInFields = '';
	    	
	    String sFields = 'ID, Name, Affilation_String__c';
	    
	    String sOrder = ' ORDER BY Name'; 
	    
	    String sLimit = '';
	    
	    // can't escape the filter clause
	    String sWhere = '';

	    list<list<sObject>> results = Search.query(
	    	'FIND \'' + sQuery + '*\'' + sInFields + 
	    		' RETURNING Affiliation__c ' + '( ' + sFields + sWhere + sOrder + sLimit + ' )'
	    );
	    
	    return results[0];
	}  

}