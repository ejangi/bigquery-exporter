@isTest(seeAllData=false)
public class BigQueryExportObjectTriggerTest {

    testMethod static void testTrigger() {
        BigQuery_Export__c ex = new BigQuery_Export__c(
        	Schedule__c = 'Daily at 1am'
        );
        
        Database.SaveResult exs = Database.insert(ex, false);
        
        BigQuery_Export_Object__c obj = new BigQuery_Export_Object__c(
            BigQuery_Export__c = exs.getId(),
        	Query__c = 'SELECT Id, Name FROM Account WHERE Name LIKE \'Bloggs%\' ORDER BY Id DESC LIMIT 1000',
            Project_ID__c = 'Test',
            Dataset_ID__c = 'Test',
            Table_ID__c = 'Test'
        );
        
        Test.startTest();
        Database.SaveResult sr = Database.insert(obj, false);
        Test.stopTest();
        
        System.debug(sr.getErrors());
        System.assertEquals(true, sr.isSuccess());
        Id bqxoid = sr.getId();
        BigQuery_Export_Object__c bqxo = [SELECT Id, Object__c FROM BigQuery_Export_Object__c WHERE Id = :bqxoid];
        System.assertEquals('Account', bqxo.Object__c);
    }
    
}