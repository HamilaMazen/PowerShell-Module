
<#
.Synopsis
   Send wake on lan packet to wake up computer
.DESCRIPTION
   Send wake on lan packet to wake up powered computer by providing its @MAC
.EXAMPLE
   Send-WakeOnLan -macadd "@MAC"

#>
function Send-WakeOnLan
{
    [CmdletBinding()]

    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $macadd
    )
    $macadd = $macadd.replace('-',':')

    $mymac = $macadd.split(':') | %{ [byte]('0x' + $_) }
    if ($mymac.Length -ne 6)
    {
        throw 'Mac Address Must be 6 hex Numbers Separated by : or -'
    }
    Write-Verbose "Creating UDP Packet"
    $UDPclient = new-Object System.Net.Sockets.UdpClient
    $UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
    $packet = [byte[]](,0xFF * 6)
    $packet += $mymac * 16
    Write-Verbose ([bitconverter]::tostring($packet))
    [void] $UDPclient.Send($packet, $packet.Length)
    Write-Host  "   - Wake-On-Lan Packet of length $($packet.Length) sent to $mymac"
}

<#
.Synopsis
   Disable user profile service on a computer
.DESCRIPTION
   Disable user profile service on a connected computer
.EXAMPLE
   Disable-Profile -ComputerName "ComputerName"

#>
function Disable-Profile
{
    [CmdletBinding()]
   
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName


    )
    $myCreds = Set-AdmCredential -Adm "Admin"
        $test = 'True'
        $counter = 0
        while ($test -eq 'True')
        {Write-Host "Trying to connect..."
          if ((Test-Connection -ComputerName $ComputerName -Quiet) -eq 'True') 
          {
          Write-Host "Computer connected !"
           $s = New-PSSession -ComputerName $ComputerName -Credential $myCreds 
           $test= 'False'
           Invoke-Command -Session $s -ScriptBlock{
           $Param1 = Read-Host -Prompt "Enter ComputerName"
           Get-service -ComputerName $ComputerName | where {$_.Name -like 'ProfSvc'} | Stop-Service -PassThru -Force | Set-Service -StartupType Disabled  
           sleep 5
           Get-service -ComputerName $ComputerName | where {$_.Name -like 'ProfSvc'} | Select-Object -Property Name,Status,StartType,DependentServices
           Write-Host "Profile disabled"
           }
                     
          }
          
         $counter++ 
         if ($counter -eq 4)
         {
           Write-Host "Unable to connect .. exiting"  
           $test= 'False'
         } 
        }


        
    }

<#
.Synopsis
   Enable Remote desktop service on a computer
.DESCRIPTION
   Enable Remote desktop service on a computer by providing computer name
.EXAMPLE
   Enable-Remote -Target "ComputerName"

#>
function Enable-Remote
{
    [CmdletBinding()]
   
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Target
    )

    $myCreds = Set-AdmCredential -Adm "Admin"

    if ((Test-Connection -ComputerName $Target -Quiet) -eq 'True')
    {
        $s = New-PSSession -ComputerName $Target -Credential $myCreds
        Invoke-Command -Session $s -ScriptBlock{
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
        Write-Host "Remote is enabled"
           }
         
    }
    
    if ((Test-Connection -ComputerName $Target -Quiet) -eq 'False')
    {
      Write-Host "Computer is not connected !!"  
    }



}

<#
.Synopsis
   Delete additional profile under computer drive
.DESCRIPTION
   Delete additional profile under computer drive
.EXAMPLE
   Delete-Profile -ComputerName "ComputerName" -User "UserProfile"
#>
function Delete-Profile
{
    [CmdletBinding()]
   
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [String][Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName,

        # Param2 help description
        [String][Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $User
    )




$myCreds = Set-AdmCredential -Adm "Admin"
$session = New-PSSession -ComputerName $ComputerName -Credential $myCreds 
Write-Host ---Connect session to $ComputerName--- 

invoke-command -Session $session -ArgumentList $ComputerName, $User  -scriptblock {
#$user = Read-Host -Prompt "Type user    "
    param ($ComputerName , $User)  
    Set-Location C:\Users
    $profiles = ( Get-ChildItem ).Name
    foreach ($profile in $profiles)
    {  
        Write-Host ---Check user $profile--- 
        if ($profile -ne $User)
        { if (($profile -like 'adm*') -or ($profile -like 'Public') -or ($profile -like '*desktop*')){Continue}
            else
                {
                    Write-Host ---Deleting $profile from local drive---
                    del ".\$profile" -Force -Recurse -ErrorAction SilentlyContinue
                }         
        }
    } 
  }
}
