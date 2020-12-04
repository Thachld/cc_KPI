({
    doInit : function(component, event, helper) {
        helper.getIndustryPicklist(component, event);        

        var discount = component.get("v.detail");
        if(discount.isnew){
            component.set("v.editMode", true);  
        }
    },

    handleChangeData :function(component,event,helper){                     
        var editmode = component.get("v.editMode");
        if(editmode){
            var valid = helper.checkValidity(component,event);

            if(valid){
                component.set("v.editMode", false);  
                
                var event = component.getEvent("KPITargetEvent");
                event.setParams({
                    'eventType':'Update'
                });
                
                event.fire();

                helper.saveKPITargetDetail(component);
            }
        }else{
            component.set("v.editMode", "true"); 
            
            var event = component.getEvent("KPITargetEvent");
                event.setParams({
                    'eventType':'editChange'
                });
                event.fire();
        }
    },
      
    handleAddKPIDetail :function(component,event,helper){    
            
        var event = component.getEvent("KPITargetEvent");
        event.setParams({
            'eventType':'Add'
        });
        
        event.fire();
    },


    handleDelete :function(component,event,helper){   

        helper.deleteKPITargetdetail(component);     

        var event = component.getEvent("KPITargetEvent");
        var idx = component.get("v.sNo");
        event.setParams({
            'eventType':'Delete',
            'recordIdx': idx
        });
        
        event.fire();

        
    },
})