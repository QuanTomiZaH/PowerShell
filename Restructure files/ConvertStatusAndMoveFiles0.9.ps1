#input variables used in script
$root = "" #location where to run script
$filefilter = "*.xls*" #Extension which to filter files

#set variables for running script
$date = Get-Date -Format "dd-MM-yyyy HH-mm-ss"
$FoldersToCreate = @('')

#Create log variables
$log = ""

#Retrieve directories in which to run script
$directories = get-childitem "" -path $root -Directory -Recurse | Select-Object -ExpandProperty fullname

#Retrieve the total number of files to be checked
foreach ($directory in $directories) {
    $totalexcelfiles += ($files = Get-ChildItem -filter $filefilter -File -path $directory).count
    $totalfiles += ($files = get-childitem -File -Path $directory -recurse).count
}

#Initialize Excel object to be used in script
$objExcel = New-Object -ComObject Excel.Application
$ObjExcel.Visible = $false
$objExcel.DisplayAlerts = $false

#Create function for time stamps in logs
function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (get-date)
}

#Create function to change status and move data based on status
function SetStatusAndMoveFiles {
    foreach ($directory in $directories) {
        foreach ($FolderToCreate in $FoldersToCreate) {
            if ((Test-Path $directory\$FolderToCreate) -eq $false) {
                new-item -ItemType Directory -Path $directory\$FolderToCreate

            }
        }
        $logdate = Get-TimeStamp
        write-output "$logdate Directories created in $directory" | add-content $log

        $nonexcelfiles = Get-ChildItem -exclude $filefilter -File -path $directory -recurse
        foreach ($nonexcelfile in $nonexcelfiles) {
            Move-Item -Path $nonexcelfile.fullname -destination $directory\Overigen
            $logdate = Get-TimeStamp
            write-output "$logdate File $($nonexcelfile.name) is excluded by filter and therefore moved to directory X" | add-content $log
            write-output "$logdate File $($nonexcelfile.name) was moved to directory X" | add-content $log
        }
        $nonexcelfilescount += $nonexcelfiles.count

        $files = Get-ChildItem -filter $filefilter -File -path $directory

        foreach ($file in $files) {
            $Excelfile = $file.fullname
            $document = $objExcel.Workbooks.Open($ExcelFile)
            $binding = "System.Reflection.BindingFlags" -as [type];
            $builtinProperties = $document.BuiltInDocumentProperties
            $status = $document.ContentTypeProperties | select-object -ExpandProperty value
            if (!$status) {
                $document.Saved = $true
                $document.close()
                $logdate = Get-TimeStamp
                write-output "$logdate File $($file.name) has no SharePoint status" | add-content $log
                move-item -path $file.fullname -Destination $directory\overigen
                $logdate = Get-TimeStamp
                write-output "$logdate File $file.name moved to directory Overigen" | add-content $log
            }
            else {
                $lastwritetime = $file.lastwritetime
                [array]$AryProperties = "Content Status"
                [array]$newValue = "$status"
                $BuiltInProperty = [System.__ComObject].InvokeMember("Item", $binding::GetProperty, $null, $builtinProperties, $AryProperties)
                $BuiltInProperty.[System.__ComObject].invokemember("value", $binding::SetProperty, $null, $BuiltInProperty, $newValue)
                $document.Save()
                $document.close()
                $logdate = Get-TimeStamp
                write-output "$logdate File $($file.name) has status $status and was successfully converted" | add-content $log
                $file.lastwritetime = $lastwritetime
                if (($status -eq 'Voor uitvoering') -OR ($status -eq 'Ingesteld')) {
                    Move-Item -Path $file.fullname -Destination $directory\$status
                    $logdate = Get-TimeStamp
                    write-output "$logdate File $($file.name) was moved to directory $status" | add-content $log
                }
                else {
                    move-item -path $file.fullname -Destination $directory\overigen
                    $logdate = Get-TimeStamp
                    write-output "$logdate File $file.name moved to directory X" | add-content $log
                }
                Clear-Variable status
            }
            $i++
            Write-Progress -Activity "Processing files..." -status "Processed $i of $($totalexcelfiles)" -PercentComplete ($i * 100 / $($totalexcelfiles))
        }
    }
}


#write start process to log
$logdate = Get-TimeStamp
write-output "$logdate Beginning conversion" | add-content $log

#Run function
Try {
    SetStatusAndMoveFiles
}
Catch {
    $logdate = Get-TimeStamp
    write-output "$logdate File $file.fullname was not converted or moved with error $_" | add-content $log
}

#Close Excel object
$objexcel.quit()

#write end process to log
$logdate = Get-TimeStamp
write-output "$logdate Conversion process complete for $totalexcelfiles files" | add-content $log
write-output "$logdate Processed $totalfiles files in total" | add-content $log

#Clear variables
Clear-Variable totalfiles
Clear-Variable totalexcelfiles
#Clear-Variable nonexcelfilescount
