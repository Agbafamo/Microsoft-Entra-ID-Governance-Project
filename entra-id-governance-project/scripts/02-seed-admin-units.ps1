# Creates a Sales administrative unit and adds Sales users to it.
. "$PSScriptRoot/00-connect.ps1"
$au = New-MgDirectoryAdministrativeUnit -DisplayName "AU-Sales" -Description "Scope for helpdesk password resets"
Get-MgUser -Filter "department eq 'Sales'" | ForEach-Object {
  New-MgDirectoryAdministrativeUnitMemberByRef -AdministrativeUnitId $au.Id `
    -BodyParameter @{ "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($_.Id)" }
}
