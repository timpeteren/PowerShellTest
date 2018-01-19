Connect-AzureAD

# whichever is easier or available, appName or appID

# appName
$app = Get-AzureADServicePrincipal -SearchString "GraphAPI-B2C-CRU-App"
$role = Get-AzureADDirectoryRole | Where-Object { $_.DisplayName -eq "Company Administrator" }
Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $app.ObjectId

# appID
$app = "37e91fb7-2bf2-4087-8c5c-02b23f670d1a"
$role = Get-AzureADDirectoryRole | Where-Object { $_.DisplayName -eq "Company Administrator" }
Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $app.ObjectId