trigger BigQueryExportObjectTrigger on BigQuery_Export_Object__c (before insert, before update) {
	BigQueryExportController.handleObjectBeforeTrigger(Trigger.new);
}