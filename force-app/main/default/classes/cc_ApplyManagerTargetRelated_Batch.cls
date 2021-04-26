public class cc_ApplyManagerTargetRelated_Batch implements Database.Batchable<SObject>{

    public cc_ApplyManagerTargetRelated_Batch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT FROM KPI_Target__c])
    }

    public void execute(Database.BatchableContext bc, List<KPI_Target__c> scope){

    }

    public void finish(Database.BatchableContext bc){

    }

}
