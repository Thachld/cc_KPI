public with sharing class cc_KPI_TargetController {
    public class PickListWraper {
        @AuraEnabled        
        public string value {get;set;}
        @AuraEnabled    
        public string label {get;set;}  
    }

    @AuraEnabled//(cacheable=true)
    public static List<User> searchUsers(String searchTerm , Integer limitSize){
        try {
            List<User> users = new List<User>(); 
            searchTerm='%' + searchTerm.trim() + '%';

            
            users = [SELECT Id, Name, Trac_Name__c FROM User WHERE Profile.Name = 'Sales Profile' AND (Name LIKE :searchTerm OR Trac_Name__c LIKE :searchTerm) LIMIT :limitSize];
            
            return users;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    

    @AuraEnabled
    public static List<KPI_Target_Detail__c> getKPIDetailsDB(String targetId){
        try {
            List<KPI_Target_Detail__c> result = new  List<KPI_Target_Detail__c>();
            result = [SELECT Id, Sale__c, Month__c, KPI_Category__c, 
                          SpendingKPI__c, PaymentKPI__c, Sale__r.Name , Sale__r.Trac_Name__c, CurrencyIsoCode
                        FROM KPI_Target_Detail__c WHERE KPI_Target__c =:targetId];

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static KPI_Target_Detail__c saveKPITargetdetailDB(KPI_Target_Detail__c targetdetail){
        try {            
            upsert targetdetail;

            return [SELECT Id, Sale__c, Month__c, KPI_Category__c, 
                      SpendingKPI__c, PaymentKPI__c, Sale__r.Name , Sale__r.Trac_Name__c, CurrencyIsoCode
                    FROM KPI_Target_Detail__c WHERE Id =:targetdetail.Id];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveKPITargetdetaislDB(List<KPI_Target_Detail__c> targetdetails){
        try {            
            upsert targetdetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteKPITargetdetaiDB(String recId){
        try {
           Delete [SELECT Id FROM KPI_Target_Detail__c WHERE Id = :recId];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
	public static List<PickListWraper> getIndustryPicklistDB(){
		List<PickListWraper> options = new List<PickListWraper>();

		Schema.DescribeFieldResult result = KPI_Target_Detail__c.KPI_Category__c.getDescribe();

		List<Schema.PicklistEntry> pList = result.getPickListValues();

		for (Schema.PicklistEntry sp: pList){
            PickListWraper pick = new PickListWraper();           
            pick.value = sp.getValue();
            pick.label = sp.getlabel();
           
            options.add(pick);
		}		
		
		return options;
    }

    
}