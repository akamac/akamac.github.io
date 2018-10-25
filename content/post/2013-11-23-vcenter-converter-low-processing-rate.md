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
If you experience too slow conversion speed while doing P2V migration or other conversion task and see no reason for this, the solution might be to disable SSL encryption for data transfers between agent and server. To accomplish this open the file &#8216;C:\ProgramData\VMware\VMware vCenter Converter Standalone\converter-worker.xml&#8217;, navigate to **nfc** section of xml and set false in **useSSL** tag. Restarting &#8216;Converter Worker&#8217; service is required. Hope this&#8217;ll help!