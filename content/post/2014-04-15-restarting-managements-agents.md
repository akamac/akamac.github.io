---
title: Restarting managements agents
date: 2014-04-15
type: aside
categories:
  - ESXi
  - PowerCLI
  - Scripting
tags:
  - management agents
  - restart
  - vpxa
---
You know the situation when the host stops reporting its performance counters, do you? CPU and RAM load are showing nils.. A simple two-liner to fix the issue at your disposal:

{{< highlight powershell >}}
Get-View -ViewType HostSystem `
         -Filter @{'Summary.QuickStats.Uptime'='^0$'} `
         -Property Name,ConfigManager | % {
  (Get-View $_.ConfigManager.ServiceSystem).RestartService('vpxa')
} 2>$null
{{< /highlight >}}