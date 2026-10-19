# Connect to Microsoft Graph with the scopes needed for the lab (lab tenant only).
Connect-MgGraph -Scopes @(
  "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All",
  "RoleManagement.ReadWrite.Directory","EntitlementManagement.ReadWrite.All",
  "AccessReview.ReadWrite.All","AuditLog.Read.All","AdministrativeUnit.ReadWrite.All",
  "Policy.ReadWrite.ConditionalAccess"
)
Get-MgContext | Select-Object TenantId, Account, Scopes
