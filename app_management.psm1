function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}
function out-log
{
    [cmdletbinding()]
    param(
        [string]$logpath,
        [string]$logtext,
        [string]$logtype = "INFO",
        [string]$logsource = "$env:computername"
    )
 
    $date = get-date
    $string = "$($date.ToShortDateString());$($date.ToShortTimeString());$logsource;$logtype;$logtext"
    Write-Verbose $string
    Out-File -FilePath $logpath -InputObject $string -Append
 
}
# Check functions
function Check-App
{
    param([string]$appname)
    if (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*  | where {$_.displayname -match $appname}){$true} 
    elseif (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*  | where {$_.displayname -match $appname}){$true} 
    else {$false}
}
function Check-File  
{
    param([string]$filepath)
    if (test-path $filepath -PathType Leaf){$true} else {$false}
}
function Check-KB 
{
    param([string]$kb)
    if ((Get-WmiObject -Query "SELECT HotFIxID FROM  Win32_QuickFixEngineering WHERE HotFIxId = '$kb'")){$true} 
    else {$false}
}
 
# Add functions
function start-msiexec
{
    param(
        [string]$Argument,
        [string]$appname,
        $credential
        )

        start-process msiexec -ArgumentList $Argument -Wait

    if (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*  | 
    where {$_.displayname -match $appname}){$true} 
    else {$false}
}
function start-exe
{
    param(
        [string]$exe,
        [string]$Argument,
        [string]$appname,
        $credential
        )
    
        start-process $exe -ArgumentList $Argument -Wait
    

    if (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*  | 
    where {$_.displayname -match $appname}){$true} 
    else {$false}
}
function send-popup 
{
    <#
Button Types
  Value Description 
    0   OK button. 
    1   OK and Cancel buttons. 
    2   Abort, Retry, and Ignore buttons. 
    3   Yes, No, and Cancel buttons. 
    4   Yes and No buttons. 
    5   Retry and Cancel buttons. 
   
Icon Types
   Value Description 
    16  "Stop Mark" icon. (0x10)
    32  "Question Mark" icon.  (0x20)
    48  "Exclamation Mark" icon. (0x30)
    64  "Information Mark" icon.  (0x40)

Possible values for IntButton the return value:
Value Description 
   1  OK button  
   2  Cancel button 
   3  Abort button 
   4  Retry button 
   5  Ignore button 
   6  Yes button 
   7  No button
#>
    [cmdletbinding()]
    param(
        [parameter(mandatory = $true)][Validateset("0","1","2","3","4","5")][int]$button,
        [parameter(mandatory = $true)][Validateset("Stop","Question","Exclamation","Information")][string]$icon,
        [parameter(mandatory = $true)][Validateset("Alert","Success")][string]$title,
        [parameter(mandatory = $true)][string]$text

    )

switch ($icon){
    "Stop"        {$i = 16}
    "Question"    {$i = 32}
    "Exclamation" {$i = 48}
    "Information" {$i = 64}
}
$hexa = $button+$i
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup($text,0,$title,$hexa) 

} #send-popup
