#Created by Robin Gjaltema and Joey Kerkhof

### Remove ###
# list the different folders from the local fileshare
#$FileShareUserLocation = 'C:\_NoBackup\TestS3Access\Functieprofiel' ###Put this in the ENV Variables
#$FileShareUserLocation = 'C:\_NoBackup\TestS3Access\Downloading' ###Put this in the ENV Variables
#$FileShareStagingLocation = 'C:\_NoBackup\TestS3Access' ###ENV (Double with the Staging area variable)
#$FromEnvironment = '' ###ENV Variable
#$LogDirectory = 'C:\_NoBackup\TestS3Access\Logs'
#$CredPath = 'C:\aws_service_cred\credentials'
#$UserProfile = 'Individual_User' ###ENV VARIABLE? Of kunnen we in één script zowel de individuele gebruikers als de groepen verplaatsen? # Los per group/individu
#$Type = 'download'
#$Type = 'upload'
### END REMOVE ###

## Examples for running the script
# Upload
# -FileShareUserLocation 'D:\Fileshare\Outbox\Individuen' -FileShareStagingLocation 'D:\Fileshare\Outbox' -FromEnvironment '' -LogDirectory 'D:\Fileshare\Logs' -CredPath 'C:\aws_service_cred\credentials' -UserProfile 'Individual_User' -Type 'upload'
# Download
# -FileShareUserLocation 'D:\Fileshare\Inbox\Individuen' -FromEnvironment '' -LogDirectory 'D:\Fileshare\Logs' -CredPath 'C:\aws_service_cred\credentials' -UserProfile 'Individual_User' -Type 'download'

# -FileShareUserLocation '' -FileShareStagingLocation '' -FileShareStagingLocation '' -FromEnvironment '' -LogDirectory '' -CredPath 'C:\aws_service_cred\credentials' -UserProfile 'Individual_User' -Type ''
### General requirements ###
#This is a script to cut and paste documents from a filelocation to an AWS s3 bucket with one command line action
#The requirements to run this script are:
#PowerShell
#AWSPowerShell module

### Actions before running the script ###
# You will need to initialize the AWS Credentials once manually and put the credentials in the defined $CredPath (recommended C:\aws_service_cred\credentials)
# Put the credentials in the defined $CredPath (recommended C:\aws_service_cred\credentials)

### Parameters ###
# -FromEnvironment <Path to the Icon> is mandatory (Only capital letters allowed)
# -CredPath <the location of the AWS credential file>
# -FileShareStagingLocation  <Location of the staging location> is mandatory (Folder in which a staging location will be built)
# -FileShareUserLocation <Location of the userprofiles> is mandatory (Folder in which all the profiles are located)
# -Type <downloading or uploading> (only small letters allowed)
# -UserProfile <Which groups is this script running for>
# -LogDirectory <Location to put the logs>



param(
  [Parameter(mandatory = $true,
    HelpMessage = "Define the type of action is done in this script, options are: 'download' and 'upload'.")]
  # [ValidatePattern('download' -or 'upload')]
  [string] $Type,
  [Parameter(mandatory = $true,
    HelpMessage = "Define the user groups this script is running in, options are: 'Individual_User' and 'Group_User'.")]
  # [ValidatePattern('Individual_User' -or 'Group_User')]
  [string] $UserProfile,
  [Parameter(mandatory = $true,
    HelpMessage = "Define the Environment this script is running in, options are: 'KA' and 'OT'.")]
  [string] $FromEnvironment,
  [Parameter(mandatory = $true,
    HelpMessage = "Add the path to the AWS Credentials on the machine")]
  [string] $CredPath,

  [Parameter(HelpMessage = "Input the location of the folder where a staging area will be created, only required when uploading")]
  [string]$FileShareStagingLocation,

  [Parameter(mandatory = $true,
    HelpMessage = "Input the location of the folder which contain all the userprofiles")]
  # [ValidateScript( {
  #     if (-Not ($_ | Test-Path) ) {
  #       throw "File or folder does not exist"
  #     }
  #     if (Test-Path -PathType Container) {
  #       throw "The Path argument must be a folder. file paths are not allowed."
  #     }
  #     return $true
  #   })]
  [string]$FileShareUserLocation,

  [Parameter(mandatory = $true,
    HelpMessage = "Input the location of the folder where the logs will be stored")]
  # [ValidateScript( {
  #     if (-Not ($_ | Test-Path) ) {
  #       throw "File or folder does not exist"
  #     }
  #     if (Test-Path -PathType Container) {
  #       throw "The Path argument must be a folder. file paths are not allowed."
  #     }
  #     return $true
  #   })]
  [string]$LogDirectory
)



