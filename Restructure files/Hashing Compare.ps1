#Importing CSV
$File1 = Import-Csv -Path ""

#Importing CSV
$File2 = Import-Csv -Path ""


#Compare both CSV files
$Results = Compare-Object -ReferenceObject $File1 -DifferenceObject $File2 -Property HASH -PassThru


$Array = @()
Foreach ($R in $Results) {
    If ( $R.sideindicator -eq "=>" ) {
        $Object = [pscustomobject][ordered] @{

            "File"              = $R.Path
            "Hash"              = $R.HASH
            "Compare indicator" = $R.sideindicator
        }
        $Array += $Object
    }
}

#Count documents in both files
($Array | sort-object HASH | Select-Object * -Unique).count

#Display results in console
$Array
$Array | Export-Csv -Path "" -NoTypeInformation
