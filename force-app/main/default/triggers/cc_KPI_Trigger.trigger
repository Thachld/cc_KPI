trigger cc_KPI_Trigger on KPI__c (after insert, after update) {

    if(cc_Util.checkTriggerAllowRun('KPI_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_KPIHandler');
    }
    
}