function Invoke_Modules {
  #Import Modules
  try {
    Write-Output 'Importing the module AWSPowerShell'
    Import-Module AWSPowerShell
    Write-Output 'The Module has been succesfully invoked' | add-content $succeslog_des
  }
  catch {
    Write-Output 'The module "AWSPowerShell" is not installed, you can find this module at: "https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html"' | add-content $errorlog_des
    Write-Output 'Exiting script' | add-content $errorlog_des
    exit 03 | add-content $errorlog_des
  }
}


function Get_AccessKeys {
  try {
    if (Test-Path -path $CredPath -PathType leaf) {
      $content = get-content -path $CredPath
    }
    else {
      $content = "C:\Users\$env:UserName\.aws"
      $CredPath = "C:\Users\$env:UserName\.aws\credentials"
    }
    $awscreds = $content -split "="
    $access_key = $awscreds[2].Substring(1)
    $secret_key = $awscreds[4].Substring(1)

    $iam_username = "enxp236-ot-productie-user"
    $region = "eu-west-1"
    $Bucketname = "enxp236-sss01"

    $Variables_Array = @($iam_username, $region, $Bucketname)
    $Keys_Array = @($access_key, $secret_key)
    Write-Output 'The access keys have been succesfully pulled' | add-content $succeslog_des
    # Initializing the connection
    Initialize-AWSDefaults -Region $Variables_Array[1] -ProfileName 'AWS_OT' -ProfileLocation $CredPath
  }
  catch {
    Write-Output 'The variables have not been properly pulled from the credential path, check the pathing and access key validity' | add-content $errorlog_des
    Write-Output 'Exiting script' | add-content $errorlog_des
    exit 01 | add-content $errorlog_des
  }
  return $Variables_Array, $Keys_Array, $CredPath
}

function Create_ProfileLocation {
  param(
    [Parameter(Mandatory = $true)] [string] $ProfileLocation
  )
  # Create a profile location area for documents if it does not exist yet
  Try {
    if (-Not (Test-Path $ProfileLocation)) {
      New-Item -Path 'C:\' -Name "aws_service_cred" -ItemType "directory"
    }
    Write-Output 'Creating the profile location has been properly achieved' | add-content $succeslog_des
  }
  catch {
    Write-Output "An error occurred, the file location for the AWS profile has not been properly created" | add-content $errorlog_des
  }
}

function Set_Credentials {
  param(
    [Parameter(Mandatory = $true)] [array] $Keys_Array,
    [Parameter(Mandatory = $true)] [array] $Variables_Array
  )
  try {
    $ProfileLocation = $CredPath.Replace("\credentials", "")
    Create_ProfileLocation -ProfileLocation $ProfileLocation
    Set-AWSCredentials -AccessKey $Keys_Array[0] -SecretKey $Keys_Array[1] -StoreAs 'AWS_OT' -ProfileLocation $CredPath
    Get-AWSCredential -ListProfileDetail -Profilelocation $CredPath
    Test-S3Bucket -BucketName $Variables_Array[2] -ProfileName 'AWS_OT' -Profilelocation $CredPath
    Write-Output 'The credentials for the AWS profile have been succesfully set' | add-content $succeslog_des
  }
  catch {
    Write-Output 'Testing the access to the S3 bucket failed. Check the AWS S3 Bucket state and network restrictions and bucket profiles' | add-content $errorlog_des
    Write-Output 'Exiting script' | add-content $errorlog_des
    exit 02 | add-content $errorlog_des
  }
  return $ProfileName
}

function Test_S3Bucket {
  param(
    [Parameter(Mandatory = $true)] [array] $Variables_Array,
    [Parameter(Mandatory = $true)] [array] $Keys_Array
  )
  Test-S3Bucket -BucketName $Variables_Array[2] -ProfileName 'AWS_OT' -ProfileLocation $CredPath
  Get-S3Object -BucketName $Variables_Array[2] -ProfileName 'AWS_OT' -ProfileLocation $CredPath
  Write-Output 'The access to the S3 bucket has been succesfully tested' | add-content $succeslog_des
  # try {
  Test-S3Bucket -BucketName $Variables_Array[2] -ProfileName default -ProfileLocation $CredPath
  Get-S3Object -BucketName $Variables_Array[2] -ProfileName default -ProfileLocation $CredPath
  Write-Output 'The access to the S3 bucket has been succesfully tested' | add-content $succeslog_des
  # }
  # catch {
  #   Set_Credentials -Variables_Array $Variables_Array -Keys_Array $Keys_Array
  # }
}

