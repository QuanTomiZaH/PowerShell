$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$root = ""

$date = get-date -format dd-MM-yyyy

$directories = get-childitem -path $root -Directory -Recurse -filter "*" | Select-Object -ExpandProperty fullname

$totalfiles = (Get-ChildItem -filter *.xls* -File -path $root -Recurse).count

$results = @()

$objExcel = New-Object -ComObject Excel.Application
$ObjExcel.Visible = $false
$objExcel.DisplayAlerts = $false

foreach ($directory in $directories) {
    $files = Get-ChildItem -filter *.xls* -File -path $directory
    foreach ($file in $files) {
        $Excelfile = $file.fullname
        $document = $objExcel.Workbooks.Open($ExcelFile)
        $status = $document.ContentTypeProperties | select-object -ExpandProperty value
        if ($status -eq $null) { $status = "" }
        $results += [PSCustomObject]@{
            Directory = $directory
            Name      = $file.Name
            Fullname  = $file.FullName
            Status    = $status
        }
        $document.Saved = $true
        $document.close()
        Clear-Variable status
        $i++
        Write-Progress -Activity "Processing files..." -status "Processed $i of $($totalfiles)" -PercentComplete ($i * 100 / $($totalfiles))
    }
}

$results | export-csv "$root\detailed results $date.csv" -NoTypeInformation -Delimiter ";"

$results.status | Group-Object | select name, count >> "$root\report $date.txt"
$countfiles = $results.count
$countdirectories = ($results.directory | select-object -Unique).count

"Total directories: $countdirectories" | Add-Content "$root\report $date.txt"
"Total files: $countfiles" | Add-Content "$root\report $date.txt"

$testformulieren = $results | where-object { $_.directory -like "" } | group-object status | select name, count | sort-object count -Descending
$instelformulieren = $results | where-object { $_.directory -like "" } | group-object status | select name, count | sort-object count -Descending

$instelformulieren >> "$root\report $date.txt"
$testformulieren >> "$root\report $date.txt"

$objExcel.quit()

$stopwatch.Stop()

$stopwatch.Elapsed >> "$root\runtime.txt"

write-output $stopwatch.Elapsed.TotalSeconds
