@isTest
public class BigQueryExportJobTest {

    testMethod static void testJob() {
        List<Object> rows = new List<Object>();
		rows.add(new BigQueryExportJob('my', 'fake', 'job'));
        
        BigQueryExportJob job = new BigQueryExportJob('my', 'fake', 'job');
        job.rows = rows;
        job.success = true;
        job.response = 'Hello world';
        
        System.assertEquals('my', job.projectId);
        System.assertEquals('job', job.tableId);
        System.assertEquals(1, job.rows.size());
    }
    
}