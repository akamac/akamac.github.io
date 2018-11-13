function Merge-Object {
  param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [Object] $First,
    [Parameter(Mandatory,ValueFromPipeline)]
    [Object] $Second
  )
  if ($First -is [HashTable] -and $Second -is [HashTable]) {
    $First + $Second; return
  }
  if ($First -is [HashTable]) {
    $First = New-Object PSObject -Property $First
  }
  if ($Second -is [HashTable]) {
    $First = New-Object PSObject -Property $Second
  }
  $FirstProperties = ($First | gm -MemberType Properties).Name
  $Merged = $First | Select $FirstProperties
  $Second | gm -MemberType Properties | ? Name -notin $FirstProperties | % {
    $Merged | Add-Member -MemberType NoteProperty -Name $_.Name -Value $Second.($_.Name)
  }
  $Merged
}
if (-not (Test-Path Alias:\Merge)) { New-Alias Merge Merge-Object }
 
function Join-Object {
  param(
    [Parameter(Mandatory)]
    [Object[]] $Left,
    [Parameter(Mandatory)]
    [Object[]] $Right,
    [Parameter(Mandatory)]
    [ValidateSet('Inner','OuterLeft','OuterRight','Outer')]
    [string] $Type,
    [Parameter(Mandatory)]
    [ScriptBlock] $On,
    [switch] $IncludeJoinProperty
  )
  if (($Left | % { $_.GetType() } | Select -Unique).Count -gt 1) {
    throw 'Left array is not homogeneous'
  }
  if (($Right | % { $_.GetType() } | Select -Unique).Count -gt 1) {
    throw 'Right array is not homogeneous'
  }
  # get properties names to join on
  if ($On.ToString() -match "[\$]Left\.(\S+)") { $LeftProperty = $Matches[1] }
  if ($On.ToString() -match "[\$]Right\.(\S+)") { $RightProperty = $Matches[1] }
  # ensure the properties' values are unique
  if (@($Left.$LeftProperty | Select -Unique).Count -lt $Left.Count) {
    throw "Specified property's values in left array are not unique"
  }
  if (@($Right.$RightProperty | Select -Unique).Count -lt $Right.Count) {
    throw "Specified property's values in right array are not unique"
  }
  $Result = @()
  # convert hashtables to psobjects
  if ($Left[0] -is [HashTable]) {
    for ($i = 0; $i -lt $Left.Count; $i++) {
      $Left[$i] = New-Object PSObject -Property $Left[$i]
    }
  }
  if ($Right[0] -is [HashTable]) {
    for ($i = 0; $i -lt $Right.Count; $i++) {
      $Right[$i] = New-Object PSObject -Property $Right[$i]
    } 
  }
  # stub objects for outer joins
  $Properties = New-Object System.Collections.Hashtable
  ($Left[0] | gm -MemberType Properties).Name | % { $Properties.Add($_, $null) }
  $LeftStubObj = New-Object PSObject -Property $Properties

  $Properties = New-Object System.Collections.Hashtable
  ($Right[0] | gm -MemberType Properties).Name | % { $Properties.Add($_, $null) }
  $RightStubObj = New-Object PSObject -Property $Properties

  if ($Type -eq 'OuterRight') {
    # swap objects and properties
    $Param = @{
      Left = $Right
      Right = $Left
      Type = 'OuterLeft'
      On = [ScriptBlock]::Create("`$Left.$RightProperty -eq `$Right.$LeftProperty")
      IncludeJoinProperty = $IncludeJoinProperty.IsPresent
    }
    Join @Param
    return
  }

  foreach ($LeftObj in $Left) {
    $Found = $false
    foreach ($RightObj in $Right) {
      $Pattern = "[\$]Left(.*)[\$]Right(.*)"
      $Replace = "`$LeftObj`$1`$RightObj`$2"
      if (& ([ScriptBlock]::Create(
            ($On.ToString() -replace $Pattern,$Replace)
          ))) {
                if ($Type -match "Outer*") { $Found = $true }
                $Result += $LeftObj | Merge $RightObj |
                Select -ExcludeProperty $LeftProperty, $RightProperty `
                  $(if ($IncludeJoinProperty.IsPresent) {
                    '*', @{N='JOIN';E={$_.($LeftProperty)}}
                  } else { '*' } )
                $Right = $Right -ne $RightObj
                break
              }
    }
    if (!$Found -and $Type -match "Outer*") {
      $Result += $LeftObj | Merge $RightStubObj |
      Select -ExcludeProperty $RightProperty, $LeftProperty `
        $(if ($IncludeJoinProperty.IsPresent) {
          '*', @{N='JOIN';E={$_.($LeftProperty)}}
        } else { '*' } )
    }
  }
  if ($Type -eq 'Outer') {
    $Right | % { $Result += $_ | Merge $LeftStubObj |
      Select -ExcludeProperty $LeftProperty, $RightProperty `
        $(if ($IncludeJoinProperty.IsPresent) {
          '*', @{N='JOIN';E={$_.($RightProperty)}}
        } else { '*' } )
    }
  }
  $Result
}
if (-not (Test-Path Alias:\Join)) { New-Alias Join Join-Object }