({
	doInit : function(component, event, helper) {
        $A.enqueueAction(component.get('c.handleLoadSchema'));
    },
    
    
    
    handleLoadSchema: function(component, event, helper) {
      	// Prepare the action to load account record
        var action = component.get("c.getBigQueryExportObjectSchema");
        action.setParams({"recordId": component.get("v.recordId")});

        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.schema", response.getReturnValue());
            } else {
                console.log('Problem getting the BigQuery Export Object, response state: ' + state);
            }
        });
        $A.enqueueAction(action);  
    },
    
    
    
    handleDone: function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
    }
})