
<#
.Synopsis
   Get a computer hostname by providing ip address
.DESCRIPTION
   Get a computer hostname by providing ip address
.EXAMPLE
  Get-HostnameFromIP -Addresses "@IPS"

#>
function Get-HostnameFromIP
{
    [CmdletBinding()]
    [Alias("hfi")]
    [OutputType([int])]
    Param
    (
        # Address as parameter
        [string[]][Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,HelpMessage="Please provide IP like X.X.X.X")]
        $Addresses

    )
foreach ($Address in $Addresses){
try{
$Hostmachine = ([System.Net.DNS]::Resolve($Address)).HostName
if (!$Error){
if ($Hostmachine -eq $Address)
{
    Write-Warning "Not found in DNS .. Please to verify your entery"
}
$Hostmachine
}  


}
catch [Exception]
{
    Write-Warning "Please to verify your entery"
}
}


}

<#
.Synopsis
   Get a computer ip address by providing hostname
.DESCRIPTION
   Get a computer ip address by providing hostname
.EXAMPLE
   Get-IPFromHostname -Hostnames "hostnames"

#>
function Get-IPFromHostname
{
    [CmdletBinding()]
    [Alias("ifh")]
    [OutputType([int])]
    Param
    (
        # Hostname as parameter
        [string[]][Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,HelpMessage="Please provide Hostname ")][string[]]
        $Hostnames
    )
foreach ($Hostname in $Hostnames){
try
{
$IP = ([System.Net.DNS]::Resolve($Hostname) ).AddressList
if (!$Error){
$IP
}    
}
catch [Exception]
{
    Write-Warning "Please to verify your entery"
}

}
}

<#
.Synopsis
   Get a computer ip address by providing @MAC
.DESCRIPTION
   Get a computer ip address by providing @MAC either by "-" style or ":" style
.EXAMPLE
   Get-IpFromMac -Macaddresses "@MACs"

#>
function Get-IpFromMac
{
    [CmdletBinding()]
    [Alias("ifm")]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,HelpMessage="Please provide MAC like XX-XX-XX-XX-XX-XX")][string[]]
        $Macaddresses
        
    )

$dhcpServer = Get-DhcpServerv4Scope -ComputerName "DhcpServerName" | Get-DhcpServerv4Lease -ComputerName "DhcpServerName"

foreach ($Macaddress in $Macaddresses){
$Macaddress = $Macaddress.replace(':','-')
try
{
    $ipv4= ($dhcpServer3 | Where-Object {$_.ClientId -like $Macaddress} | Select-Object -Property IPAddress,LeaseExpiryTime).IPAddress
}

catch [Exception]
{
    Write-Host "A problem has occured"
}

$ipv4

}
}

<#
.Synopsis
  Get computer on which a user is connected 
.DESCRIPTION
  Get computer on which a user is connected by identifying username on which server at first step then retype it for second time 

#>
function Get-ComputerFromUser
{
[Alias("cfu")]
#Initiate array
$result =@()
#Get Credebtials

$myCreds = Set-AdmCredential -Adm "Admin"
#providing entery
$user = Read-Host -Prompt "Type the user  "
#choosing server according to LOKID
$ref=(Get-ADUser $user -Properties * ).CanonicalName 
switch ($ref)
{
    {$_ -like  'LOKID1'} { $server= 'Server1'}
    {$_ -like  'LOKID2'} { $server= 'Server2' }
    {$_ -like  'LOKID3'} { $server= 'Server3'}
    Default {}
}
Write-Warning "Identifying server..."
#Make Session
$s = New-PSSession -ComputerName $server -Credential $myCreds 
#Invoke command to get computer name
$computer =Invoke-Command -Session $s -ScriptBlock {
$user = Read-Host -Prompt "Retype the user  "
$prefix="\"
(Get-SmbSession -ClientUserName $prefix$user -ErrorAction Ignore ).ClientComputerName} 
foreach ($ele in $computer) {
$result += [System.Net.DNS]::Resolve($ele)
}
$result 
}

<#
.Synopsis
   Get full name of user
