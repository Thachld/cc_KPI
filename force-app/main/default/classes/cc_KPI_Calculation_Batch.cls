global class cc_KPI_Calculation_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public String kpiPeriod {get;set;}
    public Datetime minDateTime {get;set;}
    public Datetime maxDateTime {get;set;}
    public Date minDate {get;set;}
    public Date maxDate {get;set;}    
    public List<Sale_Spending_Payment__c> listUpSertSP;   
    public List<Sale_Spending_Payment__c> listDeleteSP; 
    public Set<String> kpiIds {get;set;}   
    public List<cc_DMLResult_wrapper> lserrors  {get;set;} 

    public cc_KPI_Calculation_Batch(String period) {
        this.kpiIds = new Set<String>();        
        this.lserrors = new  List<cc_DMLResult_wrapper>();
        this.listUpSertSP = new List<Sale_Spending_Payment__c>();
        this.listDeleteSP = new List<Sale_Spending_Payment__c>();
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
        this.minDateTime = Datetime.newInstance(minDate.year(), minDate.month(), minDate.day(), 0,0,0);       
        this.maxDateTime = Datetime.newInstance(maxDate.year(), maxDate.month(), maxDate.day(), 23,59,59); 
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
      
        return Database.getQueryLocator([SELECT Id, Sales__c, 
                                                SalesManager__c, 
                                                KPI_Category__c                                                
                                        FROM KPI__c WHERE Period__c =: kpiPeriod
                                            AND  RecordType.DeveloperName = 'Sale_KPI'
                                            AND Status__c != 'Confirmed']);
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){
        
        Map<String,String> mapSale = new  Map<String,String>();
        Set<String> kpiIds = new Set<String>();
        Map<String, List<Sale_Spending_Payment__c>> mapSP= new Map<String, List<Sale_Spending_Payment__c>>();
        Map<String, List<cc_QCData_wraper>> mapSpending = new Map<String, List<cc_QCData_wraper>>();
        Map<String, List<cc_QCData_wraper>> mapPayment = new Map<String, List<cc_QCData_wraper>>();

        for(KPI__c kpi: scope){
            kpiIds.add(kpi.Id);
            if(!String.isBlank(kpi.Sales__c) ){
                mapSale.put(kpi.Sales__c, kpi.Id);
            }
        }


        for(Sale_Spending_Payment__c sp : [SELECT Id, KPI__c, KPI__r.KPIAutoNumber__c, KPI_Number__c, 
                                            Payment_Amount__c, Spending_Amount__c, KPI_Category__c
                                             FROM Sale_Spending_Payment__c 
                                            WHERE KPI__c IN :kpiIds]){
            if(mapSP.containsKey(sp.KPI__c)){
                mapSP.get(sp.KPI__c).add(sp);
            }else{
                mapSP.put(sp.KPI__c, new List<Sale_Spending_Payment__c>{sp});
            }                                 
        }

        for(AggregateResult arr  :  [SELECT Sale__c Sale__c, 
                                            Xaxis__c Xaxis__c, 
                                            Special_client__c Special_client__c, 
                                            Industry__c Industry__c, 
                                            Agency__c Agency__c, 
                                            Is_HN_Region__c Is_HN_Region__c,
                                            Xaxis_Owner__c Xaxis_Owner__c, 
                                            Strategic_Client__c Strategic_Client__c,                                 
                                        SUM(Total_Spending__c) Total_Spending__c
                                        FROM QC_Account_Data__c 
                                        WHERE syn_date__c >=: minDateTime 
                                            AND syn_date__c <=:  maxDateTime 
                                            AND Sale__c IN  :mapSale.keySet()                                           
                                        GROUP BY Sale__c, Industry__c, Xaxis__c, Special_client__c, Agency__c, Is_HN_Region__c ,Xaxis_Owner__c, Strategic_Client__c]){

            cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
            qc.Amount = (Decimal)arr.get('Total_Spending__c');                   
            String Industry = (String)arr.get('Industry__c');  
            Boolean xaxis = (Boolean)arr.get('Xaxis__c');     
            Boolean Specialclient = (Boolean)arr.get('Special_client__c');     
            String Agency = (String)arr.get('Agency__c');      
            Boolean Is_HN_Region = (Boolean)arr.get('Is_HN_Region__c');      
            Boolean Xaxis_Owner = (Boolean)arr.get('Xaxis_Owner__c');
            Boolean Strategic_Client = (Boolean)arr.get('Strategic_Client__c');
            String KPICat;

            if(Strategic_Client){
                KPICat = 'Strategic Team';
            }else if(Agency.trim() == 'Global Agency' || Agency.trim() == 'Local Agency'){   
                if(Agency.trim() == 'Local Agency'){
                    if(Is_HN_Region){
                        KPICat = Agency.trim() + ' HN';
                    }else{
                        KPICat = Agency.trim() + ' HCM';
                    }                    

                    if(Specialclient){
                        KPICat = KPICat + '-Special Client';
                    }
                }else{
                    if(xaxis){
                        if(Xaxis_Owner){
                            KPICat = Agency.trim() + '-Xaxis';
                        }else {
                            KPICat = Agency.trim();
                        }
                    }else{
                        if(Xaxis_Owner){
                            KPICat = Agency.trim() + '-Non Xaxis';
                        }else {
                            KPICat = Agency.trim();
                        }
                    }

                }                
            }else if(!String.isBlank(Industry)){
                if(Specialclient){
                    KPICat = Industry.trim() + '-Special';
                }else {
                    KPICat = Industry.trim();
                }
            }else {
                KPICat = 'Unknown';
            }            

            qc.Industry =  Industry;
            qc.KPICategory = KPICat;
            qc.SpecialClient = Specialclient;
            qc.Xaxis = xaxis;
            qc.Agency = Agency;
            qc.exists = false;

            String sale = (String) arr.get('Sale__c');
            if(mapSpending.containsKey(sale) ){
                mapSpending.get(sale).add(qc);
            }else{
                mapSpending.put(sale, new List<cc_QCData_wraper> {qc}); 
            }            
        }


        for(AggregateResult arr  :  [SELECT Sale__c Sale__c, 
                                            Xaxis__c Xaxis__c, 
                                            Special_client__c Special_client__c, 
                                            Industry__c Industry__c, 
                                            Agency__c Agency__c,   
                                            Is_HN_Region__c Is_HN_Region__c, 
                                            Xaxis_Owner__c Xaxis_Owner__c,      
                                            Strategic_Client__c Strategic_Client__c,                               
                                        SUM(Final_Amount__c) Final_Amount__c
                                        FROM Payment__c 
                                        WHERE Effective_date__c >=: minDateTime 
                                            AND Effective_date__c <=: maxDateTime 
                                            AND Stage__c = 'Done'
                                            AND Payment_method__c IN ('Cash', 'Bank Transfer', 'Payment Gateway')  
                                            AND RecordType.Name IN ('Normal payment', 'Real Payment', 'Standard payment') 
                                            AND Sale__c IN  :mapSale.keySet()                                                    
                                        GROUP BY Sale__c, Industry__c, Xaxis__c, Special_client__c, Agency__c, Is_HN_Region__c, Xaxis_Owner__c,Strategic_Client__c]){

            cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
            qc.Amount = (Decimal)arr.get('Final_Amount__c');                   
            String Industry = (String)arr.get('Industry__c');  
            Boolean xaxis = (Boolean)arr.get('Xaxis__c');     
            Boolean Specialclient = (Boolean)arr.get('Special_client__c');     
            String Agency = (String)arr.get('Agency__c');
            Boolean Is_HN_Region = (Boolean)arr.get('Is_HN_Region__c');            
            Boolean Xaxis_Owner = (Boolean)arr.get('Xaxis_Owner__c');
            Boolean Strategic_Client = (Boolean)arr.get('Strategic_Client__c');

            String KPICat;
            if(Strategic_Client){
                KPICat = 'Strategic Team';
            }else if(Agency.trim() == 'Global Agency' || Agency.trim() == 'Local Agency'){   
                if(Agency.trim() == 'Local Agency'){
                    
                    if(Is_HN_Region){
                        KPICat = Agency.trim() + ' HN';
                    }else{
                        KPICat = Agency.trim() + ' HCM';
                    }

                    if(Specialclient){
                        KPICat = KPICat + '-Special Client';
                    }
                }else{
                    if(xaxis){
                        if(Xaxis_Owner){
                            KPICat = Agency.trim() + '-Xaxis';
                        }else {
                            KPICat = Agency.trim();
                        }
                    }else{
                        if(Xaxis_Owner){
                            KPICat = Agency.trim() + '-Non Xaxis';
                        }else {
                            KPICat = Agency.trim();
                        }
                    }
                }                
            }else if(!String.isBlank(Industry)){
                if(Specialclient){
                    KPICat = Industry.trim() + '-Special';
                }else {
                    if(Industry == 'Retails' || Industry == 'FMCG'){
                        KPICat = 'FMCG-Retails';
                    }else{
                        KPICat = Industry.trim();
                    }
                    
                }
            }else {
                KPICat = 'Unknown';
            }             

            qc.Industry =  Industry;
            qc.KPICategory = KPICat;
            qc.SpecialClient = Specialclient;
            qc.Xaxis = xaxis;   
            qc.Agency = Agency;
            qc.exists = false;

            String sale = (String) arr.get('Sale__c');
            if(mapPayment.containsKey(sale) ){
                mapPayment.get(sale).add(qc);
            }else{
                mapPayment.put(sale, new List<cc_QCData_wraper> {qc}); 
            }            
        }


        for(KPI__c kpi : scope){

            List<cc_QCData_wraper> alls = new List<cc_QCData_wraper>();
            List<Sale_Spending_Payment__c> sps = mapSP.get(kpi.Id);

            if(sps != null){
                
                List<cc_QCData_wraper> spendings = new List<cc_QCData_wraper>(); 
                Map<String, List<cc_QCData_wraper>> mapAlls = new Map<String, List<cc_QCData_wraper>>();
                List<cc_QCData_wraper> payments = new List<cc_QCData_wraper>();
                spendings = mapSpending.get(kpi.Sales__c);
                payments = mapPayment.get(kpi.Sales__c);

                for(Sale_Spending_Payment__c  sp: sps){
                    sp.Spending_Amount__c = 0;
                    sp.Payment_Amount__c = 0;

                    if(spendings != null){
                        for(cc_QCData_wraper spending: spendings){

                            if(sp.KPI_Category__c == spending.KPICategory){
                                Decimal amount = spending.Amount==null?0: spending.Amount;
                                sp.Spending_Amount__c = sp.Spending_Amount__c ==null?0 : sp.Spending_Amount__c + amount;
                                spending.exists = true;                                
                            }
                        }
                    }


                    if(payments != null){
                        for(cc_QCData_wraper payment: payments){
                            if(sp.KPI_Category__c == payment.KPICategory){    
                                Decimal amount = payment.Amount==null?0: payment.Amount;                        
                                sp.Payment_Amount__c = sp.Payment_Amount__c ==null?0 : sp.Payment_Amount__c + amount;
                                payment.exists = true;                                
                            }
                        }
                    }
                    
                    this.listUpSertSP.add(sp);                    
                }              
            }

            this.kpiIds.add(kpi.Id);


            //Process for case KPI: Actual KPI data is not assign
            
        }
    }

    global void finish(Database.BatchableContext bc){        

        if(this.listUpSertSP.size() > 0){
            Schema.SObjectField field = Sale_Spending_Payment__c.Fields.KPI_Number__c;
            Database.UpsertResult[] results = Database.upsert(this.listUpSertSP, field,false);

            for(Database.UpsertResult rs: results){
                if (!rs.isSuccess()){
                    cc_DMLResult_wrapper err = new cc_DMLResult_wrapper();
                    err.Errors  = JSON.serialize(rs.getErrors()) ;  
                    this.lserrors.add(err);                 
                }else{
                    this.kpiIds.add(rs.getId());
                }
            }

            if(this.kpiIds.size() >0){
                cc_KPI_CalculationActivities_Batch activities = new cc_KPI_CalculationActivities_Batch(this.kpiIds, minDate, maxDate);
                Database.executeBatch(activities, 40);
            }

            if(this.lserrors.size() > 0){

                AsyncApexJob asyn = [SELECT id, ApexClassId, ApexClass.name,
                                        JobItemsProcessed, TotalJobItems,
                                        NumberOfErrors, CreatedBy.Email
                                    FROM AsyncApexJob
                                    WHERE Id = :bc.getJobId()];
    
                Integer successed = 0;
                BatchJobLog__c batchlog = new BatchJobLog__c();
                batchlog.BatchClassName__c = asyn.ApexClass.name;
                batchlog.JobId__c = bc.getJobId();
                batchlog.Period__c = this.kpiPeriod;
                batchlog.RunningUser__c = UserInfo.getUserId();
                insert batchlog;
    
                List<BatchJobLogDetail__c> errsLog = new List<BatchJobLogDetail__c>();
                for(cc_DMLResult_wrapper err: this.lserrors){
                    
                    BatchJobLogDetail__c log = new BatchJobLogDetail__c();
                    log.IsCreated__c = true;                
                    log.ErrorLog__c = err.Errors;
                    log.BatchJobLog__c = batchlog.Id;
    
                    errsLog.add(log);    
                } 
                
                if (errsLog.size() > 0){   
                    insert errsLog;
                }
            }
        }
    }
}