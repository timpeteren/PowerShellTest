Connect-AzureAD

# whichever is easier or available, appName or appID

# appName
$app = Get-AzureADServicePrincipal -SearchString "GraphAPI-B2C-CRU-App"
$role = Get-AzureADDirectoryRole | Where-Object { $_.DisplayName -eq "Company Administrator" }
Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $app.ObjectId

# appID
$app = ""
$role = Get-AzureADDirectoryRole | Where-Object { $_.DisplayName -eq "Company Administrator" }
Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $app.ObjectId