.DESCRIPTION
   Get full name of user by providing username
.EXAMPLE
   Get-NameFromUser -Users "UsersNames"

#>
function Get-NameFromUser
{
    [CmdletBinding()]
    [Alias("nfu")]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,HelpMessage="Type user like hamaXXXX")][string[]]
        $Users
    )
foreach ($User in $Users){
$Name = (Get-ADUser "$User" -Properties * ).DisplayName
$Name
}
}
<#
.Synopsis
   Get user from name 
.DESCRIPTION
   Get user from expression (Use of wildcard "*" to multi search)
.EXAMPLE
   Get-UserFromName -Names "*Names*"

#>
function Get-UserFromName
{
    [CmdletBinding()]
    [Alias("ufn")]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,HelpMessage="Please provide name like 'LastName, FirstName'")][string[]]
        $Names
    )
foreach ($Name in $Names){
Get-ADUser -Filter {DisplayName -like $Name} -Properties Name,DisplayName | Select-Object -Property Name,DisplayName  
}
}

<#
.Synopsis
   Get @MAC from ip address
.DESCRIPTION
   Get @MAC of a computer by providing its ip address
.EXAMPLE
   Get-MacFromIP -IPs "@IPs"

#>
function Get-MacFromIP
{
    [CmdletBinding()]
    [Alias("mfi")]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,HelpMessage="Please provide IP like X.X.X.X")][string[]]
        $IPs
    )
$dhcpServer1 = Get-DhcpServerv4Scope -ComputerName "DhcpServerName" | Get-DhcpServerv4Lease -ComputerName "DhcpServerName"
foreach ($IP in $IPs){
try
{
    $MAC= $dhcpServer1 | Where-Object {$_.IPAddress -like $IP} | Select-Object -Property ClientId
}

catch 
{
    Write-Warning "Not available on 'DhcpServerName' .. Exiting .. "
}


$MAC

}
}
<#
.Synopsis
   Get logged user on a connected computer
.DESCRIPTION
   Get logged user by providing a connected computer
.EXAMPLE
    Get-UserFromHostname -Hostnames "hostnames"
    

#>
function Get-UserFromHostname 
{
    [CmdletBinding()]
    [Alias("ufh")]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0, HelpMessage= "Please to provide hostname")][string[]]
        $Hostnames

    )
foreach ($Hostname in $Hostnames){
try
{
  $User = (Get-CimInstance -ComputerName $Hostname -ClassName win32_computersystem -ErrorAction Stop).UserName 
  $return = $User.Substring(6,8)
  $return
}
catch [Exception]
{
  
  Write-Warning "Connection is not possible!!"
}

}
}

<#
.Synopsis
   Get user information from Active directory
.DESCRIPTION
   Get computer information from Active directory in a table form by providing username
.EXAMPLE
   Get-UserInfo -Users "UsersNames"

#>
function Get-UserInfo
{
    [CmdletBinding()]
    [Alias("userinfo")]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,HelpMessage="Please provide user ")][string[]]
        $Users

    )
foreach ($User in $Users){
try
{
Get-ADUser $User -Properties * | Select-Object -Property Name,DisplayName,Title,Department,Manager,OfficePhone,mail,Created | Format-Table -AutoSize
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
{
    Write-Warning "This user could not be found in Active Directory"
}
}
}

<#
.Synopsis
   Get computer information from Active directory
.DESCRIPTION
   Get computer information from Active directory in a table form by providing computer name 
.EXAMPLE
   Get-ComputerInfo -ComputerNames "ComputersNames"
 
#>
function Get-ComputerInfo
{
    [CmdletBinding()]
    [Alias("computerinfo")]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,HelpMessage="Please provide computername ")][string[]]
        $ComputerNames

    )
foreach($ComputerName in $ComputerNames){
try
{
Get-ADComputer $ComputerName -Properties * | Select-Object -Property Name,CanonicalName,Created,Description,LastLogonDate,OperatingSystem,OperatingSystemVersion | Format-Table -AutoSize
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
{
    Write-Warning "This computer could not be found in Active Directory"
}


}

}
