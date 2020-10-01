$CSVpath = ''

$CSVarray = Import-Csv -Path $CSVpath -Delimiter ';'

Write-Output $CSVarray
$Count = 0

foreach ($item in $CSVarray) {
  $Name = $Item.'Locatie'
  $Source = $Item.'Van'
  $Destination = $Item.''
  $Count += 1

  Write-Output "Locatie: $Name"
  Write-Output "Bron: $Source"
  Write-Output "Doel: $Destination"
  if ((Test-Path $Source) -eq $True -AND ((Test-Path $Destination) -eq $True)) {
    robocopy /MIR $Source $Destination /E /FFT /MT:128 /r:3 /w:3 /log:"Location-$Name-$Count.log" /V
  }
}
