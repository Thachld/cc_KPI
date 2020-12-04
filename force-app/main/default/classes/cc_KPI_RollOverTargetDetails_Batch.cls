
global class cc_KPI_RollOverTargetDetails_Batch implements Database.Batchable<SObject> {
    public String quater {get;set;}
    global cc_KPI_RollOverTargetDetails_Batch(String pquater) {
        this.quater = pquater;
    }


    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, OwnerId, Status__c, Approval_Status__c, Quarter__c, 
                                                RecordType.Name, Sale_Manager__c, KPITargetAutoNumber__c, Include_Manager__c
                                                FROM KPI_Target__c 
                                                WHERE Quarter__c = :this.quater
                                                    AND Approval_Status__c = 'New' 
                                                    AND Status__c IN ('New' ,'Planing')]
                                                );       
    
    }

    global void execute (Database.BatchableContext bc, List<KPI_Target__c> scope){     
        Map<String,KPI_Target__c> mapKPIs = new Map<String,KPI_Target__c>();
        Map<String,String> mapManager = new Map<String,String>();
        Map<String,Set<String>> mapKPICat = new Map<String,Set<String>>();
        Map<String,User> mapUser = new Map<String,User>();
        List<KPI_Target_Detail__c> kpitargets = new List<KPI_Target_Detail__c>();
        List<User> processUsers = new List<User>();
        Set<String> inludeMngKPI = new Set<String>();


        for(KPI_Target__c kpi: scope){
            if(kpi.RecordType.Name == 'Sales KPI'){
                mapKPIs.put(kpi.Id, kpi);
            }            
        }

        System.debug('mapKPIs =>' + mapKPIs.size());
        for(String kpi: mapKPIs.keyset()){
            mapManager.put(mapKPIs.get(kpi).Sale_Manager__c, kpi);

            if (mapKPIs.get(kpi).Include_Manager__c){
                inludeMngKPI.add(mapKPIs.get(kpi).Sale_Manager__c);
            }
        }

        processUsers = [SELECT Id, KPI_Category__c, ManagerId, Trac_Name__c 
                        FROM User WHERE ManagerId IN :mapManager.keySet() AND KPI_Category__c != ''];

        if(inludeMngKPI != null){
            for(User us: [SELECT Id, KPI_Category__c, Trac_Name__c FROM User WHERE Id IN :inludeMngKPI]){
                User prsus = new User();
                prsus.Id = us.Id;
                prsus.KPI_Category__c = us.KPI_Category__c;
                prsus.ManagerId = us.Id;
                prsus.Trac_Name__c = us.Trac_Name__c;
                
                processUsers.add(prsus);
            }          
        }                

        for(User us: processUsers){
            String category = us.KPI_Category__c;
            mapUser.put(us.Id, us);

            String[] kpicat;
            if(!String.isBlank(category)){
                kpicat = category.split(';');
            }

            if(kpicat.size() > 0){
                for(String cat: kpicat){
                    if (mapKPICat.containsKey(us.Id)){
                        mapKPICat.get(us.Id).add(cat);
                    }else{
                        mapKPICat.put(us.Id, new Set<String>{cat});
                    }
                }
            }
            
        }

        System.debug('mapKPICat =>' + mapKPICat.size());
        if(mapKPICat.size() > 0){
            for(String saleId : mapKPICat.keySet() ){
                Set<String> kpicats = mapKPICat.get(saleId); 

                String managerId = mapUser.get(saleId).ManagerId;
                String kpitargetId = mapManager.get(managerId);
                String quater = mapKPIs.get(kpitargetId).Quarter__c;
                String targetNumber = mapKPIs.get(kpitargetId).KPITargetAutoNumber__c;
                String saleTracName = mapUser.get(saleId).Trac_Name__c;

                for(String cat: kpicats){
                    List<String> periods = new List<String>();
                    periods = cc_util.getPeriodbyQuarter(quater.trim());
                    for(String period : periods){
                        String targetEXNumber = targetNumber.trim() + '' + period.trim() + '' + saleTracName.trim() + '' + cat.trim();
                        KPI_Target_Detail__c kpitarget = new KPI_Target_Detail__c();

                        kpitarget.KPITargetDetailNumber__c = targetEXNumber;
                        kpitarget.Name = saleTracName + ' - ' + period;
                        kpitarget.KPI_Category__c = cat;
                        kpitarget.KPI_Target__c = kpitargetId;
                        kpitarget.Quarter__c = quater;
                        kpitarget.Period__c = period;
                        kpitarget.Sale__c = saleId;

                        kpitargets.add(kpitarget);
                    }
                    
                }
            }
        }

        System.debug('kpitargets =>' + kpitargets.size());
        if(kpitargets.size() > 0){            

            insert kpitargets;
        }


    }

    global void finish (Database.BatchableContext bc){

    }
}