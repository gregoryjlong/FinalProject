#Gregory Long
#Tuesday session
#Project 1



#$computername = $env:computername
#$date = get-date -format "MM-dd-yyyy"
#filepath = "C:\$computername-$date.txt"

#Write-Output "Gregory Long, $date, $computername Information Script" | Out-file -filepath $filepath
#set-strictmode -version 2.0
Function Get-SystemInformation
{

Param(
	[Parameter(ParameterSetName='ComputerName',Position = 0,Mandatory=$true)] [array]$computername = @()
	)
$date = get-date -format "MM-dd-yyyy"
$filepath = "C:\$computername-$date.txt"
$computername
#exit

#$computername = @()
foreach ($computer in $computername) {

Write-Output "Gregory Long, $date, $computername Information Script" | Out-file -filepath $filepath

#Command1. IP Address for a remote system and whether the system uses DHCP
Write-Output "#Command1: Operating System Information" | Out-File $filepath -append
Get-ciminstance win32_networkadapterconfiguration -computername "$computer" | Select-Object ipaddress,dhcpenabled | Out-File $filepath -append

#Command2. Acquire DNS Client Server address used by remote System
Write-Output "#Command2: Acquire DNS Client Server address used by remote System" | Out-File $filepath -Append
Get-dnsclientserveraddress | select -first 1 | Select-Object ServerAddresses | Out-File $filepath -append

#Command3.  Determine Operating System name, build, and version number of Remote System
Write-Output "#Command3:  Determine Operating System name, build, and version number of Remote System" | Out-file $filepath -Append
Get-CimInstance Win32_OperatingSystem -ComputerName $computername | Format-List -Property Name,Caption,Version,BuildNumber | Out-File $filepath -append

#Command4. Determine the amount of system memory in GB.
Write-Output "#Command4: Determine the amount of system memory in GB." | Out-File $filepath -Append
Get-ciminstance win32_physicalmemory -computername $computername | measure-object -property capacity -sum | foreach-object {"{0:N2}" -f ([math]::round(($_.sum / 1GB),2))} | out-file $filepath -Append

#Command5. Processor Name for remote system
Write-Output "#Command5: Processor Name for remote system" | Out-File $filepath -Append
Get-ciminstance win32_processor -computername $computername | select-object name | out-file $filepath -Append

#Command6. Determine the amount of free space (in GB) for c: on the remote system
Write-Output "#Command6: Determine the amount of free space (in GB) for c: on the remote system" | Out-File $filepath -Append
get-ciminstance -computername $computername win32_logicaldisk | Measure-Object -property Size -sum | foreach-object {"{0:N2}" -f ([math]::round(($_.sum / 1GB),2))} | out-file $filepath -Append

#Command7. Determine the Last Reboot performed by a remote system
Write-Output "#Command7: Determine the Last Reboot performed by a remote system" | Out-File $filepath -Append
Get-ciminstance -classname win32_operatingsystem -Computername $computername | Select-Object lastbootuptime | Out-File $filepath -Append
	
	}
}
Get-SystemInformation -ComputerName <comma separated values eg : mach1, mach2, mach3>