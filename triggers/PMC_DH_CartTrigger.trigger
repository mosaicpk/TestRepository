/**
 * @description       : 
 * @author            : siddharth.pradhan@mosaicco.com | Digital Hub
 * @group             : 
 * @last modified on  : 08-03-2023
 * @last modified by  : siddharth.pradhan@mosaicco.com | Digital Hub
**/

trigger PMC_DH_CartTrigger on WebCart (after update) {
    new PMC_DH_CartTriggerHandler().run();
}