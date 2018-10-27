---
title: Convert PSObject to hashtable
date: 2014-05-10
categories:
  - PowerShell
  - Scripting
type: aside
draft: true
---

{{< highlight powershell >}}
function ConvertTo-Hashtable {
    param(
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
}
{{< /highlight >}}