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

#Command1. Operating System Information
Write-Output "#Command1: Operating System Information" | Out-File $filepath -append
Get-CimInstance Win32_OperatingSystem -ComputerName "$computer" | Format-List -Property Name,Caption,Version | Out-file $filepath -append

#Command2. Processor information
Write-Output "#Command2: Processor Information" | Out-File $filepath -Append
Get-ciminstance win32_processor -computername "$computer" | select-object deviceid,name,maxclockspeed | out-file $filepath -Append

#Command3. IP address config
Write-Output "#Command3: IP address config" | Out-file $filepath -Append
Get-ciminstance win32_networkadapterconfiguration -computername "$computer" | format-table -property ipaddress,ipsubnet,defaultgateway,dhcpenabled | Out-File $filepath -Append

#Command4. DNS Server address
Write-Output "#Command4: DNS Server Address" | Out-File $filepath -Append
Get-dnsclientserveraddress | sort-object serveraddress | out-file $filepath -Append

#Command5. System Memory
Write-Output "#Command5: System Memory" | Out-File $filepath -Append
Get-ciminstance win32_physicalmemory -computername "$computer" | measure-object -property capacity -sum | foreach-object {"{0:N2}" -f ([math]::round(($_.sum / 1GB),2))} | out-file $filepath -Append

#Command6. Free Space
Write-Output "#Command6: Free Space" | Out-File $filepath -Append
get-ciminstance -computername "$computer" win32_logicaldisk | select-object name | where-object caption -eq "C:" | foreach-object {write-output " $($_.caption) $('{0:N2}' -f ($_.Size/1gb)) GB total, $('{0:N2}' -f ($_.FreeSpace/1gb)) GB free "} | out-file $filepath -Append
#get-ciminstance -computername "$computer" win32_logicaldisk | Select-Object FreeSpace | out-file $filepath -Append

#Command7. Last Bootup
Write-Output "#Command7: Last Bootup Date/Time" | Out-File $filepath -Append
Get-ciminstance -classname win32_operatingsystem -Computername "$computer" | Select-Object name,lastbootuptime | out-file $filepath -Append

#Command8. Last User Login
Write-Output "#Command8: Last User Login Date/Time" | Out-File $filepath -Append
Get-localuser | Where-object {$_.Lastlogon -le (get-date).AddDays(-30)} | select-object name,lastlogon | out-file $filepath -append

#Command9. Retireve All User Accounts
Write-Output "#Command9: Retrieve All User Accounts" | Out-File $filepath -Append
Get-ciminstance win32_useraccount -computername "$computer" | select-object name | out-file $filepath -Append

#Command10. Determine Installed Hotfixes And Updates
Write-Output "#Command10: Installed Hotfixes And Updates" | Out-File $filepath -Append
get-hotfix -computername "$computer" | select-object hotfixid | out-file $filepath -Append

#Command11. All Installed Applications
Write-Output "#Command11: All Installed Applications" | Out-File $filepath -Append
get-ciminstance -class win32_service -computername "$computer" | select-object name,caption,version | out-file $filepath -append
	
	}
}
Get-SystemInformation -ComputerName <comma separated values eg : mach1, mach2, mach3>