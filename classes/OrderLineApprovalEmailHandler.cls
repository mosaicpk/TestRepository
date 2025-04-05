global class OrderLineApprovalEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try {
            // Extract Email Details
            String subject = email.subject;
            String body = email.plainTextBody;
            String fromAddress = email.fromAddress;
            
            // Create a new EmailMessage record (Optional: Relate it to a Quote or Approval Record)
            EmailMessage emailRecord = new EmailMessage();
            emailRecord.Subject = subject;
            emailRecord.TextBody = body;
            emailRecord.FromAddress = fromAddress;
            emailRecord.ToAddress = envelope.toAddress;
            emailRecord.Status = 'Sent'; // Or 'Received'
            emailRecord.Incoming = true;
            
            // Relate the email to an approval record if possible (example for Quote)
            List<OrderItem> relatedQuotes = [SELECT OrderId FROM OrderItem WHERE OrderItemNumber LIKE :('%' + subject + '%') LIMIT 1];
            if (!relatedQuotes.isEmpty()) {
                emailRecord.RelatedToId = relatedQuotes[0].Id;
            }

            insert emailRecord;
        } catch (Exception e) {
            System.debug('Error Processing Email: ' + e.getMessage());
        }

        result.success = true;
        return result;
    }
}