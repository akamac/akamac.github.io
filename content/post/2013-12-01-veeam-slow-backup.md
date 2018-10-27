---
title: Veeam slow backup
date: 2013-12-01
categories:
  - vSphere
tags:
  - slow
  - snapshot
  - Veeam
draft: true
---

One day I suddenly noticed that backup jobs could no longer fit the backup window. While investigating the issue I found tons of log records pointing that before processing every VM in the job Veeam tries to clean up all the snapshots created by its own for backup purposes. In some cases they were manually deleted or lost for some reason, but the records were still kept in the database.
  
So the root cause of slow backup is detected. To fix it first ensure that all backup jobs are stopped. If so, delete all snapshots with names containing *VEEAM* and *Consolidate helper* in vSphere inventory. Then go to Veeam database and clear the VmWareSnapshot table `DELETE FROM VmWareSnapshots`. It's recommended to stop VeeamBackup service before executing the query against DB.
  
That's it. Restart your jobs and enjoy the rates you used to see!