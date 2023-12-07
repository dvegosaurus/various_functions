function export-password
{
    [cmdletBinding()]
    param(
        [string]$password,
        [string]$path
    )

    ConvertTo-SecureString $password -AsPlainText -Force | ConvertFrom-SecureString | out-file $path
}
function import-password
{
    [cmdletBinding()]
    param(
        [string]$path,
        [switch]$decrypt
    )

    $password = Get-Content  $path | Convertto-SecureString

    if ($decrypt)
    {
        $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($password)
        $result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
        $result
    }
    else
    {
        $password    
    }

}
