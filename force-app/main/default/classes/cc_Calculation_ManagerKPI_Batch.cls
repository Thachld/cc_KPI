
global class cc_Calculation_ManagerKPI_Batch implements Database.Batchable<SObject>{
    public String kpiperiod {get;set;}

    public cc_Calculation_ManagerKPI_Batch(String period) {
        this.kpiperiod = period;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Sales__c, 
                                                SalesManager__c, 
                                                KPI_Category__c    
                                        FROM KPI__c 
                                        WHERE RecordType.DeveloperName = 'Sale_Manager_KPI']);
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){

    }

    global void finish(Database.BatchableContext bc){

    }
}
