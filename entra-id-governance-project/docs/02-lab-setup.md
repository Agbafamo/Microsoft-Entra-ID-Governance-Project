# Phase 2: Lab Setup

## Why the lab environment matters

A governance lab is only credible if it is isolated, repeatable, and safe to break. The first rule is that the lab never touches a production tenant. Governance controls can lock administrators out, remove access in bulk, and send notification emails to real people, so experimenting in a live environment is reckless. The second rule is that the lab must be reproducible. Everything that can be scripted is scripted, so that the tenant can be rebuilt in an hour if it is damaged or if a trial expires.

## Prerequisites

The project needs a dedicated Microsoft Entra tenant, which can be created from a free Azure account or obtained through the Microsoft 365 Developer Program where eligible. Because the controls under test are licence-gated, the tenant needs Microsoft Entra ID P2 and Microsoft Entra ID Governance trial licences, which can be activated from the Licenses blade in the Entra admin centre. A custom domain is not required, since the default `onmicrosoft.com` domain is sufficient, but a mailbox that can receive messages for the guest persona is essential, and a free consumer or alias mailbox works well.

On the workstation, the author needs PowerShell 7 or later, the Microsoft Graph PowerShell SDK, Git, Visual Studio Code, and a screenshot tool with annotation support. An optional Azure subscription is used for the Log Analytics workspace that retains audit logs. Estimated cost is minimal if the workspace is kept small and deleted after testing.

## Preparing the tenant

The first task is to create a lab administrator, separate from any personal or work account, and to protect it with MFA. Next, two emergency access accounts are created with long random passwords stored offline, excluded from any future Conditional Access policies, and monitored by an alert that fires on every sign-in. These accounts are the only permanent Global Administrators and their existence is documented, because a governance project that locks out its own administrator has failed in an embarrassing way.

Security defaults should be reviewed. In a fresh tenant they enforce MFA registration, which is useful here because PIM activation will rely on MFA. If Conditional Access policies are introduced later, security defaults must be disabled first, since the two cannot coexist.

## Installing and connecting the tooling

The Graph SDK is installed from the PowerShell Gallery. The following commands install the modules used by the scripts and connect with the minimum scopes required for the lab. The scopes are broad because the lab administrator is configuring everything, and that breadth is itself a lesson: in production, automation should use a scoped service principal with certificate authentication rather than delegated administrator rights.

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Connect-MgGraph -Scopes @(
  "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All",
  "RoleManagement.ReadWrite.Directory","EntitlementManagement.ReadWrite.All",
  "AccessReview.ReadWrite.All","AuditLog.Read.All","Policy.ReadWrite.PermissionGrant"
)
Get-MgContext
```

The `Get-MgContext` call confirms the tenant and the scopes granted. Admin consent for these scopes will be requested the first time they are used, and that consent prompt should be captured as evidence.

## Seeding the directory

Scripts `01-create-users-groups.ps1` and `02-seed-admin-units.ps1` create the personas, the departmental security groups, and optional administrative units. Using a CSV file as the source keeps the process auditable and repeatable. After running them, the author verifies in the portal that the expected number of users and groups exist, and exports the user list as the baseline evidence for the lab.

## Audit log streaming

To keep evidence beyond the default retention window and to enable KQL queries, a Log Analytics workspace is created in a dedicated resource group, and the diagnostic setting for Entra audit and sign-in logs is configured to send data to it. This requires a role such as Security Administrator on the tenant and Contributor on the subscription. Once configured, a short wait is normal before data appears. The tables of interest are `AuditLogs` and `SigninLogs`.

## Naming, tagging, and housekeeping

Consistent names make later reviews meaningful. Groups follow `GRP-<Department>-<Purpose>`, catalogs follow `CAT-<Function>`, access packages follow `AP-<Resource>-<Level>`, and review definitions follow `AR-<Scope>-<Cadence>`. Everything created by the lab carries a description stating that it belongs to the portfolio project, so that cleanup is straightforward.

## Evidence to capture in this phase

The author captures the tenant overview with identifiers redacted, the licences assigned, the emergency access accounts with credentials obscured, the Graph connection context, the seeded user and group lists, and the diagnostic setting that streams logs to Log Analytics.

## Microsoft Learn references

- Install the Microsoft Graph PowerShell SDK: https://learn.microsoft.com/powershell/microsoftgraph/installation
- Create a development tenant: https://learn.microsoft.com/entra/identity-platform/quickstart-create-new-tenant
- Manage emergency access accounts: https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access
- Integrate Entra logs with Azure Monitor: https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs
- Security defaults: https://learn.microsoft.com/entra/fundamentals/security-defaults
