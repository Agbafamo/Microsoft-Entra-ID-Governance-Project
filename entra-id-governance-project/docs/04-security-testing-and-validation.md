# Phase 4: Security Testing and Validation

## The purpose of testing governance

A control that has never been tested is an assumption. The goal of this phase is to prove that each governance control behaves as designed, and, more interestingly, to try to defeat it. Each test below states the requirement under examination, the procedure, the expected result, and the evidence to capture. Tests are numbered so that screenshots in the `evidence` folder can be named to match, for example `T03-pim-activation-approval.png`.

## Testing directory and role management

The first test checks that no unauthorised standing privilege exists. The author lists all active role assignments in the tenant and confirms that the only permanent Global Administrators are the two emergency access accounts. The expected result is a short, explainable list. The second test confirms the administrative unit scope: signing in as Chidi after activating User Administrator scoped to the Sales administrative unit, the author attempts to reset the password of a Sales user, which should succeed, and of a Finance user, which should fail with an insufficient privileges message. The failure is the evidence that least privilege is enforced rather than merely intended.

## Testing entitlement management

The access package tests follow the lifecycle of a request. Alice signs in to the My Access portal and requests the Finance reporting package, and the test confirms that the justification field is mandatory and that the request is routed to Bola. After approval, the test confirms that Alice is added to the group and that the assignment shows an expiry date ninety days ahead. A negative test follows: a Sales user attempts to find the Finance package and should not see it, because the requestor scope excludes them. A rejection test confirms that denial leaves no access and writes an audit entry.

For the external policy, Emeka is invited through the access package flow. The test confirms that a guest account is created only after sponsor approval and that the guest receives only the groups in the package. The cleanup test removes the assignment and verifies that the guest account is later blocked or deleted according to the lifecycle setting. Since that setting operates over days, the author either shortens the timing in a lab policy or documents the configured behaviour with the policy page as evidence, stating clearly which of the two was done.

## Testing access reviews

Access reviews run on a recurrence that is too slow for a lab, so the author creates a one-off review with a short duration using the same settings as the production design. A reviewer approves one user with a justification, denies another, and ignores a third. When the review ends, the test confirms that the denied user and the non-responding user were removed from the group, that the approved user remained, and that all three outcomes appear in the review history. The non-responder case is the most important, because it proves the default-deny setting does what the design intends. The author also confirms that recommendations, such as inactivity indicators, were visible to the reviewer.

## Testing privileged identity management

Chidi activates Helpdesk Administrator and the test records the MFA prompt, the justification requirement, and the time at which the role appears in his active assignments. The author then waits for or manually shortens the duration and confirms that the role disappears. A Global Administrator activation is tested with the approval requirement: the request sits pending until Dara approves it, the notification email is received, and the activation window is limited to one hour. A negative test attempts to activate a role for which the user is not eligible, which should be impossible, and another attempts to exceed the maximum duration, which the interface should refuse.

An adversarial test then simulates a compromised account. Using a user whose credentials are assumed stolen but who is only eligible for a role, the author shows that the attacker would still need to pass MFA and, for the most sensitive role, a second person's approval. The audit log then shows the attempted activation, which supports detection. The point of this test is to demonstrate the reduction in attack surface, not just the presence of a feature.

## Testing auditability

The final tests confirm that evidence exists. The author runs the saved KQL queries and confirms that each event from the earlier tests is visible, including actor, target, time, and result. A deliberate bypass is attempted by assigning a role directly outside PIM, and the PIM alerts and the query for non-PIM assignments should flag it. The governance report script is run, and its output is compared against the portal to confirm that it is complete and accurate.

An example KQL query for non-PIM role assignments is shown below.

```kusto
AuditLogs
| where OperationName has "Add member to role" and OperationName !has "PIM"
| extend Actor = tostring(InitiatedBy.user.userPrincipalName)
| project TimeGenerated, OperationName, Actor, TargetResources, Result
| order by TimeGenerated desc
```

Table and operation names vary slightly, so the author validates the query against real log entries produced during testing rather than trusting it blindly.

## Recording results

Each test is recorded in a results table inside the repository with the test ID, requirement, outcome (pass, fail, or pass after remediation), evidence filename, and notes. Failures are not hidden. A test that failed and was fixed is more convincing to a reviewer than a perfect run, because it shows real engagement with the technology.

## Evidence to capture

Capture the request and approval pages, the group membership before and after, the review decisions and the applied results, the PIM activation prompts and active assignment lists, the approval email, the denied-action error messages, the KQL results, and the final governance report.

## Microsoft Learn references

- Request an access package in My Access: https://learn.microsoft.com/entra/id-governance/entitlement-management-request-access
- Complete an access review of groups: https://learn.microsoft.com/entra/id-governance/perform-access-review
- Activate Entra roles in PIM: https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-activate-role
- Approve or deny PIM requests: https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-approval-workflow
- Audit logs in Microsoft Entra: https://learn.microsoft.com/entra/identity/monitoring-health/concept-audit-logs
