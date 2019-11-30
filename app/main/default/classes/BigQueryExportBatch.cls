/**
 * BigQuery Exporter Batch
 * 
 * This batch takes a single BigQuery Export and processes the child objects as a batch each (in series)
 */
global class BigQueryExportBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    private Id recordId;
    private String objectType;
    private String query;
    private String projectId;
    private String datasetId;
    private String tableId;
    
    /**
     * Constructor
     */
    global BigQueryExportBatch(BigQuery_Export_Object__c bqxo) {
        this.recordId = bqxo.Id;
        this.objectType = bqxo.Object__c;
        this.query = bqxo.Query__c;
        this.projectId = bqxo.Project_ID__c;
        this.datasetId = bqxo.Dataset_ID__c;
        this.tableId = bqxo.Table_ID__c;
    }
    
    /**
     * Run the query
     */
	global Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator ql;
        Id bqxoid = this.recordId;
        BigQuery_Export_Object__c bqxo = [SELECT Id, Job_ID__c FROM BigQuery_Export_Object__c WHERE Id = :bqxoid];

        // If a job is already running, then exit:
        if (bqxo.Job_ID__c != null) {
            return null;
        }
        
        try {
	        ql = Database.getQueryLocator(this.query);
            bqxo.Job_ID__c = BC.getJobId();
            update bqxo;
        } catch(Exception e) {
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
		GoogleBigQuery google = new GoogleBigQuery(this.projectId, this.datasetId, this.tableId);
        GoogleBigQuery.InsertAll insertAll = new GoogleBigQuery.InsertAll();
        
        for (sObject o : scope) {
        	insertAll.addObject(o);
        }

        if (!google.add(insertAll)) {
           System.debug('Error: ' + google.getResponse());
        }
	}

    /**
     * This batch is done, let's queue up the next object in this batch run
     */
	global void finish(Database.BatchableContext BC){
        Id bqxoid = this.recordId;
        BigQuery_Export_Object__c bqxo = [SELECT Id, Job_ID__c FROM BigQuery_Export_Object__c WHERE Id = :bqxoid];
        bqxo.Job_ID__c = null;
        update bqxo;
	}
    
}