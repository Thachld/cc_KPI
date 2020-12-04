({
    selectRecord : function(component, event, helper){
        var getSelectRecord = component.get("v.user");
        var compEvent = component.getEvent("selectedLookup");
        compEvent.setParams({"selectedRecord" : getSelectRecord });  
        compEvent.fire()
    }
})
