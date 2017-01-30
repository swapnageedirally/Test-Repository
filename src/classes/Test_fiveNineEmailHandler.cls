@istest
public class Test_fiveNineEmailHandler {
    
    @istest(seealldata=false)
    static void Test_five9EmailHandler() {

        case c = new case(subject='test');
        insert c;

        task t = new task(Five9__Five9SessionId__c='Magnetowasright',whatID=c.id,activitydate=date.today(),status='Completed',priority='Normal');
        insert t;

        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.textAttachment inAtt = new Messaging.InboundEmail.textAttachment();

        email.subject = 'test';
        env.fromAddress = 'user@acme.com';

        // set the body of the attachment
        string header = 'SESSION ID,QUEUE WAIT TIME,CALL TIME,IVR TIME,RING TIME,SPEED OF ANSWER,TALK TIME,HOLD TIME,CONSULT TIME,TIME TO ABANDON,3RD PARTY TALK TIME,TALK TIME LESS HOLD AND PARK,CONFERENCE TIME,TRANSFERS,HOLDS,CONFERENCES,DISCONNECTED FROM HOLD,SERVICE LEVEL,ABANDONED,CAMPAIGN \n';
        string line1 = 'Magnetowasright,0:00:04,0:00:05,0:00:05,,,0:00:00,0:00:00,0:00:00,0:00:04,0:00:00,0:00:00,0:00:00,,,,0,0,1,Test Inbound Campaign \n';

        string bodyy = header + line1;

        inAtt.body = bodyy;
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'text/csv';

        email.textAttachments = new Messaging.inboundEmail.textAttachment[] {inAtt }; 

        // call the class and test it with the data in the testMethod
        fiveNineEmailHandler emailServiceObj = new fiveNineEmailHandler();
        emailServiceObj.handleInboundEmail(email, env );                      
    }
}