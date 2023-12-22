/**
 * Created By - Moris Ahmad
 * Created Date - 5 July 2023
 * Last Modified Date - 24 July 2023
 * Test Class Name - USH_RecommendEmailControllerTest
 * Description - Controller class for USH_RecommendedEmails component that fetches the template data from custom metadata along with different 
 * 				 functionalities like - provides various functionalities such as retrieving data related to cases and contacts, populating 
 * 				 recommended email templates, merging data into templates, attaching files, and sending the composed email.
 **/

public with sharing class USH_RecommendEmailController {
    
    public class dataWrapper{
        
        @AuraEnabled
        public Id templateId {get;set;}
        @AuraEnabled
        public EmailTemplate theTemplate {get;set;}
        
        @AuraEnabled
        public Case theCase {get;set;}
        @AuraEnabled
        public Contact theContact {get;set;}
        
        @AuraEnabled
        public List<String> reasonTypes = new List<String>();
        @AuraEnabled
        public List<String> recommendedTemplates = new List<String>();
        
        @AuraEnabled
        public String body {get;set;}
        @AuraEnabled
        public Boolean hasMergeFields {get;set;}
        
        @AuraEnabled
        public String toAddress {get;set;} //Should Default to Case.Contact.Email
        @AuraEnabled
    	public String ccAddress {get;set;}
        @AuraEnabled
    	public String subject {get;set;} //After the email template is selected, this should populate with the subject  
         
    	@AuraEnabled
    	public String finalBody {get;set;}
        
        @AuraEnabled
        public List<TemplateAttachment> tattchs {get;set;}
        
        @AuraEnabled
		public List<Map<String,String>> getTemplateOptions = new List<Map<String,String>>();

        @AuraEnabled
        public String errorMessage { get; set; }
      
        
    }
    
    public class TemplateAttachment {
        @AuraEnabled
        public Attachment attach {get;set;}
        @AuraEnabled
        public Boolean send {get;set;}
    }
    
    /**
     * For getting the Case and Contact Data of current page.
     * Also getting the Templates to be set in dropdown according to Reason codes from the Custom Metadata.
     * */
    @AuraEnabled
    public static dataWrapper getData(String caseId){
        dataWrapper wrapper = new dataWrapper();
        Id cid = caseId;
        
        try{
            String query = 'SELECT ' + getAllFields('Case') + ' FROM Case WHERE id = :cid';
            if(Schema.sObjectType.Case.isQueryable()){
                wrapper.theCase = Database.query(query);
            }
            
            
            if(Schema.sObjectType.Reason_Code__c.isQueryable() && Schema.sObjectType.Reason_Code__c.fields.case_lookup__c.isAccessible() && Schema.sObjectType.Reason_Code__c.fields.id.isAccessible() && Schema.sObjectType.Reason_Code__c.fields.reason_code_type__c.isAccessible() ){
                for (Reason_Code__c rc: [SELECT id, case_lookup__c, reason_code_type__c FROM Reason_Code__c WHERE case_lookup__c = :wrapper.theCase.id]) {
                    if ( !wrapper.reasonTypes.contains(rc.Reason_Code_Type__c) ) {
                        wrapper.reasonTypes.add(rc.Reason_Code_Type__c);
                    }
                }
            }
            
            if(Schema.sObjectType.Recommended_Email_Settings__mdt.isQueryable() && Schema.sObjectType.Recommended_Email_Settings__mdt.fields.email_template__c.isAccessible() && Schema.sObjectType.Recommended_Email_Settings__mdt.fields.reason_code_type__c.isAccessible()){
                for (Recommended_Email_Settings__mdt res: [SELECT email_template__c, reason_code_type__c FROM Recommended_Email_Settings__mdt WHERE reason_code_type__c IN :wrapper.reasonTypes]) {
                    wrapper.recommendedTemplates.add(res.email_template__c);
                }
            }
            
            cid = wrapper.theCase.contactId;
            if(cid != null) {
                query = 'SELECT ' + getAllFields('Contact') + ' FROM Contact WHERE id = :cid';
                if(Schema.sObjectType.Case.isQueryable()){
                    wrapper.theContact = Database.query(query);
                }
                
                wrapper.toAddress = wrapper.theContact.email;
                
            } 
            
            wrapper.hasMergeFields = true;
            
            List<Map<String,String>> templateOptions = new List<Map<String,String>>();
            templateOptions.add( new Map<String, String>{'id' => '', 'name' => 'Select one to edit & send...'} );
            
            if(Schema.sObjectType.EmailTemplate.isQueryable() && Schema.sObjectType.EmailTemplate.fields.id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.name.isAccessible() && Schema.sObjectType.EmailTemplate.fields.body.isAccessible()){
                for (EmailTemplate et: [SELECT id, name, body FROM EmailTemplate WHERE developerName IN :wrapper.recommendedTemplates]) {
                    templateOptions.add( new Map<String, String>{'id' => et.id, 'name' => et.name} );
                } //for templates
            }
            System.debug(templateOptions);
            wrapper.getTemplateOptions = templateOptions;
        } catch (Exception e) { Orld_Exception__c ex = new Orld_Exception__c(); ex.Name = 'USH-RecommendedEmailControllerException'; wrapper.errorMessage = e.getMessage(); ex.Orld_Error_Message__c = e.getMessage(); ex.Orld_Case_Id__c = caseId; ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());  if(Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.isUpdateable() && Schema.sObjectType.Orld_Exception__c.fields.Name.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Error_Message__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Line_Number__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Case_Id__c.isCreateable()){  insert ex;  } }
        return wrapper;
    }
    
    /**
     * For Selecting the template from dropdown and setting the values to input fields as per template.
     * Also Merge Fields for Email template is being handled by calling the utility class - "FieldMergeUtil".
     **/
    @AuraEnabled
    public static dataWrapper selectTemplate(String tempId, Contact con, Case cases){
        dataWrapper wrapper1 = new dataWrapper();
        try{
            if ( tempId != null && tempId != '') {
                //load the template
                if(Schema.sObjectType.EmailTemplate.isQueryable() && Schema.sObjectType.EmailTemplate.fields.id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.name.isAccessible() && Schema.sObjectType.EmailTemplate.fields.subject.isAccessible() && Schema.sObjectType.EmailTemplate.fields.body.isAccessible()){
                    wrapper1.theTemplate = [SELECT id, name, subject, body FROM EmailTemplate WHERE id = :String.escapeSingleQuotes(tempId) WITH SECURITY_ENFORCED];
                }
    
                //For Subject
                String mergeSubject = '';
                mergeSubject = wrapper1.theTemplate.Subject.remove('Case.');
                mergeSubject = mergeSubject.remove('Contact.');
                mergeSubject = mergeSubject.remove('User.');
    
                mergeSubject = FieldMergeUtil.replaceMergeFieldsWithValues( mergeSubject, cases.Id);
                mergeSubject = FieldMergeUtil.replaceMergeFieldsWithValues( mergeSubject, con.Id);
                mergeSubject = FieldMergeUtil.replaceMergeFieldsWithValues( mergeSubject, UserInfo.getUserId());
    
                
                wrapper1.theTemplate.subject = mergeSubject;
                
                //For Body
                String mergeBody = '';
                mergeBody = wrapper1.theTemplate.Body.remove('Case.');
                mergeBody = mergeBody.remove('Contact.');
                mergeBody = mergeBody.remove('User.');
    
                mergeBody = FieldMergeUtil.replaceMergeFieldsWithValues( mergeBody, cases.Id);
                mergeBody = FieldMergeUtil.replaceMergeFieldsWithValues( mergeBody, con.Id);
                mergeBody = FieldMergeUtil.replaceMergeFieldsWithValues( mergeBody, UserInfo.getUserId());
    
                if(cases.Owner.Name!= null){
                    mergeBody = mergeBody.replace('{!OwnerFullName}', cases.Owner.Name);
                    mergeBody = mergeBody.replace('{!OwnerFullName}', cases.Owner.Name);
                }else{
                    mergeBody = mergeBody.replace('{!OwnerFullName}', '');
                    mergeBody = mergeBody.replace('{!OwnerFullName}', '');
                }
    
                if(cases.Owner.Title!=null){
                    mergeBody = mergeBody.replace('{!OwnerTitle}', cases.Owner.Title);
                    mergeBody = mergeBody.replace('{!ownertitle}', cases.Owner.Title);
                }else{
                    mergeBody = mergeBody.replace('{!OwnerTitle}', '');
                    mergeBody = mergeBody.replace('{!ownertitle}', '');
                }
                
                if(cases.Owner.Phone!=null){
                    mergeBody = mergeBody.replace('{!OwnerPhone}', cases.Owner.Phone);
                    mergeBody = mergeBody.replace('{!ownerphone}', cases.Owner.Phone);
                }else{
                    mergeBody = mergeBody.replace('{!OwnerPhone}', '');
                    mergeBody = mergeBody.replace('{!ownerphone}', '');
                }
                
                if(cases.Owner.FirstName!=null){
                    mergeBody = mergeBody.replace('{!OwnerFirstName}', cases.Owner.FirstName);
                    mergeBody = mergeBody.replace('{!ownerfirstname}', cases.Owner.FirstName);
                }else{
                    mergeBody = mergeBody.replace('{!OwnerFirstName}', '');
                    mergeBody = mergeBody.replace('{!ownerfirstname}', '');
                }
                
                if(cases.Owner.LastName!=null){
                    mergeBody = mergeBody.replace('{!OwnerLastName}', cases.Owner.LastName);
                    mergeBody = mergeBody.replace('{!ownerlastname}', cases.Owner.LastName);
                }else{
                    mergeBody = mergeBody.replace('{!OwnerLastName}', '');
                    mergeBody = mergeBody.replace('{!ownerlastname}', '');
                }
                
                if(cases.Owner.Email!=null){
                    mergeBody = mergeBody.replace('{!OwnerEmail}', cases.Owner.Email);
                    mergeBody = mergeBody.replace('{!owneremail}', cases.Owner.Email);
                }else{
                    mergeBody = mergeBody.replace('{!OwnerEmail}', '');
                    mergeBody = mergeBody.replace('{!owneremail}', '');
                }
                
                if(String.isNotBlank(cases.Thread_ID__c)){
                    mergeBody = mergeBody.replace('{!thread_id}', cases.Thread_ID__c);
                    mergeBody = mergeBody.replace('{!Thread_Id}', cases.Thread_ID__c);
                    mergeBody = mergeBody.replace('{!Thread_ID}', cases.Thread_ID__c);
                    mergeBody = mergeBody.replace('{!Email_Thread}', cases.Thread_ID__c);
                    //if thread_id__c was already there correct, it may get doubled up, so we'll fix it again
                    mergeBody = mergeBody.replace('{!thread_id__c__c}', cases.Thread_ID__c);
                }
                
    
                
                wrapper1.theTemplate.Body = mergeBody;
    
                //look for attachments to the template
                List<TemplateAttachment> tattchs = new List<TemplateAttachment>();
                if(Schema.sObjectType.Attachment.isQueryable() && Schema.sObjectType.Attachment.fields.id.isAccessible() && Schema.sObjectType.Attachment.fields.parentId.isAccessible() && Schema.sObjectType.Attachment.fields.name.isAccessible() && Schema.sObjectType.Attachment.fields.body.isAccessible()){
                    for (Attachment a : [SELECT id, parentId, name, body FROM Attachment WHERE parentId = :wrapper1.theTemplate.id WITH SECURITY_ENFORCED]) {
                        TemplateAttachment ta = new TemplateAttachment();
                        ta.attach = a;
                        ta.send = true;
                        tattchs.add(ta);
                    }
                }
                         
                wrapper1.tattchs = tattchs;
    
                
            } else {
                wrapper1.hasMergeFields = false;
                wrapper1.body = '';
                wrapper1.subject = '';
            }
        } catch (Exception e){ Orld_Exception__c ex = new Orld_Exception__c();  ex.Name = 'USH-RecommendedEmailControllerException';  wrapper1.errorMessage = e.getMessage();  ex.Orld_Error_Message__c = e.getMessage(); ex.Orld_Case_Id__c = cases.Id; ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());  if(Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.isUpdateable() && Schema.sObjectType.Orld_Exception__c.fields.Name.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Error_Message__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Line_Number__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Case_Id__c.isCreateable()){  insert ex;  } }
                    
        
        return wrapper1;
    }
    
    /**
     * Sending Mail after send button is clicked.
     * Also creating the Task after sending mail as per Requirement.
     * */
    @AuraEnabled
    public static String send(List<String> fileIds, List<TemplateAttachment> templateAttachmentIds, String toAddress, String subject, String finalBody, String ccAddress, Case cases) {

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		email.setReplyTo('ushfeedback@nbcuni.com');    
        
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [select Id from OrgWideEmailAddress where Address = 'ushfeedback@nbcuni.com'];

		
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea[0].Id);
        }

		email.toAddresses = new String[] { toAddress };            
		email.subject = subject;
		email.plainTextBody = finalBody;
        
        if (ccAddress.contains(',')) {
        	email.setCcAddresses( ccAddress.split('\\,'));
        } else {
            if (ccAddress.contains(';')) {
        		email.setCcAddresses( ccAddress.split('\\;'));
            } else {
                if ( !String.isBlank(ccAddress)) {
                    email.setCcAddresses( new String[] {ccAddress});
                    
                }
            }
        }
        
        
        //For Attachment
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        if(Schema.sObjectType.ContentVersion.isQueryable() && Schema.sObjectType.ContentVersion.fields.id.isAccessible() && Schema.sObjectType.ContentVersion.fields.Title.isAccessible() && Schema.sObjectType.ContentVersion.fields.FileExtension.isAccessible() && Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() && Schema.sObjectType.ContentVersion.fields.VersionData.isAccessible()){
            contentVersions = [SELECT Id, Title, FileExtension, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId IN :fileIds];
        }  
		List<Id> contentDocumentIds = new List<Id>();

		for (ContentVersion contentVersion : contentVersions) {
    		contentDocumentIds.add(contentVersion.ContentDocumentId);
		}
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        
        if(Schema.sObjectType.ContentDocumentLink.isQueryable() && Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()){
            contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :cases.Id AND ContentDocumentId IN :fileIds];
        }
  
		List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();

		for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
    		Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
    		emailAttachment.setFileName(getFileName(contentDocumentLink.ContentDocumentId, contentVersions));
    		emailAttachment.setBody(getFileBody(contentDocumentLink.ContentDocumentId, contentVersions));
    		emailAttachments.add(emailAttachment);
		}
        
        // Add template attachments
    	for (TemplateAttachment ta : templateAttachmentIds) {

            if (ta.send) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(ta.attach.name);
                if(Schema.sObjectType.Attachment.isQueryable() && Schema.sObjectType.Attachment.fields.id.isAccessible() && Schema.sObjectType.Attachment.fields.Body.isAccessible()){
                    efa.setBody([SELECT Id, Body FROM Attachment WHERE Id = :ta.attach.Id WITH SECURITY_ENFORCED].Body);
                }
                emailAttachments.add(efa);
                
            }
        }

		if (!emailAttachments.isEmpty()) {
    		email.setFileAttachments(emailAttachments);
		}//Attachment
          
		Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage> {email};
        String result = 'Email sent successfully.';
        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
			System.debug(results);
        }catch(Exception e){ result = e.getMessage(); Orld_Exception__c ex = new Orld_Exception__c();  ex.Name = 'USH-RecommendedEmailControllerException';  ex.Orld_Error_Message__c = e.getMessage();  ex.Orld_Case_Id__c = cases.Id; ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());  if(Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.isUpdateable() && Schema.sObjectType.Orld_Exception__c.fields.Name.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Error_Message__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Line_Number__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Case_Id__c.isCreateable()){  insert ex; }}
		
        //create the task
        
        Task t = new task();
        if(Schema.sObjectType.Case.isAccessible()){
            t.whatId = cases.id;
        }   	
	    t.whoId = cases.ContactId;
	    t.subject = 'Email Sent: ' + subject;
    	t.description = 'To: ' + toAddress + '\n'
            + 'From: ' + UserInfo.getUserEmail() + '\n'
            + 'Body: \n'
            + finalBody;
    	t.status = 'Completed';
        
        try{
            // Check if the Task is insertable before inserting
            if (Schema.sObjectType.Task.isCreateable() && Schema.sObjectType.Task.fields.whatId.isCreateable() && Schema.sObjectType.Task.fields.whoId.isCreateable() && Schema.sObjectType.Task.fields.subject.isCreateable() && Schema.sObjectType.Task.fields.description.isCreateable() && Schema.sObjectType.Task.fields.status.isCreateable()) {
                insert t;
            } else {
                // Handle the situation when the Task object is not insertable
                System.debug('Task object is not insertable.');
            }
        }catch (Exception e){ result = e.getMessage(); Orld_Exception__c ex = new Orld_Exception__c();  ex.Name = 'USH-RecommendedEmailControllerException';  ex.Orld_Error_Message__c = e.getMessage(); ex.Orld_Case_Id__c = cases.Id;  ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());  if(Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.isUpdateable() && Schema.sObjectType.Orld_Exception__c.fields.Name.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Error_Message__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Line_Number__c.isCreateable() && Schema.sObjectType.Orld_Exception__c.fields.Orld_Case_Id__c.isCreateable()){  insert ex; }}
        
        
        return result;
    } //send 
    
    private static String getFileName(Id contentDocumentId, List<ContentVersion> contentVersions) {
        String title;
        String fileExtension;
        String fileName;
    for (ContentVersion contentVersion : contentVersions) {
        title = contentVersion.Title;
		fileExtension = contentVersion.FileExtension;
        fileName = title + (fileExtension != null ? '.' + fileExtension : '');
        if (contentVersion.ContentDocumentId == contentDocumentId) {
            return fileName;
        }
    }
    return null;
}
    
    private static Blob getFileBody(Id contentDocumentId, List<ContentVersion> contentVersions) {
    	for (ContentVersion contentVersion : contentVersions) {
        	if (contentVersion.ContentDocumentId == contentDocumentId) {
            	return contentVersion.VersionData;
        	}
    	}
    	return null;
	}
    
    /**
     * For getting all the fields for the Case and Contact of current page.
     * */
    @AuraEnabled 
    public static String getAllFields(String objectName) { 
        String fields = ''; 
		String delimiter = ''; 

		for (String key: Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet() ) { 
			fields = fields + delimiter + key; 
			delimiter = ','; 
		} 

        if (objectName == 'Case') { 
            fields = fields + ',owner.name, owner.title, owner.phone, owner.firstName, owner.lastName, owner.email'; 
        } 

		return fields; 

	} 
}