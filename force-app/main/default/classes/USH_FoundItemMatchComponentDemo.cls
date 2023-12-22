public with sharing class USH_FoundItemMatchComponentDemo {
    
    
    public class CaseWrapper {
        @AuraEnabled
        public Case caseObject { get; set; }
        @AuraEnabled
        public Integer Matches { get; set; }
    }
    
    @AuraEnabled
    public static String RecordType(Id recordId){
        String s;
        s=[Select RecordType.DeveloperName From Found_Item__c where Id=:recordId Limit 1].RecordType.DeveloperName;
        
        return s;
    }
    
    @AuraEnabled
    public static String checkLostItemMatch(Id recordId){
         list<Found_Item__c> f1;
         String s;
        try{
            
             if(Schema.sObjectType.Found_Item__c.isQueryable() && Schema.sObjectType.Found_Item__c.fields.USH_Lost_Item_Case_Lookup__c.isAccessible()){

            f1=[Select USH_Lost_Item_Case_Lookup__c From Found_Item__c where Id=:recordId Limit 1];
            
        }
        system.debug('size## '+f1.size());
        system.debug('f1 '+f1[0].USH_Lost_Item_Case_Lookup__c);
        
        if(f1[0].USH_Lost_Item_Case_Lookup__c==null){
            s='No match lost item is present';
        }
        else
        {
            s='Match lost item is present';
        }
            
        }catch(Exception e){
            Orld_Exception__c ex = new Orld_Exception__c(); 
                    ex.Name = 'USH-FoundItemMatchComponent'; 
                    ex.Orld_Error_Message__c = e.getMessage(); 
                    //ex.Orld_Case_Id__c=recordId;
                    ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
                if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {
                  
                    insert ex;
                }
            
        }
        
        
       
        
        return s;
    
    }
    
    
    
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
            Orld_Exception__c ex = new Orld_Exception__c(); 
                    ex.Name = 'USH-FoundItemMatchComponent'; 
                    ex.Orld_Error_Message__c = e.getMessage(); 
                    //ex.Orld_Case_Id__c=recordId;
                    ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
                if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {
                  
                    insert ex;
                }
            
        }
        
        
      
    }
    
    
    
    
    
    @AuraEnabled
    public static String getLostItemsColumsBasedOnType(Id recordId){
        
        Found_Item__c f1;
         
        try{
            
             if(Schema.sObjectType.Found_Item__c.isQueryable() && Schema.sObjectType.RecordType.fields.Name.isAccessible()){

            f1=[Select Id,RecordType.Name From Found_Item__c where Id=:recordId Limit 1];
            
        }
        
        
            
        }catch(Exception e){
            Orld_Exception__c ex = new Orld_Exception__c(); 
                    ex.Name = 'USH-FoundItemMatchComponent'; 
                    ex.Orld_Error_Message__c = e.getMessage(); 
                    //ex.Orld_Case_Id__c=recordId;
                    ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
                if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {
                  
                    insert ex;
                }
            
        }
         return f1.RecordType.Name;
        }
        
    
    
    
    
    @AuraEnabled 
    public static List<CaseWrapper> fetchLostItems(String foundItemType,String recordId){
        List<String> USHCaseFields=new List<String>();
        List <Case> lostItems;
        Found_Item__c f1;
        DescribeSObjectResult describeResult;
        DescribeSObjectResult describeResult2;
        
        List<CaseWrapper> caseList=new List<CaseWrapper>();
        
        Id lostItemRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Item').getRecordTypeId(); 
        
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
                
                if(f.contains('ush')  || f=='casenumber' || f=='recordtypeid' || f=='lost_item_status__c' || f=='Description'){
                     USHCaseFields.add(f);
                }
            }  
            
        
        String query2 = ' SELECT Contact.Name, ' + String.join( USHCaseFields, ',' ) + ' FROM ' + describeResult2.getName() +
                    ' WHERE ' + ' USH_Lost_Item_Type__c = :foundItemType ' + ' AND isdeleted = false ' + ' AND USH_Expired__c = false ' +
                    ' AND Id NOT IN (SELECT USH_Lost_Item_Case_Lookup__c FROM Found_Item__c WHERE USH_Lost_Item_Case_Lookup__c != null) WITH SECURITY_ENFORCED';   
        
            if(Schema.sObjectType.Case.isQueryable()){
            
             lostItems = Database.query(query2);
        }
          system.debug(lostItems);   
        if (!lostItems.isEmpty()) {
            
         Map <String, Schema.SObjectField> lostItemFields = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
            
         Map<String,Schema.SObjectField> newLostItemFields=new Map<String,Schema.SObjectField>();
            
            for(String s:lostItemFields.keySet()){
                
                 if(s.contains('ush')  || s=='casenumber' || s=='recordtypeid' ||  s=='lost_item_status__c' || s=='Description'){
                     newLostItemFields.put(s,lostItemFields.get(s));
                    
                }
                
            }
            system.debug(newLostItemFields);
                    
                    // matching Logic
                    for (Case li: lostItems) {
                        
                        
                        integer i = 0;
                        
                        for (String fieldName : newLostItemFields.keySet()) {
                            
                            // mismatched fields
                            if (fieldName == 'ush_lost_at__c' || fieldName == 'ush_lost_date__c'|| fieldName=='ush_picked_up__c' || fieldName=='ush_lost_item_type__c' || fieldName=='casenumber' || fieldName=='lost_item_status__c'|| fieldName=='Description') {
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
                                            system.debug('##1 '+fieldName.replace('ush_',''));
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
            
        }catch (Exception e) {
                Orld_Exception__c ex = new Orld_Exception__c(); 
                    ex.Name = 'USH-FoundItemMatchComponent'; 
                    ex.Orld_Error_Message__c = e.getMessage(); 
                    //ex.Orld_Case_Id__c=recordId;
                    ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
                if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {
                  
                    insert ex;
                }
            }
        
        
        return caseList;
        
    }
    
    @AuraEnabled
    public static Found_Item__c getLostItemRecordTypeId(Id recordId){
        
         Found_Item__c f1;
         
        try{
            
             if(Schema.sObjectType.Found_Item__c.isQueryable() && Schema.sObjectType.Found_Item__c.fields.USH_Lost_Item_Case_Lookup__c.isAccessible()){

            f1=[Select USH_Lost_Item_Case_Lookup__r.RecordTypeId,USH_Lost_Item_Case_Lookup__c, RecordType.Name From Found_Item__c where Id=:recordId Limit 1];
            
        }
        
        
        
            
        }catch(Exception e){
            Orld_Exception__c ex = new Orld_Exception__c(); 
                    ex.Name = 'USH-FoundItemMatchComponent'; 
                    ex.Orld_Error_Message__c = e.getMessage(); 
                    //ex.Orld_Case_Id__c=recordId;
                    ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
                if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {
                  
                    insert ex;
                }
            
        }
        
        
       return f1;
        
      
        
    }
    
    
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
            
        }catch(Exception e){
            Orld_Exception__c ex = new Orld_Exception__c(); 
                    ex.Name = 'USH-LostItemMatchComponent'; 
                    ex.Orld_Error_Message__c = e.getMessage(); 
                    //ex.Orld_Case_Id__c=recordId;
                    ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
                if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {
                  
                    insert ex;
                }
            
        }
        
        
      
    }
    
    @AuraEnabled
    public static List<String> getFields(String recordType){
        try{
        List<LostItemMatch__mdt> fields =[select id,DeveloperName, USH_LostItemType__c, USH_Lost_Item_Fields__c from LostItemMatch__mdt where USH_LostItemType__c = :recordType WITH SECURITY_ENFORCED];
        String flds = fields[0].USH_Lost_Item_Fields__c;
        List<String> fieldList = flds.split(',');
        System.debug('Fields: '+fieldList);
            return fieldList;
        }
        Catch(Exception e){  
            Orld_Exception__c ex = new Orld_Exception__c(); 
            ex.Name = 'USH-DynamicLostFormController'; 
            ex.Orld_Error_Message__c = e.getMessage(); 
            ex.Orld_Line_Number__c = String.valueOf(e.getLineNumber()); 
            if (Schema.sObjectType.Orld_Exception__c.isAccessible() && Schema.sObjectType.Orld_Exception__c.isCreateable()) {  
                insert ex;  
            }  
        }  
        return null; 
    }


}