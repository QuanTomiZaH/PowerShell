$searchBase = ""

Get-ADUser -Filter * -SearchBase $searchBase -Filter { enabled -eq $true }

#Set exportpath
$exportpath = "C:\temp\locatie\AD-GroupMembers.csv"

#Loop through each user, query user information and user group information. Then, for each group the user is member of export the value into an array which is then appended to the output file
foreach ($user in $users) {
  $userinfo = get-aduser $user
  $groups = Get-ADPrincipalGroupMembership $user
  $groups | ForEach-Object { New-Object PSObject -Property @{ User = $userinfo.SamAccountName; Group = $_.SamAccountName } } | Export-Csv $exportpath -Append -NoTypeInformation -Delimiter ";" -Encoding Unicode 
}
