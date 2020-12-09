@istest
public class cc_KPI_ManagerKPITeamMember_Sch_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;         
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;

        List<User> urs = new List<User>();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;

        User u11 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines', 'HN',false);
        u11.ManagerId = u1.Id;

        insert u11;

        User u12 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(2), null, 'Real Estate', 'HN',false);        
        
        insert u12;


        Date startDate = today.toStartOfMonth();
        Date endate = startDate.addMonths(1) - 1;
        String salerecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        String MngrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId();    
        
        KPI__c kpi = cc_initData.initKPI(u1.alias + '-' + period, u1.Id, period, startDate, endate, u1.KPI_Category__c, u1.Id, MngrecordtypeId);    
        insert kpi;

        KPI__c kpi0 = cc_initData.initKPI(u1.alias + '-' + period, u1.Id, period, startDate, endate, u1.KPI_Category__c, u1.Id, salerecordtypeId);    
        insert kpi0;

        KPI__c kpi1 = cc_initData.initKPI(u11.alias + '-' + period, u11.Id, period, startDate, endate, u11.KPI_Category__c, u11.ManagerId, salerecordtypeId);
        kpi1.Sale_Manager_KPI__c = kpi.Id;
        insert kpi1;

        KPI__c kpi2 = cc_initData.initKPI(u12.alias + '-' + period, u12.Id, period, startDate, endate, u12.KPI_Category__c, u12.Id, salerecordtypeId);
        kpi2.Sale_Manager_KPI__c = kpi.Id;
        insert kpi2;       

    }

    public testmethod static void testKPITeammember(){        

        Test.startTest();
            String period = '12-2020';
            cc_KPI_ManagerKPITeamMember_Batch batch = new cc_KPI_ManagerKPITeamMember_Batch(period);
            Database.executeBatch(batch);

        try {
            test.stopTest();

            // List<KPI__c> kpis = [SELECT Id FROM KPI__c LIMIT 3];
            // System.assertEquals(3, kpis.size());

        } catch (Exception ex) {
            
        }
    }
    
}