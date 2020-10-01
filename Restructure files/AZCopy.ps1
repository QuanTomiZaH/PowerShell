#SetupAzcopy
#Copy AZCopy.exe to c:\Windows\System32\azcopy.exe
# Version 2.2
<# Param(
#     [parameter(Mandatory=$true)]
#     [ValidateSet("Upload", "Download")]
#     [String[]]$Direction
#   )
#>
If (!(test-path C:\Windows\System32\azcopy.exe)) { Copy-Item ".\azcopy.exe" c:\windows\system32 }

$DestinationFolder = "E:\SharePoint tijdelijke data\EBS Noord en Zwolle" #Hier de doellocatie van de te downloaden bestanden invoeren
$enxs109sau01 = ""

# Melden wie waar naar toe
Write-host "To $DestinationFolder"

#Sync from local folder to Blob container
azcopy copy $enxs109sau01 $DestinationFolder --recursive=true
#--delete-destination true
