@isTest(SeeAllData=false)
public class BigQueryExportBatchTest {

    testMethod static void testBatch() {
        Account acc = new Account(
        	Name = 'Test Account'
        );
        
        insert acc;
        
        BigQuery_Export__c bqe = new BigQuery_Export__c(
        	Name = 'Export Schedule',
            Schedule__c = 'Daily at 1am'
        );
        
        Database.SaveResult bqeSave = Database.insert(bqe, false);
        
        BigQuery_Export_Object__c bqxo = new BigQuery_Export_Object__c(
            BigQuery_Export__c = bqeSave.getId(),
            Object__c = 'Account',
            Project_ID__c = 'my-project',
            Dataset_ID__c = 'my-dataset',
            Table_ID__c = 'my-table',
            Query__c = 'SELECT Id, Name FROM Account'
        );
        
        Database.SaveResult bqxoSave = Database.insert(bqxo, false);
        
        
        GoogleBigQueryRequestMock fakeResponse = new GoogleBigQueryRequestMock(200,
                                                 'Complete',
                                                 '{ "access_token": "access_token" }',
                                                 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        // Batch
        Test.startTest();
        BigQuery_Export_Object__c bqxo2 = [SELECT Id, Object__c, Query__c, Project_ID__c, Dataset_ID__c, Table_ID__c, Batch_Size__c, Job_ID__c, Last_Run_Start__c, Last_Run_Finished__c FROM BigQuery_Export_Object__c];
        BigQueryExportBatch batch = new BigQueryExportBatch(bqxo2);
        Id batchjobid = Database.executeBatch(batch, (Integer) bqxo2.Batch_Size__c);
        Test.stopTest();
        
        List<BigQuery_Export_Log__c> logs = [SELECT Id, Name, Type__c, Message__c FROM BigQuery_Export_Log__c];
        
        System.debug(logs);
        System.assertEquals(1, logs.size());
        System.assertEquals('Successful object export', logs[0].Type__c);
    }

}