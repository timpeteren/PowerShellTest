#####################################################
# Client Credential Grant for Azure AD B2C!!!!!!!!!!!
#####################################################

# Your Client ID and Client Secret obainted when registering your WebApp
$clientid = ''
$clientSecret = ''
$TenantName = '.onmicrosoft.com'
$resource = 'https://graph.windows.net' 
$GrantType = "client_credentials"
$Uri = "https://login.microsoftonline.com/{0}/oauth2/v2.0/token" -f $TenantName
$scopeFormatted = "{0}" -f $resource

$Body = @{
    "grant_type" = $GrantType
    "client_id" = $clientid
    "scope" = $scopeFormatted
    "client_secret" = $clientSecret
}

$token = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType "application/x-www-form-urlencoded"
Write-Output $token

#####################################################
# Password Grant for Azure AD v1 endpoint 
#####################################################

# Your Client ID and Client Secret obainted when registering your WebApp
$clientid = '' # 37e91fb7-2bf2-4087-8c5c-02b23f670d1a # GraphAPI-CRU-App
$clientSecret = '' 
$TenantName = '.onmicrosoft.com' # laerdalmedicalb2ctest
$resource = 'https://graph.windows.net/'
$GrantType = "password"
$username = "admin@{0}" -f $TenantName
$password = "xxxxxxxxx"
$Uri = "https://login.microsoftonline.com/{0}/oauth2/token" -f $TenantName

$Body = @{
    "grant_type" = $GrantType
    "client_id" = $clientid
    "resource" = $resource
    "client_secret" = $clientSecret
    "username" = $username
    "password" = $password
}

$token = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType "application/x-www-form-urlencoded"
Write-Output $token

#####################################################
# Client Credential Grant for Azure AD v1 endpoint  #
#####################################################

# Your Client ID and Client Secret obainted when registering your WebApp
$clientid = '' # 37e91fb7-2bf2-4087-8c5c-02b23f670d1a # GraphAPI-CRU-App
$clientSecret = ''
$TenantName = '.onmicrosoft.com' # laerdalmedicalb2ctest
$resource = 'https://graph.windows.net/'
$GrantType = "client_credentials"
$Uri = "https://login.microsoftonline.com/{0}/oauth2/token" -f $TenantName

$Body = @{
    "grant_type" = $GrantType
    "client_id" = $clientid
    "resource" = $resource
    "client_secret" = $clientSecret
}

$token = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType "application/x-www-form-urlencoded"
Write-Output $token


# ------------------NEXT STEP, two examples, GET, POST and PATCH------------------ #

# List users in tenant example using -Method GET
$AuthHeader = @{Authorization = "Bearer {0}" -f $token.access_token}
$TenantName = '.onmicrosoft.com' # laerdalmedicalb2ctest
$GraphUri = "https://graph.windows.net/{0}/users/?api-version=1.6" -f $TenantName

Invoke-RestMethod -Method Get -Uri $GraphUri -Headers $AuthHeader -ContentType "application/json"


# Application schema extension example using -Method POST
$AuthHeader = @{Authorization = "Bearer {0}" -f $token.access_token}
$TenantName = '.onmicrosoft.com'
$ApplicationObjectId = "" # b5013aaf-16bf-4ab2-972b-e01be641dfc0 # GraphAPI-Extensions-App
$GraphUri = "https://graph.windows.net/{0}/applications/{1}/extensionProperties?api-version=1.6" -f $TenantName, $ApplicationObjectId
$Body = @{
    name = 'newCustomAttribute'
    dataType = 'String'
    targetObjects = @("User")
}

Invoke-RestMethod -Method Post -Uri $GraphUri -Body ($Body | ConvertTo-Json) -Headers $AuthHeader -ContentType "application/json"


# Modify user attribute example using -Method PATCH
$AuthHeader = @{Authorization = "Bearer {0}" -f $token.access_token}
$TenantName = '.onmicrosoft.com'
$UserObjectId = "" # "f65af661-3c33-474f-a3df-eddeafeb7a3e" # tpe@gmail.com
$GraphUri = "https://graph.windows.net/{0}/users/{1}/?api-version=1.6" -f $TenantName, $UserObjectId

$Body = @{
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

Invoke-RestMethod -Method Patch -Uri $GraphUri -Body ($body | ConvertTo-Json) -Headers $AuthHeader -ContentType "application/json"