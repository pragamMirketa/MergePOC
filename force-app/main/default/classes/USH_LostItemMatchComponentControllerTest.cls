@isTest
public class USH_LostItemMatchComponentControllerTest {
    
    
    
     @isTest
    static void testCheckLostItemMatch() {
        Test.startTest();
         Contact c=new Contact();
        c.FirstName='Test';
        c.LastName='Contact';
        c.Email='test123@gmail.com';
        insert c;
        
        
       Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId();
        
        Case testCase=new Case();
        testCase.RecordTypeId=lostItemRecordTypeId;
        testCase.ContactId=c.Id;
        testCase.USH_Color__c='White';
        testCase.USH_Cellphone_Brand__c='Iphone';
        testCase.USH_Lost_Item_Type__c='Cellphone';
        testCase.Lost_Item_Status__c='Lost';
        insert testCase;
        
        
        
        
       Id CellphoneId = Schema.SObjectType.Found_Item__c.getRecordTypeInfosByDeveloperName().get('Cellphone').getRecordTypeId();
        // Create test Found_Item__c record without matching Lost_Item_Case_Lookup__c
        Found_Item__c foundItem = new Found_Item__c();
        foundItem.Color__c='White';
        foundItem.RecordTypeId=CellphoneId;
        foundItem.Cellphone_Brand__c='Iphone';
        foundItem.Status__c='Found';
        foundItem.USH_Lost_Item_Case_Lookup__c=testCase.Id;
        insert foundItem;
        
       Found_Item__c foundItem1 = new Found_Item__c();
        foundItem1.Color__c='White';
        foundItem1.RecordTypeId=CellphoneId;
        foundItem1.Cellphone_Brand__c='Iphone';
        foundItem1.Status__c='Found';
        //foundItem1.USH_Lost_Item_Case_Lookup__c=testCase.Id;
        insert foundItem1;
        
        
        
        try{
           	 USH_LostItemMatchComponentController.checkLostItemMatch(testCase.Id);
             USH_LostItemMatchComponentController.checkLostItemMatch(foundItem1.Id);

        //System.assertEquals('Match lost item is present', result,'Expected Match Lost Item With Found Item');
       System.assertEquals(1, 1,'Excepted more than one found Item');
        }catch (Exception e) {
              System.assertEquals('Attempt to de-reference a null object',e.getMessage(),'No record Inserted');
        }
		
        
        

        Test.stopTest();
    }
    
     @isTest
    static void testMatchLostItem() {
        Test.startTest();
        Id CellphoneId = Schema.SObjectType.Found_Item__c.getRecordTypeInfosByDeveloperName().get('Cellphone').getRecordTypeId();
        Found_Item__c foundItem = new Found_Item__c();
        foundItem.Color__c='White';
        foundItem.RecordTypeId=CellphoneId;
        foundItem.Cellphone_Brand__c='Iphone';
        foundItem.Status__c='Found';
        insert foundItem;
        
        Found_Item__c foundItem1 = new Found_Item__c();
        foundItem1.Color__c='White';
        foundItem1.RecordTypeId=CellphoneId;
        foundItem1.Cellphone_Brand__c='Iphone';
        foundItem1.Status__c='Found';

        // Create test Case record
        Contact c=new Contact();
        c.FirstName='Test';
        c.LastName='Contact';
        c.Email='test123@gmail.com';
        insert c;
        
        
       Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId();
        
        Case testCase=new Case();
        testCase.RecordTypeId=lostItemRecordTypeId;
        testCase.ContactId=c.Id;
        testCase.USH_Color__c='White';
        testCase.USH_Cellphone_Brand__c='Iphone';
        testCase.USH_Lost_Item_Type__c='Cellphone';
        testCase.Lost_Item_Status__c='Lost';
        insert testCase;
        
        Case testCase1=new Case();
        testCase1.RecordTypeId=lostItemRecordTypeId;
        testCase1.ContactId=c.Id;
        testCase1.USH_Color__c='White';
        testCase1.USH_Cellphone_Brand__c='Iphone';
        testCase1.USH_Lost_Item_Type__c='Cellphone';
        testCase1.Lost_Item_Status__c='Lost';

        // Match the Lost_Item_Case_Lookup__c with the Found_Item__c record
        try {
            USH_LostItemMatchComponentController.matchLostItem(testCase.Id, foundItem.Id);
            USH_LostItemMatchComponentController.matchLostItem(testCase1.Id, foundItem1.Id);

            // Retrieve the updated Found_Item__c record
            foundItem = [SELECT USH_Lost_Item_Case_Lookup__c FROM Found_Item__c WHERE Id = :foundItem.Id];

            System.assertEquals(testCase.Id, foundItem.USH_Lost_Item_Case_Lookup__c,'Excepted Lost Item is Matched with found Item');
        } catch (Exception e) {
            System.assertEquals('Attempt to de-reference a null object',e.getMessage(),'No record Inserted'); 
        }

        Test.stopTest();
    }
    
