<#
#Gregory Long
#Tuesday session
#Final Project

.SYNOPSIS
    .
.DESCRIPTION
    Powershell script to get system information on target machines which are passed as parameter for this script.
.PARAMETER Computername
    System hostname or ipaddress
.PARAMETER LiteralPath
    Specify one single machine or more than one machine hostname or ipaddress.
#>

Function Get-SystemInformation
{
$computername = @()
	
$date = get-date -format "MM-dd-yyyy"
$filepath = "C:\$computername-$date.txt"

foreach ($computer in $computername) {

try {
New-PSSession -ComputerName $computer -Credential Domain01\Admin01 -ThrottleLimit 16

Write-Output "Gregory Long, $date, $computername Information Script" | Out-file -filepath $filepath

#Command1. IP Address for a remote system and whether the system uses DHCP
#Write-Output "#Command1: Operating System Information" | Out-File $filepath -append
$cmd1 = Get-ciminstance win32_networkadapterconfiguration -computername $computer | Select-Object ipaddress,dhcpenabled | select -first 2

#Command2. Acquire DNS Client Server address used by remote System
#Write-Output "#Command2: Acquire DNS Client Server address used by remote System" | Out-File $filepath -Append
$cmd2 = Get-dnsclientserveraddress | select -first 1 | Select-Object ServerAddresses

#Command3.  Determine Operating System name, build, and version number of Remote System
#Write-Output "#Command3:  Determine Operating System name, build, and version number of Remote System" | Out-file $filepath -Append
$cmd3 = Get-CimInstance Win32_OperatingSystem -ComputerName "$computer" | Select-Object Name,Caption,Version,BuildNumber

#Command4. Determine the amount of system memory in GB.
#Write-Output "#Command4: Determine the amount of system memory in GB." | Out-File $filepath -Append
$cmd4 = Get-ciminstance win32_physicalmemory -computername "$computer" | measure-object -property capacity -sum | foreach-object {"{0:N2}" -f ([math]::round(($_.sum / 1GB),2))}

#Command5. Processor Name for remote system
#Write-Output "#Command5: Processor Name for remote system" | Out-File $filepath -Append
$cmd5 = Get-ciminstance win32_processor -computername $computername | select-object name

#Command6. Determine the amount of free space (in GB) for c: on the remote system
#Write-Output "#Command6: Determine the amount of free space (in GB) for c: on the remote system" | Out-File $filepath -Append
$cmd6 = get-ciminstance -computername "$computer" win32_logicaldisk | Measure-Object -property Size -sum | foreach-object {"{0:N2}" -f ([math]::round(($_.sum / 1GB),2))}

#Command7. Determine the Last Reboot performed by a remote system
#Write-Output "#Command7: Determine the Last Reboot performed by a remote system" | Out-File $filepath -Append
$cmd7 = Get-ciminstance -classname win32_operatingsystem -Computername "$computer" | Select-Object lastbootuptime

#Outputing an Object
$syshash = [ordered]@{ MachineName = $computer; RemoteIPAddress = $cmd1.ipaddress; RemoteUsesDHCP = $cmd1.dhcpenabled; RemoteDNSClientServerAddress = $cmd2.ServerAddresses; RemoteOSName = $cmd3.Caption; RemoteOSBuildNumber = $cmd3.BuildNumber; RemoteOSVersion = $cmd3.Version; RemoteMemoryinGB = $cmd4; RemoteProcessorName = $cmd5.name; RemoteFreeSpace = $cmd6; RemoteLastReboot = $cmd7.lastbootuptime } 
Write-Verbose $syshash | Out-File $filepath -Append
	}
catch [error] {
	Write-Host "$computer unable to get system information  due to the errors in the script."
	}
	}
}
Get-SystemInformation -ComputerName <comma separated values eg : mach1, mach2, mach3>