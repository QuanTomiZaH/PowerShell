# 2021-01
#
## Parameter Block ##
param(
  [Parameter(mandatory = $true,
    HelpMessage = "Define the type of action is done in this script, options are: 'download' and 'upload'.")]
  [string] $Client,
  [Parameter(mandatory = $true,
    HelpMessage = "Define the type of action is done in this script, options are: 'download' and 'upload'.")]
  [string] $ClientSecret,
  [Parameter(mandatory = $true,
    HelpMessage = "Input the location of the folder which contain all the userprofiles")]
  [string] $BackupPath
)

function get-base64auth() {
  param(
    [Parameter(mandatory = $true)] [string] $ClientSecret,
    [Parameter(mandatory = $true)] [string] $Client
  )
  $Cred = $Client + ':' + $ClientSecret
  $Base64 = [System.Text.Encoding]::UTF8.GetBytes($Cred)
  $Base64Credentials = [Convert]::ToBase64String($Base64)
  $ApiCredentials = "Basic $Base64Credentials"
  return $ApiCredentials
}

# Getting authentication from the API
function get-apiauthentication {
  param(
    [Parameter(Mandatory = $true)] [string] $AuthHeader
  )
  $Endpoint = '<EndPoint>'
  $Header = @{
    'authorization' = $AuthHeader
  }
  $Body = 'grant_type=client_credentials'
  $Token = Invoke-RestMethod -Method Post -Uri $Endpoint -Headers $Header -Body $Body
  $BearerToken = $Token.access_token
  $BearerToken = "Bearer $BearerToken"
  return $BearerToken
}

function get-backup {
  param(
    [Parameter(Mandatory = $true)] [string] $BearerToken,
    [Parameter(Mandatory = $true)] [string] $BackupPath
  )

  $Header = @{
    'authorization' = $BearerToken
  }
  $Endpoint = "<EndPoint>"

  Invoke-RestMethod -Method Get -Uri $Endpoint -Headers $Header | Out-File -FilePath $BackupPath
}

function Main {
  $ApiCredentials = get-base64auth -Client $Client -ClientSecret $ClientSecret
  $BearerToken = get-apiauthentication -AuthHeader $ApiCredentials
  get-backup -BearerToken $BearerToken -BackupPath $BackupPath
}

## EntryPoint ##
Main
