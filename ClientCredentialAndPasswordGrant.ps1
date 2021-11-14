#####################################################
# Client Credential Grant for Azure AD B2C!!!!!!!!!!!
#####################################################

# Your Client ID and Client Secret obainted when registering your WebApp
$clientId = ''
$clientSecret = ''
$tenantName = '.onmicrosoft.com'
$resource = 'https://graph.windows.net' 
$grantType = "client_credentials"
$uri = "https://login.microsoftonline.com/{0}/oauth2/v2.0/token" -f $tenantName
$scopeFormatted = "{0}" -f $resource

$body = @{
    "grant_type" = $grantType
    "client_id" = $clientId
    "scope" = $scopeFormatted
    "client_secret" = $clientSecret
}

$token = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
Write-Output $token

#####################################################
# Password Grant for Azure AD v1 endpoint 
#####################################################

# Your Client ID and Client Secret obainted when registering your WebApp
$clientId = ''
$clientSecret = '' 
$tenantName = '.onmicrosoft.com'
$resource = 'https://graph.windows.net/'
$grantType = "password"
$username = "globaladmin@{0}" -f $tenantName
$password = ""
$uri = "https://login.microsoftonline.com/{0}/oauth2/token" -f $tenantName

$body = @{
    "grant_type" = $grantType
    "client_id" = $clientid
    "resource" = $resource
    "client_secret" = $clientSecret
    "username" = $username
    "password" = $password
}

$token = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
Write-Output $token

#####################################################
# Client Credential Grant for Azure AD v1 endpoint  #
#####################################################

# Your Client ID and Client Secret obainted when registering your WebApp
$clientId = ''
$clientSecret = ''
$tenantName = '.onmicrosoft.com'
$resource = 'https://graph.windows.net/'
$grantType = "client_credentials"
$uri = "https://login.microsoftonline.com/{0}/oauth2/token" -f $tenantName

$Body = @{
    "grant_type" = $grantType
    "client_id" = $clientId
    "resource" = $resource
    "client_secret" = $clientSecret
}

$token = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
Write-Output $token


# ------------------NEXT STEP, two examples, GET, POST and PATCH------------------ #

# List users in tenant example using -Method GET
$authHeader = @{Authorization = "Bearer {0}" -f $token.access_token}
$tenantName = '.onmicrosoft.com'
$graphUri = "https://graph.windows.net/{0}/users/?api-version=1.6" -f $tenantName

Invoke-RestMethod -Method Get -Uri $graphUri -Headers $authHeader -ContentType "application/json"


# Application schema extension example using -Method POST
$authHeader = @{Authorization = "Bearer {0}" -f $token.access_token}
$tenantName = '.onmicrosoft.com'
$applicationObjectId = ""
$graphUri = "https://graph.windows.net/{0}/applications/{1}/extensionProperties?api-version=1.6" -f $tenantName, $applicationObjectId
$body = @{
    name = 'newCustomAttribute'
    dataType = 'String'
    targetObjects = @("User")
}

Invoke-RestMethod -Method Post -Uri $graphUri -Body ($body | ConvertTo-Json) -Headers $authHeader -ContentType "application/json"


# Modify user attribute example using -Method PATCH
$authHeader = @{Authorization = "Bearer {0}" -f $token.access_token}
$tenantName = '.onmicrosoft.com'
$userObjectId = ""
$graphUri = "https://graph.windows.net/{0}/users/{1}/?api-version=1.6" -f $tenantName, $userObjectId

$body = @{
    signInNames = @(
        @{
            type = "emailAddress"
            value = "name@someMail.com"
        },
        @{
            type = "userName"
            value = "53125"
        }
    )    
}

Invoke-RestMethod -Method Patch -Uri $graphUri -Body ($body | ConvertTo-Json) -Headers $authHeader -ContentType "application/json"