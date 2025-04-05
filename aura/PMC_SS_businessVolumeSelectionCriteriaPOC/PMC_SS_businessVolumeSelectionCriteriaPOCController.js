({
	 init : function(cmp, event, helper) {
        var pageRef = cmp.get("v.pageReference");
        var state = pageRef.state; 
        var base64Context = state.inContextOfRef;
	   if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        cmp.set("v.recordId", addressableContext.attributes.recordId);
    },
})