# Microsoft Entra ID Governance: A Hands-On Identity Security Portfolio Project

## Introduction

This repository documents the design, implementation, testing, and publication of a hands-on Microsoft Entra ID Governance lab. The project treats identity as the primary security perimeter and shows how an organisation can control who has access to what, for how long, and with what evidence. It was built as a professional portfolio piece, which means every claim in the documentation is backed by a configuration, a script, a test, or a captured piece of evidence rather than by theory alone.

The lab covers five connected capabilities. The first is the lifecycle management of users, groups, and administrative roles. The second is Entitlement Management, where access packages bundle the groups, applications, and sites a person needs and make them requestable, approvable, and expirable. The third is Access Reviews, which force periodic recertification so that access does not outlive its justification. The fourth is Privileged Identity Management, which converts standing administrative privilege into just-in-time, approval-gated, time-boxed elevation. The fifth is governance reporting, in which audit logs and exported evidence prove that the controls operate as designed.

## How to read this repository

The documentation is written as a sequence of essays rather than a checklist, because governance decisions are judgement calls and the reasoning matters as much as the clicks. The essays follow the project phases in order. Start with `docs/01-requirements-and-architecture.md`, which sets objectives, scope, licensing, and the design of the lab tenant. Continue with `docs/02-lab-setup.md` for prerequisites and environment preparation, then `docs/03-implementation.md` for the step-by-step build. `docs/04-security-testing-and-validation.md` explains how each control was attacked and verified, and `docs/05-troubleshooting.md` records the errors encountered and how they were resolved. `docs/06-security-considerations-and-lessons-learned.md` is an honest reflection on limitations and what would change in production, and `docs/07-github-publication.md` describes how to publish the work cleanly and safely.

## Repository layout

The `docs` folder holds the essays. The `scripts` folder holds PowerShell automation built on the Microsoft Graph PowerShell SDK, numbered in the order they should be run. The `evidence` folder holds screenshots and exported reports, named to match the validation tests in essay four.

## Expected outcomes

After completing the project, a reader should be able to demonstrate a tenant where every administrative role is eligible rather than permanent, where new joiners and contractors obtain access only through approved access packages, where guest and privileged access is recertified on a schedule with automatic removal of unreviewed access, and where an auditor can be handed a log export that traces any access decision from request to expiry. Just as importantly, the author can explain the design trade-offs behind each of these outcomes in an interview or client workshop.

## A note on scope and safety

This project runs in a dedicated lab tenant with synthetic identities only. No production tenant, real employee data, or client information appears anywhere in the repository. Tenant identifiers, domain names, and object IDs are redacted in screenshots, and no secrets are committed. The hybrid identity integration with on-premises Active Directory and the Entra ID Protection capabilities are natural extensions and are intended as companion modules in the same repository structure.

## Licence and disclaimer

The material is provided for educational purposes. Licensing requirements and portal layouts change frequently, so always verify against the linked Microsoft Learn pages before reproducing the lab.
