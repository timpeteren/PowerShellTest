#####################################################
#Client Credential Grant for AzureAD B2C
#####################################################

# Your Client ID and Client Secret obainted when registering your WebApp
$clientid = ''
$clientSecret = ''
$resource = 'https://graph.windows.net' 
$GrantType = "client_credentials"
$Uri = "https://login.microsoftonline.com/ws16b2c.onmicrosoft.com/oauth2/v2.0/token"
$scopeFormatted = "{0}" -f $resource

$Body = @{
    "grant_type" = $GrantType
    "client_id" = $clientid
    "scope" = $scopeFormatted
    "client_secret" = $clientSecret
}

$token = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType "application/x-www-form-urlencoded"
Write-Output $token.access_token

#####################################################
#Client Credential Grant for AzureAD
#####################################################

# Your Client ID and Client Secret obainted when registering your WebApp
$clientid = ''
$clientSecret = ''
$resource = 'https://graph.windows.net/'
$GrantType = "password"
$Uri = "https://login.microsoftonline.com/ws16b2c.onmicrosoft.com/oauth2/token"

$Body = @{
    "grant_type" = $GrantType
    "client_id" = $clientid
    "resource" = $resource
    "client_secret" = $clientSecret
    "username" = "globaladmin@ws16b2c.onmicrosoft.com"
    "password" = ""
}

$token = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType "application/x-www-form-urlencoded"
Write-Output $token

# ------------------NEXT STEP------------------

$AuthHeader = @{Authorization = "Bearer {0}" -f $token.access_token}
$UserObjectId = "f65af661-3c33-474f-a3df-eddeafeb7a3e"
$ApplicationObjectId = ""
$GraphUri = "https://graph.windows.net/ws16b2c.onmicrosoft.com/applications/{0}/extensionProperties?api-version=1.6" -f $ApplicationObjectId
$body = @{
    signInNames = @(
        @{
            type = "emailAddress"
            value = "tpe@gmail.com"
        },
        @{
            type = "userName"
            value = "53125"
        }
    )    
}

$GraphUri = "https://graph.windows.net/ws16b2c.onmicrosoft.com/users/{0}?api-version=1.6" -f $UserObjectId
$body = @{
    jobTitle = 'ElConsulente'
}

Invoke-RestMethod -Method Get -Uri $GraphUri  -Headers $AuthHeader -ContentType "application/json"

