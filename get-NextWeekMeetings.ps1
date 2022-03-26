get-process outlook.exe | Stop-Process
Start-Process outlook
start-sleep -s 15

$mailAddressesFilePath = "C:\temp\mailAddresses.csv"
$addresses = import-csv $mailAddressesFilePath -Delimiter "`t"
$mailParams = @{

}

#### HTML Vars
$htmlHeaders = @'
<style>
    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;
    }
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }
   table {
             font-size: 12px;
             border: 0px; 
             font-family: Arial, Helvetica, sans-serif;
       } 
    td {
             padding: 4px;
             margin: 0px;
             border: 0;
       }
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
       }

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
    tbody tr:nth-child(odd) {
        background: #f0f1f0;
    }

        #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }
</style>
'@

#### Functions
Function Get-OutlookCalendar {

    [cmdletbinding()]
    param(
        [datetime]$start = (get-date),
        [datetime]$end = (get-date).addDays(7)
    )
    Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null
    $olFolders = "Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [type]
    $outlook = new-object -comobject outlook.application
    $namespace = $outlook.GetNameSpace("MAPI")
    $folder = $namespace.getDefaultFolder($olFolders::olFolderCalendar)
    $folder.items | where-object { $_.start -gt $start -AND $_.start -lt $end} 

 } #end function Get-OutlookCalendar


#### INIT
$appointments = Get-OutlookCalendar | Select-Object -Property Subject, Start, Duration,StartUTC,endUTC, Location, Organizer, @{n="conflict";e={$false}},GlobalAppointmentID

#### Core
foreach ($appointment in $appointments){
    foreach ($otherAppointement in ($appointments | where {$_.GlobalAppointmentID -notmatch $appointment.GlobalAppointmentID})){   
        if ($appointment.StartUTC -gt $otherAppointement.StartUTC -and $appointment.StartUTC -lt $otherAppointement.endUTC){
            $appointment.conflict = $true
            $otherAppointement.conflict = $true
        }
    }
}

##### Personnal HTML Creation
$htmlTable = $appointments | select subject,start,duration,organizer,conflict | sort start | ConvertTo-Html -Title appointment 
$title = "<h1>Reunion des 7 prochains jours</h1>"
$table = "$title $htmlTable" 

$htmlBody = @"

<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40"><head><meta http-equiv=Content-Type content="text/html; charset=iso-8859-1"><meta name=Generator content="Microsoft Word 15 (filtered medium)"><!--[if !mso]><style>v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style><![endif]--><style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;
	mso-fareast-language:EN-US;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;
	mso-fareast-language:EN-US;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:70.85pt 70.85pt 70.85pt 70.85pt;}
div.WordSection1
	{page:WordSection1;}
--></style>
$htmlHeaders

<!--[if gte mso 9]><xml>
<o:shapedefaults v:ext="edit" spidmax="1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext="edit">
<o:idmap v:ext="edit" data="1" />
</o:shapelayout></xml><![endif]--></head><body lang=FR link="#0563C1" vlink="#954F72" style='word-wrap:break-word'>

