---
title: Expand RDM in virtual compatibility mode
date: 2014-07-23
layout: aside
categories:
  - ESXi
  - vSphere
tags:
  - expand
  - extend
  - HBA
  - no downtime
  - pRDM
  - RDM
  - rescan
  - virtual compatibility mode
  - vMotion
  - vRDM
---
As opposed to the physical RDM mode with the virtual one after expanding the LUN on the storage array side and rescanning HBA vm still can&#8217;t see the increased capacity. The official VMware tutorial says to shutdown vm and re-add RDM. This isn&#8217;t acceptable. The hint to make it happen with no downtime is to vMotion vm after rescanning HBA on the destination host. That&#8217;s it!