trigger QuoteLineItemTrigger on SBQQ__QuoteLine__c (before update) {
    MassUpdateQuoteLinesHandler.massUpdateQuoteLines(Trigger.New, Trigger.Oldmap);
}