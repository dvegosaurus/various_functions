Function Get-RDPSession {
    <#
        .SYNOPSIS
            Shows all the users currently logged in to specified or remote computers
    
        .DESCRIPTION
            Shows the users currently logged into the specified computername if not specified local computers will be shown.
    
        .PARAMETER ComputerName
            One or more computernames
    
        .EXAMPLE
            PS C:\> Get-LoggedInUser
            Shows the users logged into the local system
    
        .EXAMPLE
            PS C:\> Get-LoggedInUser -Computer server1,server2,server3
            Shows the users logged into server1, server2, and server3
    
        .EXAMPLE
            PS C:\> Get-LoggedInUser  | where{$_.sessionname -match 'RDP'}  ## shows where users are connected VIA RDP
    
        .Example
    
            PS C:\> Get-ADComputer -Filter *|select -exp name |Foreach{Get-LoggedInUser -Computer $_ } 
            Shows all computers in active directory computers
    
        .Example
    
            PS C:\> get-content C:\listofcomputers.txt |Foreach{Get-LoggedInUser -Computer $_ } 
            Shows all computers in the text file.
    
        .Example 
           
            PS C:\> Get-LoggedInUser -computer server1,server2  | where{$_.username -eq 'admin'}
           Shows where a user islogged in to. 
    
        .MORE
             [PSCustomObject]@{
              ComputerName    = $Comp
              Username        = $line.SubString(1, 20).Trim()
              SessionName     = $line.SubString(23, 17).Trim()
              #ID             = $line.SubString(42, 2).Trim()
              State           = $line.SubString(46, 6).Trim()
              #Idle           = $line.SubString(54, 9).Trim().Replace('+', '.')
              #LogonTime      = [datetime]$line.SubString(65)
    
              Remove # Against each if you want to see the Output of the Value
          
    ************************************************************************
     Notes: Run as administrator
     Author: Jiten https://community.spiceworks.com/people/jitensh
    Date Created: 08/30/2018
         Credits: 
    Last Revised: 08/30/2018
    ************************************************************************
    #>
    
    [cmdletbinding()]
       param(
       [String[]]$Computer = $env:COMPUTERNAME
       )
    
       ForEach ($Comp in $Computer) 
       { 
       If (-not (Test-Connection -ComputerName $comp -Quiet -Count 1 -ea silentlycontinue)) 
       {
       Write-Warning "$comp is Offline"; continue 
       } 
       $stringOutput = quser /server:$Comp 2>$null
          If (!$stringOutput)
          {
          Write-Warning "Unable to retrieve quser info for `"$Comp`""
          }
          ForEach ($line in $stringOutput){
             If ($line -match "logon time") 
             {Continue}
    
             [PSCustomObject]@{
              Computer        = $Comp
              Username        = $line.SubString(1, 20).Trim()
              SessionName     = $line.SubString(23, 17).Trim()
              sessionID       = $line.SubString(42, 2).Trim()
              State           = $line.SubString(46, 6).Trim()
              #Idle           = $line.SubString(54, 9).Trim().Replace('+', '.')
              #LogonTime      = [datetime]$line.SubString(65)
              }
              
          } 
       } 
    }
    
    
    function disconnect-RDPSession {
            <#
        .SYNOPSIS
            disconnect RDPSessions using session ID
    
        .DESCRIPTION
            disconnect RDPSessions using session ID
    
        .PARAMETER ComputerName
            session ID and computer
    
        .EXAMPLE
            PS C:\> disconnect-RDPSession -computer <computer> -sessionID <ID>
            disconnect the session ID on a computer

        .EXAMPLE
            PS C:\> get-RDPSession -Computer $computer  | where {$_.state -match "d.co"} | disconnect-RDPSession
            disconnect all disconnected session on a compuer
    
          
    ************************************************************************
     Notes: Run as administrator
     Author: dvegosaurus https://github.com/dvegosaurus
    ************************************************************************
    #>
        [CmdletBinding()]
        param(
            [Parameter(ValueFromPipelineByPropertyName)]
            [string]$computer = $env:COMPUTERNAME,
            [Parameter(ValueFromPipelineByPropertyName)]
            [int]$sessionID
        )
    
        process {
            If (-not (Test-Connection -ComputerName $computer -Quiet -Count 1 -ea silentlycontinue)) {
                Write-Warning "failed to connect to $computer"; continue 
            } 
            else {
                reset session $sessionID /server:$computer
                write-host "reset session $sessionID /server:$computer" -f Yellow
            }
        }
       
    }
    
    
    