function Create_Staging {
  $FileShareStagingLocation = 'C:\_NoBackup\TestS3Access' ###Put this in the ENV Variables
  # Create a Staging area for documents if it does not exist yet
  Try {
    if (-Not (Test-Path "$FileShareStagingLocation/staging/")) {
      New-Item -Path $FileShareStagingLocation -Name "staging" -ItemType "directory"
    }
    Write-Output 'Creating the staging area has been properly achieved' | add-content $succeslog_des
  }
  catch {
    Write-Output "An error occurred, the file location for the staging area has not been properly created" | add-content $errorlog_des
  }
}

function Select_Uploading {
  # Put the different profile maps in an Array
  $UploadUserArray = Get-ChildItem $FileShareUserLocation | Where-Object { $_.PSIsContainer } | Foreach-Object { $_.Name }

  $Job = @()
  foreach ($UserFolder in $UploadUserArray) {
    try {
      # Only start the Job if the folder contains users
      $directoryInfo = Get-ChildItem "$FileShareUserLocation\$UserFolder" | Measure-Object
      if ($directoryInfo.count -ne 0) {
        Write-Output "Starting job $UserFolder"
        $Job += start-job -name "S3Upload-$UserFolder" -ScriptBlock $ScriptBlock_Upload -ArgumentList $Variables_Array, $UserFolder, $FileShareStagingLocation, $FileShareUserLocation, $succeslog_des, $errorlog_des, $FromEnvironment, $UserProfile, $CredPath
      }
      else {
        Write-Output "Folder $UserFolder is empty, skipping"
      }
    }
    catch {
      Write-Output "Error during uploading/staging the $UserFolder to the S3 Bucket, check the staging folder for content" | add-content $errorlog_des
    }
  }
  $Job | Wait-Job | Remove-Job
}

function Select_Downloading {
  # Put the different profile maps in an Array
  $UploadUserArray = Get-ChildItem $FileShareUserLocation | Where-Object { $_.PSIsContainer } | Foreach-Object { $_.Name }
  $KeyArrayPerUserGroup = @()
  # Get items based in t
  foreach ($User in $UploadUserArray) {
    $VarListKeysFromS3 = "$FromEnvironment/$UserProfile/$User/"
    try {
      $KeyArrayUser = Get-S3Object -BucketName $Variables_Array[2] -ProfileName 'AWS_OT' -KeyPrefix $VarListKeysFromS3 -select 'S3Objects.Key' -ProfileLocation $CredPath
    }
    catch {
      Write-Output "The user:$User does not have any documents to download" | add-content $errorlog_down_des
    }
    if ($null -ne $KeyArrayUser) {
      $KeyArrayPerUserGroup += , $KeyArrayUser
    }
  }
  $Job = @()
  If ($Job -ne $null) { clear-variable results }
  If ($KeyArrayPerUserGroup -ne $null) {
    foreach ($UserKeyCollection in $KeyArrayPerUserGroup) {
      Write-Output "Starting job filling $FileShareUserLocation" | add-content $succeslog_down_des
      try {
        $UserKeyCollection
        $Job += start-job -ScriptBlock $ScriptBlock_Download -ArgumentList $Variables_Array, $UserKeyCollection, $FileShareUserLocation, $succeslog_down_des, $errorlog_down_des, $CredPath
      }
      catch {
        Write-Output "Error during downloading from the S3 Bucket, check the OT environment and logging for downloaded items" | add-content $errorlog_des
      }
    }
    $Job | Wait-Job | Remove-Job
  }
  else {
    Write-Output 'No jobs started, nothing to download'
  }
}

