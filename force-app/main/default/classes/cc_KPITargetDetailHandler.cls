public with sharing class cc_KPITargetDetailHandler implements  cc_ITrigger{
    Set<String> kpiTeamIds = new Set<String>();
    Set<String> kpiManagerIds = new Set<String>();
    Id teamrecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sales_KPI').getRecordTypeId();    
    Id managerrecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Manager_KPI').getRecordTypeId();
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isInsert
    }
    
    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkAfter() {	
        if(Trigger.isInsert){
           
            for(KPI_Target__c target :(List<KPI_Target__c>)Trigger.new){
                if(!String.isBlank(target.Quarter__c)){
                    if(target.RecordTypeId == teamrecordtypeId){
                        kpiTeamIds.add(target.Id);
                    }else if(target.RecordTypeId == managerrecordtypeId){
                        kpiManagerIds.add(target.Id);
                    }
                    
                }
            }


        }else if (Trigger.isUpdate) {     
            Map<Id,KPI_Target__c> newMap = (Map<Id,KPI_Target__c>)Trigger.newMap; 
            Map<Id,KPI_Target__c> oldMap = (Map<Id,KPI_Target__c>)Trigger.oldMap;     

            for(KPI_Target__c newrq: newMap.values()){
                KPI_Target__c oldrq = oldMap.get(newrq.Id);
            }
        }			
    }
    
    /**
    * beforeInsert
    *
    * This method is called iteratively for each record to be inserted during a BEFORE
    * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    */
    public void beforeInsert(SObject so) {}
    
    /**
    * beforeUpdate
    *
    * This method is called iteratively for each record to be updated during a BEFORE
    * trigger.
    */
    public void beforeUpdate(SObject oldSo, SObject so) {}

    /**
    * beforeDelete
    *
    * This method is called iteratively for each record to be deleted during a BEFORE
    * trigger.
    */
    public void beforeDelete(SObject so) {}
       

    /**
    * afterInsert
    *
    * This method is called iteratively for each record inserted during an AFTER
    * trigger. Always put field validation in the 'After' methods in case another trigger
    * has modified any values. The record is 'read only' by this point.
    */
    public void afterInsert(SObject so) {}

    /**
    * afterUpdate
    *
    * This method is called iteratively for each record updated during an AFTER
    * trigger.
    */
    public void afterUpdate(SObject oldSo, SObject so) {}

    /**
    * afterDelete
    *
    * This method is called iteratively for each record deleted during an AFTER
    * trigger.
    */
    public void afterDelete(SObject so) {}
    
    /**
    * afterUnDelete
    *
    * This method is called iteratively for each record Undeleted during an AFTER
    * trigger.
    */
    public void afterUnDelete(SObject so) {}

    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this 
    * method to accomplish any final operations such as creation or updates of other records.
    */
    public void andFinally() {       
        System.debug('kpiTeamIds =>' + kpiTeamIds.size());
        if(kpiTeamIds.size() > 0){            
            cc_KPITargetDetail_Async.attemTeamKPITarget(kpiTeamIds);
        }
        System.debug('kpiManagerIds =>' + kpiManagerIds.size());
        if(kpiManagerIds.size() >0){
            cc_KPITargetDetail_Async.attemManagerKPITarget(kpiManagerIds);
        }
    }       
}