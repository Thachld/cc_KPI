global class cc_KPI_ApplySaleTarget_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public String kpiPeriod {get;set;}
    public List<cc_DMLResult_wrapper> lserrors  {get;set;}

    public cc_KPI_ApplySaleTarget_Batch(String period) {
        this.kpiPeriod = period;
        this.lserrors = new List<cc_DMLResult_wrapper>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Sales__c, Name, KPIAutoNumber__c, Sales__r.Trac_Name__c, Period__c
                                        FROM KPI__c 
                                        WHERE Period__c = :this.kpiPeriod
                                            AND Sales__c != ''
                                            AND Status__c != 'Confirmed']);       
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){
        Set<String> saleIds= new Set<String>();
        Map<String,List<KPI_Target_Detail__c>> mapTargets = new Map<String,List<KPI_Target_Detail__c>>();
        List<Sale_Spending_Payment__c> listSaleKPIsToUpdate = new List<Sale_Spending_Payment__c>();

        for(KPI__c kpi: scope){
            saleIds.add(kpi.Sales__c);
        }

        if(saleIds != null){        
            for (KPI_Target_Detail__c target : [SELECT Id, Sale__c, SpendingKPI__c, PaymentKPI__c,  KPI_Category__c
                                                FROM KPI_Target_Detail__c 
                                                WHERE Sale__c IN :saleIds 
                                                AND Period__c = :this.kpiPeriod
                                                AND KPI_Target__r.Approval_Status__c = 'Approved']){
                if(mapTargets.containsKey(target.Sale__c)){
                    mapTargets.get(target.Sale__c).add(target);
                }else{
                    mapTargets.put(target.Sale__c,  new List<KPI_Target_Detail__c>{target});
                }                                    
            }
        }

        for(KPI__c kpi: scope){
            List<KPI_Target_Detail__c> saletargets = mapTargets.get(kpi.Sales__c);
            if(saletargets != null){
                for(KPI_Target_Detail__c target: saletargets){
                    Sale_Spending_Payment__c saleKPI = new Sale_Spending_Payment__c();
                    String externalNumber = (String)kpi.KPIAutoNumber__c + '_' + (String)target.KPI_Category__c + '_' + (String)kpi.Period__c;                    
                    saleKPI.KPI__c = kpi.Id;
                    saleKPI.KPI_Category__c = target.KPI_Category__c;
                    saleKPI.Name = (String)kpi.Sales__r.Trac_Name__c + ' - ' + (String)target.KPI_Category__c;
                    saleKPI.KPI_Sale_Target__c = target.Id;
                    saleKPI.PaymentKPI__c = target.PaymentKPI__c;
                    saleKPI.SpendingKPI__c = target.SpendingKPI__c;
                    saleKPI.KPI_Number__c = externalNumber;
                    
                    listSaleKPIsToUpdate.add(saleKPI);
                }
            }

        }

        if(listSaleKPIsToUpdate.size() > 0 ){

            Schema.SObjectField field = Sale_Spending_Payment__c.Fields.KPI_Number__c;
            Database.UpsertResult[] results = Database.upsert(listSaleKPIsToUpdate, field,false);

            for(Database.UpsertResult rs: results){
                if (!rs.isSuccess()){
                    cc_DMLResult_wrapper err = new cc_DMLResult_wrapper();
                    err.Errors  = JSON.serialize(rs.getErrors()) ;  
                    this.lserrors.add(err);                 
                }
            }
        }

    }

    global void finish(Database.BatchableContext bc){
        
    }
}