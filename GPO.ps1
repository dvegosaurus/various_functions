
$domainname = "contoso.local"


function get-CSVGPOReport {

    [cmdletbinding()]
    param(
        $domain
    )

    # INIT
    $gpos = get-gpo -all
    $gpoScopes = @("computer","user")
    $data = @()
    $domainname = $domain

    # MAIN
    $data = foreach ($gpo in $gpos) {
        
        $report = [xml](Get-GPOReport -ReportType xml -id $gpo.id)

        # policy
        # security
        # gpp

        foreach ($gpoScope in $gpoScopes){
            
            # extract GPO
            $policies = $report.gpo.$gpoScope.ExtensionData.Extension.Policy
            
            foreach ($policy in $policies){
                if ($policy.name){
                    [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Type      = "GPO"
                        parameter = $policy.name
                        state     = $policy.state
                        Linked    = if ($report.gpo.linksto){$true} else {$false} 
                    }
                }
            }

            # extract GPP
            $lastpath = if ($gpoScope -match "computer"){"machine"} else {"user"}
            $gpps = gci "\\$domainname\sysvol\$domainname\Policies\{$($gpo.id)}\$lastpath" -Recurse -file -filter *.xml
            foreach ($gpp in $gpps){

                # registry
                $file = [xml](get-content $gpp.fullname)
                $propertyname = ($file | Get-Member -MemberType Properties | where {$_.name -ne "xml"}).name
                $subproperty =  ($file.$propertyname | Get-Member -MemberType Properties | where {$_.name -ne "clsid"}).name
                $item = $file.$propertyname.$subproperty.Properties
            # $item
                # printer items
                if ($item.psobject.properties.name -contains "useDNS" -and $item.psobject.properties.name -contains "ipAddress"){
                    [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Type      = "printer"
                        parameter = $item.localName
                        state     = $item.path
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }
                    continue
                }

                # registry items
                if ($item.psobject.properties.name -contains "hive"){
                    [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Type      = "registry"
                        parameter = "$($item.hive)\$($item.key)\$($item.name)"
                        state     = $item.value
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }
                    continue
                }
            
                # network map items
                if ($item.psobject.properties.name -contains "allAdminDrive"){
                    [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Type      = "networkmap"
                        parameter = $item.name
                        state     = $item.path
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }
                    continue
                }
            
                # file items
                if ($item.psobject.properties.name -contains "targetPath"){
                    [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Type      = "file"
                        parameter = $item.fromPath
                        state     = $item.targetPath
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }
                    continue
                }
            
                # folder items
                if ( $item.psobject.properties.name -contains "path" -and
                    $item.psobject.properties.name -notcontains "limitUsers" -and
                    $item.psobject.properties.name -notcontains "ipAddress" -and
                    $item.psobject.properties.name -notcontains "port" ){
                    [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Type      = "folder"
                        parameter = $item.path
                        state     = $item.path
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }
                    continue
                }  

                # folder items
                if ($item.psobject.properties.name -contains "path" -and $item.psobject.properties.name -contains "port"){
                    [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Type      = "printer"
                        parameter = $item.path
                        state     = $item.path
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }
                    continue
                }  

                # environment variable items
                if ($item.psobject.properties.name -contains "user" -and $item.psobject.properties.name -contains "partial"){
                    [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Type      = "environment"
                        parameter = $item.name
                        state     = $item.value
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }
                    continue
                }  
                
            } # foreach ($gpp in $gpps)

        } # foreach ($gpoScope in $gpoScopes)
    }       

    $data
}

get-CSVGPOReport -domain $domainname 
