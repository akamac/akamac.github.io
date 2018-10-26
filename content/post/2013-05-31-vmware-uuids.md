---
title: VMware UUIDs
date: 2013-05-31
categories:
  - PowerCLI
tags:
  - powercli
  - uuid
---
Hi everybody! My first post is about UUIDs &#8211; identifiers used for virtual machines in vSphere infrastructure. If you ever looked in vm config file (*.vmx) you could see 3 different lines containing 128-bit hex numbers. They are:

  * uuid.bios
  * uuid.location
  * vc.uuid

Because of having some issues with software licensing inside guest OS I decided to explore what the every value is responsible for. Web hasn&#8217;t gave me the complete answer about the meaning of all of these parameters so my investigations led me to the following conclusion I&#8217;d like to share with you.

**uuid.bios** &#8211; this value acts as GUID analog in physical machine, you should keep it to make the license not to get broken. If you want to export VM, for example using vCenter Converter, and run it in VMware Player/Workstation you should also add the following line to exported vmx file together with copying the source uuid.bios value:
  
<span style="padding-left: 10%"><em>uuid.action = &#8220;keep&#8221;</em></span>
  
It prevents player/workstation from asking whether you moved or copied VM with default answer &#8220;I moved it&#8221;. If the valid uuid.bios line is present in config file it will be preserved and the software license will be OK. Another option for uuid.action is &#8220;change&#8221;. In this case VMware will generate the value when you power on VM in new location (host or even folder). You can read [this KB article](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1541) to learn more about it. So the uuid.bios setting is done. Let&#8217;s look through others two.

**uuid.location** is generated every time VM is vMotion&#8217;ed to another host/storage. I guess it&#8217;s used by vCenter for some internal purposes like ..

**vc.uuid** is used by vCenter to identify VM together with MoRef ID you&#8217;ve seen while working with PowerCLI. It&#8217;s unique and is generated when you add VM to inventory (or create VM). If the value is already present in config file (and there is no duplicate in current inventory) it&#8217;s left intact.

That&#8217;s enough for the first post. In the end &#8211; a little piece of PowerShell code to automate the postprocessing of exported VM to ensure its uuid.bios value is the same as source vm&#8217;s. It guarantees the persistence of all licenses that depends on GUID.

Stay tuned, keep learning!