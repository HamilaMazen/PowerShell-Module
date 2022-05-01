<#
.Synopsis
   This command allows you to retreive software update of a computer remotely 
.DESCRIPTION
   This command allows you to retreive software update of a computer remotely by specifying a target computer or a list of computers
.EXAMPLE
   Get-SoftwareUpdateOnComputer -Computers  "ComputerName"

#>
function Get-SoftwareUpdateOnComputer
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [string[]][Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Computers
    )

foreach ($Computer in $Computers){
$Test = Test-Connection -ComputerName $Computer -Quiet
if ($Test -eq 'True') {
    try{
    Get-CimInstance -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer -ErrorAction SilentlyContinue | Where-Object {$_.EvaluationState -notlike "0" } | Select-Object -Property PSComputerName,Name,EvaluationState
    }
    catch [Exception]
    {
     Write-Host "Unable to retrieve Updates from " $Computer
    }    
}else {Write-Host $Computer failed !!!}

}
}
<#
.Synopsis
   This command allows you to execute software update on a computer remotely 
.DESCRIPTION
   This command allows you to execute software update on a computer remotely by specifying a target computer or a list of computers
.EXAMPLE
    Execute-UpdateOnComputer -Computers "ComputerName"
   

#>
function Execute-UpdateOnComputer
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [string[]][Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Computers

    )

foreach ($Computer in $Computers){

 $Updates= (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -notlike "0"})
 Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Updates) -Namespace root\ccm\clientsdk -ComputerName $Computer


    }
  }


<#
.Synopsis
   This command allows you to trigger an application update on a computer remotely 
.DESCRIPTION
   This command allows you to trigger applications updates on a computer remotely by specifying a target computer or a list of computers, mention list of applications to trigger and to apply method on them (install , uninstall)
.EXAMPLE
    Trigger-AppInstallation -Computername "ComputerName" -AppName "ApplicationName" -Method Install
.EXAMPLE
    Trigger-AppInstallation -Computername "ComputerName" -AppName "ApplicationName" -Method Uninstall
   

#>
Function Trigger-AppInstallation
{
 
Param
(
 [String[]][Parameter(Mandatory=$True, Position=1)] $Computername,
 [String][Parameter(Mandatory=$True, Position=2)] $AppName,
 [ValidateSet("Install","Uninstall")]
 [String][Parameter(Mandatory=$True, Position=3)] $Method
)
 
foreach ($comp in $Computername){

$Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $comp -ErrorAction SilentlyContinue | Where-Object {$_.Name -like $AppName})
 
$Args = @{EnforcePreference = [UINT32] 0
Id = "$($Application.id)"
IsMachineTarget = $Application.IsMachineTarget
IsRebootIfNeeded = $False
Priority = 'High'
Revision = "$($Application.Revision)" }

 
Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -ComputerName $Computername -MethodName $Method -Arguments $Args -ErrorAction SilentlyContinue
}
 
}

<#
.Synopsis
   This command allows you to retreive applications update of a computer remotely 
.DESCRIPTION
   This command allows you to retrieve applications updates on a computer remotely by specifying a target computer or a list of computers

.EXAMPLE
   Get-ApplicationOnComputer -Computers "ComputerName"
#>
function Get-ApplicationOnComputer
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [string[]][Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Computers
    )

foreach ($Computer in $Computers){
$Test = Test-Connection -ComputerName $Computer -Quiet
if ($Test -eq 'True') {
    try{
    function Switch ($param1)
    {
            switch ($param1){
    
        '1' {$eval = "Installed" }
        '4' {$eval = "Past due - will be retried"}
        '6' {$eval = "Downloading"}
        '12' {$eval = "Waiting to install  / Installing"}
        '13' {$eval = "Requires restart"}
        '26' {$eval = "Waiting to begin"}
        '27' {$eval = "Installed"}
        '34'{$eval = "Repair failed"}
        Default {$eval = "Not known"}
        
    }
    $eval
    }

    Get-CimInstance -Namespace "root\ccm\clientSDK" -Class CCM_Application -ComputerName $Computer -ErrorAction SilentlyContinue  | Select-Object -Property PSComputerName,Name,InstallState,@{n='Eval';e={& Switch ($_.EvaluationState)}    }

    }
    catch [Exception]
    {
     Write-Host "Unable to retrieve Updates from " $Computer
    }    
}else {Write-Host $Computer failed !!!}

}
}

