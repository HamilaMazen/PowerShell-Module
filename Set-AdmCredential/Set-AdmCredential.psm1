<#
.Synopsis
   Description sommaire
.DESCRIPTION
   Description détaillée
.EXAMPLE
    Set-AdmCredential -Adm "Admin"
#>
function Set-AdmCredential
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Adm

    )

$password = ConvertTo-SecureString "P@ssWord" -AsPlainText -Force
$myCreds = New-Object System.Management.Automation.PSCredential ($Adm, $password)
return $myCreds
}