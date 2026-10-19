# Phase 1: Requirements and Architecture

## Objectives and expected outcomes

The central objective of this project is to demonstrate that identity governance is a set of enforceable, testable controls rather than a policy document. A fictional company, Contoso Lab, is used as the scenario. It has employees in Finance, IT, and Sales, uses external contractors and partners as guest users, and has administrators whose standing privileges represent the largest single risk in the tenant. The governance programme must answer four questions that every auditor eventually asks. Who has access? Why do they have it? Who approved it? When does it end?

From that framing come five measurable outcomes. Every privileged directory role must be assigned as eligible through Privileged Identity Management, with the sole exception of two emergency access accounts. Every business application and group must be reachable only through an access package with a defined approver, expiry, and review cycle. Every guest account must have a sponsor and must be recertified at least quarterly, with unreviewed access removed automatically. Every elevation to a privileged role must require MFA, a written justification, and, for the most sensitive roles, a second person's approval. Finally, the audit trail for all of these events must be exportable and must tell a coherent story from request to removal.

## Scope

The project is limited to the cloud-side governance plane of Microsoft Entra ID: user, group, and role administration, Entitlement Management, Access Reviews, Privileged Identity Management, and audit reporting. Conditional Access is touched only where PIM can require it through authentication context. Hybrid synchronisation with on-premises Active Directory and risk-based protection through Entra ID Protection are deliberately excluded here so that this module stays focused, but the design leaves room for them. Groups, for instance, are cloud-only in this lab, and the naming conventions are chosen so that synchronised groups could be slotted in later.

## Licensing and prerequisites in principle

Governance features are licence-gated, and understanding that is part of the exercise. Privileged Identity Management and Access Reviews have historically required Microsoft Entra ID P2, while Entitlement Management and the more advanced lifecycle capabilities are associated with P2 or the Microsoft Entra ID Governance add-on. Microsoft has revised these boundaries more than once, so the authoritative reference is the licensing page for Entra ID Governance on Microsoft Learn, which should be checked at the time of building. A trial tenant with P2 and Governance trial licences assigned to the lab users is sufficient. Guest-user billing in Entra is based on monthly active users, so the small guest population in this lab is not a cost concern.

## Roles and personas

Six personas make the scenario concrete. Alice Okafor is a Finance analyst who requests access to the Finance reporting package. Bola Adeyemi is the Finance manager who approves it. Chidi Eze is an IT helpdesk engineer who needs temporary User Administrator rights to reset accounts. Dara Lawal is the security lead who acts as second approver for privileged roles. Emeka Contractor is an external guest from a partner company, invited through entitlement management. A lab administrator, who is the project author, holds the Global Administrator role only through eligibility, and two break-glass accounts sit outside the normal controls with strong, vaulted credentials and alerting on any sign-in.

## Architecture

The architecture has four layers. At the foundation is the directory itself, containing users, security groups, and administrative units. Above it sits the access layer, in which Entitlement Management catalogues hold resources and access packages expose them through policies. Next is the privilege layer, where PIM governs both Microsoft Entra roles and, optionally, privileged group membership. Wrapped around all of these is the assurance layer, consisting of Access Reviews that continually challenge existing access, and the audit and reporting pipeline that preserves evidence.

Data flows through the design in a consistent pattern. A person requests an access package. The policy routes the request to the manager, and optionally a second approver. On approval, the platform adds the person to the groups in the package for a fixed duration. As the expiry approaches, the person is notified and may request an extension. Independently, a recurring access review asks the reviewers to confirm or deny continued need. Every one of those steps writes to the Entra audit log, which is streamed to a Log Analytics workspace so that it can be queried with KQL and retained beyond the default window. Privileged roles follow a parallel path: an eligible user activates a role in PIM, satisfies MFA and justification requirements, waits for approval where configured, receives the role for a limited number of hours, and loses it automatically.

## Design decisions and their reasoning

Several decisions deserve explanation. Access is granted to groups, never directly to users, because groups can be reviewed and packaged and because direct assignments scatter evidence. Groups are named with a predictable convention such as `GRP-Finance-Reporting-Readers`, so that reviewers can interpret them without a lookup. Catalogs are separated by business function so that delegated catalog owners, rather than global administrators, manage their own resources. Activation durations are kept short, typically one to four hours, because the purpose of just-in-time access is to shrink the window of exposure. Approval is reserved for the highest-impact roles, since requiring it everywhere trains approvers to click without reading. Reviews default to denial when reviewers do not respond, because a governance process that silently preserves access when people are busy is not a control.

## Success criteria

The project is complete when each outcome above has a corresponding validation test in Phase 4, each test has captured evidence in the `evidence` folder, and an independent reader could reproduce the lab from the documentation alone.

## Microsoft Learn references

- What is Microsoft Entra ID Governance: https://learn.microsoft.com/entra/id-governance/identity-governance-overview
- Microsoft Entra ID Governance licensing fundamentals: https://learn.microsoft.com/entra/id-governance/licensing-fundamentals
- Plan a Privileged Identity Management deployment: https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-deployment-plan
- Entitlement management overview: https://learn.microsoft.com/entra/id-governance/entitlement-management-overview
- Access reviews overview: https://learn.microsoft.com/entra/id-governance/access-reviews-overview
- Emergency access accounts: https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access
