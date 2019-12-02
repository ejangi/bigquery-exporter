public class BigQueryExportJob {

    public Boolean success { get; set; }
    public String response { get; set; }
    
    public String projectId { get; set; }
    public String datasetId { get; set; }
    public String tableId { get; set; }
    
    public List<Object> rows { get; set; }
    
    
    
    public BigQueryExportJob(String projectId, String datasetId, String tableId) {
        this.projectId = projectId;
        this.datasetId = datasetId;
        this.tableId = tableId;
    }

}