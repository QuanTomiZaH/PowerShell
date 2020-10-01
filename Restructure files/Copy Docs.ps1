#Importing CSV
$CompareCsV = Import-Csv -Path ""

#Add the paths where the documents are
$NewPathStart = ""
$OldPathStart = ""
$CompareCsV.Count

Foreach ($Row in $CompareCsV) {
    $OldPath = $Row.File
    $TargetPath = $OldPath.replace($OldPathStart, $NewPathStart)
    $CreatePath = $TargetPath -creplace '\\(?:.(?!\\))+$'

    Try {
        If (!(Test-Path $CreatePath)) {
            New-Item -Path $CreatePath -ItemType Directory
            Write-Output "Komt u maar: $CreatePath"
            Write-Output $TargetPath
        }
        Copy-Item -Path $OldPath -Destination $TargetPath -Force
        #robocopy $OldPath $TargetPath /FFT /MT:64 /r:3 /w:3
        Write-Output "Het is gelukt om $OldPath te kopi�ren naar de nieuwe structuur"
    }
    Catch {
        #Write-Output "Het is niet gelukt om $OldPath te kopi�ren"
    }
}

#Count documents in both files
#Write-Output "Array Success:"
#$ArraySucces | Out-File -FilePath  ""
#$ArraySucces.count

#Write-Output "Array Failure:"
#$ArrayFailure | Out-File -FilePath ""
#$ArrayFailure.count
