# Creates lab personas, departmental groups and resource groups. Lab tenant only.
. "$PSScriptRoot/00-connect.ps1"
$users = Import-Csv "$PSScriptRoot/data/users.csv"

foreach ($u in $users) {
  if (Get-MgUser -Filter "userPrincipalName eq '$($u.UserPrincipalName)'" -ErrorAction SilentlyContinue) { continue }
  $pwd = -join ((48..57)+(65..90)+(97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
  New-MgUser -DisplayName $u.DisplayName -UserPrincipalName $u.UserPrincipalName `
    -MailNickname ($u.UserPrincipalName.Split('@')[0]) -Department $u.Department `
    -JobTitle $u.JobTitle -AccountEnabled `
    -PasswordProfile @{ Password = $pwd; ForceChangePasswordNextSignIn = $true } | Out-Null
  Write-Host "Created $($u.UserPrincipalName)"   # Do not log passwords.
}

# Set manager relationships (drives approval routing)
foreach ($u in $users | Where-Object Manager) {
  $user = Get-MgUser -Filter "userPrincipalName eq '$($u.UserPrincipalName)'"
  $mgr  = Get-MgUser -Filter "userPrincipalName eq '$($u.Manager)'"
  Set-MgUserManagerByRef -UserId $user.Id -BodyParameter @{ "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($mgr.Id)" }
}

$groups = "GRP-Finance-Reporting-Readers","GRP-IT-Helpdesk-Tooling","GRP-Finance-Staff","GRP-Security-Reviewers"
$owner  = (Get-MgUser -Filter "userPrincipalName eq '$($users[1].UserPrincipalName)'").Id
foreach ($g in $groups) {
  if (Get-MgGroup -Filter "displayName eq '$g'") { continue }
  $grp = New-MgGroup -DisplayName $g -MailEnabled:$false -MailNickname $g.ToLower() -SecurityEnabled `
    -Description "Entra governance portfolio project"
  New-MgGroupOwnerByRef -GroupId $grp.Id -BodyParameter @{ "@odata.id" = "https://graph.microsoft.com/v1.0/users/$owner" }
}
