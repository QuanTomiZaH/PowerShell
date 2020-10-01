#Importing CSV
$CompareCsV = Import-Csv -Path ""

#Add the paths where the documents are
$NewPathStart = ""
$OldPathStart = ""
$CompareCsV.Count

#Lege Arrays voor de controle
$ArraySucces = @()
$ArrayFailure = @()

Foreach ($Row in $CompareCsV) {
    #$Row.GetType()
    $Row
    #$OldPath = $Row.File
    #Write-Output $OldPath
    #$TargetPath = $OldPath.replace($OldPathStart, $NewPathStart)

    Try {
        #Copy-Item -Path $OldPath -Destination $TargetPath -Force
        #Write-Output "Het is gelukt om $OldPath te verplaatsen naar de nieuwe structuur"
        $ArraySucces += $OldPath
    }
    Catch {
        #Write-Output "Het is niet gelukt om $OldPath te verplaatsen"
        $ArrayFailure += $OldPath
    }
}


#Count documents in both files
Write-Output "Array Success:"
#$ArraySucces | Out-File -FilePath  ""
$ArraySucces.count

Write-Output "Array Failure:"
#$ArrayFailure | Out-File -FilePath ""
$ArrayFailure.count
