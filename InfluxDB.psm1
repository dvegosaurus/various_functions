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
