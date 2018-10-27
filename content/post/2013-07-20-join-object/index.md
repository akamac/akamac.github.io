---
title: Join-Object
date: 2013-07-20
categories:
  - PowerShell
tags:
  - join-object
  - merge-object
  - powershell
---
If you ever wrote SQL queries and now use PowerShell for scripting maybe you missed &#8216;Join' possibility in PoSH. Here it is!
  
Nothing special. I just tried to create Join-Object with the same functionality as inner/outer Join statements in SQL. My version of Join-Object uses standalone Merge-Object function for merging 2 arrays of custom objects / hashtables. Resulting object is an array of objects that contains all properties from joined objects except the ones with the same name, which are discarded. If you also want to include the property on which you join the collections use $IncludeJoinProperty switch. The expression for specifying the property to join on is that simple:
  
`-On {$Left.'propertyName' -eq $Right.'propertyName'}`
  
Collections to be joined must contain objects of the same type otherwise the error is generated. Also function throws an error in case of the values of join property in collection (left or right) are not unique. Merge and Join aliases added by default.
  
If you have any questions drop me a line in comments. Use it on your own risk :)

{{< gist akamac ab449697d8f1cf57db8b149752062dfd >}}