<#
.Synopsis
   Connect to a switch and execute command  
.DESCRIPTION
   Connect to a switch through SSH session and execute multiple commands
   
#>
# Requires the function of Invoke-CiscoCommand

function Manage-Switch {
#Get Credebtials

$myCreds = Set-AdmCredential -Adm "Admin"

#Specify targets (Array of targets 'target1','target2'...)
[string]$ip = Read-Host 'Please to specify target : ' 

#Specify commands to execute (Array of commands 'command1','command2'...) 
[string]$cmd= Read-Host 'Enter your command' 

while ($cmd -ne 'exit')
{
#invoke commands to execute on targets
Invoke-CiscoCommand -IPAddress $ip -Command $cmd -Credential $myCreds  

#Wait 
Start-Sleep -Milliseconds 500

#Specify commands to execute (Array of commands 'command1','command2'...) 
[string]$cmd= Read-Host 'Enter your command' 
    
}
}