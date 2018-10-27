---
title: 'ForEach: cmdlet vs keyword'
date: 2013-06-15
categories:
  - PowerShell
---

Here is a little note about the difference of these two loop constructions.

**foreach** is a reserved keyword in PoSH that allows you to loop through collection of objects and make some action on every item. Inside the foreach loop `$foreach` automatic variable is available. It presents the loop enumerator and can be used, for instance, to skip the current object in collection (`.MoveNext()` method).

**ForEach-Object** is a cmdlet doing almost the same thing but the difference is the usecase. Since the collection is piped to the cmdlet the objects are pushed down the pipeline as soon as they are generated. It affects the performance greatly when a collection isn't created at the start of processing. When the last is long-time operation using the cmdlet you can achieve much better overall performance than using its brother-keyword. In other case one should consider using the keyword for higher execution speed.

Since both have the same alias foreach the PoSH parser is smart enough to select the appropriate construction depending on the place it is used.