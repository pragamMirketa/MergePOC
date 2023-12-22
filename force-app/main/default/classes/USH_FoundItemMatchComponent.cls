/**
 * Created By - Raghav Popli
 * Created Date - 09 August 2023
 * Last Modified Date-11 Aug 2023
 * Description - This Class is used to Match and Umatach Found Item with the list of Lost Items.
 **/




// 
public with sharing class USH_FoundItemMatchComponent {
    
    // Case Wrapper which is used to store the all the similar lost items to found item and it's matches.
    public class CaseWrapper {
        @AuraEnabled
        public Case caseObject { get; set; }
        @AuraEnabled
        public Integer Matches { get; set; }
    }
    
    
    
   
    //This Function is used to check if found item is linked to a lost item or not.
    @AuraEnabled
    public static String checkLostItemMatch(Id recordId){
         list<Found_Item__c> f1;
         String s;
        try{
            
             if(Schema.sObjectType.Found_Item__c.isQueryable() && Schema.sObjectType.Found_Item__c.fields.USH_Lost_Item_Case_Lookup__c.isAccessible()){

            f1=[Select USH_Lost_Item_Case_Lookup__c From Found_Item__c where Id=:recordId Limit 1];
            
        }
            
            if(f1!=null){
                
                if(f1[0].USH_Lost_Item_Case_Lookup__c==null){
            s='No match lost item is present';
        }
        else
        {
            s='Match lost item is present';
        }
                
            }     
        
        
            
        }catch(Exception e){ Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-FoundItemMatchComponent'; ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex; }
            
        }
        
        return s;
    
    }
    
    
   //This function is called when we want  to match found item  with the lost item
    @AuraEnabled
    public static void matchLostItem(Id recordId,Id lostItemId){
        Found_Item__c f1;
        
        try{
             if(Schema.sObjectType.Found_Item__c.isAccessible() && Schema.sObjectType.Found_Item__c.isUpdateable()){
            f1=new Found_Item__c();
            f1.Id=recordId;
           f1.USH_Lost_Item_Case_Lookup__c=lostItemId;
            
            update f1;
        }
            
        }catch(Exception e){
           Orld_Exception__c ex = new Orld_Exception__c(); ex.Name = 'USH-FoundItemMatchComponent'; ex.Orld_Error_Message__c = e.getMessage(); ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) { insert ex; }
            
        }
        
        
      
    }
    
    
    
    
    // This function is used to get the type of the found item on the basis of which found item is rendered
    @AuraEnabled
    public static List<Lost_Items_Columns__mdt> getLostItemsColumsBasedOnType(Id recordId){
        
        Found_Item__c f1;
         List<Lost_Items_Columns__mdt>  lostItemColumns;
        
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('Lost_Items_Columns__mdt').getDescribe().fields.getMap();
         
        try{
            
             if(Schema.sObjectType.Found_Item__c.isQueryable() && Schema.sObjectType.RecordType.fields.Name.isAccessible()){
			
            f1=[Select Id,RecordType.DeveloperName From Found_Item__c where Id=:recordId Limit 1];
            system.debug('f1 '+f1);
        }
            if(Schema.sObjectType.Lost_Items_Columns__mdt.isQueryable() && 
               fieldsMap.get('USH_Column_Field_Label__c').getDescribe().isAccessible() &&
               fieldsMap.get('USH_Column_Field_Name__c').getDescribe().isAccessible() &&
               fieldsMap.get('USH_Column_Field_Name__c').getDescribe().isAccessible() &&
               fieldsMap.get('USH_Column_Field_Type__c').getDescribe().isAccessible()&&
                fieldsMap.get('USH_Column_Number__c').getDescribe().isAccessible() &&
               fieldsMap.get('USH_Data_Filter_Field__c').getDescribe().isAccessible() &&
               fieldsMap.get('MasterLabel').getDescribe().isAccessible()){  
                   lostItemColumns=[SELECT USH_Column_Field_Label__c, USH_Column_Field_Name__c, USH_Column_Field_Type__c, MasterLabel,USH_Column_Number__c,USH_Data_Filter_Field__c FROM Lost_Items_Columns__mdt where MasterLabel=:f1.RecordType.DeveloperName Order By USH_Column_Number__c];  
               }  
       /** if(Schema.sObjectType.Found_Item__c.isAccessible()){
            describeResult = Found_Item__c.getSObjectType().getDescribe();
        }
          List <String> fieldNames = new List <String> (describeResult.fields.getMap().keySet());
                
                String query = ' SELECT RecordType.Name, ' + String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName() +
                    ' WHERE ' + ' id = :recordId WITH SECURITY_ENFORCED' + ' LIMIT 1 '; 
            
            
            if(Schema.sObjectType.Found_Item__c.isQueryable()){
            
              f1 = Database.query(query);
        }**/ 
        
            
        }catch(Exception e){ Orld_Exception__c ex = new Orld_Exception__c(); ex.Name = 'USH-FoundItemMatchComponent'; ex.Orld_Error_Message__c = e.getMessage(); ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) { insert ex; }
            
        }
         return lostItemColumns;
        }
    
    
    
    
    @AuraEnabled
    public static Found_Item__c  getFoundItemFilterType(String recordId, String filterField){
        
        system.debug('filterfield '+filterField);
        
        Found_Item__c f1;
        DescribeSObjectResult describeResult;
        try{
            if(Schema.sObjectType.Found_Item__c.isAccessible()){
            describeResult = Found_Item__c.getSObjectType().getDescribe();
        }
        
          String query = ' SELECT Id, ' + String.escapeSingleQuotes(filterField) + ' FROM ' + describeResult.getName() +
                    ' WHERE ' + ' id = :recordId WITH SECURITY_ENFORCED' + ' LIMIT 1 '; 
            
            
            if(Schema.sObjectType.Found_Item__c.isQueryable()){
            
              f1 = Database.query(query);
        }
            
        }catch(Exception e){ Orld_Exception__c ex = new Orld_Exception__c(); ex.Name = 'USH-FoundItemMatchComponent'; ex.Orld_Error_Message__c = e.getMessage(); ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) { insert ex; }
            
        }
        
        
        
        
        return f1;
        
    }
        
    
    
    
    // This function is used to fetch the possible match lost item with the found item.
    @AuraEnabled 
    public static List<CaseWrapper> fetchLostItems(String foundItemType,String recordId){
        List<String> USHCaseFields=new List<String>();
        List <Case> lostItems=new List<Case>();
        Found_Item__c f1=new Found_Item__c();
        DescribeSObjectResult describeResult;
        DescribeSObjectResult describeResult2;
        
        List<CaseWrapper> caseList=new List<CaseWrapper>();
        
       USH_Fields_To_Skip_Lost_Found__mdt  notUsedlostItemFields;
        
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('USH_Fields_To_Skip_Lost_Found__mdt').getDescribe().fields.getMap();
        
        //Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId(); 
        
        try{
            
            
             if(Schema.sObjectType.Found_Item__c.isAccessible()){
            describeResult = Found_Item__c.getSObjectType().getDescribe();
        }
          List <String> fieldNames = new List <String> (describeResult.fields.getMap().keySet());
                
                String query = ' SELECT RecordType.Name, ' + String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName() +
                    ' WHERE ' + ' id = :recordId WITH SECURITY_ENFORCED' + ' LIMIT 1 '; 
            
            
            if(Schema.sObjectType.Found_Item__c.isQueryable()){
            
              f1 = Database.query(query);
        }     
                  
            
            
        
         
        if(Schema.sObjectType.Case.isAccessible()){
            describeResult2 = Case.getSObjectType().getDescribe();
        }
          
                
                List <String> fieldNames2 = new List <String> (describeResult2.fields.getMap().keySet());
            
            for(String f:fieldNames2){
                
                if(f.startsWith('ush_')  || f=='casenumber' || f=='recordtypeid' || f=='lost_item_status__c' || f=='Description'){
                     USHCaseFields.add(f);
                }
            }  
            
        
        String query2 = ' SELECT Contact.Name, ' + String.join( USHCaseFields, ',' ) + ' FROM ' + describeResult2.getName() +
                    ' WHERE ' + ' USH_Lost_Item_Type__c = :foundItemType ' + ' AND isdeleted = false ' + ' AND USH_Expired__c = false ' +
                    ' AND Id NOT IN (SELECT USH_Lost_Item_Case_Lookup__c FROM Found_Item__c WHERE USH_Lost_Item_Case_Lookup__c != null) WITH SECURITY_ENFORCED';   
        
            if(Schema.sObjectType.Case.isQueryable()){
            
             lostItems = Database.query(query2);
        }
           
        if (!lostItems.isEmpty()) {
            
         Map <String, Schema.SObjectField> lostItemFields = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
            
         Map<String,Schema.SObjectField> newLostItemFields=new Map<String,Schema.SObjectField>();
            
            
            
            
            for(String s:lostItemFields.keySet()){
                
                 if(s.startsWith('ush_')  || s=='casenumber' || s=='recordtypeid' ||  s=='lost_item_status__c' || s=='Description' ){
                     newLostItemFields.put(s,lostItemFields.get(s));
                    
                }
                
            }
            
            
            
            
            
            
            if(Schema.sObjectType.USH_Fields_To_Skip_Lost_Found__mdt.isQueryable() && 
               fieldsMap.get('Fields_Api_Name__c').getDescribe().isAccessible() &&
               fieldsMap.get('MasterLabel').getDescribe().isAccessible()){  
                   notUsedlostItemFields=[SELECT Fields_Api_Name__c, MasterLabel FROM USH_Fields_To_Skip_Lost_Found__mdt where MasterLabel='Lost Items'];  
               }
            
            List<String> fieldsToSkip=new List<String>();
            fieldsToSkip=notUsedlostItemFields.Fields_Api_Name__c.split(',');
            List<String> newList=new List<String>();
            for(String s: fieldsToSkip){
                
               String s1=s.toLowerCase();
                
                
               newList.add(s1);
                
            }
            system.debug('##fields '+newList);
            
            
            
           
                    
                    // matching Logic
                    for (Case li: lostItems) {
                        
                        
                        integer i = 0;
                        
                        for (String fieldName : newLostItemFields.keySet()) {
                            
                            
                            // mismatched fields
                            /**if (fieldName == 'ush_lost_at__c' || fieldName == 'ush_lost_date__c'|| fieldName=='ush_picked_up__c' || fieldName=='ush_lost_item_type__c' || fieldName=='casenumber' || fieldName=='lost_item_status__c'|| fieldName=='Description' || newList.contains(fieldName)) {
                                continue; 
                            }**/
                            
                            if (newList.contains(fieldName)) {
                                continue; 
                            }
                            
                            // field types to check
                            if (String.valueOf(newLostItemFields.get(fieldName).getDescribe().getType()) == 'PICKLIST' 
                                || String.valueOf(newLostItemFields.get(fieldName).getDescribe().getType()) == 'BOOLEAN'
                                || String.valueOf(newLostItemFields.get(fieldName).getDescribe().getType()) == 'CURRENCY'
                                || String.valueOf(newLostItemFields.get(fieldName).getDescribe().getType()) == 'PHONE'
                                || String.valueOf(newLostItemFields.get(fieldName).getDescribe().getType()) == 'DATE') {
                                   
                                  
                                    // fields to avoid
                                    if (li.get(fieldName) == null ||  f1.get(fieldName.replace('ush_','')) == null) {
                                            continue;  
                                        }
                                    
                                    // check for matches
                                    if (li.get(fieldName) == f1.get(fieldName.replace('ush_','')) 
                                        && String.valueOf(newLostItemFields.get(fieldName).getDescribe().getType()) != 'BOOLEAN') {
                                           
                                            i++;
                                        }  
                                    
                                    // for booleans
                                    if (String.valueOf(newLostItemFields.get(fieldName).getDescribe().getType()) == 'BOOLEAN') {
                                        if (li.get(fieldName) != false  && li.get(fieldName) == f1.get(fieldName.replace('ush_',''))) {
                                            i++;  
                                        }
                                    }
                                }
                        }
                        
                        // mismatch field name
                        // 
                      
                           
                        if (li.USH_Lost_At__c != null && li.USH_Lost_At__c == f1.Found_At__c) {
                            i++;
                        }
                       
                        if (li.USH_Lost_Date__c != null && li.USH_Lost_Date__c == f1.Found_Date__c) {
                            i++;
                        }
                        if (li.Lost_Item_Status__c != null && li.Lost_Item_Status__c == f1.Status__c) {
                            i++;
                        }
                        
                        // if there are more that 2 matches found, add the lost item to the map
                        if(i >= 1) {
                            
                            CaseWrapper cs=new CaseWrapper();
                            cs.caseObject=li;
                            cs.Matches=i;
                            caseList.add(cs);
                        }
                    }
                       
            
            
        }
            
        }catch (Exception e) {Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-FoundItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex; } }
        
        
        return caseList;
        
    }
    // This function is used return lost item match and it's record type from found item.
    @AuraEnabled
    public static Found_Item__c getLostItemRecordTypeId(Id recordId){
        
         Found_Item__c f1;
         
        try{
            
             if(Schema.sObjectType.Found_Item__c.isQueryable() && Schema.sObjectType.Found_Item__c.fields.USH_Lost_Item_Case_Lookup__c.isAccessible()){

            f1=[Select USH_Lost_Item_Case_Lookup__r.RecordTypeId,USH_Lost_Item_Case_Lookup__c, RecordType.DeveloperName From Found_Item__c where Id=:recordId Limit 1];
            
        }
        
        
        
            
        }catch(Exception e){
            Orld_Exception__c ex = new Orld_Exception__c(); ex.Name = 'USH-FoundItemMatchComponent'; ex.Orld_Error_Message__c = e.getMessage(); ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) { insert ex; }
            
        }
        
        
       return f1;
        
      
        
    }
    
    // This function is used to unmatch the lost item with the matched found item.
     @AuraEnabled
    public static void unmatchLostItem(Id foundItemRecordId){
        Found_Item__c f1;
        
        try{
             if(Schema.sObjectType.Found_Item__c.isAccessible() && Schema.sObjectType.Found_Item__c.isUpdateable()){
            f1=new Found_Item__c();
            f1.Id=foundItemRecordId;
           f1.USH_Lost_Item_Case_Lookup__c=null;
            
            update f1;
        }
            
        }catch(Exception e){Orld_Exception__c ex = new Orld_Exception__c();ex.Name = 'USH-FoundItemMatchComponent';ex.Orld_Error_Message__c = e.getMessage();ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber());if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {insert ex;}
            
        }
        
        
      
    }

}