# Combines all files in recursive sub folders into single files.
# Modify -Include to specify what files.
# Modify Structure to customise outputted structure.
# To delete original files: ./combine.ps1 -confirm $true 

# Usage
# 1. Place script into folder
# 2. In Powershell cd to the folder
# 3. Type ./combine.ps1 and press <ENTER>

param( $confirm )

$currentPath = (Get-Location).toString().Replace("/", "\")

$targetPath = ( "{0}\*" -f $currentPath )

# INCLUDE
$files = Get-ChildItem $targetPath -Recurse -Include *.json, *.xml

$currentFolder = ""
$nextFolder = ""

foreach( $file in $files)
{

  $fileFullName = ( $file.FullName ).Replace("/", "\")

  # Get containing folder name file is in.
  $nextFolder = Split-Path -Leaf ( Split-Path -Parent $fileFullName )
  
  $outputFile = ( "{0}\{1}_combined.txt" -f $currentPath, $nextFolder )

  if( $nextFolder -ne $currentFolder )
  {
    Set-Content $outputFile ""

    $currentFolder = $nextFolder
  }

  # STRUCTURE
  $name = $file.Name
  $entityName = $name.Replace(".json", "")

  Add-Content $outputFile "`r`n"
  Add-Content $outputFile "--------------------------------------------------------------"
  Add-Content $outputFile ( "ENTITY {0} " -f $entityName )
  Add-Content $outputFile "--------------------------------------------------------------`r`n"

  $fileContent = Get-Content $file

  foreach($line in $fileContent )
  {
    Add-Content $outputFile $line
  }

  if( $confirm )
  {
    Remove-Item $fileFullName -Force
  }

}