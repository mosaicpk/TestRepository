public with sharing class ContractFlowCaller {
     // Method to run the flow as a System Administrator
    public static void runFlowAsSystemAdmin() {
        // Query for a System Administrator user
        User adminUser = [SELECT Id FROM User WHERE Name = 'Default Workflow' LIMIT 1];
 
        // Check if a System Admin user exists
        if (adminUser != null) {
            // Run as the System Admin user
            System.runAs(adminUser) {
                // Map for flow inputs (use if your flow requires variables)
                Map<String, Object> flowInputs = new Map<String, Object>();
                flowInputs.put('InputVariable1', 'Value1'); // Replace with actual variables and values
                flowInputs.put('InputVariable2', 'Value2');
 
                // Start the flow
                Flow.Interview.Update_Contract flow = new Flow.Interview.Update_Contract(flowInputs);
                flow.start();
            }
        } else {
            // Handle case where no System Admin user is found
            System.debug('No System Administrator user found.');
        }
    }

}