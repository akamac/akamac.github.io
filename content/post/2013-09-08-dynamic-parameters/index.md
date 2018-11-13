---
title: Dynamic parameters
date: 2013-09-08
categories:
  - PowerShell
  - Scripting
draft: true
---

Today we're going to touch on dynamic parameters available in advanced functions. These are parameters that are added at run-time depending on the environment. The great example is the parameters that are dynamically exposed to the current parameter set of `Get-Item` cmdlet based on PS provider (FileSystem, Registry) used.
  
Faced it once, you should have found out that simply adding such a parameter to the function means writing a bunch of code. Let's make a life easier!

{{< gist akamac bc0e5f2981f6b1327f0c60a64b2e26b6 >}}

Parameters created with this function are not available in script's body using the parameter's name but are exposed via `$PSBoundParameters` variable.
  
All the parameter attributes can be set by passing its values in hashtable to `-Options`. Other common attributes (`mandatory` switch, `position`, accepting values from pipeline) are also available. To add multiple dynamic parameters you should pipe one function call to another. Braindead simple! Here is an example:

```powershell
New-DynamicParam -ParameterName Solution `
                 -ParameterType string `
                 -Mandatory `
                 -Options @{ValidateNotNullOrEmpty = $null} |
New-DynamicParam -ParameterName Effort `
                 -ParameterType int `
                 -Mandatory `
                 -Options @{ValidateSet = (1,2,3)}
```