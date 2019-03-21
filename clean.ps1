# Removes all files as specified by -Include.
# To actually delete files: ./clean.ps1 -confirm $true 

# Usage
# 1. Place script into folder
# 2. In Powershell cd to the folder
# 3. Type ./clean.ps1 and press <ENTER>

param ( $confirm )

$currentPath = (Get-Location).toString().Replace("/", "\")

$outputFile = ( "{0}\result.txt" -f $currentPath )
Set-Content $outputFile ""

Start-Transcript $outputFile

if( $confirm )
{
  Remove-Item * -Include *.json, *.xml -Exclude *.ps1 -Recurse -Verbose
}
else
{
  Remove-Item * -Include *.json, *.xml -Exclude *.ps1 -Recurse -WhatIf
}

Stop-Transcript