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
    HelpMessage = "The location of the folder which will be scanned and subsequently cleaned")]
  [string] $CleanDirLocation,
  [Parameter(mandatory = $true,
    HelpMessage = "How old the files(days) can be when they need to be deleted")]
  [int] $DeleteFilesOlderThan
)

# Start delete files and or folders script
$DeleteDateTime = (Get-Date).AddDays(-$DeleteFilesOlderThan)
$date = Get-Date -Format "yyyyMMdd"

#Function to get timestamping in the logs
function Get-TimeStamp {
  return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

# Create a logfile if it does not exist yet
$LogFileLocationDate = "$LogFileLocation\$date Remove_Old_Bestandsoverdracht_Items_Log.txt"
If ((Test-Path $LogFileLocationDate) -eq $false) {
  Write-Output 'The logfile does not exist yet. Creating a new logfile'
  New-Item -Path $LogFileLocation -Name "$date Remove_Old_Bestandsoverdracht_Items_Log.txt" -ItemType 'File'
}
Write-Output "----------------------------------------" >> $LogFileLocationDate
$d1 = Get-TimeStamp
Write-Output "$d1 Start deleting old postbus files and folders at $CleanDirLocation :" >> $LogFileLocationDate

# Delete the files older than X days
$FilesArray = Get-ChildItem -Path $CleanDirLocation -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $DeleteDateTime }
foreach ($File in $FilesArray) {
  if ($Null -ne $File) {
    try {
      $d1 = Get-TimeStamp
      write-Output "$d1 Deleting File: $File" >> $LogFileLocationDate
      Remove-Item $File.FullName | out-null
    }
    Catch {
      $d1 = Get-TimeStamp
      write-Output "$d1 Error Deleting File: $Folder" >> $LogFileLocationDate
    }
  }
}

# Delete any empty directories left behind after deleting the old files.
do {
  $Directories = Get-ChildItem -Path $CleanDirLocation -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
  foreach ($Folder in $Directories) {
    try {
      $d1 = Get-TimeStamp
      write-Output "$d1 Deleting Folder: $Folder" >> $LogFileLocationDate
      Remove-Item $Folder
    }
    Catch {
      $d1 = Get-TimeStamp
      write-Output "$d1 Error Deleting Folder: $Folder" >> $LogFileLocationDate
    }
  }
} while ($Directories.count -gt 0)

$d1 = Get-TimeStamp
Write-Output "$d1 Finished deleting old files and or folders at $CleanDirLocation :" >> $LogFileLocationDate
