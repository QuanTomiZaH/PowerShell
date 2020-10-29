$OU = "OU=Users,OU=Accounts,DC=<DClocation>"

$folders = Get-ChildItem -Path "<Path>" | select FullName

foreach ($folder in $folders) {
  #Write-Output $folder.FullName
  $acl = get-acl $folder.FullName
  #Write-Output $acl
  $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("<accountname>", "Fullcontrol", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
  #Write-Output $acl.Access
  set-acl $folder.FullName $acl
}
