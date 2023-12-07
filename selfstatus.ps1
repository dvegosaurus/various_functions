$tracker= "C:\Users\dveg\Desktop\selfstatus.conf"
function set-config ($file){

    $lines = get-content $file 
    $pso = [PSCustomObject]@{}

    foreach ($line in $lines){
        
        $split = $line.split("=")
        $pso | Add-Member -MemberType NoteProperty -Name $split[0] -Value $split[1] -Force

    }

    return $pso
}


while ($true){

    $data = set-config -file $tracker
    
    foreach ($property in $data.psobject.Properties){

        $string = "my_state,state=$($property.name),active=$($property.value) state=$($property.value)"
        $string
        Invoke-RestMethod -uri "http://localhost:8086/write?db=test" -Method Post -Body $string
    }


    Start-Sleep -Seconds 60

}