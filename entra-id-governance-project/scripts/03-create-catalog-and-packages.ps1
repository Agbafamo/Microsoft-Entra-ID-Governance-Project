# Creates a catalog, adds a group resource, builds an access package and an internal policy.
# Entitlement management payloads are detailed; validate against the Graph docs for your tenant/SDK version:
# https://learn.microsoft.com/graph/api/resources/entitlementmanagement-overview
. "$PSScriptRoot/00-connect.ps1"
$base = "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement"
$post = { param($uri,$body) Invoke-MgGraphRequest -Method POST -Uri $uri -Body ($body | ConvertTo-Json -Depth 15) -ContentType "application/json" }

$group = Get-MgGroup -Filter "displayName eq 'GRP-Finance-Reporting-Readers'"
$staff = Get-MgGroup -Filter "displayName eq 'GRP-Finance-Staff'"

# 1. Catalog
$cat = & $post "$base/catalogs" @{ displayName="CAT-Finance"; description="Finance resources (portfolio lab)"; isExternallyVisible=$false }

# 2. Add the group to the catalog
& $post "$base/resourceRequests" @{
  requestType = "adminAdd"
  catalog  = @{ id = $cat.id }
  resource = @{ originId = $group.Id; originSystem = "AadGroup" }
} | Out-Null
Start-Sleep -Seconds 20

# 3. Access package
$ap = & $post "$base/accessPackages" @{
  displayName = "AP-Finance-Reporting-Standard"
  description = "Read access to finance reporting"
  catalog = @{ id = $cat.id }
}

# 4. Attach the group's Member role to the package
$res  = (Invoke-MgGraphRequest -Uri "$base/catalogs/$($cat.id)/resources?`$filter=originId eq '$($group.Id)'&`$expand=roles").value[0]
$role = $res.roles | Where-Object displayName -eq "Member"
& $post "$base/accessPackages/$($ap.id)/resourceRoleScopes" @{
  role  = @{ originId=$role.originId; displayName="Member"; originSystem="AadGroup"
             resource = @{ id=$res.id; originId=$group.Id; originSystem="AadGroup" } }
  scope = @{ originId=$group.Id; originSystem="AadGroup" }
} | Out-Null

# 5. Internal policy: Finance staff request, manager approves, 90 days, extendable
& $post "$base/assignmentPolicies" @{
  accessPackageId = $ap.id
  displayName     = "Finance staff - manager approval"
  description     = "Internal employees; 90 days"
  durationInDays  = 90
  canExtend       = $true
  requestorSettings = @{
    scopeType = "SpecificDirectorySubjects"; acceptRequests = $true
    allowedRequestors = @(@{ "@odata.type"="#microsoft.graph.groupMembers"; id=$staff.Id; description="Finance staff" })
  }
  requestApprovalSettings = @{
    isApprovalRequiredForAdd = $true; isApprovalRequiredForUpdate = $false
    stages = @(@{
      durationBeforeAutomaticDenial = "P7D"; isApproverJustificationRequired = $false; isEscalationEnabled = $false
      primaryApprovers = @(@{ "@odata.type"="#microsoft.graph.requestorManager"; managerLevel=1 })
    })
  }
} | Out-Null
Write-Host "Catalog, package and policy created. Review in My Access / Entra admin centre."
# Add the two-stage package (AP-IT-Helpdesk-Tooling) and the external policy by duplicating step 3-5 with
# a second stage (securityLead as approver) and requestorSettings.scopeType = "SpecificConnectedOrganizationSubjects".
