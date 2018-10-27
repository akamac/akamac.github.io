---
title: Expand RDM in virtual compatibility mode
date: 2014-07-23
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
type: aside
---

If you cannot see a new capacity after increasing the LUN backing vRDM (known bug), the solution will be to vMotion a vm after rescanning HBA on the destination host. That's easy.