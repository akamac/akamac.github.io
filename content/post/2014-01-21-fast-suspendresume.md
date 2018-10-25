---
title: Fast Suspend/Resume
date: 2014-01-21
categories:
  - ESXi
  - PowerCLI
tags:
  - CBT
  - Changed Block Tracking
  - fast suspend resume
  - fsr
---
Have you ever come across the term in subj? It&#8217;s time to reveal what it stands for.
  
First, three examples when this action can be performed.
  
To enable [CBT](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1020128) for virtual machine in addition to make vm reconfiguration one need to perform so called _stun/unstun cycle_ for vm. This could be power on/off, suspend/resume, create/remove snapshot, vm migration.
  
Another example is changing the build type for running vm (release/debug/stats). This can be done in vm advanced settings tab or via command line utils. In order to BuildType change is applied FSR is performed transparently by the 5.x hypervisor (for ESXi 4.x vm is actually suspended and then resumed).
  
And the most frequent one is hot-add hardware to vm.
  
In fact Fast Suspend/Resume equals to migration to the same host &#8211; that&#8217;s simple.

Below you can find an example of CBT enabling script (most of backup tools enable it automatically).

<pre class="expand:true lang:default decode:true " title="Enable CBT" >Get-View -ViewType VirtualMachine -Property Name,Config,Snapshot,Runtime | % {
    if ([int]$_.Config.Version.Split('-')[-1] -gt 4 -and -not $_.Config.ChangeTrackingEnabled -and -not $_.Snapshot) {
        Write-Verbose "Enabling CBT for $($_.Name)"
        $VmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$VmConfigSpec.ChangeTrackingEnabled = $true
        $_.ReconfigVM_Task($VmConfigSpec)
        Write-Verbose "$($_.Name) - performing Fast Suspend Resume to enable CBT"
        $_.MigrateVM_Task($null, $_.Runtime.Host, 'highPriority', $null)
    }
}</pre>