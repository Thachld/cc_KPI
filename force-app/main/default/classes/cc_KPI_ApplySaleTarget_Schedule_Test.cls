@istest
public class cc_KPI_ApplySaleTarget_Schedule_Test {
    @TestSetup
    static void testSetup(){
        List<User> urs = new List<User>();
        List<KPI__c> kpis = new List<KPI__c>();
        list<KPI_Target__c> targets = new List<KPI_Target__c>();
        list<KPI_Target_Detail__c> details = new List<KPI_Target_Detail__c>();

        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(2), null, 'Game', 'HN',false);
        User u3 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(3), null, 'Game-Special', 'HN',false);
        User u4 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(4), null, 'Local agency HN', 'HN',false);
        User u5 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(5), null, 'Local Agency HN-Special Client', 'HN',false);
        User u6 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(6), null, 'Global Agency', 'HN',false);
        User u7 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(7), null, 'Global Agency', 'HN',true);
        User u8 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(8), null, 'Local Agency HCM', 'HN',false);

        User u9 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(8), null,
                                         'Local Agency HCM;Airlines;Real Estate;Game;Game-Special;Local agency HN;Local Agency HN-Special Client;Global Agency', 'HN',false);
        
        
        urs.add(u1);
        urs.add(u2);
        urs.add(u3);
        urs.add(u4);
        urs.add(u5);
        urs.add(u6);
        urs.add(u7);
        urs.add(u8);       

        insert urs;

        

        for(User us: urs){
            Date startDate = today.toStartOfMonth();
            Date endate = startDate.addMonths(1) - 1;
            KPI__c kpi = cc_initData.initKPI(us.alias + '-' + period, us.Id, period, startDate, endate, us.KPI_Category__c);

            kpis.add(kpi);
        }

        insert kpis;

        insert u9;
        String salerecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sales_KPI').getRecordTypeId(); 
        KPI_Target__c target = cc_initData.initKPITarget('Target Sales Tesst', u9.Id, salerecordtypeId, '4-2020');
        insert target;

        for(User us: urs){            
            String[] kpicat;
            if(!String.isBlank(us.KPI_Category__c)){
                kpicat = us.KPI_Category__c.split(';');
            }

            for(String cat: kpicat){
                KPI_Target_Detail__c detail = cc_initData.initKPITargetdetail(us.Alias, us.Id, target.Id, '4-2020', period, cat);
                details.add(detail);
            }
        }

        insert details;
    }

    public testmethod static void testSchedule(){
        Datetime dt = Datetime.now().addMinutes(2);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        
        String jobId = System.schedule('calKPI', CRON_EXP, new cc_KPI_ApplySaleTarget_Schedule());

        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
    }
}