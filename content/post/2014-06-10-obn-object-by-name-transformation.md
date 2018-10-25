---
title: OBN (Object By Name) transformation
date: 2014-06-10
categories:
  - PowerCLI
  - PowerShell
  - Scripting
tags:
  - object by name
  - OBN
  - transformation
---
You might have known that most of PowerCLI cmdlets parameters accept objects or object names (with wildcard characters allowed). Take a look at New-VM cmdlet: you can pass strings to VMHost, ResourcePool, Datastore, etc. parameters as well as the objects itself. Or maybe you&#8217;ve even never noticed this since it just works!
  
Want the same behavior for your own functions? No problem! Use the function below to perform transparent transformation from any eligible object to the object you need (View or Impl). The neat feature it has is limiting the retrieved properties for view object, what considerably improves performance in some cases.

This is how to integrate it to your own function:

<pre class="expand:true lang:default decode:true " title="OBN usage example">function Get-VMHostInfo {
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [PSObject[]] $VMHost
    )
    Process {
        ObnTransform -Object $VMHost -ObjectType VMHost -View -Properties Config,ConfigManager,Hardware | % {
            # $_ is your object!
        }
    }
}</pre>

The one thing you should be aware of is that it accepts wildcards, while you may think the regular expressions are more powerful tool (and I completely agree with you). The reason I had in mind was to not to confuse users who got used to the default PowerCLI behavior. It&#8217;s up to you to remove _ConvertTo-Regex_ part from _-Filter_ parameter in _Get-View_ call. But in this case sometimes you might be puzzled when the script can&#8217;t find an object with the name you are hundred percent sure exists. Doh! Any braces in the name? Use _[regex]::Escape()_ to escape them.

<pre class="expand:true lang:default decode:true " title="OBN (Object By Name) transformation">function script:ObnTransform {
    Param(
        [Parameter(Mandatory)]
        [PSObject[]] $Object,
        [Parameter(Mandatory)]
        [ValidateSet(
            'Datacenter',
            'Folder',
            'VMHost',
            'ComputeResource',
            'Cluster',
            'ResourcePool',
            'VM',
            'vApp',
            'Datastore',
            'DatastoreCluster',
            'DistributedVirtualSwitch',
            'DistributedPortGroup'
        )]
        [string] $ObjectType,
        [Parameter(Mandatory,ParameterSetName='Impl')]
        [switch] $Impl,
        [Parameter(Mandatory,ParameterSetName='View')]
        [switch] $View,
        [Parameter(ParameterSetName='View')]
        [string[]] $Properties = 'Name',
        [string[]] $VIServer = $global:DefaultVIServers
    )
    Begin {
        $ViewImpl = @{
            Datacenter = [PSCustomObject]@{View = 'Datacenter'; Impl = 'DatacenterImpl'};
            Folder = [PSCustomObject]@{View = 'Folder'; Impl = 'FolderImpl'};
            VMHost = [PSCustomObject]@{View = 'HostSystem'; Impl = 'VMHostImpl'};
            ComputeResource = [PSCustomObject]@{View = 'ComputeResource'; Impl = @('ClusterImpl','VMHostImpl')};
            Cluster = [PSCustomObject]@{View = 'ClusterComputeResource'; Impl = 'ClusterImpl'};
            ResourcePool = [PSCustomObject]@{View = 'ResourcePool'; Impl = 'ResourcePoolImpl'};
            VM = [PSCustomObject]@{View = 'VirtualMachine'; Impl = 'VirtualMachineImpl'};
            vApp = [PSCustomObject]@{View = 'VirtualApp'; Impl = 'VAppImpl'};
            Datastore = [PSCustomObject]@{View = 'Datastore'; Impl = @('VmfsDatastoreImpl','NasDatastoreImpl')};
            DatastoreCluster = [PSCustomObject]@{View = 'StoragePod'; Impl = 'DatastoreCluster'};
            DistributedVirtualSwitch = [PSCustomObject]@{View = 'VmwareDistributedVirtualSwitch'; Impl = @('DistributedSwitchImpl','VmwareVDSwitchImpl')};
            DistributedPortgroup = [PSCustomObject]@{View = 'DistributedVirtualPortgroup'; Impl = 'DistributedPortGroupImpl'}; # Network,OpaqueNetwork
            #VirtualSwitchImpl,VirtualPortGroupImpl - no corresponding ViewTypes
        }
    }
    Process {
        foreach ($CurrentObject in $Object) {
            switch ($CurrentObject.GetType().Name) {
                'string' {
                    $ObjectView = Get-View -ViewType $ViewImpl.$ObjectType.View -Property $Properties -Filter @{Name = ConvertTo-Regex $CurrentObject}
                    if ($Impl.IsPresent) { $ObjectView | Get-VIObjectByVIView }
                    else { $ObjectView }
                    break
                }
                {$_ -in $ViewImpl.Values.View} {
                    if ($Impl.IsPresent) { $CurrentObject | Get-VIObjectByVIView }
                    else {
                        $AbsentProperties = $Properties | ? { -not $CurrentObject.$_ }
                        if ($AbsentProperties) {
                            $CurrentObject.UpdateViewData($AbsentProperties)
                        }
                        $CurrentObject
                    }
                    break
                }
                {$_ -in $ViewImpl.Values.Impl} {
                    if ($View.IsPresent) { $CurrentObject | Get-View -Property $Properties }
                    else { $CurrentObject }
                    break
                }
                default { throw 'Incorrect object type' }
            }
        }
    }
}

function ConvertTo-Regex {
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $WildCardExpression
    )
    '^'+(($WildCardExpression -replace '\*','.*') -replace '\?','.{1}')+'$'
}</pre>