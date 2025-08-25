$logfolder="c:\programdata\kiwi"

$appsdata=@'
AppID;AppPath;BlockingProcesses
Adobe.Acrobat.Reader.64-bit;C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe;Acrobat
Google.Chrome;C:\Program Files\Google\Chrome\Application\chrome.exe
Zoom.Zoom;C:\Program Files\Zoom\bin\zoom.exe;zoom
PDFsam.PDFsam;C:\Program Files\PDFsam Basic\pdfsam.exe;pdfsam
Logitech.OptionsPlus;C:\Program Files\LogiOptionsPlus\logioptionsplus.exe
7zip.7zip;C:\Program Files\7-Zip\7z.exe;7z,7zFM,7zG
Dell.CommandUpdate.Universal;C:\Program Files\Dell\CommandUpdate\dcu-cli.exe
Lenovo.SystemUpdate;C:\Program Files (x86)\Lenovo\System Update\tvsu.exe
Mozilla.Firefox;C:\Program Files\Mozilla Firefox\firefox.exe
Microsoft.Edge;C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
WireGuard.WireGuard;C:\Program Files\WireGuard\wireguard.exe
Microsoft.Office;C:\Program Files\Microsoft Office\Office16\OSPP.HTM;WINWORD,EXCEL,OUTLOOK,ONENOTE,POWERPNT
'@

$winget=(get-childitem "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*\winget.exe")[0].fullname
$wingetoutput=.$winget list --upgrade-available --accept-source-agreements
if ($wingetoutput -like "*No installed package found matching input criteria*")
{
} else
{
    $apps=$appsdata | convertfrom-csv -delimiter ";"
    foreach ($app in $apps)
    {
        if (test-path $app.apppath)
        {
            $ok=$true
            if ($app.BlockingProcesses -ne $null)
            {
                $blockingprocesses=[array]$($app.BlockingProcesses -split ",")
                $processes=get-process
                foreach ($blockingprocess in $blockingprocesses)
                {
                    if ($processes.processname -contains $blockingprocess)
                    {
                        $ok=$false
                    }
                }
            }
            if ($wingetoutput -like "*$($app.AppID)*") {} else { $ok=$false } 
            if ($ok)
            { 
                "- updating $($app.appid)"
                $logfile="$logfolder\winget-update-$($app.AppID -replace '\.','-').log"
                if (test-path $logfile) { remove-item $logfile -confirm:$false -force }
                .$winget upgrade -e $app.AppId --accept-source-agreements --disable-interactivity --log $logfile
            } else { "- skipping $($app.appid)" }
        }
    }
}
exit 0
