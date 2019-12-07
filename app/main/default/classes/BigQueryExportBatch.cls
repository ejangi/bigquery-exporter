/**
 * BigQuery Exporter Batch
 * 
 * This batch takes a single BigQuery Export and processes the child objects as a batch each (in series)
 */
global class BigQueryExportBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    private BigQuery_Export_Object__c bqxo;
    
    /**
     * Constructor
     */
    global BigQueryExportBatch(BigQuery_Export_Object__c bqxo) {
        this.bqxo = bqxo;
    }
    
    /**
     * Run the query
     */
	global Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator ql;
        Id bqxoid = this.bqxo.Id;

        // If a job is already running, then exit:
        if (this.bqxo.Job_ID__c != null) {
            return null;
        }
        
        try {
	        ql = Database.getQueryLocator(this.bqxo.Query__c);
            this.bqxo.Job_ID__c = BC.getJobId();
            this.bqxo.Last_Run_Start__c = DateTime.now();
            update this.bqxo;
        } catch(Exception e) {
            BigQuery_Export_Log__c l = new BigQuery_Export_Log__c(
	            Type__c = 'Error',
				Message__c = e.getMessage(),
				Name = this.bqxo.Object__c + ' batch start error'
    	    );
	        insert l;
            System.debug(e);
            return null;
        }

        return ql;
	}

    /**
     * Send a portion (a batch) of records to BigQuery
     */
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		// InsertAll
		BigQueryExportJob job = new BigQueryExportJob(this.bqxo.Project_ID__c, this.bqxo.Dataset_ID__c, this.bqxo.Table_ID__c);
        job.rows = scope;
		BigQueryExportJob run = BigQueryExportController.runJob(job);

        // Log errors
        if (!run.success) {
            BigQuery_Export_Log__c l = new BigQuery_Export_Log__c(
            	Type__c = 'Error',
                Message__c = run.response,
                Name = this.bqxo.Object__c + ' failed to export batch'
            );
            insert l;
        }
	}

    /**
     * This batch is done, let's queue up the next object in this batch run
     */
	global void finish(Database.BatchableContext BC){
        this.bqxo.Job_ID__c = null;
        this.bqxo.Last_Run_Finished__c = DateTime.now();
        update bqxo;
        
        BigQuery_Export_Log__c l = new BigQuery_Export_Log__c(
            Type__c = 'Successful object export',
			Message__c = BC.getJobId() + ' finished at ' + DateTime.now(),
			Name = this.bqxo.Object__c + ' exported successfully'
        );
        insert l;
	}
    
}