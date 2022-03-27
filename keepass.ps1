$path = 'C:\Program Files (x86)\KeePass Password Safe 2'
[Reflection.Assembly]::LoadFile("$path\KeePass.exe") | Out-Null
[Reflection.Assembly]::LoadFile("$path\KeePass.XmlSerializers.dll") | Out-Null

# prerequisites install-module PoShKeePass

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
        path = "T:\xxxxxxxx.kdbx"
        pass = 'xxxxxxxxx'
    }
    @{
        path =  "O:\xxxxxxxx.kdbx"
        pass = 'xxxxxxxxxxx'
    }
)

$data = foreach ($file in $files){
    get-keepass -path $file.path  -password $file.Pass  | get-KeepassEntries
}


# create credential for the new Keepass
$user = "toto"
$pwd = ConvertTo-SecureString "toto" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user,$pwd)

# create the keepass
$dbname = "kp"
$dbprofilename = "test"
$dbpath = "C:\Temp\$dbname.kdbx"

New-KeePassDatabase -DatabasePath C:\temp\kp.kdbx -MasterKey $cred
Get-KeePassDatabaseConfiguration | Remove-KeePassDatabaseConfiguration -Confirm:$false
$kpdatabase = New-KeePassDatabaseConfiguration -DatabasePath $dbpath -DatabaseProfileName $dbprofilename -UseMasterKey 

# import the keepass entries into the new keepass
foreach ($item in $data){
    # if the group does not exist create it
    $groups = get-KeePassGroup -MasterKey $cred -DatabaseProfileName $dbprofilename
    $groupPath = "$dbname/$($item.Keepass)"
    if ($groupPath -notin $groups.fullpath){
        New-KeePassGroup -MasterKey $cred -DatabaseProfileName $dbprofilename -KeePassGroupName $item.Keepass -KeePassGroupParentPath $dbname
    }

    # splatting for cleaner code
    $params = @{
        Title                 = $item.Title
        KeePassPassword       = $item.Password | ConvertTo-SecureString -AsPlainText -Force
        DatabaseProfileName   = $dbprofilename
        KeePassEntryGroupPath = $groupPath
        MasterKey             = $cred        
    }
    if ($item.URL){$params += @{URL= $item.URL}} # URL might be empty so we add it only if it has content
    if ($item.Notes){$params += @{Notes= $item.Notes}}
    if ($item.UserName.Length -ne 0){$params += @{UserName = $item.UserName}} else {$params += @{UserName = ' '}}

    New-KeePassEntry  @params 


}
