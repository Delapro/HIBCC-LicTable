# ladet LICTable.xls von HIBCC, siehe https://www.hibcc.org/udi-resources-2/
# Installiert LibreOffice
# konvertiert die LICTable in eine DBF-Datei
# ladet die DBF-Datei und wandelt sie in das Delapro-Format um

$psversionTable
pwd
Start-Bitstransfer https://www.hibcc.org/wp-content/uploads/LICTable.xls -Verbose
apt install libreoffice-core-nogui libreoffice-calc-nogui -y
$p=start-process -PassThru 'scalc' -ArgumentList @('--convert-to', 'dbf', '.\LICTable.xls'); while (-not $p.hasexited) {Start-sleep -Milliseconds 100}
dir LICTable.dbf
