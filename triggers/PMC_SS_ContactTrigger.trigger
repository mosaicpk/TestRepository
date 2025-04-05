trigger PMC_SS_ContactTrigger on Contact (before insert, before update) {
    new PMC_ContactTriggerHandler().run();
}