public class ContinueCaseController {
	
	public ContinueCaseController(ApexPages.StandardController controller) {
		string instance = 'https://' + ApexPages.currentPage().getHeaders().get('Host');
		instance += '/ui/support/servicedesk/ServiceDeskPage#/csr_createcase?cfid=1234545678';
		system.debug('INSTANCE IS ' + instance);
	}
}