/**
* @description This class will be used to handle all trigger operations of OrderItem object
* @author Raphael Soares
* @storynumber GCPM-2396 - FPD I - PM Approval Workflow and Approvers
*/
trigger OrderItemTrigger on OrderItem (after update) {
    new OrderItemTriggerHandler().run();
}