$ScriptBlock_Upload = {
  param($Variables_Array, $UserFolder, $FileShareStagingLocation, $FileShareUserLocation, $succeslog_des, $errorlog_des, $FromEnvironment, $UserProfile, $CredPath)

  ### Moving objects to a staging area ###
  # Create the profile folder in the staging area
  try {
    New-Item -Path "$FileShareStagingLocation/staging" -Name $UserFolder -ItemType "directory"
    Move-Item -Path "$FileShareUserLocation/$UserFolder/*" -Destination "$FileShareStagingLocation/staging/$UserFolder"
    Write-Output "Succesfully moved items to $FileShareStagingLocation/staging/$UserFolder" | add-content $succeslog_des
  }
  catch {
    Write-Output "Unable to create a folder in the staging area for $UserFolder or Unable to move files to the staging area in: $UserFolder" | add-content $errorlog_des
  }
  ### Uploading Items to the S3 Bucket ###
  try {
    $TimeStamp = Get-Date -Format "yyyyMMddHHmm"
    Write-Output "Start writing items to $FileShareStagingLocation/staging/$UserFolder to the AWS S3 Bucket on $TimeStamp" | add-content $succeslog_des
    Write-S3Object -BucketName $Variables_Array[2] -ProfileName 'AWS_OT' -Folder "$FileShareStagingLocation/staging/$UserFolder" -Recurse -KeyPrefix "$FromEnvironment\$UserProfile\$UserFolder" -ProfileLocation $CredPath
    $TimeStamp = Get-Date -Format "yyyyMMddHHmm"
    Write-Output "Succesfully completed uploading all items in $FileShareStagingLocation/staging/$UserFolder to the AWS S3 Bucket on $TimeStamp" | add-content $succeslog_des
  }
  catch {
    Write-Output "An error occurred, the files at $UserFolder have not been properly uploaded to the AWS S3 bucket" | add-content $errorlog_des
  }
  ### Delete items from the staging area ###
  try {
    Remove-Item "$FileShareStagingLocation/staging/$UserFolder" -Recurse -Force
    Write-Output "Removed the folder at $FileShareStagingLocation/staging/$UserFolder" | add-content $succeslog_des
  }
  catch {
    Write-Output "Unable to delete the designated folder $UserFolder" | add-content $errorlog_des
  }
}

$ScriptBlock_Download = {
  param($Variables_Array, $UserKeyCollection, $FileShareUserLocation, $succeslog_down_des, $errorlog_down_des, $CredPath)
  ### Downloading Items to the S3 Bucket ### #CHANGE
  try {
    $TimeStamp = Get-Date -Format "yyyyMMddHHmm"
    Write-Output "Start writing items to $FileShareUserLocation from the AWS S3 Bucket on $TimeStamp"
    foreach ($Key in $UserKeyCollection) {
      # Regex the foldername
      $TargetLocation = $Key -creplace '^../.*?/'
      $TargetLocation = "$FileShareUserLocation/$TargetLocation"
      # Download the specific file, the folders will be created if they don't exist
      Read-S3Object -BucketName $Variables_Array[2] -ProfileName 'AWS_OT' -Key $Key -File $TargetLocation -ProfileLocation $CredPath
      $TimeStamp = Get-Date -Format "yyyyMMddHHmm"
      Write-Output "Downloaded $Key at $TimeStamp" | add-content $succeslog_down_des
      # Delete the document if it does not exist
      Remove-S3Object -BucketName $Variables_Array[2] -ProfileName 'AWS_OT' -Key $Key -ProfileLocation $CredPath -Force
      Write-Output "Removed $Key at $TimeStamp" | add-content $succeslog_down_des
    }
    $TimeStamp = Get-Date -Format "yyyyMMddHHmm"
    Write-Output "Succesfully completed downloading all items to $FileShareUserLocation on $TimeStamp" | add-content $succeslog_down_des
  }
  catch {
    $error  | add-content $errorlog_down_des
    Write-Output "An error occurred, the files downloaded from the s3 to $FileShareUserLocation did not succeed" | add-content $errorlog_down_des
  }
}

function main {
  $Variables_Array = ''
  $Keys_Array = ''
  Write-Output "##### Starting the upload at $logdate #####" | add-content $succeslog_des
  Invoke_Modules
  $Variables_Array, $Keys_Array = Get_AccessKeys
  Test_S3Bucket -Variables_Array $Variables_Array -Keys_Array $Keys_Array
  if ($type -eq "upload") {
    Create_Staging
    Select_Uploading -Variables_Array $Variables_Array
  }
  elseif ($type -eq "download") {
    Select_Downloading -Variables_array $Variables_Array
  }
  else {
    exit 1
  }
}

#Logfiles
$logdate = (Get-Date -format "dd-MM-yyy")
$succeslog_des = "$LogDirectory\Succeslog_description " + $logdate + ".txt"
$errorlog_des = "$LogDirectory\Errorlog_description " + $logdate + ".txt"
if ($Type -eq 'download') {
  $succeslog_down_des = "$LogDirectory\succeslog_down_description " + $logdate + ".txt"
  $errorlog_down_des = "$LogDirectory\errorlog_down_description " + $logdate + ".txt"
}


#entry point
main
