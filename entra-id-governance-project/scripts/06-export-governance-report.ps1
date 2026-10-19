# Exports eligible/active role assignments, access package assignments and review definitions to CSV.
. "$PSScriptRoot/00-connect.ps1"
$out = "$PSScriptRoot/../output"; New-Item -ItemType Directory -Force $out | Out-Null

Get-MgRoleManagementDirectoryRoleEligibilitySchedule -All -ExpandProperty "principal,roleDefinition" |
  Select-Object @{n="Principal";e={$_.Principal.AdditionalProperties.userPrincipalName}}, @{n="Role";e={$_.RoleDefinition.DisplayName}}, StartDateTime, @{n="End";e={$_.ScheduleInfo.Expiration.EndDateTime}} |
  Export-Csv "$out/eligible-assignments.csv" -NoTypeInformation

Get-MgRoleManagementDirectoryRoleAssignmentSchedule -All -ExpandProperty "principal,roleDefinition" |
  Select-Object @{n="Principal";e={$_.Principal.AdditionalProperties.userPrincipalName}}, @{n="Role";e={$_.RoleDefinition.DisplayName}}, AssignmentType, StartDateTime |
  Export-Csv "$out/active-assignments.csv" -NoTypeInformation

(Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/assignments?`$expand=target,accessPackage&`$top=999").value |
  ForEach-Object { [pscustomobject]@{ User=$_.target.email; Package=$_.accessPackage.displayName; State=$_.state; Expires=$_.schedule.expiration.endDateTime } } |
  Export-Csv "$out/access-package-assignments.csv" -NoTypeInformation

(Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions").value |
  Select-Object displayName, status, createdDateTime | Export-Csv "$out/access-reviews.csv" -NoTypeInformation
Write-Host "Reports written to $out (do not commit real data)."
