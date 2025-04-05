trigger PMC_SS_KnowledgeArticleVersionTrigger on Knowledge__kav (before insert,
                                                                before update,after update
                                                              ) {
                                                                  
                                                                  
if(trigger.isBefore && trigger.isUpdate  ) 
    system.debug('==========Ram --isBefore--->'); 
 else if(trigger.isAfter && trigger.isUpdate  )
{
    system.debug('==========Ram --isAfter--->'); 
}
    

}