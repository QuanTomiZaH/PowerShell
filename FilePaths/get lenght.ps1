#oneliner

Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue |
>>   Where-Object { $_.FullName.Length -gt 260 } | Select FullName -ExpandProperty FullName >> "E:\Functieprofielen\logs.log"


Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName.Length -gt 260 } | Select FullName -ExpandProperty FullName >> "E:\Functieprofielen\logs.log"
