# Phase 6: Security Considerations, Limitations, and Lessons Learned

## Security considerations in the design

The first consideration is that governance tooling is itself a high-value target. The roles that administer PIM, Entitlement Management, and Access Reviews can grant or remove access to everything else, so these roles, notably Privileged Role Administrator and Identity Governance Administrator, deserve the same protection as Global Administrator. In this lab they are eligible-only, require MFA, and generate notifications, and in production they would additionally sit behind phishing-resistant authentication and a Conditional Access authentication context.

The second consideration is the emergency access accounts. They are an intentional exception to the model, which means they are an attractive target. Their credentials must be long, stored offline, split between custodians where possible, and monitored with an alert on any use. They should be tested on a schedule and the test recorded, because an untested break-glass account is a false comfort.

The third consideration is separation of duties. A person who requests access should not approve it, and an administrator who configures a review should not be its only reviewer. The lab approximates this with distinct personas, but a real deployment should encode these rules in the policies and verify them with periodic reports. Entitlement Management also supports incompatible access packages, which prevent a person from holding two packages whose combination creates fraud risk, and this would be a valuable extension.

The fourth consideration is automation identity. Scripts that call Graph with broad delegated scopes are convenient in a lab but dangerous in operation. A production implementation would use an app registration or managed identity with only the application permissions needed, certificate or federated credentials in place of secrets, and its own review cycle.

The fifth consideration is data handling. Audit logs contain names, email addresses, and justifications. They should be retained according to the organisation's policy, and where regulations such as NDPR or GDPR apply, the retention period and access to the logs should be documented as part of the compliance story.

## Limitations of the project

The lab is intentionally small. It does not demonstrate scale behaviours such as reviewing thousands of memberships, where reviewer fatigue becomes the dominant risk. It uses synthetic users, so the human factors of approval and review, including delays, rubber-stamping, and disputes, are only imagined. Cloud-only groups simplify the picture, since real organisations often have synchronised groups whose membership is managed on premises and therefore cannot be modified by entitlement management in the same way. Trial licences limit the duration of the lab, so the evidence represents a point in time. The lab covers Microsoft Entra roles and group membership, but not Azure resource roles, application-specific roles, or Lifecycle Workflows for joiner, mover, and leaver automation, all of which would be strong next steps. Finally, portal screens and licensing terms change, so some details will age, which is why the documentation links to Microsoft Learn rather than reproducing it.

## Lessons learned

Several lessons emerged that are worth stating plainly. The most important is that governance is a design problem before it is a configuration problem. The settings are simple. Deciding who the reviewers are, how long access should last, and which roles need approval is difficult, and a poorly designed policy configured perfectly is still a poor policy.

A second lesson is that defaults matter more than features. The decision that a review defaults to denial, that eligibility expires, and that permanent assignment is disabled does more to reduce risk than any single advanced capability, because defaults determine what happens when people are busy.

A third lesson is that group ownership is the quiet foundation of everything. Entitlement management, delegation, and access reviews all become awkward when groups have no owners, so assigning owners at creation time should be treated as mandatory.

A fourth lesson is that evidence is a product. Capturing screenshots and exports as the work happens is far easier than reconstructing them, and the habit of tying each piece of evidence to a requirement turns a lab into an argument.

A final lesson concerns friction. Every control adds friction for someone, and controls that are too heavy get bypassed. Reserving approval for the roles that truly warrant it, keeping activation simple for low-risk roles, and explaining the reasons to users are what keep a governance programme alive over time.

## Recommendations for production

A production rollout should begin with discovery, since the first review in a real tenant will uncover years of accumulated access. It should proceed role by role, converting the most privileged assignments to eligible first, and should measure outcomes such as the number of standing privileged assignments, the percentage of guests with sponsors, review completion rates, and the average time to approve a request. It should align with frameworks such as ISO 27001 Annex A access control requirements, NIST SP 800-53 access control families, and Zero Trust principles, and it should be reviewed on a regular cadence.

## Microsoft Learn references

- Secure privileged access in Entra: https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-deployment
- Incompatible access packages: https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-incompatible
- Lifecycle Workflows overview: https://learn.microsoft.com/entra/id-governance/what-are-lifecycle-workflows
- Best practices for Entra roles: https://learn.microsoft.com/entra/identity/role-based-access-control/best-practices
- Zero Trust identity guidance: https://learn.microsoft.com/security/zero-trust/deploy/identity
