# ladet LICTable.xls von HIBCC, siehe https://www.hibcc.org/udi-resources-2/
# Installiert LibreOffice
# konvertiert die LICTable in eine DBF-Datei
# ladet die DBF-Datei und wandelt sie in das Delapro-Format um

$psversionTable
pwd

# easy.PS1 laden, damit Install-StartBitstransfer zur Verfügung steht
# '& {$s=(Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/Delapro/DelaproInstall/master/DLPInstall.PS1).Content.Replace([string][char]10,[char]13+[char]10); $s=$s.SubString(0, $s.IndexOf(''CMDLET-ENDE'')); $tempPath = ''C:\temp''; $scriptPath=Join-Path -Path $tempPath -ChildPath easy.PS1; If (-Not (Test-Path $tempPath)) {md $tempPath} ; Set-Content -path $scriptPath -value $s; cd $tempPath; powershell.exe -NoExit -NoProfile -executionPolicy Bypass -File $scriptPath }'
$s=(Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/Delapro/DelaproInstall/master/DLPInstall.PS1).Content
$s=$s.SubString(0, $s.IndexOf('CMDLET-ENDE'))
Set-Content -path './easy.PS1' -value $s
'"$([string][char]10)Am Scriptende$([string][char]10)"' | Add-Content -path './easy.PS1'

dir ./easy.PS1
'easy.PS1 Ende:'
tail easy.PS1

. ./easy.PS1

# DBF-Routinen gleich laden
'DBFDownload/Init'
. Invoke-PSDBFDownloadAndInit
'easy/Delapro-Umgebung komplett vorhanden'

# 'Installiere LibreOffice'
# sudo apt install libreoffice-core-nogui libreoffice-calc-nogui -y

'Lade LICTable'
Start-BitsTransfer 'https://www.hibcc.org/wp-content/uploads/LICTable.xls' -ErrorAction SilentlyContinue -Verbose
dir LICTable.xls

'Starte Konvertierung'
# Windows
# $p=start-process -PassThru 'scalc' -ArgumentList @('--convert-to', 'dbf', '.\LICTable.xls'); while (-not $p.hasexited) {Start-sleep -Milliseconds 100; '.'}
# Linux
$p=start-process -PassThru 'libreoffice' -ArgumentList @('--headless', '--convert-to', 'dbf', '.\LICTable.xls', "--outdir $(Resolve-Path .)"); while (-not $p.hasexited) {Start-sleep -Milliseconds 100; Write-Host '.' -NoNewLine}

dir LICTable.dbf

# öffnet eine beliebe DBF-Datei und gibt die kompletten Records als Objekt zurück
Function Get-DBFTable {
    [CmdletBinding()]
    Param(
        [string]$Path
    )

    $Path = Resolve-Path $Path
    $Dbf = Use-DBF $Path
    $Dbf.GoTop()
    foreach($nr in $Dbf.ListAll()) {$Dbf.Goto($nr); New-Object PSObject -Property $Dbf.Fields }
    $Dbf.Close()
}

# Delapro-Anpassung
$Lic = Get-DBFTable ./LICTable.dbf

"Anzahl Sätze: $($Lic.Length)"
