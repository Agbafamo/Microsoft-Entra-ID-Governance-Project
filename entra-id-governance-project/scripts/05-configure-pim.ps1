# Makes users ELIGIBLE (not active) for roles and tightens role settings.
. "$PSScriptRoot/00-connect.ps1"

$roles = @{
  HelpdeskAdmin = "729827e3-9c14-49f7-bb1b-9608f156bbb8"
  UserAdmin     = "fe930be7-5e62-47db-91af-98c3a49a38b1"
  GlobalAdmin   = "62e90394-69f5-4237-9190-012177145e10"
}

function New-Eligibility($upn,$roleId,$months=6) {
  $u = Get-MgUser -Filter "userPrincipalName eq '$upn'"
  New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter @{
    action="adminAssign"; justification="Portfolio lab eligibility"
    roleDefinitionId=$roleId; directoryScopeId="/"; principalId=$u.Id
    scheduleInfo=@{ startDateTime=(Get-Date).ToUniversalTime().ToString("o")
                    expiration=@{ type="afterDateTime"; endDateTime=(Get-Date).AddMonths($months).ToUniversalTime().ToString("o") } }
  }
}

function Set-PimRoleSettings($roleId,$maxDuration,$requireApproval=$false,$approverId=$null) {
  $assign = Get-MgPolicyRoleManagementPolicyAssignment -Filter "scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '$roleId'"
  $policyId = $assign.PolicyId
  $target = @{ caller="EndUser"; operations=@("all"); level="Assignment"; inheritableSettings=@(); enforcedSettings=@() }

  Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $policyId -UnifiedRoleManagementPolicyRuleId "Expiration_EndUser_Assignment" -BodyParameter @{
    "@odata.type"="#microsoft.graph.unifiedRoleManagementPolicyExpirationRule"; id="Expiration_EndUser_Assignment"
    isExpirationRequired=$true; maximumDuration=$maxDuration; target=$target }

  Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $policyId -UnifiedRoleManagementPolicyRuleId "Enablement_EndUser_Assignment" -BodyParameter @{
    "@odata.type"="#microsoft.graph.unifiedRoleManagementPolicyEnablementRule"; id="Enablement_EndUser_Assignment"
    enabledRules=@("MultiFactorAuthentication","Justification","Ticketing"); target=$target }

  Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $policyId -UnifiedRoleManagementPolicyRuleId "Expiration_Admin_Eligibility" -BodyParameter @{
    "@odata.type"="#microsoft.graph.unifiedRoleManagementPolicyExpirationRule"; id="Expiration_Admin_Eligibility"
    isExpirationRequired=$true; maximumDuration="P180D"
    target=@{ caller="Admin"; operations=@("all"); level="Eligibility"; inheritableSettings=@(); enforcedSettings=@() } }

  if ($requireApproval) {
    Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $policyId -UnifiedRoleManagementPolicyRuleId "Approval_EndUser_Assignment" -BodyParameter @{
      "@odata.type"="#microsoft.graph.unifiedRoleManagementPolicyApprovalRule"; id="Approval_EndUser_Assignment"; target=$target
      setting=@{ isApprovalRequired=$true; isApprovalRequiredForExtension=$false; isRequestorJustificationRequired=$true
                 approvalMode="SingleStage"
                 approvalStages=@(@{ approvalStageTimeOutInDays=1; isApproverJustificationRequired=$true; escalationTimeInMinutes=0
                                     primaryApprovers=@(@{ "@odata.type"="#microsoft.graph.singleUser"; userId=$approverId }) }) } }
  }
}

$tenant = (Get-MgContext).Account.Split('@')[1]
New-Eligibility "chidi.eze@$tenant" $roles.HelpdeskAdmin
New-Eligibility "chidi.eze@$tenant" $roles.UserAdmin
Set-PimRoleSettings $roles.HelpdeskAdmin "PT4H"
Set-PimRoleSettings $roles.UserAdmin     "PT2H"
$dara = (Get-MgUser -Filter "userPrincipalName eq 'dara.lawal@$tenant'").Id
Set-PimRoleSettings $roles.GlobalAdmin   "PT1H" $true $dara
# Note: replace $tenant above with your lab domain if your admin UPN uses a different suffix.
# Review: https://learn.microsoft.com/graph/api/resources/privilegedidentitymanagementv3-overview
