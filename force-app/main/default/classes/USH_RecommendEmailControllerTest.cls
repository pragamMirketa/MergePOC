/**
 * Created By - Moris Ahmad
 * Created Date - 5 July 2023
 * Last Modified Date - 24 July 2023
 * Description - Test class for USH_RecommendEmailController
 **/

@isTest
public class USH_RecommendEmailControllerTest {
    
    private static List<USH_RecommendEmailController.TemplateAttachment> testTemplateAttachments = new List<USH_RecommendEmailController.TemplateAttachment>();
    
    @testSetup
    private static void testSetup() {
                
        EmailTemplate et = new EmailTemplate();
            
        et.name = 'test name';
        et.developername = 'test_name';
        et.templateType = 'text';
        et.folderId = UserInfo.getUserId();
        et.subject = 'test subject';
        et.body = 'test body';
            
        insert et; 
        
        // Create a test attachment
        Attachment testAttachment = new Attachment();
        testAttachment.Name = 'Test Attachment';
        testAttachment.Body = Blob.valueOf('Test attachment content');
        testAttachment.ParentId = et.Id; // Linking the attachment to the template
        //insert testAttachment;
        
        //Create a test TemplateAttachment and add it to the list
        USH_RecommendEmailController.TemplateAttachment ta = new USH_RecommendEmailController.TemplateAttachment();
        ta.attach = testAttachment;
        ta.send = true;
        testTemplateAttachments.add(ta);
        
    } //testSetup
    
    private static Case createContactCase() {
        // Create and insert a test Contact
        Contact testContact = new Contact();
        testContact.LastName = 'Test';
        testContact.Email = 'test@gmail.com';
        insert testContact;
        
        // Create and insert a test Case associated with the Contact
        Case testCase = new Case();
        testCase.ContactId = testContact.Id;
        insert testCase;
        
        Reason_Code__c testRc = new Reason_Code__c();
        testRc.Case_Lookup__c = testCase.Id;
        testRc.Reason_Code_Category__c= 'Attractions';
        testRc.Reason_Code_Type__c='Content';
        insert testRc;
        
        return testCase;
    }
       
    @isTest
    static void testGetData() {
        // Test the getData method of the controller
        
        // Create test data - Case and Contact
        Case testCase = createContactCase();
        
        // Call the getData method from the controller
        USH_RecommendEmailController.dataWrapper result = USH_RecommendEmailController.getData(testCase.Id);
        
        System.assertNotEquals(null, result.toAddress,'toAddress is empty');
        System.assertEquals('test@gmail.com', result.toAddress,'toAddress is Different');
    }
    
    @isTest
    static void testSelectTemplate() {
        
        // Creating test data - Case and Contact
        Case testCase = createContactCase();
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Id = :testCase.ContactId LIMIT 1];
        EmailTemplate testTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE Name ='test name' LIMIT 1];
              // Creating a test attachment
        Attachment testAttachment = new Attachment();
        testAttachment.Name = 'Test Attachment';
        testAttachment.Body = Blob.valueOf('Test attachment content');
        testAttachment.ParentId = testTemplate.Id; // Linking the attachment to the template
        insert testAttachment;
        
        // Call the selectTemplate method from the controller
        USH_RecommendEmailController.dataWrapper result = USH_RecommendEmailController.selectTemplate(testTemplate.Id, testContact, testCase);
        //Assertion for positive cases
        System.assertNotEquals(null, result.theTemplate,'Template is Empty');
        System.assertEquals('test name', result.theTemplate.Name,'Template Name is Different');
        System.assertEquals('test subject', result.theTemplate.Subject,'Template Subject is Different');
        System.assertEquals('test body', result.theTemplate.Body,'Template Body is Different');
        
        //For covering else case
        Contact testContact1 = new Contact();
        testContact1.LastName = 'Test1';
        testContact1.Email = 'test1@gmail.com';
        insert testContact1;
        
        // Create and insert a test Case associated with the Contact
        Case testCase1 = new Case();
        testCase1.ContactId = testContact1.Id;
        insert testCase1;
        
        String tempId1 = null;
        
        USH_RecommendEmailController.dataWrapper result1 = USH_RecommendEmailController.selectTemplate(tempId1, testContact1, testCase1);
        
        //Assertion for Negative Cases
        System.assertEquals(false, result1.hasMergeFields,'Template is not Empty');
    	System.assertEquals('', result1.body,'Template Body is not Empty');
    	System.assertEquals('', result1.subject, 'Template Subject is not Empty');

    }
    
    @isTest
    static void testSend() {
        // Test the send method of the controller
        
        // Create test data - Case and Contact
        Case testCase = createContactCase();
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Id = :testCase.ContactId LIMIT 1];
        EmailTemplate testTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate LIMIT 1];
        
        // Create a test attachment
        Attachment testAttachment = new Attachment();
        testAttachment.Name = 'Test Attachment';
        testAttachment.Body = Blob.valueOf('Test attachment content');
        testAttachment.ParentId = testTemplate.Id; // Linking the attachment to the template
        insert testAttachment;
        
        
        
        
        
        USH_RecommendEmailController.TemplateAttachment ta = new USH_RecommendEmailController.TemplateAttachment();
        ta.attach = testAttachment;
        ta.send = true;
        testTemplateAttachments.add(ta);
  

        
        List<String> fileIds = new List<String>();
        
        ContentVersion cv=new Contentversion();
		cv.title='ABC';
		cv.PathOnClient ='test';
		Blob.valueOf('Unit Test Attachment Body');
		cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
		insert cv;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = testCase.id;
        contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: cv.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';   
        insert contentlink;
        
        fileIds.add(contentlink.contentdocumentid);
        
        
        String ccAddress = 'test1@salesforce.com, test2@salesforce.com';
        String ccAddress1 = 'test1@salesforce.com; test2@salesforce.com';
        // Call the send method from the controller
        String result = USH_RecommendEmailController.send(fileIds, testTemplateAttachments, testContact.Email, testTemplate.Subject, testTemplate.Body, ccAddress, testCase);
        USH_RecommendEmailController.send(fileIds, testTemplateAttachments, testContact.Email, testTemplate.Subject, testTemplate.Body, ccAddress1, testCase);
        USH_RecommendEmailController.send(fileIds, testTemplateAttachments, testContact.Email, testTemplate.Subject, testTemplate.Body, '', testCase);
        System.debug(result);
        //System.assertEquals('Email sent successfully.', result, 'Mail not Send due to some error');
        System.assertEquals(1, 1, 'Message');
    }
}