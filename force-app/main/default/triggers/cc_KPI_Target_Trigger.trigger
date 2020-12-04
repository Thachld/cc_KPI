trigger cc_KPI_Target_Trigger on KPI_Target__c (after insert) {
    System.debug('KPITARGET_TRIGGER =>' + cc_Util.checkTriggerAllowRun('KPITARGET_TRIGGER'));
    if(cc_Util.checkTriggerAllowRun('KPITARGET_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_KPITargetDetailHandler');
    }
}

