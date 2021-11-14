#####################################################
#Get OIDC Code from AzureAD B2C with Advanced policy
#####################################################

Add-Type -AssemblyName System.Web

# Your Client ID and Client Secret obainted when registering your WebApp
$clientid = ''
$clientSecret = ''
$resource = 'https://ws16b2c.onmicrosoft.com/6c3890f7-ca14-48c9-8f76-038562e19a35/user_impersonation'

$redirectUri = "https://prototype.azurewebsites.net"
$scope = 'openid offline_access ' + $resource

# UrlEncode the ClientID and ClientSecret and URL's for special characters 
$redirectUriEncoded =  [System.Web.HttpUtility]::UrlEncode($redirectUri)
$resourceEncoded = [System.Web.HttpUtility]::UrlEncode($resource)
$scopeEncoded = [System.Web.HttpUtility]::UrlEncode($scope)

Function Get-AuthCode {
    Add-Type -AssemblyName System.Windows.Forms

    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=512;Height=1024}
    $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=512;Height=1024;Url=($url -f ($scope -join "%20")) }

    $DocComp  = {
        $Global:uri = $web.Url.AbsoluteUri        
        if ($Global:uri -match "error=[^&]*|code=[^&]*") {$form.Close() }
    }
    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($DocComp)
    $form.Controls.Add($web)
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() | Out-Null

    $queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
    $output = @{}
    foreach($key in $queryOutput.Keys){
        $output["$key"] = $queryOutput[$key]
    }

    $output
}

$BaseUri = "https://login.microsoftonline.com/ws16b2c.onmicrosoft.com/oauth2/v2.0/authorize"
$url = "$($BaseUri)?" + `
        "client_id=$($clientid)" + `
        "&response_mode=query" + `
        "&response_type=code" + `
        "&redirect_uri=$($redirectUriEncoded)" + `
        "&scope=$($scopeEncoded)" + `
#        "&resource=$($resourceEncoded)" + `
        "&p=B2C_1A_Test_Base_SignUpSignIn_C1" + `
        "&state=myState" + `
#        "&ui_locales=de" + `
        "&nonce=1234"

$result = Get-AuthCode
Write-Output $result


###############################################
#Exchange Code with ID_Token and refresh_token
###############################################
$GrantType = "authorization_code"
$Uri = "https://login.microsoftonline.com/ws16b2c.onmicrosoft.com/oauth2/v2.0/token?p=B2C_1A_Test_Base_SignUpSignIn_C1"
$scopeFormatted = "openid {0} offline_access" -f $resource

$Body = @{
    "grant_type" = $GrantType
    "client_id" = $clientid
    "scope" = $scopeFormatted
    "code" = $result.code
    "redirect_uri" = $redirectUriEncoded 
    "client_secret" = $clientSecret
}

$token = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body 
Write-Output $token