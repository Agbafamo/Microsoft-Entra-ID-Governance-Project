# Quarterly access review of the Finance reporting group; owners review; default deny; auto-apply.
. "$PSScriptRoot/00-connect.ps1"
$groupId = (Get-MgGroup -Filter "displayName eq 'GRP-Finance-Reporting-Readers'").Id
$body = @{
  displayName = "AR-Finance-Reporting-Quarterly"
  descriptionForAdmins = "Quarterly recertification of Finance reporting access"
  scope = @{ "@odata.type"="#microsoft.graph.accessReviewQueryScope"; query="/groups/$groupId/transitiveMembers"; queryType="MicrosoftGraph" }
  reviewers = @(@{ query="/groups/$groupId/owners"; queryType="MicrosoftGraph" })
  settings = @{
    mailNotificationsEnabled=$true; reminderNotificationsEnabled=$true
    justificationRequiredOnApproval=$true; defaultDecisionEnabled=$true; defaultDecision="Deny"
    instanceDurationInDays=14; autoApplyDecisionsEnabled=$true; recommendationsEnabled=$true
    recurrence = @{ pattern=@{ type="absoluteMonthly"; interval=3 }; range=@{ type="noEnd"; startDate=(Get-Date).AddDays(1).ToString("yyyy-MM-dd") } }
  }
} | ConvertTo-Json -Depth 10
Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions" -Body $body -ContentType "application/json"

# Guest review (all guests, quarterly) - reviewers: guest's manager/sponsor with fallback reviewer
$guest = @{
  displayName = "AR-Guests-Quarterly"
  scope = @{ "@odata.type"="#microsoft.graph.accessReviewQueryScope"
             query="./members/microsoft.graph.user/?`$filter=(userType eq 'Guest')"; queryType="MicrosoftGraph" }
  instanceEnumerationScope = @{ "@odata.type"="#microsoft.graph.accessReviewQueryScope"
             query="/groups?`$filter=(groupTypes/any(c:c eq 'Unified'))"; queryType="MicrosoftGraph" }
  reviewers = @(@{ query="/groups/$((Get-MgGroup -Filter "displayName eq 'GRP-Security-Reviewers'").Id)/members"; queryType="MicrosoftGraph" })
  settings = @{ defaultDecisionEnabled=$true; defaultDecision="Deny"; autoApplyDecisionsEnabled=$true
                justificationRequiredOnApproval=$true; instanceDurationInDays=14
                recurrence=@{ pattern=@{ type="absoluteMonthly"; interval=3 }; range=@{ type="noEnd"; startDate=(Get-Date).AddDays(1).ToString("yyyy-MM-dd") } } }
} | ConvertTo-Json -Depth 10
# Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions" -Body $guest -ContentType "application/json"
# (Uncomment after validating the guest-scope query in your tenant. Privileged-role review: use the PIM
#  access review scope: /identityGovernance/accessReviews/... with query "/roleManagement/directory/roleAssignmentScheduleInstances".)
