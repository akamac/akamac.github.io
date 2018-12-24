---
title: PowerShell scheduled job output redirection
date: 2013-12-23
tags:
  - PowerShell
  - output redirection
  - scheduled task
---

Scheduling the script execution is rather common task. You might know that it's possible to manage scheduled tasks in PowerShell with built-in ScheduledTask module cmdlets. To keep track whether the task ran successfully or not it's quite useful to redirect the output of the script to a file. PowerShell allows output redirection for all stream types (standard/error/warning/etc), see [TechNet about_Redirection help topic](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection).
  
To be able to run your scripts with `-Verbose` option you should leverage *Advanced_Functions* syntax (see [another Core About topic](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced)). Just add couple of strings to the beginning of the script:

```powershell
[CmdletBinding()]
param()
```

and use `Write-Verbose` cmdlet throughout the script where chatty output is needed. At first glance it seems to be an easy task to combine all the mentioned together, but in fact I saw lots of questions across the web where people struggled to make it work. Indeed, it took much effort before I succeeded. I've tested many different configuration and most of them didn't work for me too. That's what I came up with and it worked for me:

```powershell
Register-ScheduledJob .. -ScriptBlock { C:\Scheduled.ps1 -Verbose *> 'C:\Scheduled.log' }
```