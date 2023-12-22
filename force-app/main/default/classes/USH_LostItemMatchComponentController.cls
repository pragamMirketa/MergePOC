/**
 * Created By - Raghav Popli
 * Created Date - 09 August 2023
 * Last Modified Date-11 Aug 2023
 * Description - This Class is used to Match Lost Item with the list of Found Item to it
 **/






public with sharing class USH_LostItemMatchComponentController {
    
    
    // Found Item Wrapper which is used to store the Found Item and no of matching fields with lost items.
     public class FoundItemWrapper {
        @AuraEnabled
        public Found_Item__c foundItemObject { get; set; }
        @AuraEnabled
        public Integer Matches { get; set; }
    }
    
    
    
     @AuraEnabled
    public static String checkLostItemMatch(Id recordId){
         list<Found_Item__c> f1;
         String s;
        try{
            
             if(Schema.sObjectType.Found_Item__c.isQueryable() && Schema.sObjectType.Found_Item__c.fields.USH_Lost_Item_Case_Lookup__c.isAccessible()){

            f1=[Select USH_Lost_Item_Case_Lookup__c From Found_Item__c where USH_Lost_Item_Case_Lookup__c!=null And USH_Lost_Item_Case_Lookup__c=:recordId Limit 1];
            
        }
            
            if(f1!=null){
                
               if(f1.size()==0){
            s='No match lost item is present';
        }
        else
        {
            s='Match lost item is present';
        } 
            }
                
                 
                
               
      
       
            
        }catch(Exception e){
           Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-LostItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Case_Id__c=recordId;ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex;}
            
        }
        
        
       
        
        return s;
    
    }
    
    
     @AuraEnabled
    public static void matchLostItem(Id recordId,Id foundItemId){
        Found_Item__c f1;
        
        try{
             if(Schema.sObjectType.Found_Item__c.isAccessible() && Schema.sObjectType.Found_Item__c.isUpdateable()){
            f1=new Found_Item__c();
            f1.Id=foundItemId;
           f1.USH_Lost_Item_Case_Lookup__c=recordId;
            
            update f1;
        }
            
        }catch(Exception e){
           Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-LostItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Case_Id__c=recordId;ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex;}
            
        }
        
        
      
    }
    
     @AuraEnabled
    public static List<Found_Items_Column__mdt> getFoundItemsColumsBasedOnType(Id recordId){
        
        Case cs;
          List<Found_Items_Column__mdt>  foundItemColumns;
        
         Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('Found_Items_Column__mdt').getDescribe().fields.getMap();
         
        try{
            
             if(Schema.sObjectType.Case.isQueryable() && Schema.sObjectType.Case.fields.USH_Lost_Item_Type__c.isAccessible()){

            cs=[Select Id,USH_Lost_Item_Type__c From Case where Id=:recordId Limit 1];
            
        }
            
            
       if(Schema.sObjectType.Lost_Items_Columns__mdt.isQueryable() && 
               fieldsMap.get('USH_Column_Field_Label__c').getDescribe().isAccessible() &&
               fieldsMap.get('USH_Column_Field_Name__c').getDescribe().isAccessible() &&
               fieldsMap.get('USH_Column_Field_Name__c').getDescribe().isAccessible() &&
               fieldsMap.get('USH_Column_Field_Type__c').getDescribe().isAccessible()&&
                fieldsMap.get('USH_Column_Number__c').getDescribe().isAccessible() &&
               fieldsMap.get('USH_Data_Filter_Field__c').getDescribe().isAccessible() &&
               fieldsMap.get('MasterLabel').getDescribe().isAccessible()){  
                   foundItemColumns=[SELECT USH_Column_Field_Label__c, USH_Column_Field_Name__c, USH_Column_Field_Type__c, MasterLabel,USH_Column_Number__c,USH_Data_Filter_Field__c FROM Found_Items_Column__mdt where MasterLabel=:cs.USH_Lost_Item_Type__c Order By USH_Column_Number__c];  
               }       
        
        
            
        }catch(Exception e){
            Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-LostItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Case_Id__c=recordId;ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex;}
            
        }
         return foundItemColumns;
        }
    
    
    
    
    
       @AuraEnabled
    public static Case  getLostItemFilterType(String recordId, String filterField){
        
        Case cs;
        DescribeSObjectResult describeResult;
        
        try{
            
            if(Schema.sObjectType.Case.isAccessible()){
            describeResult = Case.getSObjectType().getDescribe();
        }
        
          String query = ' SELECT Id, ' + String.escapeSingleQuotes(filterField) + ' FROM ' + describeResult.getName() +
                    ' WHERE ' + ' id = :recordId WITH SECURITY_ENFORCED' + ' LIMIT 1 '; 
            
            
            if(Schema.sObjectType.Case.isQueryable()){
            
              cs = Database.query(query);
        }
            
        }catch(Exception e){
            Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-LostItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Case_Id__c=recordId;ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex;}
            
        }
        
        
        
        
        return cs;
        
    }
    
    
    
     @AuraEnabled 
    public static List<FoundItemWrapper> fetchFoundItems(String lostItemType,String recordId){
         List<String> USHCaseFields=new List<String>();
        List<FoundItemWrapper> foundItemList=new List<FoundItemWrapper>();
         DescribeSObjectResult describeResult;
        DescribeSObjectResult describeResult2;
        Case theLostItem=new Case();
        list<Found_Item__c> foundItems=new list<Found_Item__c>();
        USH_Fields_To_Skip_Lost_Found__mdt  notUsedFoundItemFields;
        
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('USH_Fields_To_Skip_Lost_Found__mdt').getDescribe().fields.getMap();
        
        
        
        
        Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId();
        
        system.debug(lostItemRecordTypeId);
        try{
            
             if(Schema.sObjectType.Case.isAccessible()){
            describeResult = Case.getSObjectType().getDescribe();
        }
            
            List <String> fieldNames = new List <String> (describeResult.fields.getMap().keySet());
            
            for(String f:fieldNames){
                
                if(f.contains('ush') || f=='lost_item_status__c'){
                    system.debug(f);
                     USHCaseFields.add(f);
                }
            }
           
            
             String query = ' SELECT ' + String.join( USHCaseFields, ',' ) + ' FROM ' + describeResult.getName() +
                    ' WHERE ' + ' id = :recordId AND RecordTypeId=:lostItemRecordTypeId ' + 'WITH SECURITY_ENFORCED LIMIT 1 '; 
                
              if(Schema.sObjectType.Case.isQueryable()){
            
              theLostItem = Database.query(query);
        }
           system.debug(theLostItem);
            
             if(Schema.sObjectType.Found_Item__c.isAccessible()){
             describeResult2 = Found_Item__c.getSObjectType().getDescribe();
        }
            
         
                
                List <String> fieldNames2 = new List <String> (describeResult2.fields.getMap().keySet());
                
                String query2 = ' SELECT RecordType.Name,Contact__r.Name, ' + String.join( fieldNames2, ',' ) + ' FROM ' + describeResult2.getName() +
                    ' WHERE ' + ' RecordType.DeveloperName = :lostItemType ' + ' AND isdeleted = false ' + ' AND Expired__c = false ' +
                    ' AND USH_Lost_Item_Case_Lookup__c = null WITH SECURITY_ENFORCED';   
            
            
            if(Schema.sObjectType.Found_Item__c.isQueryable()){
            
              foundItems = Database.query(query2);
        }
             system.debug(foundItems);
            
            
       if (!foundItems.isEmpty()) {
                    
                    // get the found item fields 
                    Map <String, Schema.SObjectField> foundItemFields = Schema.getGlobalDescribe().get('Found_Item__c').getDescribe().fields.getMap();
                     Map<String,Schema.SObjectField> newfoundItemFields=new Map<String,Schema.SObjectField>();
           
           
           for(String s:foundItemFields.keyset()){
               if(USHCaseFields.contains('ush_'+s)){
                  newfoundItemFields.put(s,foundItemFields.get(s)); 
               }
           }
           
                    
         if(Schema.sObjectType.USH_Fields_To_Skip_Lost_Found__mdt.isQueryable() && 
               fieldsMap.get('Fields_Api_Name__c').getDescribe().isAccessible() &&
               fieldsMap.get('MasterLabel').getDescribe().isAccessible()){  
                   notUsedFoundItemFields=[SELECT Fields_Api_Name__c, MasterLabel FROM USH_Fields_To_Skip_Lost_Found__mdt where MasterLabel='Found Items'];  
               }
            
            List<String> fieldsToSkip=new List<String>();
            fieldsToSkip= notUsedFoundItemFields.Fields_Api_Name__c.split(',');
            List<String> newList=new List<String>();
            for(String s: fieldsToSkip){
                
               String s1=s.toLowerCase();
                
                
               newList.add(s1);
                
            }
            system.debug('##fields '+newList);  
           
           
                        
                    
                    // matching Logic
                    for (Found_Item__c fi: foundItems) {
                        
                        integer i = 0;
                        
                        for (String fieldName : newfoundItemFields.keySet()) {
                            
                            // mismatched fields
                                                       
                            if (newList.contains(fieldName)) {
                                continue; 
                            }
                            
                            // field types to check
                            if (String.valueOf(newfoundItemFields.get(fieldName).getDescribe().getType()) == 'PICKLIST' 
                                || String.valueOf(newfoundItemFields.get(fieldName).getDescribe().getType()) == 'BOOLEAN'
                                || String.valueOf(newfoundItemFields.get(fieldName).getDescribe().getType()) == 'CURRENCY'
                                || String.valueOf(newfoundItemFields.get(fieldName).getDescribe().getType()) == 'PHONE'
                                || String.valueOf(newfoundItemFields.get(fieldName).getDescribe().getType()) == 'DATE') {
                                    system.debug(fieldName);
                                    system.debug(fi.get(fieldName));
                                    system.debug(theLostItem.get('ush_'+fieldName));
                                    
                                    // fields to avoid
                                    if (fi.get(fieldName) == null || theLostItem.get('ush_'+fieldName) == null) {
                                            continue;  
                                        }
                                    
                                    // check for matches
                                    if (fi.get(fieldName) == theLostItem.get('ush_'+fieldName) 
                                        && String.valueOf(newfoundItemFields.get(fieldName).getDescribe().getType()) != 'BOOLEAN') {  
                                            i++;
                                        }
                                    
                                    // for booleans
                                    if (String.valueOf(newfoundItemFields.get(fieldName).getDescribe().getType()) == 'BOOLEAN') {
                                        if (fi.get(fieldName) != false  && fi.get(fieldName) == theLostItem.get('ush_'+fieldName)) {
                                            i++;  
                                        }
                                    }
                                }
                        }
                        
                        // mismatch field name
                        if (fi.Found_At__c != null && fi.Found_At__c == theLostItem.USH_Lost_At__c) {
                            i++;
                        }
                        
                        if (fi.Found_Date__c != null && fi.Found_Date__c == theLostItem.USH_Lost_Date__c) {
                            i++;
                        }
                         if (fi.Status__c != null && fi.Status__c == theLostItem.Lost_Item_Status__c) {
                            i++;
                        }
                        
                        // if there are more that 2 matches found, add the found item to the list
                        if(i >= 1) {
                            FoundItemWrapper cs=new FoundItemWrapper();
                            cs.foundItemObject=fi;
                            cs.Matches=i;
                            foundItemList.add(cs);
                        }
                    }
                    
                   
                }     
            
            
            
        }catch(Exception e){
            
            
             Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-LostItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Case_Id__c=recordId;ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex;}
        }
        
        
        return foundItemList;
        
    }
    
    
    @AuraEnabled
    public static Found_Item__c getFoundItemRecordTypeId(Id recordId){
        
         Found_Item__c f1;
         
        try{
            
             if(Schema.sObjectType.Found_Item__c.isQueryable() && Schema.sObjectType.Found_Item__c.fields.USH_Lost_Item_Case_Lookup__c.isAccessible() && Schema.sObjectType.RecordType.fields.Id.isAccessible()){

            f1=[Select RecordTypeId,RecordType.DeveloperName,USH_Lost_Item_Case_Lookup__c,Id From Found_Item__c where USH_Lost_Item_Case_Lookup__c=:recordId Limit 1];
            
        }
        
        
        
            
        }catch(Exception e){
           Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-LostItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Case_Id__c=recordId;ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex;}
            
        }
        
        
       return f1;
        
      
         
    }
    
     @AuraEnabled
    public static void unmatchFoundItem(Id foundItemRecordId){
        Found_Item__c f1;
        
        try{
             if(Schema.sObjectType.Found_Item__c.isAccessible() && Schema.sObjectType.Found_Item__c.isUpdateable()){
            f1=new Found_Item__c();
            f1.Id=foundItemRecordId;
           f1.USH_Lost_Item_Case_Lookup__c=null;
            
            update f1;
        }
            
        }catch(Exception e){
           Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-LostItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex;}
            
        }
        
        
      
    }

}