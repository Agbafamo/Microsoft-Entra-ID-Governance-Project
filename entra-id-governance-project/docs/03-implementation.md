# Phase 3: Implementation

## Overview

Implementation proceeds in five movements that mirror the architecture: directory foundations, entitlement management, access reviews, privileged identity management, and reporting. Each movement is described here as a narrative, with the scripts in the `scripts` folder providing the repeatable version of every portal step. Portal navigation changes regularly, so the descriptions refer to the feature names rather than exact menu paths.

## Movement one: users, groups, and administrative roles

The directory foundation begins with users. The script `01-create-users-groups.ps1` reads a CSV file of personas and creates each user with a generated temporary password, a department, a job title, and a manager relationship. The manager attribute matters, because it later drives approval routing in access packages. Security groups are then created for each department and for each resource that will be packaged, for example `GRP-Finance-Reporting-Readers`. Groups are assigned owners, because group ownership is what makes access reviews and catalog delegation workable.

Administrative role management is where the lab first departs from habit. Rather than assigning Helpdesk Administrator to Chidi directly, the design reserves the assignment for PIM, covered below. Administrative units are introduced to demonstrate scoping: Chidi's eventual User Administrator rights are limited to an administrative unit containing only Sales users, so that even an elevated helpdesk engineer cannot reset the password of a Finance manager or a security lead. This reflects least privilege in a way that role names alone cannot.

## Movement two: entitlement management and access packages

Entitlement management starts with a catalog, which is a container of resources and the unit of delegation. The catalog `CAT-Finance` is created, and the Finance reporting group is added as a resource. An access package, `AP-Finance-Reporting-Standard`, is then built around that resource. The package is given a policy that defines who may request it, who approves it, how long the access lasts, and whether the grant can be extended.

For the internal employee policy, the allowed requestors are members of the Finance department, the first-stage approver is the requestor's manager, and the access duration is ninety days with extension permitted. A justification is mandatory, because the justification becomes part of the evidence trail. For the external policy, the allowed requestors are users from a specific connected organisation, a sponsor is required to approve, access lasts thirty days, and the guest account is automatically removed from the directory a set period after losing their last package. This last setting is the one that prevents the accumulation of orphaned guest accounts, which is among the most common governance failures in real tenants.

A second package, `AP-IT-Helpdesk-Tooling`, uses two approval stages, manager then security lead, to demonstrate multi-stage approval. The scripts `03-create-catalog-and-packages.ps1` and the policy JSON in `scripts/policies` express the same configuration through Graph so that it can be reviewed in a pull request.

## Movement three: access reviews

Access reviews are the control that catches everything the earlier controls miss. Three reviews are configured. The first is a quarterly review of the Finance reporting group in which the reviewers are the group owners, justification is required on approval, recommendations are enabled so that reviewers see last sign-in information, and the default decision on non-response is Deny with decisions applied automatically. The second is a quarterly review of all guest users in the tenant, with the guest's sponsor or manager as reviewer, falling back to a designated security reviewer. The third is a monthly review of privileged role assignments, performed by the security lead, because privileged access deserves a faster cycle than ordinary access.

The choice to apply decisions automatically and to default to denial is deliberate and slightly uncomfortable. It means that a busy manager who ignores the review email will cause access to be removed, and someone will then complain. That complaint is the control working. The recurrence pattern, start date, and duration of each review are captured in `04-create-access-reviews.ps1`, which posts access review schedule definitions to the Graph API.

## Movement four: privileged identity management

PIM turns administrative roles from a standing state into an event. For each role in scope, the process has three parts: make users eligible rather than active, define the role settings, and test activation.

Eligibility is assigned for a bounded period, such as six months, so that even the eligibility expires and must be renewed. Role settings are then tuned according to risk. For Helpdesk Administrator, the maximum activation duration is four hours, MFA and a justification are required, and no approval is needed, since the role is limited and frequently used. For User Administrator, activation is limited to two hours with MFA, justification, and a ticket reference. For Global Administrator, the maximum is one hour, approval from the security lead is required, and notifications are sent to a monitored mailbox on every activation. The settings also disable permanent eligibility and permanent active assignment, closing the loophole where an administrator might simply be granted a permanent assignment through PIM itself.

The script `05-configure-pim.ps1` creates the eligibility schedule requests and updates the role management policy rules for expiration, enablement, and approval. Because the policy rule objects are verbose, the script wraps them in small helper functions. Alerts in PIM, such as roles assigned outside PIM or too many global administrators, are reviewed and the findings are recorded as evidence.

## Movement five: governance reporting and audit

Reporting converts the configuration into evidence. In the portal, the audit log is filtered by categories such as EntitlementManagement, AccessReviews, and RoleManagement to demonstrate that each event is recorded. In Log Analytics, saved KQL queries in `scripts/kql` show activations per user per week, access package requests and their outcomes, review decisions by reviewer, and any role assignment that bypassed PIM. The script `06-export-governance-report.ps1` produces a CSV and a summary document containing current eligible assignments, active assignments, access package assignments with expiry dates, and open access reviews. This report is the artefact a reader would hand to an auditor.

## Representative configuration

The following snippet shows the shape of an access review definition posted through Graph. It is representative rather than exhaustive, and the full version resides in the scripts folder.

```powershell
$body = @{
  displayName = "AR-Finance-Reporting-Quarterly"
  descriptionForAdmins = "Quarterly recertification of Finance reporting access"
  scope = @{ "@odata.type" = "#microsoft.graph.accessReviewQueryScope"
             query = "/groups/$groupId/transitiveMembers"; queryType = "MicrosoftGraph" }
  reviewers = @(@{ query = "/groups/$groupId/owners"; queryType = "MicrosoftGraph" })
  settings = @{
    mailNotificationsEnabled = $true
    reminderNotificationsEnabled = $true
    justificationRequiredOnApproval = $true
    defaultDecisionEnabled = $true
    defaultDecision = "Deny"
    instanceDurationInDays = 14
    autoApplyDecisionsEnabled = $true
    recommendationsEnabled = $true
    recurrence = @{
      pattern = @{ type = "absoluteMonthly"; interval = 3 }
      range   = @{ type = "noEnd"; startDate = "2026-11-02" }
    }
  }
} | ConvertTo-Json -Depth 10
Invoke-MgGraphRequest -Method POST `
  -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions" `
  -Body $body -ContentType "application/json"
```

## Evidence to capture in this phase

For each movement the author captures the configuration screens and the resulting objects: the user and group lists with owners, the catalog and access package policy pages showing approvers and expiry, the three access review definitions, the PIM eligible assignment list, the role settings for each configured role, and the exported governance report. Screenshots should be annotated with a short caption naming the control and the requirement it satisfies.

## Microsoft Learn references

- Create and manage users: https://learn.microsoft.com/entra/fundamentals/how-to-create-delete-users
- Administrative units: https://learn.microsoft.com/entra/identity/role-based-access-control/administrative-units
- Create a catalog: https://learn.microsoft.com/entra/id-governance/entitlement-management-catalog-create
- Create an access package: https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-create
- Create an access review of groups: https://learn.microsoft.com/entra/id-governance/create-access-review
- Configure Entra role settings in PIM: https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings
- Assign Entra roles in PIM: https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-add-role-to-user
- Graph API for access reviews: https://learn.microsoft.com/graph/api/resources/accessreviewsv2-overview
