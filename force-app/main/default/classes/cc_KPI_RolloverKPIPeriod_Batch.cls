global class cc_KPI_RolloverKPIPeriod_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public String kpiPeriod {get;set;}
    public Date minDate {get;set;}
    public Date maxDate {get;set;}    
    public Map<String,List<User>> mapManager {get;set;}
    public List<KPI__c> insertKPIs {get;set;}     
    public List<cc_DMLResult_wrapper> lserrors  {get;set;}

    public cc_KPI_RolloverKPIPeriod_Batch(String period) {
        this.lserrors = new List<cc_DMLResult_wrapper>();
        this.insertKPIs = new List<KPI__c>();
        this.mapManager = new Map<String,List<User>>();
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
        Map<String, User> mapUser = new Map<String, User>();
        String SaleLKPIrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        String SaleMmgKPIrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId(); 


        for(User user: scope){
            if(mapManager.containsKey(user.ManagerId)){
                mapManager.get(user.ManagerId).add(user);
            }else {
                mapManager.put(user.ManagerId, new List<User>{user});
            }

            mapUser.put(user.Id, user);
        }

        for(String mngId : mapManager.keySet()){
            if(mapUser.containsKey(mngId)){            
                KPI__c kpi = new KPI__c();

                kpi.RecordtypeId = SaleMmgKPIrecordtypeId;
                kpi.Name = mapUser.get(mngId).Trac_Name__c + ': Manager KPI - ' + this.kpiPeriod;
                kpi.Period__c = this.kpiPeriod;
                kpi.KPI_Category__c = mapUser.get(mngId).KPI_Category__c;
                kpi.SalesManager__c  = mapUser.get(mngId).ManagerId;
                kpi.Sales__c = mngId;
                kpi.From_Date__c = this.minDate;
                kpi.To_Date__c = this.maxDate;
                kpi.KPI_Number__c = 'KPIMNG_' + mngId + '_' + this.kpiPeriod;
                System.debug('kpi.KPI_Number__c =>' + kpi.KPI_Number__c);
                kpi.Status__c = 'New';
                kpi.OwnerId = mngId;
                this.insertKPIs.add(kpi);
            }
        }


        for(User sale: scope){
            KPI__c kpi = new KPI__c();

            kpi.RecordtypeId = SaleLKPIrecordtypeId;
            kpi.Name = sale.Trac_Name__c + ': Sale KPI - ' + this.kpiPeriod;
            kpi.Period__c = this.kpiPeriod;
            kpi.KPI_Category__c = sale.KPI_Category__c;

            //Sale is sale manager role
            if(mapManager.containsKey(sale.Id)){
                kpi.SalesManager__c  = sale.Id;
            }else{
                kpi.SalesManager__c  = sale.ManagerId;
            }
            
            kpi.Sales__c = sale.Id;
            kpi.From_Date__c = this.minDate;
            kpi.To_Date__c = this.maxDate;
            kpi.KPI_Number__c = 'KPISALE_' + sale.Id + '_' + this.kpiPeriod;
            System.debug('kpi.KPI_Number__c =>' + kpi.KPI_Number__c);
            kpi.Status__c = 'New';
            kpi.OwnerId = sale.Id;
            this.insertKPIs.add(kpi);
        }     
    }

    global void finish(Database.BatchableContext bc){
        if(this.insertKPIs.size() > 0){
            Schema.SObjectField field = KPI__c.Fields.KPI_Number__c;
            Database.upsert(this.insertKPIs, field, true);

            cc_KPI_GenSaleSpending_Cast_Batch saleSpening_cashbatch = new cc_KPI_GenSaleSpending_Cast_Batch(this.kpiPeriod);
            Database.executeBatch(saleSpening_cashbatch, 200);
        }
    }
    
}