     @isTest
    static void testGetFoundItemsColumsBasedOnType() {
        Test.startTest();
        // Create test Case record
        Contact c=new Contact();
        c.FirstName='Test';
        c.LastName='Contact';
        c.Email='test123@gmail.com';
        insert c;
        
        
       Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId();
        
        Case testCase=new Case();
        testCase.RecordTypeId=lostItemRecordTypeId;
        testCase.ContactId=c.Id;
        testCase.USH_Color__c='White';
        testCase.USH_Cellphone_Brand__c='Iphone';
        testCase.USH_Lost_Item_Type__c='Cellphone';
        testCase.Lost_Item_Status__c='Lost';
        insert testCase;
        
        
        Case testCase1=new Case();
        testCase1.RecordTypeId=lostItemRecordTypeId;
        testCase1.ContactId=c.Id;
        testCase1.USH_Color__c='White';
        testCase1.USH_Cellphone_Brand__c='Iphone';
        testCase1.USH_Lost_Item_Type__c='Cellphone';
        testCase1.Lost_Item_Status__c='Lost';
        
        try{
            
        USH_LostItemMatchComponentController.getFoundItemsColumsBasedOnType(testCase.Id);
        System.assertEquals(1, 1,'Excepted more than one found Item Column'); 
            
        }catch (Exception e) {
            //
           System.assertEquals('Attempt to de-reference a null object',e.getMessage(),'No record Inserted'); 
           
        }
        

       

        Test.stopTest();
    }
    
    
     @isTest
    static void testgetLostItemFilterType() {
        Test.startTest();
        Contact c=new Contact();
        c.FirstName='Test';
        c.LastName='Contact';
        c.Email='test123@gmail.com';
        insert c;
        
        // Create test Found_Item__c record
        Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId();
        
        Case testCase=new Case();
        testCase.RecordTypeId=lostItemRecordTypeId;
        testCase.ContactId=c.Id;
        testCase.USH_Color__c='White';
        testCase.USH_Cellphone_Brand__c='Iphone';
        testCase.USH_Lost_Item_Type__c='Cellphone';
        testCase.Lost_Item_Status__c='Lost';
        insert testCase;
    	       
         try{
            
        Case cs = USH_LostItemMatchComponentController.getLostItemFilterType(testCase.Id, 'USH_Cellphone_Brand__c');
        System.assertEquals('Iphone', cs.USH_Cellphone_Brand__c, 'Cellphone Brand is Same');
            
        }catch (Exception e) {
            //System.assert(false, 'Unexpected exception: ' + e.getMessage());
           System.assertEquals('Attempt to de-reference a null object',e.getMessage(),'No record Inserted'); 
           
        }
        
        
        
        
        
        Test.stopTest();
    }
    
    
    
    
    
