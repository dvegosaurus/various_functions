function Get-GrafanaDashBoard
{
    [CmdLetBinding()]
    param
    (
        [parameter(mandatory=$true)][string]$Uri,
        [parameter(mandatory=$true)][string]$apiKey
    )

    # generate a header with a token (created in Grafana)
    $header = @{Authorization = "Bearer $apiKey"}
    (Invoke-RestMethod -Uri "$uri/api/search?type=dash-db" -Method Get -Headers $header).syncroot
}
function Export-GrafanaDashBoard
{
    [CmdLetBinding()]
    param
    (
        [parameter(mandatory=$true,ValueFromPipeline = $true)]$Dashboard,
        [parameter(mandatory=$true)][validatescript({test-path $_} )][string]$path
    )
    foreach ($dash in $dashboard)
    {
        # get dashboard info
        $newdash = Invoke-RestMethod -Uri "http://localhost:3000/api/dashboards/uid/$($Dashboard.uid)" -Method Get -Headers $header
        # reset ID
        $newdash.dashboard.id = "null"
        $title = $dash.title.replace(":","_") -replace '\\|\/','_'
        $db = $newdash | select dashboard,folderId | ConvertTo-Json -Depth 15
        $db | Out-File  "$path\$title.json"
    }

}
function Move-GrafanaDashBoard
{
    [CmdLetBinding()]
    param
    (
        [parameter(mandatory=$true,ValueFromPipeline = $true)]$Dashboard,
        [parameter(mandatory=$true)][string]$Uri,
        [parameter(mandatory=$true)][INT32]$FolderId,
        [parameter(mandatory=$true)][string]$SourceApiKey,
        [parameter(mandatory=$true)][string]$DestApiKey
    )

    $Sourceheader = @{Authorization = "Bearer $SourceApiKey"}
    $Destheader = @{Authorization = "Bearer $DestApiKey"}
    $createendpoint = "/api/dashboards/db"
    $getendpoint    = "/api/dashboards/uid"
    $contenttype    = 'application/json'
    
    $newdash = Invoke-RestMethod -Uri "$uri$getendpoint/$($Dashboard.uid)" -Method Get -Headers $Sourceheader
    $newdash.dashboard.id = "null"
    $newdash | Add-Member -Name "folderId" -Value $FolderId -MemberType NoteProperty
    $db = $newdash | select dashboard,folderid | ConvertTo-Json -Depth 15
    Invoke-RestMethod "$uri$createendpoint" -Method Post -Headers $Destheader -Body $db -ContentType  $contenttype
}
function Get-GrafanaFolder
{
    [CmdLetBinding()]
    param
    (
        [parameter(mandatory=$true)][string]$Uri,
        [parameter(mandatory=$true)][string]$apiKey
    )

    # generate a header with a token (created in Grafana)
    $header = @{Authorization = "Bearer $apiKey"}
    (Invoke-RestMethod -Uri "$uri/api/folders" -Method Get -Headers $header).syncroot
}
function New-GrafanaFolder
{
    [CmdLetBinding()]
    param
    (
        [parameter(mandatory=$true)][string]$Foldername,
        [parameter(mandatory=$true)][string]$Uri,
        [parameter(mandatory=$true)][string]$apiKey
    )

    # generate a header with a token (created in Grafana)
    $endpoint = "/api/folders"
    $header = @{Authorization = "Bearer $apiKey"}
    $body = @{title = $Foldername} | ConvertTo-Json
    $contenttype = "application/json"
    Invoke-RestMethod -Uri "$uri$endpoint" -Method Post -Headers $header -Body $body -ContentType $contenttype
}
function Get-GrafanaDatasource
{
    [CmdLetBinding()]
    param
    (
        [parameter(mandatory=$true)][string]$Uri,
        [parameter(mandatory=$true)][string]$apiKey
    )

    $endpoint = "/api/datasources"
    $header = @{Authorization = "Bearer $apiKey"}
    (Invoke-RestMethod -Uri "$uri$endpoint" -Method Get -Headers $header).syncroot
}
function Import-GrafanaDatasource
{
    [CmdLetBinding()]
    param
    (
        [parameter(mandatory=$true,ValueFromPipeline = $true)]$Datasource,
        [parameter(mandatory=$true)][string]$Uri,
        [parameter(mandatory=$true)][string]$apiKey
    )

    $endpoint = "/api/datasources"
    $header = @{Authorization = "Bearer $apiKey"}
    $contenttype = "application/json"

    foreach ($ds in $Datasource)
    {
        $ds.jsondata = "null"
        $body = $ds | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Uri "$uri$endpoint" -Method Post -Headers $header -Body $body -ContentType $contenttype
    }
    
}

# Get-GrafanaDashBoard -uri $uri -apiKey $adminKey | 
# % {Export-GrafanaD-DashboardashBoard  $_  -path "C:\TICK\Dashboards_Backup"}