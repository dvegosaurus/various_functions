$path = 'C:\Program Files (x86)\KeePass Password Safe 2'
[Reflection.Assembly]::LoadFile("$path\KeePass.exe") | Out-Null
[Reflection.Assembly]::LoadFile("$path\KeePass.XmlSerializers.dll") | Out-Null

function get-keepass {
    param(
        $path,
        $password
    )
    $KDBX = New-Object KeePassLib.PwDatabase
    $IoConnectionInfo = New-Object KeePassLib.Serialization.IOConnectionInfo
    $IoConnectionInfo.Path = $path
    $Key = New-Object KeePassLib.Keys.CompositeKey
    $Key.AddUserKey((New-Object KeePassLib.Keys.KcpPassword($password)))
    $KDBX.Open($IoConnectionInfo, $Key, $null)
    return $KDBX
}


function get-KeepassEntries {
    [cmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        $KDBX
    )
    $Entries = $KDBX.RootGroup.GetObjects($true,$true)
    $Entries | Foreach-Object {
        [PSCustomObject]@{
            Keepass  = $KDBX.Name
            Title    = $_.Strings.ReadSafe('Title')
            UserName = $_.Strings.ReadSafe('UserName')
            Password = $_.Strings.ReadSafe('Password')
            URL      = $_.Strings.ReadSafe('URL')
            Notes    = $_.Strings.ReadSafe('Notes')
            LastModificationTime = $_.LastModificationTime
        }
    }
}

$files = @(
    @{
        path = "T:\perso.kdbx"
        pass = 'xxxxxxxx'
    }
    @{
        path =  "O:\client.kdbx"
        pass = 'xxxxxxxxxxx'
    }
)

$data = foreach ($file in $files){
    get-keepass -path $file.path  -password $file.Pass  | get-KeepassEntries
}

$data | Out-GridView
