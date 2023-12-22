/**
 * Created By - Pragam Kaistha
 * Created Date - 04 August 2023
 * Class Name - USH_NewCaseButtonControllerTest
 * Description - It is test class for USH_NewCaseButtonControllerTest.
 **/
@isTest
private class USH_NewCaseButtonControllerTest {
    
    @isTest
    static void testGetProfileName() {
			RecordType testRecordType = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Front_Desk' AND IsActive = true LIMIT 1];
            Map<String, String> result = USH_NewCaseButtonController.getData(testRecordType.Id);
            Profile pf = [Select Name from Profile where id = :UserInfo.getProfileId()];
            // Perform assertions
            System.assertEquals(pf.Name, result.get('profileName'), 'Profile Name are not same.');
     }
    
    
    @isTest
    static void testCreateCase() {
        RecordType testRecordType = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Front_Desk' AND IsActive = true LIMIT 1];
        Contact con = new Contact(LastName='ABC');
        insert con;
        String caseId = USH_NewCaseButtonController.createCase(testRecordType.Id, 'Contact', con.id);
            System.assertNotEquals(null, caseId, 'CaseId is null.');
            Case createdCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :caseId LIMIT 1];
            System.assertEquals(testRecordType.Id, createdCase.RecordTypeId,'RecordTypeId is not same.');
        
    }
    
    
    @isTest
    static void testCreateCaseNull() {
        RecordType testRecordType = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Front_Desk' AND IsActive = true LIMIT 1];
        Contact con = new Contact(LastName='ABC');
        insert con;
        String caseId = USH_NewCaseButtonController.createCase(testRecordType.Id, null, null);
            System.assertNotEquals(null, caseId, 'CaseId is null.');
            Case createdCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :caseId LIMIT 1];
            System.assertEquals(testRecordType.Id, createdCase.RecordTypeId,'RecordTypeId is not same.');
        
    }
    
    
    @isTest
    static void testCreateCaseException(){
        
       try{
             Test.startTest();
        
 		  USH_NewCaseButtonController.createCase('123','abc','123');        
           Test.stopTest();
            
        }catch(exception e){
             Orld_Exception__c ex = new Orld_Exception__c(); 
                    ex.Name = 'USH-NewCaseButtonControllerTest'; 
                    ex.Orld_Error_Message__c = e.getMessage(); 
                    ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());
                    insert ex;
            
             Orld_Exception__c e1=[Select Orld_Error_Message__c From Orld_Exception__c where Name='USH-NewCaseButtonControllerTest'];
             system.assertEquals(e.getMessage(), e1.Orld_Error_Message__c,'Error Message');
        }
    }
        
    @isTest
    static void testProfileNameException(){
        
       try{
             Test.startTest();
        
 			USH_NewCaseButtonController.getData('123');        
           Test.stopTest();
            
        }catch(exception e){
             Orld_Exception__c ex = new Orld_Exception__c(); 
                    ex.Name = 'USH-NewCaseButtonControllerTest'; 
                    ex.Orld_Error_Message__c = e.getMessage(); 
                    ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());
                    insert ex;
            
             Orld_Exception__c e1=[Select Orld_Error_Message__c From Orld_Exception__c where Name='USH-NewCaseButtonControllerTest'];
             system.assertEquals(e.getMessage(), e1.Orld_Error_Message__c,'Error Message');
        }
    }
}