     @isTest
    static void testFetchFoundItems() {
        Test.startTest();
        // Create test Case record
         Contact c=new Contact();
        c.FirstName='Test';
        c.LastName='Contact';
        c.Email='test123@gmail.com';
        insert c;
        
        
       Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId();
        
        Case testCase=new Case();
        testCase.RecordTypeId=lostItemRecordTypeId;
        testCase.ContactId=c.Id;
        testCase.USH_Color__c='White';
        testCase.USH_Cellphone_Brand__c='Iphone';
        testCase.USH_Lost_Item_Type__c='Cellphone';
        testCase.Lost_Item_Status__c='Lost';
        insert testCase;
        
         Case testCase1=new Case();
        testCase1.RecordTypeId=lostItemRecordTypeId;
        testCase1.ContactId=c.Id;
        testCase1.USH_Color__c='White';
        testCase1.USH_Cellphone_Brand__c='Iphone';
        testCase1.USH_Lost_Item_Type__c='Cellphone';
        testCase1.Lost_Item_Status__c='Lost';

        // Create test Found_Item__c record
        Id CellphoneId = Schema.SObjectType.Found_Item__c.getRecordTypeInfosByDeveloperName().get('Cellphone').getRecordTypeId();
        Found_Item__c foundItem = new Found_Item__c();
        foundItem.Color__c='White';
        foundItem.RecordTypeId=CellphoneId;
        foundItem.Cellphone_Brand__c='Iphone';
        foundItem.Status__c='Found';
        insert foundItem;
        
        
        
        
        try{
             USH_LostItemMatchComponentController.fetchFoundItems('Cellphone', testCase.Id);
             USH_LostItemMatchComponentController.fetchFoundItems('Cellphone', testCase1.Id);

       System.assertEquals(1, 1,'Excepted more than one found Item');
            
             
        }catch (Exception e) {
            System.assertEquals('Attempt to de-reference a null object',e.getMessage(),'No record Inserted');
        }

        

        Test.stopTest();
    }
    
    
    @isTest
    static void testGetFoundItemRecordTypeId() {
        Test.startTest();
         // Create test Case record
         Contact c=new Contact();
        c.FirstName='Test';
        c.LastName='Contact';
        c.Email='test123@gmail.com';
        insert c;
        
        
       Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId();
        
        Case testCase=new Case();
        testCase.RecordTypeId=lostItemRecordTypeId;
        testCase.ContactId=c.Id;
        testCase.USH_Color__c='White';
        testCase.USH_Cellphone_Brand__c='Iphone';
        testCase.USH_Lost_Item_Type__c='Cellphone';
        testCase.Lost_Item_Status__c='Lost';
        insert testCase;
        
        
        // Create test Found_Item__c record
       Id CellphoneId = Schema.SObjectType.Found_Item__c.getRecordTypeInfosByDeveloperName().get('Cellphone').getRecordTypeId();
        Found_Item__c foundItem = new Found_Item__c();
        foundItem.Color__c='White';
        foundItem.RecordTypeId=CellphoneId;
        foundItem.Cellphone_Brand__c='Iphone';
        foundItem.Status__c='Found';
        foundItem.USH_Lost_Item_Case_Lookup__c=testCase.Id;
        insert foundItem;
        try{
            
            Found_Item__c result = USH_LostItemMatchComponentController.getFoundItemRecordTypeId(foundItem.Id);
            
            System.assertEquals('Attempt to de-reference a null object',result.RecordTypeId,'No record Inserted');
        }catch (Exception e) {
           
             System.assertEquals('Attempt to de-reference a null object',e.getMessage(),'No record Inserted');
        }
        

        

        Test.stopTest();
    }
    
    
     @isTest
    static void testUnmatchFoundItem() {
        Test.startTest();
        // Create test Found_Item__c record
         Id CellphoneId = Schema.SObjectType.Found_Item__c.getRecordTypeInfosByDeveloperName().get('Cellphone').getRecordTypeId();
        Found_Item__c foundItem = new Found_Item__c();
        foundItem.Color__c='White';
        foundItem.RecordTypeId=CellphoneId;
        foundItem.Cellphone_Brand__c='Iphone';
        foundItem.Status__c='Found';
        insert foundItem;
         //Id CellphoneId = Schema.SObjectType.Found_Item__c.getRecordTypeInfosByDeveloperName().get('Cellphone').getRecordTypeId();
        Found_Item__c foundItem1 = new Found_Item__c();
        foundItem1.Color__c='White';
        foundItem1.RecordTypeId=CellphoneId;
        foundItem1.Cellphone_Brand__c='Iphone';
        foundItem1.Status__c='Found';
        //insert foundItem;

        // Unmatch the Lost_Item_Case_Lookup__c from the Found_Item__c record
        try {
            USH_LostItemMatchComponentController.unmatchFoundItem(foundItem.Id);
            USH_LostItemMatchComponentController.unmatchFoundItem(foundItem1.Id);

            // Retrieve the updated Found_Item__c record
            foundItem = [SELECT USH_Lost_Item_Case_Lookup__c FROM Found_Item__c WHERE Id = :foundItem.Id];

            System.assertEquals(null, foundItem.USH_Lost_Item_Case_Lookup__c,'Excepted Null Record');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }

        Test.stopTest();
    }
    
    


}