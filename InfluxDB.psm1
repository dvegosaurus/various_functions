function get-timestamp
{
    [Cmdletbinding()]
    param(
        [parameter(mandatory=$true)]$timeOffset
    )
    if ([timezone]::CurrentTimeZone.IsDaylightSavingTime((get-date)))
    {
        $timestamp = [INT64]((New-TimeSpan -Start ($epoch = [timezone]::CurrentTimeZone.ToLocalTime((get-date "01/01/1970 00:00:00"))) -End (Get-Date).AddHours($timeOffset)).TotalSeconds) *1000000000
    }
    else
    {
        $timestamp = [INT64]((New-TimeSpan -Start ($epoch = [timezone]::CurrentTimeZone.ToLocalTime((get-date "01/01/1970 00:00:00"))) -End (Get-Date)).TotalSeconds) *1000000000
    }

    $timestamp
} # get-timestamp -timeoffset -1

class influxDBwriter
{
    [string]$uri
    [string]$port
    [string]$measurement
    [INT64]$timestamp

    influxDBwriter(){
        $this.timestamp = [INT64]((New-TimeSpan -Start ([timezone]::CurrentTimeZone.ToLocalTime((get-date "01/01/1970 00:00:00"))) -End (Get-Date)).TotalSeconds) *1000000000
    }

    influxDBwriter($uri,$port){
        $this.uri = $uri
        $this.port = $port
        $this.timestamp = [INT64]((New-TimeSpan -Start ([timezone]::CurrentTimeZone.ToLocalTime((get-date "01/01/1970 00:00:00"))) -End (Get-Date)).TotalSeconds) *1000000000
    }

    [void]writedata($string,[bool]$sendTimestamp){
        $params = @{
            uri = "$($this.uri):($this.port)/write?db=$($this.measurement)"
            body = $string
            method = "post"
        }
        invoke-restmethod @params
    }

    [void]updateTimestamp(){
        $this.timestamp = [INT64]((New-TimeSpan -Start ([timezone]::CurrentTimeZone.ToLocalTime((get-date "01/01/1970 00:00:00"))) -End (Get-Date)).TotalSeconds) *1000000000
    }

}


#$influxDB = [influxDBwriter]::new()
#$influxDB.port = "8086"
#$InfluxDB.uri = "http://localhost"
#$influxDB.updateTimestamp()
