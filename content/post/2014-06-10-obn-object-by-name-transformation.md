---
title: Object By Name transformation
date: 2014-06-10
categories:
  - PowerCLI
  - PowerShell
  - Scripting
tags:
  - object by name
  - OBN
  - transformation
draft: true
---

You might have known that most of PowerCLI cmdlets parameters accept objects or object names (with wildcard characters allowed). Take a look at `New-VM` cmdlet: you can pass strings to `VMHost`, `ResourcePool`, `Datastore`, etc. parameters as well as the objects itself. Or maybe you've even never noticed this since it just works!
  
Want the same behavior for your own functions? No problem! Use the function below to perform transparent transformation from any eligible object to the object you need (View or Impl). The neat feature it has is limiting the retrieved properties for view object, what considerably improves performance in some cases.

This is how to integrate it into your own function:

The one thing you should be aware of is that it accepts wildcards, while you may think the regular expressions are more powerful tool (and I completely agree with you). The reason I had in mind was to not confuse users who got used to the default PowerCLI behavior. It's up to you to remove `ConvertTo-Regex` part from `-Filter` parameter in `Get-View` call. But in this case sometimes you might be puzzled when the script can't find an object with the name you are hundred percent sure exists. Doh! Any braces in the name? Use `[regex]::Escape()` to escape them.
