# Phase 5: Common Errors, Troubleshooting, and Remediation

## How to approach failures in governance tooling

Governance features sit at the intersection of licensing, permissions, and timing, and most failures trace back to one of those three. A useful habit is to ask, in order, whether the licence is assigned, whether the actor holds the right role or scope, and whether enough time has passed for the platform to process the change. Many governance operations are asynchronous, so an apparent failure is sometimes just latency. The notes below record the problems most likely to appear during this lab and the reasoning that resolves them.

## Licensing and feature availability

The most common early failure is a portal blade that displays a licence prompt or an API call that returns a forbidden or not-licensed error. The cause is usually that the P2 or Governance trial has not been assigned to the relevant users, or that the trial has expired. Assigning the licence to the lab administrator and to the users who will request access or be reviewed resolves most cases. If a feature is missing entirely, the author checks the current licensing page, since boundaries between P2 and the Governance add-on have shifted over time.

## Graph PowerShell permissions and consent

Errors such as insufficient privileges to complete the operation almost always mean the connected session lacks a scope. The remedy is to disconnect, reconnect with the additional scope, and approve the consent prompt. The `Get-MgContext` output lists the granted scopes and is the first thing to inspect. A subtler problem occurs when the signed-in account is a guest or lacks a directory role, in which case delegated scopes alone are not enough. Another recurring issue is that cmdlet names differ between SDK versions, particularly in the governance modules. Running `Get-Command -Module Microsoft.Graph.Identity.Governance` shows what is available, and falling back to `Invoke-MgGraphRequest` against the documented REST endpoint is a reliable alternative that is also version-independent.

## Entitlement management problems

When a user cannot see an access package, the cause is nearly always the requestor scope on the policy. The user may not be in the allowed group, or, for external users, their organisation may not be a connected organisation. When a request is approved but access does not appear, the author checks the assignment state, which may be delivering, and waits several minutes before suspecting a fault. If a package refuses to accept a group resource, the group may be a dynamic group, which cannot be managed this way, or it may lack the right type, since role-assignable groups and mail-enabled groups have restrictions. Missing approver notifications are usually spam-filtered, which the author can confirm by checking the approval list in My Access directly.

## Access review problems

If a review does not start, the start date or recurrence is the usual culprit, and the review definition should be inspected for status. If no reviewers are listed, the scope may contain no groups with owners, so a fallback reviewer must be configured. If decisions are not applied after the review ends, the apply setting may be off, or the review may simply be awaiting the end date. A frequent surprise is that removing a user from a group through a review does not delete the account, since only the membership is removed. This is correct behaviour, though it surprises newcomers.

## PIM problems

Activation failures commonly stem from MFA registration. If the user has not registered an authentication method, activation stalls, so registration should be completed before testing. If a role appears as active immediately after activation but permissions seem not to apply, token refresh is the usual cause, and the user should sign out and back in. If approvers do not receive requests, the approver list in the role settings may be empty, or approver notifications may be going to a filtered mailbox. When a user wants to assign a permanent role but the option is greyed out, the role settings have intentionally disabled permanent assignment, which confirms the control works. A final trap is changing role settings and expecting immediate effect on existing assignments, whereas new settings apply to future activations.

## Audit and reporting problems

If Log Analytics tables are empty, the diagnostic setting may have been saved without selecting the audit category, or the ingestion delay has not yet passed. If KQL queries return nothing, the operation name strings may differ from those assumed, so the author inspects raw `AuditLogs` rows for the events generated during testing and adapts the filter to match.

## Remediation discipline

Every fix is recorded in a short entry that states the symptom, the cause, the remedy, and how recurrence can be prevented. These entries are valuable for the portfolio because they show practical diagnostic skill, and they are the part of the repository most likely to help another practitioner.

## Microsoft Learn references

- Troubleshoot entitlement management: https://learn.microsoft.com/entra/id-governance/entitlement-management-troubleshoot
- Troubleshoot PIM: https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-troubleshoot
- Graph PowerShell troubleshooting: https://learn.microsoft.com/powershell/microsoftgraph/troubleshooting
- Microsoft Entra licensing for governance: https://learn.microsoft.com/entra/id-governance/licensing-fundamentals
