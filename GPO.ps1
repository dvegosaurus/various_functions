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
    foreach ($gpo in $gpos) {
        
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
                        Category  = $policy.Category
                        Type      = "GPO"
                        parameter = $policy.name
                        state     = $policy.state
                        Linked    = if ($report.gpo.linksto){$true} else {$false} 
                    }
                }
            }

            # extract GPP
            $lastpath = if ($gpoScope -match "computer"){"machine"} else {"user"}
            [array]$gpps = gci "\\$domainname\sysvol\$domainname\Policies\{$($gpo.id)}\$lastpath" -Recurse -file -filter *.xml
            foreach ($gpp in $gpps){ 
                    $PSO = [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Category  = "GPP"
                        Type      = ""
                        parameter = ""
                        state     = ""
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }
                    # registry
                    $file = [xml](get-content $gpp.fullname)
                    $propertyname = ($file | Get-Member -MemberType Properties | where {$_.name -ne "xml"}).name
                    $subproperty =  ($file.$propertyname | Get-Member -MemberType Properties | where {$_.name -ne "clsid"}).name
                    $items = @($file.$propertyname.$subproperty.Properties)

                    foreach ($item in $items){
                        
                        # printer items
                        if ($item.psobject.properties.name -contains "useDNS" -and $item.psobject.properties.name -contains "ipAddress"){
                                $pso.Type      = "printer"
                                $pso.parameter = $item.localName
                                $pso.state     = $item.path
                        }

                        # registry items
                        if ($item.psobject.properties.name -contains "hive"){
                                $pso.Type      = "registry"
                                $pso.parameter = "$($item.hive)\$($item.key)\$($item.name)"
                                $pso.state     = $item.value
                        }
                    
                        # network map items
                        if ($item.psobject.properties.name -contains "allAdminDrive"){
                                $PSO.Type      = "networkmap"
                                $PSO.parameter = $item.name
                                $PSO.state     = $item.path
                        }
                    
                        # file items
                        if ($item.psobject.properties.name -contains "targetPath"){
                                $PSO.Type      = "file"
                                $PSO.parameter = $item.fromPath
                                $PSO.state     = $item.targetPath
                        }
                    
                        # folder items
                        if ( $item.psobject.properties.name -contains "path" -and
                            $item.psobject.properties.name -notcontains "limitUsers" -and
                            $item.psobject.properties.name -notcontains "ipAddress" -and
                            $item.psobject.properties.name -notcontains "port" ){
                                $PSO.Type      = "folder"
                                $PSO.parameter = $item.path
                                $PSO.state     = $item.path
                        }  

                        # folder items
                        if ($item.psobject.properties.name -contains "path" -and $item.psobject.properties.name -contains "port"){
                                $PSO.Type      = "printer"
                                $PSO.parameter = $item.path
                                $PSO.state     = $item.path
                        }  

                        # environment variable items
                        if ($item.psobject.properties.name -contains "user" -and $item.psobject.properties.name -contains "partial"){
                                $PSO.Type      = "environment"
                                $PSO.parameter = $item.name
                                $PSO.state     = $item.value
                        }  
                        # inifiles items
                        if ($item.psobject.properties.name -contains "section" -and $item.psobject.properties.name -contains "property"){
                                $PSO.Type      = "inifile"
                                $PSO.parameter = $item.path
                                $PSO.state     = $item.section
                        }  

                        # shortcut items
                        if ($item.psobject.properties.name -contains "shortcutPath" -and $item.psobject.properties.name -contains "targetPath"){
                                $PSO.Type      = "shortcut"
                                $PSO.parameter = $item.targetPath
                                $PSO.state     = $item.shortcutPath
                        }  

                        # group items
                        if ($item.psobject.properties.name -contains "groupname"){
                                $PSO.Type      = "shortcut"
                                $PSO.parameter = $item.targetPath
                                $PSO.state     = $item.shortcutPath
                        }  


                        
                        $PSO
       
                    } # foreach ($item in $items)
            } # foreach ($gpp in $gpps)


            # extract scripts
            $lastpath = if ($gpoScope -match "computer"){"machine"} else {"user"}
            [array]$scripts = gci "\\$domainname\sysvol\$domainname\Policies\{$($gpo.id)}\$lastpath" -Recurse -file | where {$_.FullName -match "\.ps1|\.cmd"}
            
            foreach ($script in $scripts){
                 $PSO = [PSCustomObject]@{
                        Name      = $gpo.displayname
                        Scope     = $gpoScope
                        Category  = "scripts"
                        Type      = "scripts"
                        parameter = $script.basename
                        state     = $script.basename
                        Linked    = if ($report.gpo.linksto){$true} else {$false}
                    }

                    $PSO
            } #   foreach ($script in $scripts){

        } # foreach ($gpoScope in $gpoScopes)
    }      
   
}

function get-CSVSecPolReport {

    [cmdletbinding()]
    param(
        $domain
    )

    $files = gci "\\$domain\sysvol\$domain\Policies\*\Machine\Microsoft\Windows NT\SecEdit\*"  -File

    foreach ($file in $files){
        
        $null = $file -match '\{(.+)\}'
        $gpoID = $Matches[1]
        $gpo = get-gpo -guid $gpoID
        $report = [xml](Get-GPOReport -ReportType xml -id $gpo.id)
        $content = get-content $file.FullName

        foreach ($line in $content){

            if ($line -match '\[.+\]'){
            
                $PSO = [PSCustomObject]@{
                    name      = $gpo.DisplayName
                    Scope     = "machine"
                    Category  = "secpol"
                    Type      = ""
                    parameter = ""
                    state     = ""
                    linked    = if ($report.gpo.linksto){$true} else {$false} 
                }
                $PSO.Type = $line -replace '\[|\]',''
                continue
            }
            else {
                $split = $line.Split('=')
                $PSO.parameter = $split[0]
                $pso.state = $split[1]
            }

            $PSO
        }

    }

}


$domainname = "contoso.local"
$data = get-CSVGPOReport -domain $domainname 
$data += get-CSVSecPolReport -domain $domainname
$data  | out-gridview