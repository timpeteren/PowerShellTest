﻿&lt;#
&nbsp;
.COPYRIGHT
Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
See LICENSE in the project root for license information.
 
#&gt;
 
####################################################
&nbsp;
function Get-AuthToken {
 
&lt;#
.SYNOPSIS
This function is used to authenticate with the Graph API REST interface
.DESCRIPTION
The function authenticate with the Graph API Interface with the tenant name
.EXAMPLE
Get-AuthToken
Authenticates you with the Graph API interface
.NOTES
NAME: Get-AuthToken
#&gt;
 
[cmdletbinding()]
 
param
(
    [Parameter(Mandatory=$true)]
    $User
)
 
$userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
 
$tenant = $userUpn.Host
 
Write-Host "Checking for AzureAD module..."
 
    $AadModule = Get-Module -Name "AzureAD" -ListAvailable
 
    if ($AadModule -eq $null) {
 
        Write-Host "AzureAD PowerShell module not found, looking for AzureADPreview"
        $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable
 
    }
 
    if ($AadModule -eq $null) {
        write-host
        write-host "AzureAD Powershell module not installed..." -f Red
        write-host "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt" -f Yellow
        write-host "Script can't continue..." -f Red
        write-host
        exit
    }
 
# Getting path to ActiveDirectory Assemblies
# If the module count is greater than 1 find the latest version
 
    if($AadModule.count -gt 1){
 
        $Latest_Version = ($AadModule | select version | Sort-Object)[-1]
 
        $aadModule = $AadModule | ? { $_.version -eq $Latest_Version.version }
 
            # Checking if there are multiple versions of the same module found
 
            if($AadModule.count -gt 1){
 
            $aadModule = $AadModule | select -Unique
 
            }
 
        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
 
    }
 
    else {
 
        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
 
    }
 
[System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
 
[System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
 
$clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
&nbsp;
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
&nbsp;
$resourceAppIdURI = "https://graph.microsoft.com"
&nbsp;
$authority = "https://login.microsoftonline.com/$Tenant"
&nbsp;
    try {
 
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
 
    # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
    # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession
 
    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
 
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")
 
    $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI,$clientId,$redirectUri,$platformParameters,$userId).Result
 
        # If the accesstoken is valid then create the authentication header
 
        if($authResult.AccessToken){
 
        # Creating header for Authorization token
 
        $authHeader = @{
            'Content-Type'='application/json'
            'Authorization'="Bearer " + $authResult.AccessToken
            'ExpiresOn'=$authResult.ExpiresOn
            }
 
        return $authHeader
 
        }
 
        else {
 
        Write-Host
        Write-Host "Authorization Access Token is null, please re-run authentication..." -ForegroundColor Red
        Write-Host
        break
 
        }
 
    }
 
    catch {
 
    write-host $_.Exception.Message -f Red
    write-host $_.Exception.ItemName -f Red
    write-host
    break
 
    }
 
}
&nbsp;
####################################################
 
Function Add-DeviceConfigurationPolicy(){
 
&lt;#
.SYNOPSIS
This function is used to add an device configuration policy using the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and adds a device configuration policy
.EXAMPLE
Add-DeviceConfigurationPolicy -JSON $JSON
Adds a device configuration policy in Intune
.NOTES
NAME: Add-DeviceConfigurationPolicy
#&gt;
 
[cmdletbinding()]
 
param
(
    $JSON
)
 
$graphApiVersion = "Beta"
$DCP_resource = "deviceManagement/deviceConfigurations"
Write-Verbose "Resource: $DCP_resource"
 
    try {
 
        if($JSON -eq "" -or $JSON -eq $null){
 
        write-host "No JSON specified, please specify valid JSON for the Android Policy..." -f Red
 
        }
 
        else {
 
        Test-JSON -JSON $JSON
 
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)"
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"
 
        }
 
    }
 
    catch {
 
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
 
    }
 
}
 
####################################################
 
Function Test-JSON(){
 
&lt;#
.SYNOPSIS
This function is used to test if the JSON passed to a REST Post request is valid
.DESCRIPTION
The function tests if the JSON passed to the REST Post is valid
.EXAMPLE
Test-JSON -JSON $JSON
Test if the JSON is valid before calling the Graph REST interface
.NOTES
NAME: Test-AuthHeader
#&gt;
 
param (
 
$JSON
 
)
 
    try {
 
    $TestJSON = ConvertFrom-Json $JSON -ErrorAction Stop
    $validJson = $true
 
    }
 
    catch {
 
    $validJson = $false
    $_.Exception
 
    }
 
    if (!$validJson){
 
    Write-Host "Provided JSON isn't in valid JSON format" -f Red
    break
 
    }
 
}
 
####################################################
 
#region Authentication
 
write-host
 
# Checking if authToken exists before running authentication
if($global:authToken){
 
    # Setting DateTime to Universal time to work in all timezones
    $DateTime = (Get-Date).ToUniversalTime()
 
    # If the authToken exists checking when it expires
    $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes
 
        if($TokenExpires -le 0){
 
        write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
        write-host
 
            # Defining User Principal Name if not present
 
            if($User -eq $null -or $User -eq ""){
 
            $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
            Write-Host
 
            }
 
        $global:authToken = Get-AuthToken -User $User
 
        }
}
 
# Authentication doesn't exist, calling Get-AuthToken function
 
else {
 
    if($User -eq $null -or $User -eq ""){
 
    $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
    Write-Host
 
    }
 
# Getting the authorization token
$global:authToken = Get-AuthToken -User $User
 
}
 
#endregion
 
####################################################
 
$Windows = @"
 
{
 
 "@odata.type": "#microsoft.graph.windows10CustomConfiguration",
 
  "lastModifiedDateTime": "2017-01-01T00:00:35.1329464-08:00",
  "assignmentStatus": "Assignment Status value",
  "assignmentProgress": "Assignment Progress value",
  "assignmentErrorMessage": "Assignment Error Message value",
  "description": "Windows 10 - Custom - Self-Service Password Reset from Lock Screen",
  "displayName": "Windows 10 - Custom - Self-Service Password Reset from Lock Screen",
  "version": 1024,
  "omaSettings": [
              {
      "@odata.type": "microsoft.graph.omaSettingInteger",
      "displayName": "Self-Service Password Reset from Lock Screen",
      "description": "1 - Enable Password reset",
      "omaUri": "./Vendor/MSFT/Policy/Config/Authentication/AllowAadPasswordReset",
      "value": 0
       }
       ,
       {
      "@odata.type": "microsoft.graph.omaSettingInteger",
      "displayName": "EnablePinRecovery",
      "description": "1 - EnablePinRecovery",
      "omaUri": "./Device/Vendor/MSFT/PassportForWork/c56dd45b-1da6-4bd0-a53b-1466782d6ee5/Policies/EnablePinRecovery",
      "value": "1"
    }
 
  ]
  }
 
"@
####################################################
 
# Add-DeviceConfigurationPolicy -Json $Windows