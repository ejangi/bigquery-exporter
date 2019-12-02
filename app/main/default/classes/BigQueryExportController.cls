public class BigQueryExportController {

    public BigQueryExportController() {}



    public static BigQueryExportJob runJob(BigQueryExportJob job) {
        GoogleBigQuery google = new GoogleBigQuery(job.projectId, job.datasetId, job.tableId);
        GoogleBigQuery.InsertAll insertAll = new GoogleBigQuery.InsertAll();
        
        for (Object o : job.rows) {
        	insertAll.addObject(o);
        }

        if (!google.add(insertAll)) {
            job.response = google.getResponse();
        	System.debug('Error: ' + job.response);
        }
        
        job.rows = null;
        job.success = google.isSuccess();
        return job;
    }
    
}