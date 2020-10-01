$path = '' #Hier de top level pad van de te scannen bestanden invoeren
$report_path = '' #Hier de loggingslocatie van de Drive invoeren

Get-ChildItem -Path "$path" -Recurse -Force -File |
Get-FileHash -Algorithm MD5 |
Sort-Object -Property 'Path' |
Export-Csv -Path "$report_path" -NoTypeInformation
