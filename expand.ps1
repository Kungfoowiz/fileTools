
# Iterates all files.
# Creates folders for each file based on first and last names in the file name.
# Moves the files into their firstName_lastName folder.
# Unmatched files are placed into an Unmatched_UniqueID folder.

# Modify Include to specify what files.
# Modify Output Structure to customise outputted structure.

# To check what the command will do: ./expand.ps1
# Check .\log.txt for details.

# To confirm folder creation and moving the files: ./expand.ps1 -confirm $true 

# Usage
# 1. Place script and .\dataset folder into a folder
# 2. Place all files you want iterated into .\target folder
# 3. In Powershell cd to the folder
# 4. Type   ./expand.ps1 -confirm $true    Press <ENTER>


param( $confirm )


$currentPath = (Get-Location).toString().Replace("/", "\")

$targetPath = ( "{0}\target\*" -f $currentPath )

$outputPath = ".\output\"


# Datasets are used to match first and last names.
$firstNamesDataset = Get-Content ( $currentPath + "\dataset\first_names.csv" )
$lastNamesDataset = Get-Content ( $currentPath + "\dataset\last_names.csv" )


$log = ".\log.txt"
Set-Content $log ( "Time started {0}" -f ( Get-Date -format "dd-MM-yyyy HH:mm:ss.fffff" ) )



# INCLUDE
$files = Get-ChildItem $targetPath

$index = 0
$indexTotal = $files.Length


foreach( $file in $files )
{

  $guid = New-Guid

  $fullName = ""

  $firstName = ""
  $firstNameFound = $false

  $lastName = ""
  $lastNameFound = $false

  $fileName = $file.BaseName


  # Split base file name into words.
  $words = $fileName -split " "


  # First name search.

  # Iterate words, match against first names dataset.
  foreach( $word in $words )
  {

    if( $firstNameFound )
    {
      break
    }

    foreach( $first in $firstNamesDataset )
    {

      if( $word -eq $first )
      {

        if( $word.Length -gt $firstName.Length )
        {
          $firstName = $first
          $firstNameFound = $true
          break
        }
      }

    }

  }



  # Last name search.

  # Iterate words, match against first names dataset.

  # Save any character position of any found first name,
  # so we create words only after that position onwords.
  $lastNameStartIndex = $fileName.IndexOf( $firstName ) + $firstName.Length

  if( $lastNameStartIndex -lt 0 )
  {
    $lastNameStartIndex = 0
  }

  $words = ( $fileName.SubString( $lastNameStartIndex ) ) -split " "


  foreach( $word in $words )
  {

    if( $lastNameFound )
    {
      break
    }

    foreach( $last in $lastNamesDataset )
    {

      if( $word -eq $last )
      {

        if( $word.Length -gt $lastName.Length )
        {
          $lastName = $last
          $lastNameFound = $true
          break
        }
      }

    }

  }



  
  


  # OUTPUT STRUCTURE


  
  if( $firstName -eq "" -and $lastName -eq "")
  {
    $fullName = ( "Unmatched_{0}" -f $guid )
  }

  elseif( $firstName -eq "")
  {
    $fullName = ( "Unmatched_FirstName_{0}_{1}" -f $lastName, $guid )
  }

  elseif( $lastName -eq "" )
  {
    $fullName = ( "Unmatched_LastName_{0}_{1}" -f $firstName, $guid )
  }

  else
  {
    $fullName = ( "{0}_{1}" -f $firstName, $lastName )
  }




  $targetOutputPath = $outputPath + $fullName
  
  if( ( Test-Path -Path $targetOutputPath ) -eq $false ){

    if( $confirm )
    {
      New-Item -ItemType directory -Path $targetOutputPath | Out-Null
    }
    
    Add-Content $log ( "creating folder {0}" -f $targetOutputPath )
  }

  
  if( $confirm )
  {
    Move-Item -LiteralPath $file.FullName -Destination $targetOutputPath -Force
  }

  Add-Content $log ( "moving from {0} to {1}" -f $file.FullName, $targetOutputPath  )


  $percentComplete = [Math]::Round( ( $index / $indexTotal * 100 ), 0 )

  
  Write-Progress -Activity "Processing files" `
    -Status ( "{0} of {1} files" -f $index++, $indexTotal ) `
    -PercentComplete $percentComplete



  
}



Add-Content $log ( "Time done {0}" -f ( Get-Date -format "dd-MM-yyyy HH:mm:ss.fffff" ) )