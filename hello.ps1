
function Write-Message
{
    [CmdletBinding()]
    Param
    (
       
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Message
    )

    Begin
    {
    }
    Process
    {
     Write-Host "Message:" + $Message
    }
    End
    {
    }
}
write-host "PSSCriptroot: $PSScriptRoot"
Write-Host "Myinvocation.mycommand.path: $($MyInvocation.MyCommand.Path)"
Write-Host "PSCommandpath: $PsCommandPath"


