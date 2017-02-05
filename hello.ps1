
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
