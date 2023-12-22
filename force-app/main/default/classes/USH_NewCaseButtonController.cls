/**
 * Created By - Pragam Kaistha
 * Created Date - 01 August 2023
 * Updated Date - 21 August 2023
 * Test Class Name - USH_NewCaseButtonControllerTest
 * Description - It gets the data like profile name, record type name, and record type id for current user and helps to redirect if new case is directly created or fill information page should open.
 * Update - Updated for Related List New Case
 **/
public with sharing class USH_NewCaseButtonController {
    
    //It gets profile name, record type name if recordTypeId is not null else get the record type id
	@AuraEnabled
    public static Map<String,String> getData(String recordTypeId) {
        try{
        	String profileId = UserInfo.getProfileId();
        	Profile thisProfile;
            //Get profile name
        	If(Schema.sObjectType.Profile.isQueryable()){
            	thisProfile = [Select Name from Profile where id = :profileId Limit 1];
        	}
        	String profileName = thisProfile.Name;
			Map<String,String> mp = new Map<String,String>();
			mp.put('profileName', profileName);   
			//Get record type name except Master
            List<SelectOption> recordTypes1 = new List<SelectOption>();
			for(RecordTypeInfo info: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
    			if(info.isAvailable()) {
        			recordTypes1.add(new SelectOption(info.getRecordTypeId(), info.getName()));
    			}
			}
			for( SelectOption selopt: recordTypes1 ) {
                if(!(selopt.getLabel().toLowerCase().contains('master'))){
                    mp.put('getrecTypeId', selopt.getValue());
                }
			}
            // Get record type name
        	if(recordTypeId!=null){
            	List<RecordType> recordTypesDName;
        		If(Schema.sObjectType.RecordType.isQueryable() && Schema.sObjectType.RecordType.fields.Id.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible() && Schema.sObjectType.RecordType.fields.SobjectType.isAccessible() && Schema.sObjectType.RecordType.fields.IsActive.isAccessible()){
        			recordTypesDName=[Select Id, DeveloperName from RecordType WHERE id = :recordTypeId ];
        		}
        		String recTypeDName=recordTypesDName[0].DeveloperName;
        		mp.put('recTypeDName', recTypeDName);
        	}
            return mp;
        }
        catch(Exception e){
            Orld_Exception__c ex = new Orld_Exception__c(); 
            ex.Name = 'USH-NewCaseButtonController'; 
            ex.Orld_Error_Message__c = e.getMessage(); 
            ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
            if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {  
                insert ex;  
            }  
        }
        return null;
    }
    
    // It creates the case record with the selected record type id and if created from related list it would populate the lookup
    @AuraEnabled
    public static String createCase(String recTypeId, String objName, String relatedRecordId) {
        try{
            Case newCase;
            if(Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.fields.Id.isAccessible() && Schema.sObjectType.Case.fields.RecordTypeId.isAccessible()){
        	newCase = new Case(RecordTypeId = recTypeId);
            }
            if(objName != null && relatedRecordId != null){
              
                Id relatedRecId = relatedRecordId; 
                String relatedObjectName = objName; 

                // Fetch the Case object's schema to get the Contact ID lookup field name
                Schema.DescribeSObjectResult caseDescribe = Case.SObjectType.getDescribe();
                String relatedRecIdFieldName = null;

                // Get the SObjectType dynamically
                Schema.SObjectType relatedObjectType = Schema.getGlobalDescribe().get(relatedObjectName);
      
                
                if (relatedObjectType != null) {
                    // Iterate through the fields to find the Contact ID lookup field
                    for (Schema.SObjectField field : caseDescribe.fields.getMap().values()) {
                        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                        if(Schema.sObjectType.Case.isAccessible() && fieldDescribe.isAccessible() && fieldDescribe.isUpdateable()){
                        if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE &&
                            fieldDescribe.getReferenceTo().contains(relatedObjectType)) {
                            relatedRecIdFieldName = fieldDescribe.getName();
                            break;
                        }
                        }
                    }
                } 
                if (relatedRecIdFieldName != null) {
                
					newCase.put(relatedRecIdFieldName, relatedRecId);
             if (Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.isCreateable()){
                insert newCase;
            }
                } 
            }
            else{
            if (Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.isCreateable()){
                insert newCase;
            }
        }
        	return String.ValueOf(newCase.Id);
        }
        catch(Exception e){ 
            Orld_Exception__c ex = new Orld_Exception__c(); 
            ex.Name = 'USH-NewCaseButtonController'; 
            ex.Orld_Error_Message__c = e.getMessage(); 
            ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
            if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {  
                insert ex;  
            }  
        }
        return null;
    }
}