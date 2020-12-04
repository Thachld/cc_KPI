({
    //Init Case Sub category piclist
    getKPIQuarterPicklist : function(component, event){
        var action = component.get("c.getKPIQuarterPicklistDB");            
		action.setCallback(this, function(response){
			var state = response.getState();            
			if (state === "SUCCESS"){
                var result = response.getReturnValue();			
                
                var js = JSON.stringify(result);
                
                component.set("v.quarterPick", result);               

			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){

			}
		});

		$A.enqueueAction(action);
    },


    //Init Case Sub category piclist
    getKPITypePicklist : function(component, event){
        var action = component.get("c.getKPITypePicklistDB");            
		action.setCallback(this, function(response){
			var state = response.getState();            
			if (state === "SUCCESS"){
                var result = response.getReturnValue();			
                
                var js = JSON.stringify(result);
                
                component.set("v.typePick", result);               

			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){

			}
		});

		$A.enqueueAction(action);
    },

})
