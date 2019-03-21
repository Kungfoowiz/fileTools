# Finds structure/patterns in files and outputs them to a hunted file.
# Modify -Include to specify what files.
# Modify Structure and Sanitise to customise outputted structure.
# To delete original files: ./hunt.ps1 -confirm $true 

# Usage
# 1. Place script into folder
# 2. In Powershell cd to the folder
# 3. Type ./hunt.ps1 and press <ENTER>

param ( $confirm )

$currentPath = (Get-Location).toString().Replace("/", "\")

$targetPath = ( "{0}\*" -f $currentPath )

$outputFile = ( "{0}\hunted.csv" -f $currentPath )
Set-Content $outputFile ""

# INCLUDE
$files = Get-ChildItem $targetPath -Recurse -Include *.json, *.xml

$currentName = ""
$nextName = ""

foreach( $file in $files)
{

  # Get containing folder name file is in.
  $nextName = Split-Path -Leaf ( Split-Path -Parent $file.FullName )


  if( $nextName -ne $currentName )
  {
    Add-Content $outputFile "`r`n"
    Add-Content $outputFile "`r`n--------------------------------------------------------------,"
    Add-Content $outputFile ( "NAME {0} ," -f $nextName)
    Add-Content $outputFile "--------------------------------------------------------------,`r`n"
    $currentName = $nextName
  }

  
  $fileContent = Get-Content $file.FullName

  foreach($line in $fileContent )
  {
  
    
    # Find this STRUCTURE.
    $structure = '("permalink": ")|("image_url": ")'
    $found = $line -match $structure

    if( $found ){
      
      # SANITISE.
      $result = $line.Replace('"permalink": "', "")
      $result = $result.Replace('"image_url": "', "")

      $result = $result.Replace( '"', "")
      $result = $result.Trim()
      $result = $result.Replace( "\/", "/" )
      
      $result = ( "{0}," -f $result )

      
      Add-Content $outputFile $result
      
    }

  }

  if( $confirm )
  {
    Remove-Item $file.FullName -Force
  }

}