---
title: PowerShell scheduled job output redirection
date: 2013-12-23
categories:
  - PowerShell
  - Scripting
tags:
  - output redirection
  - scheduled task
  - verbose
---
Scheduling the script execution is rather common task. You might know that it&#8217;s possible to manage scheduled tasks in PowerShell with built-in ScheduledTask module cmdlets. To keep track whether the task run successfully or not it&#8217;s quite useful to redirect the output of the script to a file. PowerShell allows output redirection for all stream types (standard/error/warning/etc), see <a title="TechNet about_Redirection help topic" href="http://technet.microsoft.com/en-us/library/hh847746.aspx" target="_blank">TechNet about_Redirection help topic</a>.
  
To be able to run your scripts with -Verbose option you should leverage Advanced_Functions syntax (see [another Core About topic](http://technet.microsoft.com/en-us/library/hh847806.aspx "about_Functions_Advanced")). Just add couple of strings to the beginning of the script

<pre class="lang:ps decode:true">[CmdletBinding()]
Param ()</pre>

and use Write-Verbose cmdlet throughout the script where chatty output is needed. At first glance it seems to be an easy task to combine all mentioned together, but in fact I saw lots of questions across the web where people struggled to make it work. Indeed it took much effort before I succeeded. I&#8217;ve tested many different configuration and most of them didn&#8217;t work for me too. That&#8217;s what I came up with and it worked for me:

<pre class="lang:ps decode:true">Register-ScheduledJob -Name Scheduled -Credential $Cred -Trigger (New-JobTrigger -Daily -At '11:00 PM') -ScriptBlock { D:\Scheduled.ps1 -Verbose *&gt; 'D:\Scheduled.log' }</pre>