<p class=MsoNormal><o:p>&nbsp;</o:p></p><p class=MsoNormal>$table<o:p></o:p></p>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>
<p class=MsoNormal>Cordialement<o:p></o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=721 style='width:540.7pt;border-collapse:collapse'><tr><td width=721 style='width:540.7pt;padding:0cm 5.4pt 0cm 5.4pt'><p class=MsoNormal><span style='color:#1F497D;mso-fareast-language:FR'><o:p>&nbsp;</o:p></span></p></td></tr></table>
<p class=MsoNormal><span style='display:none;mso-fareast-language:FR'><o:p>&nbsp;</o:p></span></p><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=491 style='width:13.0cm;border-collapse:collapse'><tr style='height:3.5pt'><td width=28 rowspan=7 style='width:21.05pt;padding:0cm 0cm 0cm 0cm;height:3.5pt'><p class=MsoNormal><a href="https://horizon.prolival.fr/simulateur.php"><span style='font-size:9.0pt;color:#1F497D;mso-fareast-language:FR;text-decoration:none'><img border=0 width=26 height=26 style='width:.2708in;height:.2708in' id="Image_x0020_1" src="cid:image001.png@01D830AC.130766F0"></span></a><span style='font-size:12.0pt;color:#13395C;mso-fareast-language:FR'><o:p></o:p></span></p><p class=MsoNormal><span style='font-size:12.0pt;color:#13395C;mso-fareast-language:FR'><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><a href="https://www.linkedin.com/company/prolival/"><span style='font-size:9.0pt;color:#1F497D;mso-fareast-language:FR;text-decoration:none'><img border=0 width=26 height=26 style='width:.2708in;height:.2708in' id="Image_x0020_2" src="cid:image002.png@01D830AC.130766F0"></span></a><span style='font-size:12.0pt;color:#13395C;mso-fareast-language:FR'><o:p></o:p></span></p><p class=MsoNormal><span style='font-size:12.0pt;color:#13395C;mso-fareast-language:FR'><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><a href="https://twitter.com/prolival"><span style='font-size:9.0pt;color:#1F497D;mso-fareast-language:FR;text-decoration:none'><img border=0 width=26 height=26 style='width:.2708in;height:.2708in' id="Image_x0020_3" src="cid:image003.png@01D830AC.130766F0"></span></a><span style='font-size:12.0pt;color:#13395C;mso-fareast-language:FR'><o:p></o:p></span></p></td><td width=272 style='width:204.25pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'><p class=MsoNormal><span style='font-size:12.0pt;color:#13395C;mso-fareast-language:FR'>Romain GOURTAY</span><span style='color:#1F497D;mso-fareast-language:FR'><o:p></o:p></span></p></td><td width=191 rowspan=7 style='width:143.25pt;padding:0cm 0cm 0cm 0cm;height:3.5pt'><p class=MsoNormal align=center style='text-align:center'><span style='color:#1F497D;mso-fareast-language:FR'><img border=0 width=183 height=160 style='width:1.9062in;height:1.6666in' id="Image_x0020_4" src="cid:image004.png@01D830AC.130766F0"><o:p></o:p></span></p></td></tr><tr style='height:3.5pt'><td width=272 style='width:204.25pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'><p class=MsoNormal><i><span style='font-size:12.0pt;color:#EE991A;mso-fareast-language:FR'>Ingénieur Systèmes<o:p></o:p></span></i></p><p class=MsoNormal><i><span style='font-size:12.0pt;color:#EE991A;mso-fareast-language:FR'>Pôle Expertise Projet Innovation et Conseil</span></i><span style='color:#1F497D;mso-fareast-language:FR'><o:p></o:p></span></p></td></tr><tr style='height:1.2pt'><td width=272 style='width:204.25pt;padding:0cm 5.4pt 0cm 5.4pt;height:1.2pt'><p class=MsoNormal><i><span style='font-size:10.0pt;color:#EE991A;mso-fareast-language:FR'><o:p>&nbsp;</o:p></span></i></p></td></tr><tr style='height:2.2pt'><td width=272 style='width:204.25pt;padding:0cm 5.4pt 0cm 5.4pt;height:2.2pt'><p class=MsoNormal><b><i><span style='font-size:9.0pt;color:#8EA5B6;mso-fareast-language:FR'>T.</span></i></b><i><span style='font-size:9.0pt;color:#8EA5B6;mso-fareast-language:FR'> + 33 1 41 43 84 35 /&nbsp; M. +33 6 68 25 10 82</span></i><span style='color:#1F497D;mso-fareast-language:FR'><o:p></o:p></span></p></td></tr><tr style='height:2.05pt'><td width=272 style='width:204.25pt;padding:0cm 5.4pt 0cm 5.4pt;height:2.05pt'></td></tr><tr style='height:4.65pt'><td width=272 style='width:204.25pt;padding:0cm 5.4pt 0cm 5.4pt;height:4.65pt'><p class=MsoNormal><span style='font-size:10.0pt;color:#1F497D;mso-fareast-language:FR'><o:p>&nbsp;</o:p></span></p></td></tr><tr style='height:22.4pt'><td width=272 valign=top style='width:204.25pt;padding:0cm 5.4pt 0cm 5.4pt;height:22.4pt'><p class=MsoNormal><span style='color:#1F497D;mso-fareast-language:FR'><a href="http://www.prolival.fr/"><i><span style='font-size:10.0pt;color:#8EA5B6;text-decoration:none'>www.prolival.fr</span></i></a></span><i><span style='font-size:8.0pt;color:#8EA5B6;mso-fareast-language:FR'><o:p></o:p></span></i></p><p class=MsoNormal><i><span style='font-size:9.0pt;color:#8EA5B6;mso-fareast-language:FR'>420 rue d&#8217;Estienne d&#8217;Orves - 92700 Colombes<o:p></o:p></span></i></p></td></tr><tr style='height:22.4pt'><td width=491 colspan=3 valign=top style='width:13.0cm;padding:0cm 0cm 0cm 0cm;height:22.4pt'><p class=MsoNormal><span style='font-size:12.0pt;color:#13395C;mso-fareast-language:FR'><img border=0 width=481 height=57 style='width:5.0104in;height:.5937in' id="Image_x0020_5" src="cid:image005.png@01D830AC.130766F0"><o:p></o:p></span></p></td></tr></table><p class=MsoNormal><span style='mso-fareast-language:FR'><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><o:p>&nbsp;</o:p></p></div></body>
</html>
"@

##### 
$outlook = new-object -comobject outlook.application
$Mail = $Outlook.CreateItem(0)
$Mail.To = ($outlook.Session.Accounts | select SmtpAddress -First 1).SmtpAddress
$Mail.Subject = "[PROL] Reunions a venir"
$Mail.HTMLBody = $htmlBody
$Mail.Send()

#<div class=WordSection1><p class=MsoNormal>Bonjour,<o:p></o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p>
#<p class=MsoNormal>Une réunion planifié entre nous est en conflit avec une autre. Pouvons nous la replanifier&nbsp;?<o:p></o:p></p>


##### Organizer HTML Creation
#### Send mail
# foreach ($appointment in ( $appointments | where {$_.conflict}) ){
#     if ($appointment.Organizer -in $addresses.name){
#         echo toto
#     }

# }