---
title: Enumerating through hashtable in PoSH
date: 2013-07-21
categories:
  - PowerShell
  - Scripting
layout: aside
---
<pre class="expand:true lang:ps decode:true " >$ht = @{a=1; b=2; c=3}
$ht.GetEnumerator() | % { $_.key; $_.value }</pre>