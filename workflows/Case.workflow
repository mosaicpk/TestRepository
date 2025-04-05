<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PMC_QualityApprovalEmail</fullName>
        <description>Quality Approval Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>SSR</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>testmosaiccs@mosaicco.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PMC_emails/PMC_SS_CaseResolved</template>
    </alerts>
    <alerts>
        <fullName>PMC_SS_NotifyUserOnCaseCreationEmailAlert</fullName>
        <description>Notify user that Case has been created</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply.testmosaiccs@mosaicco.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PMC_emails/PMC_SS_KnowledgeArticleRequestCaseTemplate</template>
    </alerts>
    <fieldUpdates>
        <fullName>ChangePriorityToHigh</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Changes the case priority to high.</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_ApprovalforFinallevel</fullName>
        <field>PMC_SS_ApprovalStatus__c</field>
        <literalValue>Final Approved</literalValue>
        <name>Approval for Final level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_ApprovalforFirstlevel</fullName>
        <field>PMC_SS_ApprovalStatus__c</field>
        <literalValue>Level 1 Approved</literalValue>
        <name>Approval for First level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_ApprovalforSecondlevel</fullName>
        <field>PMC_SS_ApprovalStatus__c</field>
        <literalValue>Level 2 Approved</literalValue>
        <name>Approval for Second level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_Rejection</fullName>
        <field>PMC_SS_ApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_ApprovalforThirdLevel</fullName>
        <description>Approval status field update for Third level approval</description>
        <field>PMC_SS_ApprovalStatus__c</field>
        <literalValue>Level 3 Approved</literalValue>
        <name>Approval for Third Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_CaseNearbyMilestoneCompleted</fullName>
        <field>PMC_SS_MilestoneIsNearby__c</field>
        <literalValue>0</literalValue>
        <name>Case Nearby Milestone Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_FirstContactMilestoneCompleted</fullName>
        <field>PMC_SS_MilestoneIsViolated__c</field>
        <literalValue>0</literalValue>
        <name>First Contact Milestone Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_FirstContactMilestoneNearby</fullName>
        <field>PMC_SS_MilestoneIsNearby__c</field>
        <literalValue>1</literalValue>
        <name>First Contact Milestone Nearby</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_FirstContactMilestoneViolated</fullName>
        <field>PMC_SS_MilestoneIsViolated__c</field>
        <literalValue>1</literalValue>
        <name>First Contact Milestone Violated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_ResetActionReason</fullName>
        <description>To reset back the Action Reason when Case approval is Rejected.</description>
        <field>PMC_SS_ActionReason__c</field>
        <name>Reset Action Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_ResolutionMilestoneCompleted</fullName>
        <field>PMC_SS_MilestoneIsViolated__c</field>
        <literalValue>0</literalValue>
        <name>Resolution Milestone Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_ResolutionMilestoneNearby</fullName>
        <field>PMC_SS_MilestoneIsNearby__c</field>
        <literalValue>1</literalValue>
        <name>Resolution Milestone Nearby</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PMC_SS_ResolutionMilestoneViolated</fullName>
        <field>PMC_SS_MilestoneIsViolated__c</field>
        <literalValue>1</literalValue>
        <name>Resolution Milestone Violated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>d</fullName>
        <field>POC_Approved__c</field>
        <literalValue>1</literalValue>
        <name>d</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <tasks>
        <fullName>milestone</fullName>
        <assignedToType>owner</assignedToType>
        <description>testing milestone</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>milestone</subject>
    </tasks>
</Workflow>
