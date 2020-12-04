global class cc_KPI_GenSaleSpending_Cast_Batch implements Database.Batchable<SObject>{
    public String period {get;set;}
    public cc_KPI_GenSaleSpending_Cast_Batch(String pperiod) {
        this.period = pperiod;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT ID,KPI_Category__c , KPIAutoNumber__c, Period__c, Sales__r.Trac_Name__c, Sales__c 
                                            FROM KPI__c 
                                            WHERE Period__c = :this.period
                                                AND Status__c != 'Confirmed']);    
    }


    global void execute(Database.BatchableContext bc, List<KPI__c> scope){
        Set<String> kpis = new Set<String>();
        Map<String,KPI__c> mapkpi = new Map<String,KPI__c>();
        Map<String,List<Sale_Spending_Payment__c>> mapSSP = new Map<String,List<Sale_Spending_Payment__c>>();
        List<Sale_Spending_Payment__c> listtoInsert = new List<Sale_Spending_Payment__c>();

        for (KPI__c kpi: scope){
            if(!mapkpi.containsKey(kpi.Id)){
                mapkpi.put(kpi.Id,kpi);
            }

            kpis.add(kpi.Id);
        }   

        for(Sale_Spending_Payment__c sp: [SELECT Id, KPI_Category__c, KPI__r.KPI_Category__c, KPI__r.KPIAutoNumber__c,KPI__c 
                                            FROM Sale_Spending_Payment__c WHERE KPI__c IN :kpis]){
            
            if(mapSSP.containsKey(sp.KPI__c)){
                mapSSP.get(sp.KPI__c).add(sp);
            }else{
                mapSSP.put(sp.KPI__c, new List<Sale_Spending_Payment__c>{sp});
            }
        }

        System.debug('mapkpi=>' + mapkpi.size());
        System.debug('mapSSP=>' + mapSSP.size());

        for(String kpiId: mapkpi.keySet()){  
            List<Sale_Spending_Payment__c> sps = new List<Sale_Spending_Payment__c>();
                      
            String[] kpicat;
            if(!String.isBlank(mapkpi.get(kpiId).KPI_Category__c )){
                kpicat = mapkpi.get(kpiId).KPI_Category__c.split(';');
            }

            if(kpicat != null ){
                sps = mapSSP.get(kpiId);
                for(String cat: kpicat){
                    Boolean exists = false;
                    if(sps != null){
                        for(Sale_Spending_Payment__c sp: sps ){
                            if(cat == sp.KPI_Category__c){
                                exists = true;
                            }
                        }
                    }

                    System.debug('sps=>' + sps);
                    System.debug('exists=>' + exists);
                    if(!exists){
                        Sale_Spending_Payment__c saleKPI = new Sale_Spending_Payment__c();
                        String externalNumber = (String)mapkpi.get(kpiId).KPIAutoNumber__c + '_' + (String)cat + '_' + (String)mapkpi.get(kpiId).Period__c;   
                        System.debug('externalNumber=>' + externalNumber);                 
                        saleKPI.KPI__c = kpiId;
                        saleKPI.KPI_Category__c = cat;
                        saleKPI.Name = (String)mapkpi.get(kpiId).Sales__r.Trac_Name__c + ' - ' + (String)cat;                       
                        saleKPI.PaymentKPI__c = 0;
                        saleKPI.SpendingKPI__c = 0;
                        saleKPI.KPI_Number__c = externalNumber;

                        listtoInsert.add(saleKPI);
                    }
                }
            }
        }


        if(listtoInsert.size() > 0 ){
            insert listtoInsert;
        }
    }

    global void finish(Database.BatchableContext bc){

    }


}
