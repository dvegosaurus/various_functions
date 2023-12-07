function stop-xserver {
     [cmdletbinding()]
     param(
        [parameter(mandatory=$true)]
        [pscustomobject]$servers,
        $lot,
        $app,
        $wait
     )
    if (( $servers.order | Where-Object {$_}).count -ne $servers.count ){throw "some server don't have an order set"}
    
    $data = $servers | Where-Object {$_.lot -eq $lot} | Sort-Object order

    $data 

    start-sleep -s $wait

}
function get-numberoflots {
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true)]
        $servers
    )

    if ($null -eq $servers.lot){throw "la liste de serveur fournie ne contient pas d'attribut 'lot'"}
    ($servers | Select-Object -unique lot).count
}

$servers = @(
    [PSCustomObject]@{
        name = "SERVER1"
        lot  = 1
        role = "web"
        order = 1
    }
    [PSCustomObject]@{
        name = "SERVER2"
        lot  = 1
        role = "app"
        order = 2
    }
    [PSCustomObject]@{
        name = "SERVER3"
        lot  = 2
        role = "web"
        order = 1
    }
    [PSCustomObject]@{
        name = "SERVER4"
        lot  = 2
        role = "app"
        order = 2
    }
)
$waitfor = 1

$numberoflots = get-numberoflots -servers $servers
foreach ($lot in (1..$numberoflots)){stop-xserver -servers $servers -lot $lot -wait $waitfor}

