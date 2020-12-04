@istest
public class cc_KPI_CaculateController_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  

        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);


        
    }
}
