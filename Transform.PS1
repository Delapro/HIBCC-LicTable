# ladet LICTable.xls von HIBCC, siehe https://www.hibcc.org/udi-resources-2/
# Installiert LibreOffice
# konvertiert die LICTable in eine DBF-Datei
# ladet die DBF-Datei und wandelt sie in das Delapro-Format um

$psversionTable
pwd

# easy.PS1 laden, damit Install-StartBitstransfer zur Verfügung steht
# '& {$s=(Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/Delapro/DelaproInstall/master/DLPInstall.PS1).Content.Replace([string][char]10,[char]13+[char]10); $s=$s.SubString(0, $s.IndexOf(''CMDLET-ENDE'')); $tempPath = ''C:\temp''; $scriptPath=Join-Path -Path $tempPath -ChildPath easy.PS1; If (-Not (Test-Path $tempPath)) {md $tempPath} ; Set-Content -path $scriptPath -value $s; cd $tempPath; powershell.exe -NoExit -NoProfile -executionPolicy Bypass -File $scriptPath }'
$s=(Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/Delapro/DelaproInstall/master/DLPInstall.PS1).Content
$s=$s.SubString(0, $s.IndexOf(''CMDLET-ENDE''))
Set-Content -path './easy.PS1' -value $s
. ./easy.PS1
Install-StartBitstransfer

Start-Bitstransfer https://www.hibcc.org/wp-content/uploads/LICTable.xls -Verbose
apt install libreoffice-core-nogui libreoffice-calc-nogui -y
$p=start-process -PassThru 'scalc' -ArgumentList @('--convert-to', 'dbf', '.\LICTable.xls'); while (-not $p.hasexited) {Start-sleep -Milliseconds 100}
dir LICTable.dbf


