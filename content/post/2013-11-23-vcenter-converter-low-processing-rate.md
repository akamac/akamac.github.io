---
title: vCenter Converter 5 low processing rate
date: 2013-11-23
categories:
  - vSphere
tags:
  - slow
  - SSL
  - vCenter Converter
---

If you experience too slow conversion speed while doing P2V migration or other conversion task and see no reason for this, the solution might be to disable SSL encryption for data transfers between the agent and the server. To accomplish this open the file `C:\ProgramData\VMware\VMware vCenter Converter Standalone\converter-worker.xml` and disable SSL:

```xml
<nfc>
  <useSsl>false</useSsl>
</nfc>
```

Restarting *Converter Worker* service is required. Hope this helps!