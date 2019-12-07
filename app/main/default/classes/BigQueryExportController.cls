public with sharing class BigQueryExportController {

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
    
    
    
    @AuraEnabled
    public static BigQuery_Export_Object__c getBigQueryExportObject(Id recordId) {
        return [SELECT Id, Name, Query__c FROM BigQuery_Export_Object__c WHERE Id = :recordId];
    }
    
    
    
    @AuraEnabled
    public static String getBigQueryExportObjectSchema(Id recordId) {
        BigQuery_Export_Object__c bqxo = [SELECT Id, Query__c FROM BigQuery_Export_Object__c WHERE Id = :recordId];
        String query = bqxo.Query__c.toLowerCase();
        query = query.replace('select', '').trim();
        List<String> fr = query.split('from');
        String obj = fr[1].trim();
        SObjectType objType = Schema.getGlobalDescribe().get(obj);
        Map<String,Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
		List<String> jsonList = new List<String>();
        String json = '';
        
        for (Schema.SobjectField f : fields.values()) {
            Schema.DescribeFieldResult d = f.getDescribe();
            String name = d.getName();
            String t = String.valueOf(d.getType());

            if (fr[0].contains(name.toLowerCase())) {
                String js = '{';
                js += '"name":"' + name + '",';
                js += '"type":"' + sfTypeToBqType(t) + '",';
                js += '"mode":"nullable"';
                js += '}';
                jsonList.add(js);
            }
        }

        if (jsonList.size() > 0) {
            json += '[';
	        for (String js : jsonList) {
    			json += js + ',';
        	}
            json = json.removeEnd(',');
            json += ']';
        }
        
        return json;
    }
    
    
    
    public static void handleObjectBeforeTrigger(List<BigQuery_Export_Object__c> scope) {
        for (BigQuery_Export_Object__c obj : scope) {
            obj.Object__c = getObjectNameFromQuery(obj.Query__c);
        }
    }
    
    
    
    public static String sfTypeToBqType(String sfType) {
        Set<String> strings = new Set<String>{ 'ID', 'PICKLIST', 'EMAIL', 'ENCRYPTEDSTRING', 'MULTIPICKLIST', 'PHONE', 'REFERENCE', 'TEXTAREA', 'URL' };
        Set<String> floats = new Set<String>{ 'CURRENCY', 'DECIMAL' };
            
        if (strings.contains(sfType)) {
        	return 'STRING';    
        }
        
        if (floats.contains(sfType)) {
        	return 'FLOAT';    
        }
        
        return sfType;
    }
    
    
    
    public static String getObjectNameFromQuery(String query) {
        query = query.replace('(?i)select', '').trim();
        List<String> fr = query.split('(?i)from');
        List<String> extras = fr[1].trim().split(' ');
		return extras[0];
    }
    
}