@isTest
public class GoogleBigQueryTest {
    
    testMethod static void testInsertRow() {
        GoogleBigQueryRequestMock fakeResponse = new GoogleBigQueryRequestMock(200,
                                                 'Complete',
                                                 '{ "access_token": "access_token" }',
                                                 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        String projectId = 'my-fake-project';
        String datasetId = 'my-fake-dataset';
        String tableId = 'my-fake-table';
            
        GoogleBigQuery google = new GoogleBigQuery(projectId, datasetId, tableId);
        GoogleBigQuery.InsertAll insertAll = new GoogleBigQuery.InsertAll();
        
        Account acc = new Account(
        	Name = 'My Fake Account'
        );
            
        insertAll.addObject(acc);
        google.add(insertAll);
        
        System.assertEquals(true, google.isSuccess());
    }
    
}