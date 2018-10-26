---
title: Retrieve CDP/LLDP info
date: 2014-06-10
categories:
  - PowerCLI
  - PowerShell
  - Scripting
tags:
  - CDP
  - LLDP
  - vmnic
---
Search for an easy way to get CDP/LLDP info for any given ESXi physical port (vmnic)? Here it is!
  
It relies on ObnTransformation from my <a title="OBN transformation" href="http://purple-screen.com/?p=447" target="_blank">previous post</a> and also depends on <a title="PowerShell Community Extensions" href="http://pscx.codeplex.com/" target="_blank">PowerShell Community Extensions</a> for ?? alias (Invoke-NullCoalescing). You can replace the latter with the simple _if_ in case you don&#8217;t have PSCX installed.
  
Keep in mind that (some) devices return MAC instead of the management IP in LLDP info.
  
By default all vmnics are queried.