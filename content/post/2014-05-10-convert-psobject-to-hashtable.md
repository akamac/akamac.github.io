---
title: Convert PSObject to hashtable
date: 2014-05-10
categories:
  - PowerShell
  - Scripting
layout: aside
---
<pre class="expand:true lang:ps decode:true crayon-selected" title="Convert PSObject to hashtable">function ConvertTo-Hashtable {
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [PSObject[]] $Object
    )
    Process {
        foreach ($obj in $Object) {
            $ht = [ordered]@{}
            $obj | Get-Member -MemberType *Property | % {
                $ht.($_.Name) = $obj.($_.Name)
            }
            $ht
        }
    }
}</pre>

&nbsp;