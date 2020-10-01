if ((Get-WmiObject win32_computersystem | select-object -ExpandProperty domain) -eq "prd. .it") {
    $Datadisk = ""
    $Beheergroep = ""
    $KAbeheergroep = ""
}
else {
    $Datadisk = ""
    $Beheergroep = ""
}

# Set variables to run script
$rootfoldername = "Postbus"
$Postbus = "$datadisk$rootfoldername"

# Create postbus root directory and set permissions
if ((test-path "$Postbus") -eq $false) {
    New-Item -ItemType Directory -Path $Postbus
    $acl = get-acl $Postbus
    $acl.SetAccessRuleProtection($true, $false)
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(" \Domain Users", "ReadAndExecute", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    if ($KAbeheergroep -gt 0) { $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
    Set-Acl -Path $Postbus $acl


    #create inbox directories
    New-Item -ItemType Directory -Path "$Postbus\Inbox"
    New-Item -ItemType Directory -Path "$Postbus\Inbox\Individuen"

    #create outbox directories
    New-Item -ItemType Directory -Path "$Postbus\Outbox"
    New-Item -ItemType Directory -Path "$Postbus\Outbox\Individuen"

    #create staging directories
    New-Item -ItemType Directory -Path "$Postbus\Outbox\staging"
    New-Item -ItemType Directory -Path "$Postbus\Outbox\staging_groepen"

    #create log directories and remove domain users permission
    New-Item -ItemType Directory -Path "$Postbus\Logs"
    New-Item -ItemType Directory -Path "$Postbus\Logs_groepen"

    #remove domain user access for logs directory
    $acllogs = get-acl "$Postbus\Logs"
    $acllogs.SetAccessRuleProtection($true, $false)
    $acllogs.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    $acllogs.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    if ($KAbeheergroep -gt 0) { $acllogs.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
    set-acl -Path "$Postbus\Logs" -AclObject $acllogs

    #remove domain user access for logs_groepen directory
    $acllogsgroepen = Get-Acl "$Postbus\Logs_groepen"
    $acllogsgroepen.SetAccessRuleProtection($true, $false)
    $acllogsgroepen.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    $acllogsgroepen.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    if ($KAbeheergroep -gt 0) { $acllogsgroepen.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
    set-acl -Path "$Postbus\Logs_groepen" -AclObject $acllogsgroepen

    #remove domain user access for staging directory
    $aclstaging = Get-Acl "$Postbus\Outbox\staging"
    $aclstaging.SetAccessRuleProtection($true, $false)
    $aclstaging.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    $aclstaging.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    if ($KAbeheergroep -gt 0) { $aclstaging.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
    set-acl -Path "$Postbus\Outbox\staging" -AclObject $aclstaging

    #remove domain user access for staging_groepen directory
    $aclstaginggroepen = Get-Acl "$Postbus\Outbox\staging_groepen"
    $aclstaginggroepen.SetAccessRuleProtection($true, $false)
    $aclstaginggroepen.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    $aclstaginggroepen.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    if ($KAbeheergroep -gt 0) { $aclstaginggroepen.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
    set-acl -Path "$Postbus\Outbox\staging_groepen" -AclObject $aclstaginggroepen
}

#import CSV to process for user permissions
$users = Import-Csv -Path C:\Tmp\Postvak-Creation\OT-Users.csv -Delimiter ";"

#set inbox/outbox creation variables for individuals
$IndividualInboxPath = "$Postbus\Inbox\Individuen"
$IndividualOutboxPath = "$Postbus\Outbox\Individuen"

#create inboxes for all users in CSV
foreach ($user in $users) {
    if ((test-path -Path $IndividualInboxPath\$($user.samaccountname)) -eq $false) {
        New-Item -ItemType Directory -Path $IndividualInboxPath\$($user.samaccountname)
        $AclIndividualInbox = get-acl -Path $IndividualInboxPath\$($user.samaccountname)
        $AclIndividualInbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(" \$($user.samaccountname)", "ReadAndExecute", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        $AclIndividualInbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(" \$($user.samaccountname)", "DeleteSubdirectoriesAndFiles, Delete, ReadAndExecute, Synchronize", 'ContainerInherit,ObjectInherit', 'InheritOnly', 'Allow')))
        $AclIndividualInbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        $AclIndividualInbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        if ($KAbeheergroep -gt 0) { $AclIndividualInbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
        $AclIndividualInbox.SetAccessRuleProtection($true, $false)
        set-acl -Path $IndividualInboxPath\$($user.samaccountname) -AclObject $AclIndividualInbox
    }
}

#create outboxes for all users in CSV
foreach ($user in $users) {
    if ((test-path -Path $IndividualOutboxPath\$($user.samaccountname)) -eq $false) {
        New-Item -ItemType Directory -Path $IndividualOutboxPath\$($user.samaccountname)
        $AclIndividualOutbox = get-acl -Path $IndividualOutboxPath\$($user.samaccountname)
        $AclIndividualOutbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(" \$($user.samaccountname)", "Write, ReadAndExecute, Synchronize", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        $AclIndividualOutbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        $AclIndividualOutbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        $AclIndividualOutbox.SetAccessRuleProtection($true, $false)
        if ($KAbeheergroep -gt 0) { $AclIndividualOutbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
        set-acl -Path $IndividualOutboxPath\$($user.samaccountname) -AclObject $AclIndividualOutbox
    }
}

If ((test-path -Path $Postbus\Inbox\Groepen) -eq $false) {
    New-Item -ItemType Directory -Path "$Postbus\Inbox\Groepen"

    #import CSV to process for inbox group permissions
    $groupsandpermissions = import-csv -Path C:\Tmp\Postvak-Creation\Groups-Inbox.csv -Delimiter ";"

    #set inbox/outbox creation variables for groups
    $GroupInboxPath = "$Postbus\Inbox\Groepen"
    $GroupOutboxPath = "$Postbus\Outbox\Groepen"

    #determine unique folders in import
    $uniquedirectories = $groupsandpermissions.foldername | select-object -Unique

    #create inboxes for all groups in CSV
    foreach ($uniquedirectory in $uniquedirectories) {
        New-Item -ItemType Directory -Path $GroupInboxPath\$uniquedirectory
        $aclgroupinbox = get-acl $GroupInboxPath\$uniquedirectory
        $aclgroupinbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        if ($KAbeheergroep -gt 0) { $aclgroupinbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
        $aclgroupinbox.SetAccessRuleProtection($true, $false)
        (get-item $GroupInboxPath\$uniquedirectory).SetAccessControl($aclgroupinbox)
    }

    Clear-Variable aclgroupinbox

    #Set specific group permissions for inbox folders
    foreach ($row in $groupsandpermissions) {
        $aclgroupinbox = get-acl "$GroupInboxPath\$($row.foldername)"
        $aclgroupinbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule((" \" + $row.IdentityReference), $row.Permissions, $row.InheritanceFlags, $row.Propagationflags, $row.AccessControlType)))
        $aclgroupinbox.SetAccessRuleProtection($true, $false)
        #set-acl -path $row.FolderPath $aclgroupinbox
        (get-item $GroupInboxPath\$($row.foldername)).SetAccessControl($aclgroupinbox)
    }

    #clear variables for reuse
    Clear-Variable uniquedirectories
    Clear-Variable uniquedirectory
    Clear-Variable row
}

If ((test-path -Path $Postbus\Outbox\Groepen) -eq $false) {
    New-Item -ItemType Directory -Path "$Postbus\Outbox\Groepen"

    #import CSV to process for outbox group permissions
    $groupsandpermissions = import-csv -Path C:\Tmp\Postvak-Creation\Groups-Outbox.csv -Delimiter ";"

    #determine unique folders in import
    $uniquedirectories = $groupsandpermissions.foldername | select-object -Unique

    #create outboxes for all groups in CSV
    foreach ($uniquedirectory in $uniquedirectories) {
        New-Item -ItemType Directory -Path $GroupOutboxPath\$uniquedirectory
        $aclgroupoutbox = get-acl $GroupOutboxPath\$uniquedirectory
        $aclgroupoutbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Beheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        if ($KAbeheergroep -gt 0) { $aclgroupoutbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($KABeheergroep, "FULLCONTROL", 'ContainerInherit,ObjectInherit', 'None', 'Allow'))) }
        $aclgroupoutbox.SetAccessRuleProtection($true, $false)
        (get-item $GroupOutboxPath\$uniquedirectory).SetAccessControl($aclgroupoutbox)
    }

    Clear-Variable aclgroupoutbox

    #set specific group permissions for outbox folders
    foreach ($row in $groupsandpermissions) {
        $aclgroupoutbox = get-acl $GroupOutboxPath\$($row.foldername)
        $aclgroupoutbox.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule((" \" + $row.IdentityReference), $row.Permissions, $row.InheritanceFlags, $row.Propagationflags, $row.AccessControlType)))
        $aclgroupoutbox.SetAccessRuleProtection($true, $false)
        #set-acl -path $row.FolderPath $aclgroupoutbox
        (get-item $GroupOutboxPath\$($row.foldername)).SetAccessControl($aclgroupoutbox)
    }
}

