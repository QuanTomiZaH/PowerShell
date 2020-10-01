# Created by Robin Gjaltema
# August 2020
#
# ---------------------
#
# Parameters
param(
  [Parameter(mandatory = $true,
    HelpMessage = "Path to the folder where the logs have to be written")]
  [string] $LogFileLocation,
  [Parameter(mandatory = $true,
    HelpMessage = "The top level location of the folder, below which subfolders will be scanned and subsequently cleaned")]
  [string] $CleanDirTopLocation,
  [Parameter(mandatory = $true,
    HelpMessage = "How old the files can be when they need to be deleted")]
  [int] $DeleteFilesOlderThan
)

# Start delete files and or folders script
$d1 = Get-Date
$DeleteDateTime = (Get-Date).AddDays(-$DeleteFilesOlderThan)
$d1 = Get-Date -Format "yyyyMMdd HH;mm"

# Create a logfile if it does not exist yet
$LogFileLocationDate = "$LogFileLocation\Remove_Old_Postbus_Items_Log_$d1.txt"
If ((Test-Path $LogFileLocationDate) -eq $false) {
  Write-Output 'The logfile does not exist yet. Creating a new logfile'
  New-Item -Path $LogFileLocation -Name "Remove_Old_Postbus_Items_Log_$d1.txt" -ItemType 'File'
}
Write-Output "----------------------------------------" >> $LogFileLocationDate
Write-Output "Start deleting old postbus files and folders at: $d1" >> $LogFileLocationDate

#Create the array of folders to clean
$Postbussen = Get-ChildItem -Path $CleanDirTopLocation -Directory

foreach ($Folder in $Postbussen) {
  # Delete files older than the $DeleteFilesOlderThan.
  Get-ChildItem -Path "$CleanDirTopLocation\$Folder" -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $DeleteDateTime } | Remove-Item -Force

  # Delete any empty directories left behind after deleting the old files.
  Get-ChildItem -Path "$CleanDirTopLocation\$Folder" -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse

  $d2 = Get-Date -Format "yyyyMMdd HH;mm"
  Write-Output "Finished deleting old files and or folders at "$CleanDirTopLocation\$Folder":" $d2 >> $LogFileLocationDate
}

Write-Output "Done Cleaning the Postvakken" >> $LogFileLocationDate