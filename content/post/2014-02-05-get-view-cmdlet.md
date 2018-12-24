---
title: The power of Get-View
date: 2014-02-05
tags:
  - PowerCLI
  - Get-View
  - LinkedView
  - UpdateViewData
---

Today we're going to discover very powerful Get-View cmdlet. I'm sure most of you have seen it in many scripts found across the web. This cmdlet returns .NET view objects thus exposing API methods and properties to PowerShell environment. This is crucial in advanced manipulating with vSphere infrastructure.

First, it's worth mentioning that getting implementation objects (those produced by `Get-VM`, `Get-VMHost`, etc) takes more time than getting view objects, though in the last versions I found the gap decreased significantly. Let's discover the available parameters that need to be discussed:

### -VIObject, -Id
  
View object can be retrieved by MoRef `-Id` or by passing the impl object `-VIObject` to the cmdlet. Don't forget to use `-Server` parameter when retrieving objects by MoRef if you are working with multiple default vCenter servers since MoRefs are not unique across different vCenter servers.

### -Property
  
This parameter allows you to limit the object properties to be retrieved and can significantly speed up the query execution. Going ahead, one interesting thing you may wonder while using this parameter together with `-Filter`: does the property that objects are filtered by need to be specified here? The answer is no, they do not.

### -Filter
  
This parameter accepts a hash table: `@{Name='^TestVM[1-9]$'; 'Config.Version'='7'; 'Snapshot'=''}`, where both keys and values represent the strings and imply that for any object returned every specified key must match the corresponding value. The key can be any nested property but not the property of linked object - for linked objects use `-SearchRoot` parameter (more on that later). You can use the power of regular expressions for value strings. You may wonder how to test whether the property exists for the object? Just specify this property with the empty value. The example above will filter all vms with name matching `TestVM`, hardware version equal to `vmx-07` and for which at least one snapshot exists.
  
Filtering on the server side prevents the objects that don't satisfy the specified criteria to be transfered to the client, thus it again increases the performance.

### -ViewType

The parameter allows you to query for object of a specific type. To learn more about types, inheritance and so on go to [API reference guide](https://code.vmware.com/apis/449/vsphere).

Another really useful types of objects that can be retrieved by Get-View are different types of managers. The full list can be obtained with `(Get-View ServiceInstance).Content` call.
  
One can use them to manipulate alarms (`Get-View AlarmManager`), tasks (`Get-View TaskManager`), files and so on. So it's very useful stuff too.

---

Ok, this part is done. Now let's explore the base view object. We have an interesting liaison here: `UpdateViewData()` method and `.LinkedView` property.
  
Until `UpdateViewData()` is invoked, the `.LinkedView` property is empty. Parameters of `UpdateViewData()` invocation are (multiple) properties of the current or linked object you want to obtain. Together with a property name, we can specify a property object type. In some cases it's quite useful to restrict the possible values, if the property is the list of object of different types. Let's see an example: consider navigating through inventory folders - every time you want to get the child objects, but only those of type *Folder*:

{{< highlight powershell >}}
$FolderView = Get-View -ViewType Folder -Property Name -Filter @{Name='RootFolder'}
# The call will retrieve ChildEntity property for the current folder. No linked views are populated
$FolderView.UpdateViewData('ChildEntity')
# The call below will fill the LinkedView property
$FolderView.UpdateViewData('ChildEntity.*')
# or you can restrict the child objects retrieved to folders with only Name and ChildEntity properties obtained
$FolderView.UpdateViewData('[Folder]ChildEntity.Name','[Folder]ChildEntity.ChildEntity')</pre>
{{< /highlight >}}

The type restriction is neccessary when you specify the property path that include containers and this property doesn't belong to all entities a container can include. Thus `$FolderView.UpdateViewData('ChildEntity.ChildEntity')` won't work because folder can include vm objects for which `ChildEntity` property isn't defined.

Got it? Then another example of digging even deeper:

{{< highlight powershell >}}
$VmView = Get-View -ViewType VirtualMachine -Property Name -Filter @{Name='TestVM'}
$VmView.UpdateViewData('Runtime.Host.Datastore.Name')
# will extract the names of all datastores connected to host where vm is currently running
$VmView.Runtime.LinkedView.Host.LinkedView.Datastore.Name
{{< /highlight >}}

So, instead of calling Get-View multiple times you can leverage `UpdateViewData()` method call. It [really accelerates](http://www.vnugglets.com/2012/08/even-faster-powercli-code-with-get-view.html) your scripts where you need to get nested view objects.

Now that you are aware of the foundation of advanced PowerCLI scripting, use `Get-View` in your scripts when processing the bulk of data and the speed is a vital factor. When operating few objects stay with common impl-getting cmdlets not to loose the simplicity of your scripts.