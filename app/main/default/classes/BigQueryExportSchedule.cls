global class BigQueryExportSchedule implements Schedulable {

    global void execute(SchedulableContext SC) {
        DateTime now = System.now();
        Integer year = now.year();
        Integer month = now.month();
        Integer day = now.day();
        Integer hour = now.hour();
        Integer minute = now.minute();
        
        if (minute > 0 && minute < 30) {
            minute = 0;
        }
        // We're actually closer to the next hour
        else {
            minute = 0;
            hour = hour + 1;
        }
        
        if (hour > 23) {
            hour = 0;
            day = day + 1;
        }
        
        if (day > daysInMonth(month, year)) {
            day = 1;
            month = month + 1;
        }
        
        if (month > 11) {
            month = 1;
            year = year + 1;
        }
        
        DateTime currentDT = DateTime.newInstance(now.year(), now.month(), now.day(), hour, minute, 0);
        String currentSchedule = 'Daily at ' + currentDT.hour() + currentDT.format('a');
    	
        List<BigQuery_Export__c> queue = new List<BigQuery_Export__c>();
        List<BigQuery_Export__c> bqExports = [SELECT Id, Schedule__c, Last_Run__c FROM BigQuery_Export__c];  
        
        for(BigQuery_Export__c bqExport : bqExports) {
            if (bqExport.Schedule__c == currentSchedule) {
               queue.add(bqExport); 
            }
        }
        
        if (queue.size() > 0) {
            for(BigQuery_Export__c bqExport : queue) {
                String bqeid = bqExport.Id;
             	List<BigQuery_Export_Object__c> bqeObjects = [SELECT Id, Object__c, Query__c, Project_ID__c, Dataset_ID__c, Table_ID__c FROM BigQuery_Export_Object__c WHERE BigQuery_Export__c = :bqeid];
                
                for (BigQuery_Export_Object__c bqeObject : bqeObjects) {
                    BigQueryExportBatch b = new BigQueryExportBatch(bqeObject);
					Id batchInstanceId = Database.executeBatch(b, 200);
                }
            }
        }
    }
    
    
    
    private Integer daysInMonth(Integer month, Integer year) {
        Integer days = 31;
        Set<Integer> daysWith30 = new Set<Integer>{4,6,9,11};
        Boolean isLeapYear = ((Math.mod(year, 4) == 0) && (Math.mod(year, 100) != 0) || (Math.mod(year, 400) == 0));
        
        if (daysWith30.contains(month)) {
            days = 30;
        }
        
        if (month == 2 && isLeapYear) {
            return 29;
        }
        else if (month == 2 && !isLeapYear) {
            return 28;
        }
        
        return days;
    }
    
}