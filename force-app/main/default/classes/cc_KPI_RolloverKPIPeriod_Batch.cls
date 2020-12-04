global class cc_KPI_RolloverKPIPeriod_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public String kpiPeriod {get;set;}
    public Date minDate {get;set;}
    public Date maxDate {get;set;}    
    public List<KPI__c> insertKPIs {get;set;}     
    public List<cc_DMLResult_wrapper> lserrors  {get;set;}

    public cc_KPI_RolloverKPIPeriod_Batch(String period) {
        this.lserrors = new List<cc_DMLResult_wrapper>();
        this.insertKPIs = new List<KPI__c>();
        this.kpiPeriod = period;

        date dtToday = date.today();
        Date rundate;
        //Get First day of month and last day Of Month in runing period        
        if(!string.isBlank(period)){    
            string[] M = period.split('-');
            dtToday = date.NewInstance(integer.valueOf(M[1]), integer.valueOf(M[0]), 1 );
            rundate = dtToday;
        }else{           
            rundate = dttoday.addMonths(-1);                
        }

        this.minDate = rundate.toStartOfMonth();        
        this.maxDate = minDate.addDays(Date.daysInMonth(minDate.year(), minDate.month()) - 1);  
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, ManagerId, KPI_Category__c, Trac_Name__c
                                        FROM User 
                                        WHERE Profile.Name = 'Sales Profile'
                                            AND KPI_Category__c != ''
                                            AND IsActive = true]);       
    }

    global void execute(Database.BatchableContext bc, List<User> scope){

        for(User sale: scope){
            KPI__c kpi = new KPI__c();
            kpi.Name = sale.Trac_Name__c + ': KPI Tháng ' + this.kpiPeriod;
            kpi.Period__c = this.kpiPeriod;
            kpi.KPI_Category__c = sale.KPI_Category__c;
            kpi.SalesManager__c  = sale.ManagerId;
            kpi.Sales__c = sale.Id;
            kpi.From_Date__c = this.minDate;
            kpi.To_Date__c = this.maxDate;
            kpi.KPI_Number__c = 'KPI' + sale + '_' + this.kpiPeriod;
            kpi.Status__c = 'New';
            kpi.OwnerId = sale.Id;
            this.insertKPIs.add(kpi);
        }     
    }

    global void finish(Database.BatchableContext bc){
        if(this.insertKPIs.size() > 0){
            Database.SaveResult[] results = Database.insert(this.insertKPIs,false);

            cc_KPI_GenSaleSpending_Cast_Batch saleSpening_cashbatch = new cc_KPI_GenSaleSpending_Cast_Batch(this.kpiPeriod);
            Database.executeBatch(saleSpening_cashbatch, 200);
        }
    }
    
}