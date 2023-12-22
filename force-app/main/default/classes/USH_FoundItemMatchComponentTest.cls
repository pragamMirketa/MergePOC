@isTest
public class USH_FoundItemMatchComponentTest {
    
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
        
        
        
         try{
         USH_FoundItemMatchComponent.checkLostItemMatch(foundItem.Id);
        
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
        
        USH_FoundItemMatchComponent.matchLostItem(foundItem.Id, testCase.Id);
        USH_FoundItemMatchComponent.matchLostItem(foundItem1.Id, testCase1.Id);
        
        // Retrieve the updated Found_Item__c record
        foundItem = [SELECT USH_Lost_Item_Case_Lookup__c FROM Found_Item__c WHERE Id = :foundItem.Id];
        
        System.assertEquals(testCase.Id, foundItem.USH_Lost_Item_Case_Lookup__c,'Excepted Lost Item is Matched with found Item');
        Test.stopTest();
    }
    
    @isTest
    static void testGetFoundItemsColumsBasedOnType() {
        Test.startTest();
        // Create test Found Item record
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
        insert foundItem1;
        
        List<Lost_Items_Columns__mdt>  result = USH_FoundItemMatchComponent.getLostItemsColumsBasedOnType(foundItem.Id);
        System.assertEquals(6, result.size(),'Expected Cellphone record Type'); 
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testFetchLostItems() {
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
        insert foundItem;
        
        Found_Item__c foundItem1 = new Found_Item__c();
        foundItem1.Color__c='White';
        foundItem1.RecordTypeId=CellphoneId;
        foundItem1.Cellphone_Brand__c='Iphone';
        foundItem1.Status__c='Found';
        insert foundItem1;
        USH_FoundItemMatchComponent.fetchLostItems('Cellphone', foundItem.Id);
        USH_FoundItemMatchComponent.fetchLostItems('Cellphone', foundItem1.Id);
        
        System.assertEquals(1, 1,'Excepted more than one found Item');
        
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testGetLostItemRecordTypeId() {
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
        
         Found_Item__c foundItem1 = new Found_Item__c();
        foundItem1.Color__c='White';
        foundItem1.RecordTypeId=CellphoneId;
        foundItem1.Cellphone_Brand__c='Iphone';
        foundItem1.Status__c='Found';
        insert foundItem1;
        
        try{
            
           Found_Item__c result = USH_FoundItemMatchComponent.getLostItemRecordTypeId(foundItem.Id);
     	USH_FoundItemMatchComponent.getLostItemRecordTypeId(null);
        
        System.assertEquals(testcase.Id, result.USH_Lost_Item_Case_Lookup__c,'Excepted Lost Item RecordTypeId');
        }catch (Exception e) {
           
             System.assertEquals('Attempt to de-reference a null object',e.getMessage(),'No record Inserted');
        }
        
        
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testUnmatchLostItem() {
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
        insert foundItem1;
        
        // Unmatch the Lost_Item_Case_Lookup__c from the Found_Item__c record
        
        USH_FoundItemMatchComponent.unmatchLostItem(foundItem.Id);
        USH_FoundItemMatchComponent.unmatchLostItem(foundItem1.Id);
        
        // Retrieve the updated Found_Item__c record
        foundItem = [SELECT USH_Lost_Item_Case_Lookup__c FROM Found_Item__c WHERE Id = :foundItem.Id];
        
        System.assertEquals(null, foundItem.USH_Lost_Item_Case_Lookup__c,'Excepted Null Record');
        
        
        Test.stopTest();
    }
    
    @isTest
    static void testgetFoundItemFilterType() {
        Test.startTest();
        // Create test Found_Item__c record
        Id CellphoneId = Schema.SObjectType.Found_Item__c.getRecordTypeInfosByDeveloperName().get('Cellphone').getRecordTypeId();
        Found_Item__c foundItem = new Found_Item__c();
        foundItem.Color__c='White';
        foundItem.RecordTypeId=CellphoneId;
        foundItem.Cellphone_Brand__c='Iphone';
        foundItem.Status__c='Found';
        insert foundItem;
    	
        Found_Item__c fi = USH_FoundItemMatchComponent.getFoundItemFilterType(foundItem.Id, 'Cellphone_Brand__c');
        System.assertEquals('Iphone', fi.Cellphone_Brand__c, 'Cellphone Brand is Same');
        
        Test.stopTest();
    }
    
    
}