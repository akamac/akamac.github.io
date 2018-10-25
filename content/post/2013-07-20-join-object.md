---
title: Join-Object
date: 2013-07-20
categories:
  - PowerShell
tags:
  - join-object
  - merge-object
  - powershell
---
If you ever wrote SQL queries and now use PowerShell for scripting maybe you missed &#8216;Join&#8217; possibility in PoSH. Here it is!
  
Nothing special. I just tried to create Join-Object with the same functionality as inner/outer Join statements in SQL. My version of Join-Object uses standalone Merge-Object function for merging 2 arrays of custom objects / hashtables. Resulting object is an array of objects that contains all properties from joined objects except the ones with the same name, which are discarded. If you also want to include the property on which you join the collections use $IncludeJoinProperty switch. The expression for specifying the property to join on is that simple:
  
<span class="minimize:true lang:ps decode:true  crayon-inline " >-On {$Left.&#8217;propertyName&#8217; -eq $Right.&#8217;propertyName&#8217;}</span>
  
Collections to be joined must contain objects of the same type otherwise the error is generated. Also function throws an error in case of the values of join property in collection (left or right) are not unique. Merge and Join aliases added by default.
  
If you have any questions drop me a line in comments. Use it on your own risk :)

<pre class="expand:true lang:ps decode:true " title="Join-Object" >function Merge-Object {
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object] $First,
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object] $Second
    )
    if ($First -is [HashTable] -and $Second -is [HashTable]) { $First + $Second; return }
    if ($First -is [HashTable]) { $First = New-Object PSObject -Property $First }
    if ($Second -is [HashTable]) { $First = New-Object PSObject -Property $Second }
    $FirstProperties = ($First | gm -MemberType Properties).Name
    $Merged = $First | Select $FirstProperties
    $Second | gm -MemberType Properties | ? Name -notin $FirstProperties |
    % { $Merged | Add-Member -MemberType NoteProperty -Name $_.Name -Value $Second.($_.Name) }
    $Merged
}
if (-not (Test-Path Alias:\Merge)) { New-Alias Merge Merge-Object }
 
function Join-Object {
    Param (
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
    if (($Left | % { $_.GetType() } | Select -Unique).Count -gt 1) { throw 'Left array is not homogeneous' }
    if (($Right | % { $_.GetType() } | Select -Unique).Count -gt 1) { throw 'Right array is not homogeneous' }
    # get properties names to join on
    if ($On.ToString() -match "[\$]Left\.(\S+)") { $LeftProperty = $Matches[1] }
    if ($On.ToString() -match "[\$]Right\.(\S+)") { $RightProperty = $Matches[1] }
    # ensure the properties' values are unique
    if (@($Left.$LeftProperty | Select -Unique).Count -lt $Left.Count) {
        throw "Specified property's values in left array are not unique" }
    if (@($Right.$RightProperty | Select -Unique).Count -lt $Right.Count) {
        throw "Specified property's values in right array are not unique" }
    $Result = @()
    # convert hashtables to psobjects
    if ($Left[0] -is [HashTable]) { for ($i = 0; $i -lt $Left.Count; $i++) { $Left[$i] = New-Object PSObject -Property $Left[$i] } }
    if ($Right[0] -is [HashTable]) { for ($i = 0; $i -lt $Right.Count; $i++) { $Right[$i] = New-Object PSObject -Property $Right[$i] } }
    # stub objects for outer joins
    $Properties = New-Object System.Collections.Hashtable
    ($Left[0] | gm -MemberType Properties).Name | % { $Properties.Add($_, $null) }
    $LeftStubObj = New-Object PSObject -Property $Properties
 
    $Properties = New-Object System.Collections.Hashtable
    ($Right[0] | gm -MemberType Properties).Name | % { $Properties.Add($_, $null) }
    $RightStubObj = New-Object PSObject -Property $Properties
 
    if ($Type -eq 'OuterRight') {
        # swap objects and properties
        Join $Right $Left OuterLeft ([ScriptBlock]::Create("`$Left.$RightProperty -eq `$Right.$LeftProperty")) `
        -IncludeJoinProperty:($IncludeJoinProperty.IsPresent)
        return
    }
 
    foreach ($LeftObj in $Left) {
        $Found = $false
        foreach ($RightObj in $Right) {
            if (& ([ScriptBlock]::Create(($On.ToString() -replace "[\$]Left(.*)[\$]Right(.*)","`$LeftObj`$1`$RightObj`$2")))) {
                if ($Type -match "Outer*") { $Found = $true }
                $Result += $LeftObj | Merge $RightObj | Select -ExcludeProperty $LeftProperty, $RightProperty `
                $(if ($IncludeJoinProperty.IsPresent) { '*', @{N='JOIN';E={$_.($LeftProperty)}} } Else { '*' } )
                $Right = $Right -ne $RightObj
                break
            }
        }
        if (!$Found -and $Type -match "Outer*") {
            $Result += $LeftObj | Merge $RightStubObj | Select -ExcludeProperty $RightProperty, $LeftProperty `
            $(if ($IncludeJoinProperty.IsPresent) { '*', @{N='JOIN';E={$_.($LeftProperty)}} } else { '*' } )
        }
    }
    if ($Type -eq 'Outer') {
        $Right | % { $Result += $_ | Merge $LeftStubObj | Select -ExcludeProperty $LeftProperty, $RightProperty `
        $(if ($IncludeJoinProperty.IsPresent) { '*', @{N='JOIN';E={$_.($RightProperty)}} } else { '*' } )
        }
    }
    $Result
}
if (-not (Test-Path Alias:\Join)) { New-Alias Join Join-Object }</pre>