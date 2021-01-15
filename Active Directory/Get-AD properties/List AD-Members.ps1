#Set exportpath

$exportpath = "C:\temp\locatie\Persoonsgegevens.csv"

$searchBase = ""

Get-ADUser -Filter { enabled -eq $true } -SearchBase $searchBase -Properties  EmailAddress, Title, EmployeeNumber | Select-Object SamAccountName, GivenName, Surname, Title, EmailAddress, EmployeeNumber | Export-Csv $exportpath -Append -NoTypeInformation -Delimiter ";" -Encoding Unicode 
