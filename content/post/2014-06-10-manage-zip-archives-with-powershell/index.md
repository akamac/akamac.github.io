---
title: Manage Zip archives with PowerShell
date: 2014-06-10
categories:
  - PowerShell
  - Scripting
tags:
  - add
  - expand
  - extract
  - NET
  - zip
---

I know there are lots of examples and function implementations out there (for instance, the one [from jaykul](http://huddledmasses.org/a-new-way-to-zip-and-unzip-in-powershell-3-and-net-4-5)), nonetheless I'd like to add my 2 cents. Even 5c, since my version is more powerful :) It allows you to set compression level, append/replace files to/in existing archives and extract only necessary files from archive.
  
For instance, to extract *vmware.xml* file from the archive's root and all the files from the *vib* folder stored in root also (yep, we're expanding metadata.zip), creating subfolder in the current directory (replacing if already exists), you need to run the following command: `Extract-ZipFile -ZipFilePath metadata.zip -FilesToExtract vmware.xml,vibs/ -CreateSubfolder -Force`
  
The slash character at the end indicates that you'd like to expand a folder, not a file.

{{< gist akamac a65a6d8bfe62f0d3b954298f2880511d >}}