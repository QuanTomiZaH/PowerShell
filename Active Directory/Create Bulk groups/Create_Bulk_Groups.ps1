# Robin Gjaltema 2020-10
#
#
#
Import-Module ActiveDirectory
#Import CSV
$path = Split-Path -parent $MyInvocation.MyCommand.Definition
$newpath = $path + "\bulk_input.csv"
$csv = @()
$csv = Import-Csv -Path $newpath

#Get Domain Base
$searchbase = Get-ADDomain | ForEach-Object { $_.DistinguishedName }

#Loop through all items in the CSV
ForEach ($item In $csv) {
  #Check if the OU exists
  $check = [ADSI]::Exists("LDAP://$($item.GroupLocation),$($searchbase)")

  If ($check -eq $True) {
    Try {
      #Check if the Group already exists
      Get-ADGroup $item.GroupName | Out-Null
      Write-Host "Group $($item.GroupName) alread exists! Group creation skipped!"
    }
    Catch {
      #Create the group if it doesn't exist
      New-ADGroup -Name $item.GroupName -GroupScope $item.GroupType -Description $item.Description -Path ($($item.GroupLocation) + "," + $($searchbase))  | Out-Null
      Write-Host "Group $($item.GroupName) created!"
    }
  }
  Else {
    Write-Host "Target OU can't be found! Group creation skipped!"
  }
}
