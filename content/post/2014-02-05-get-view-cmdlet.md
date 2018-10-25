---
title: The power of Get-View
date: 2014-02-05
categories:
  - PowerCLI
tags:
  - Filter
  - Get-View
  - LinkedView
  - Manager
  - UpdateViewData
---
Today we&#8217;re going to discover very useful Get-View cmdlet. I&#8217;m sure most of you have seen it in many scripts found across the web. This cmdlet returns .NET view objects thus exposing API methods and properties to PowerShell environment. This is crucial in advanced manipulating with vSphere infrastructure.

First it&#8217;s worth mentioning that getting implementation objects (those produced by Get-VM, Get-VMHost, etc) takes more time than getting view objects, though in the last versions I found the gap decreased significantly. In fact impl objects are composed of the properties of corresponding view objects.

Let&#8217;s discover the available parameters that need to be discussed:

**-VIObject, -Id**
  
View object can be retrieved by MoRef (-Id) or by passing the impl object (-VIObject) to cmdlet. Don&#8217;t forget to use -Server parameter when retrieving objects by MoRef if you are working with multiple _default_ vCenter servers since MoRef are not unique across different vCenter servers.

**-Property**
  
This parameter allows you to limit the object properties to be retrieved that can significantly speed up the query execution. Going ahead, one interesting thing you may wonder while using this parameter together with -Filter: does the property that objects are filtered by need to be specified here? The answer is no, they don&#8217;t.

**-Filter**
  
This parameter accepts the hash table:
  
<span class="lang:default decode:true  crayon-inline crayon-selected">@{Name=&#8217;^TestVM[1-9]$&#8217;; &#8216;Config.Version&#8217;=&#8217;7&#8217;; &#8216;Snapshot&#8217;=&#8221;}</span>
  
where both keys and values represent the strings and imply that for any object returned every specified key must match the corresponding value. The key can be any nested property but not the property of linked object &#8211; for linked objects use -SearchRoot parameter (more on that later). You can use the power of regular expressions for value strings. You may wonder how to test whether the property exists for the object? Just specify this property with the empty value. The example above will filter all vms with name matching &#8216;TestVM&#8217;, hardware version equal to &#8216;vmx-07&#8217; and for which at least one snapshot exists.
  
Filtering on the server side prevents the objects that don&#8217;t satisfy the specified criteria to be transfered to the client thus it again increases the performance.

**-ViewType**
  
Unfortunately cmdlet implementation is missing the list of possible values for this parameter (any reason this can&#8217;t be implemented?). You can find out accepted viewtypes by calling Get-View with any incorrect string. Having the list it&#8217;s easy to understand which type to use in a query. To learn more about types, inheritance and so on go to <a title="API reference guide" href="http://pubs.vmware.com/vsphere-55/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc%2Fright-pane.html" target="_blank">API reference guide</a>.

Another really useful objects that can be retrieved by Get-View are different types of managers. The full list can be obtained with &#8216;(Get-View ServiceInstance).Content&#8217; call.
  
One can use them to manipulate alarms (Get-View AlarmManager), tasks (Get-View TaskManager), files and so on. So it&#8217;s very useful stuff too.

Ok, this part is done. Now let&#8217;s explore the base view object.
  
We have an interesting liaison here: **UpdateViewData** method and **LinkedView** property.
  
Until UpdateViewData is invoked the LinkedView property is empty. Parameters of UpdateViewData invocation are the (multiple) properties of current or linked object you want to obtain. Together with the property name we can specify the property object type. In some cases it&#8217;s quite useful to restrict the possible values if the property is the list of object of different types. Let&#8217;s see an example because the code is better than thousand words. Consider navigating through inventory folders: every time you want to get the child objects but only those of type &#8216;Folder&#8217;:

<pre class="expand:true lang:ps decode:true" title="LinkedView">$FolderView = Get-View -ViewType Folder -Property Name -Filter @{Name='RootFolder'}
# The call will retrieve ChildEntity property for current folder. No linked views are populated
$FolderView.UpdateViewData('ChildEntity')
# The call below will fill the LinkedView property
$FolderView.UpdateViewData('ChildEntity.*')
# or you can restrict the child objects retrieved to folders with only Name and ChildEntity properties obtained
$FolderView.UpdateViewData('[Folder]ChildEntity.Name','[Folder]ChildEntity.ChildEntity')</pre>

The type restriction is neccessary when you specify the property path that include containers and this property doesn&#8217;t belong to all entities container can include. Thus
  
<span class="lang:default decode:true  crayon-inline ">$FolderView.UpdateViewData(&#8216;ChildEntity.ChildEntity&#8217;)</span>
  
won&#8217;t work because folder can include vm objects for which ChildEntity property isn&#8217;t defined.

Got it? Then another example of digging even deeper:

<pre class="expand:true lang:ps decode:true" title="LinkedView">$VmView = Get-View -ViewType VirtualMachine -Property Name -Filter @{Name='TestVM'}
$VmView.UpdateViewData('Runtime.Host.Datastore.Name')
# will extract the names of all datastores connected to host where vm is currently running
$VmView.Runtime.LinkedView.Host.LinkedView.Datastore.Name</pre>

So, instead of calling Get-View multiple times leverage UpdateViewData method call. It <a title="really accelerates" href="http://www.vnugglets.com/2012/08/even-faster-powercli-code-with-get-view.html" target="_blank">really accelerates</a> your scripts where you need to get nested view objects.

Now you are aware of the foundation of advanced PowerCLI scripting. Use Get-View in your scripts when processing the bulk of data and the speed is a vital factor.
  
When operating few objects stay with common impl-getting cmdlets not to loose the simplicity of your scripts.

There is another batch of interesting information I&#8217;m ready to share.
  
Stay tuned!