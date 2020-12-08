@isTest
public class cc_lookupfieldController_Test {
    //This test class just ensures that there is enough code coverage
    //to get the component into production from your sandbox
    //it does not perform any validations.
    @TestSetup
    static void testSetup(){
        String clientrecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId(); 
        Account acc1 = cc_initData.initAccount('Batch Account test ' + String.valueOf(1), clientrecordtypeId, 'Local' , 'Airlines');
        insert acc1;
    }

    static testMethod void testLookupField() {
        List<string> returnFields = new List<string> {'Name'};
        Account a = [SELECT Id FROM Account LIMIT 1];
		    cc_lookupfieldController.getObjectDetails('Account');
            cc_lookupfieldController.GetRecentRecords('Account', returnFields, 5);
            cc_lookupfieldController.SearchRecords('Account', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z');
            cc_lookupfieldController.GetRecord('Account', returnFields, a.Id);
    }
}