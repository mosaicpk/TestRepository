trigger ooo on OutOfOffice (after delete) {
	//trigger.new[0].addError('Error during insert Update');
	//
	List<User> lstUserToUpdate = new List<User>();
    
	for(OutOfOffice objOOO : trigger.old)
    {
        lstUserToUpdate.add(new User(Id=objOOO.UserId,PMC_SS_OutOfOffice__c=false));
	}
    if(!lstUserToUpdate.isEmpty()) 
    update lstUserToUpdate;
}