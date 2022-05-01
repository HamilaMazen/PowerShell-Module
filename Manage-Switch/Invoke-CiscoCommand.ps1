#requires -Version 2.0 -Modules Posh-SSH
#Requires -Module Posh-SSH

<#
        .SYNOPSIS
        Run commands on your Cisco iOS device.
 
        .DESCRIPTION
        Executes commands on a Cisco device as if you were connected to the terminal via SSH.
 
        .PARAMETER IPAddress
        IP address of the Cisco device you want to execute commands on. This can be a piped list.
 
        .PARAMETER Command
        Commands that will be executed on the target system. One command per line, typed in quotes, or held
        in a string variable.
 
        .PARAMETER Credential
        Credentials with rights to run defined commands on the target device.
 
        .EXAMPLE
        Invoke-CiscoCommand -IPAddress 192.168.1.1 -Command 'show run' -Credential $myCreds
        Returns the running-configuration of Cisco device located at 192.168.1.1
 
        .NOTES
        Requires Posh-SSH and Core to run.
 
        .LINK
        https://www.powershellgallery.com/packages/posh-ssh
             
 
        .INPUTS
        String text for commands, IPaddress object, and PSCredential.
 
        .OUTPUTS
        Returns the value from commands ran. Using the "Verbose" parameter shows the commands ran, and prompts.
#>

function Invoke-CiscoCommand {
[CmdLetBinding()]
Param
(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='IP address')]
    [Alias('ComputerName','Name','Switch','Router','Host')]
    [IPAddress[]] $IPAddress,
        
    [Parameter(Mandatory=$true,HelpMessage='Command to be run')]
    [String[]] $Command,
        
    [Parameter(Mandatory=$true,HelpMessage='Credentials for managed network object')]
    [PSCredential] [System.Management.Automation.Credential()] $Credential
)

Process
{
    # Variables
    $strNewLine = "`n"
    $strPattern = '#|^$|configuration...|Current configuration :|^\r\n|^$'
        
    # Connect to the Cisco switch
    $objSessionCisco = New-SSHSession -ComputerName $IPAddress -Credential $Credential -AcceptKey -ConnectionTimeout 90 -ErrorAction Stop

    $SshStream = New-SSHShellStream -SessionID $($objSessionCisco.SessionID)
        
    # Set terminal length
    $SshStream.WriteLine('terminal length 0')
    $null = $SshStream.Read()

    $arrayCommands = $Command.Split($strNewLine)

    Foreach ($strCiscoCommand in $arrayCommands)
    {
        $SshStream.WriteLine(('{0}' -f $strCiscoCommand))
    
        # Takes a bit for the command to run sometimes
        Start-Sleep -Milliseconds 200
    }
        
    $rawOutput = @()
        
    $boolDataReceived = $false
        
    :waiter While ($true)
    {
        $streamOut = $sshStream.Read() 
            
        If ($boolDataReceived -eq $true -and $streamOut.Length -eq 0 -and -not $(($rawOutput.Split($strNewLine) | Select-Object -Last 1) -eq ''))
        {
            break waiter
        }
            
        If ($streamOut.Length -gt 0) 
        {
            $rawOutput += $streamOut
            $streamOut = $null 
            $boolDataReceived = $true # Watch until we do not receive data anymore
        }

        Start-Sleep -Milliseconds 200
    }
    
    If (!($PSBoundParameters['Verbose'])) 
    {
        $rawOutput = $rawOutput.Split($strNewLine) | Select-String -NotMatch -Pattern $strPattern
    }
        
    $rawOutput

    $null = Remove-SSHSession -SessionId $($objSessionCisco.SessionId)
}
}