# Phase 7: Documentation and GitHub Publication

## Publishing as a professional act

A portfolio repository is read by hiring managers, clients, and peers who have only a few minutes. It should therefore communicate the purpose of the project, the quality of the engineering, and the care taken over safety within the first screen of the README. Publication is also a security activity, because a governance project can easily leak tenant identifiers, email addresses, or credentials through screenshots and scripts. This essay covers how to prepare, sanitise, and release the repository.

## Preparing the repository

The folder is initialised as a Git repository, and a `.gitignore` is created before the first commit so that secrets and local artefacts never enter history. It should exclude `*.pfx`, `*.pem`, `*.key`, `.env`, local CSV exports that contain real addresses, and any `output` directory. The user CSV in the repository should contain only fictional people on a domain the author controls or on a clearly synthetic domain. Commit messages should be meaningful, and the commit history should show the work in phases, which reinforces the narrative of the essays.

A recommended sequence of commits follows the phases: initial structure and README, requirements and architecture, lab setup and scripts one and two, entitlement management, access reviews, PIM, validation evidence, and troubleshooting and lessons. This pattern gives readers a visible build story.

## Sanitising evidence

Before any screenshot is committed, the author checks it for tenant IDs, subscription IDs, object IDs, real email addresses, IP addresses, and any token or secret. Redaction should use solid blocks rather than blur, since blur can sometimes be reversed. Screenshots are named by test ID and compressed to a reasonable size. Exported CSV and JSON evidence is reviewed line by line, or better still, produced from the synthetic lab tenant only. A secret scanner such as Gitleaks or GitHub's own secret scanning is run before the first push, and if a secret is ever committed, the correct response is to rotate it immediately, since deleting the commit does not undo exposure.

## Writing the README

The README is the front door. It should open with a two-sentence statement of what the project demonstrates, followed by the scope, the architecture overview, and a pointer to the essays in reading order. A diagram of the architecture, exported as an image and stored in the repository, helps because many readers will scan before they read. A brief section stating the skills demonstrated, such as identity governance design, PIM configuration, Graph automation, KQL analysis, and compliance mapping, helps recruiters and clients locate relevance quickly. The README should also state limitations honestly, which signals maturity.

## Repository settings and discoverability

The repository is given a clear name such as `entra-id-governance-lab`, a concise description, and topics including `microsoft-entra`, `identity-governance`, `pim`, `access-reviews`, `entitlement-management`, `zero-trust`, and `powershell`. Branch protection is not essential for a personal project, though enabling it demonstrates good practice. A licence file, typically MIT for scripts with a note that documentation is for educational use, clarifies reuse. Pinning the repository on the author's GitHub profile and linking it from the professional profile and the Techadem materials extends its reach, and a short write-up or post summarising the lessons learned will typically reach more readers than the repository alone.

## The release commands

The following commands show the minimal publishing flow once the GitHub repository has been created in the browser.

```bash
cd entra-id-governance-project
git init
git add .
git commit -m "Initial structure and README"
git branch -M main
git remote add origin https://github.com/<your-username>/entra-id-governance-lab.git
git push -u origin main
```

Subsequent commits should be made phase by phase as described earlier, and a tagged release such as `v1.0` can mark the completed project.

## Maintaining the project

Governance guidance ages quickly, so a short changelog and a line in the README stating the date the lab was last validated against current Microsoft documentation protect the repository's credibility. Issues can be left open for suggested improvements, and the planned companion modules for Entra ID Protection and hybrid identity with on-premises Active Directory can be tracked in a roadmap section, which turns a single project into the beginning of a body of work.

## Microsoft Learn and external references

- Microsoft Graph PowerShell SDK documentation: https://learn.microsoft.com/powershell/microsoftgraph/overview
- GitHub documentation on repositories and secret scanning: https://docs.github.com/code-security/secret-scanning/introduction/about-secret-scanning
- Microsoft Entra documentation hub: https://learn.microsoft.com/entra/
