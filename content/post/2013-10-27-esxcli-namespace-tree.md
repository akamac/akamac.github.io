---
title: Esxcli namespace tree
date: 2013-10-27
categories:
  - PowerCLI
  - PowerShell
  - Scripting
---
Every time a new ESXi version released I wonder what the functionality was added to _esxcli_. As you know all available namespaces and commands can be retrieved by typing _esxcli command list_ in the console. To make the output look pretty I&#8217;ve written a couple of lines of PoSH code that generates the handy namespaces tree view.

<pre class="lang:ps decode:true " title="esxcli" >$esxcli = Get-VMHost $Name | Get-EsxCli
$EsxcliNamespaceFile = [IO.File]::CreateText('D:\esxcli.txt')
$EsxcliNamespaceTree = $esxcli.esxcli.command.list()
$Commands = @()
foreach ($Namespace in $EsxcliNamespaceTree) {
    $Commands += @{Path = $Namespace.Namespace.Split('.'); Operation = $Namespace.Command }
}
 
function Expand-Tree ($Tree, $TabNum = 0) {
    $Tree | Group -Property {@($_.Path)[0]} | Sort Name | % {
        if ($_.Group.Path -eq $null) { $EsxcliNamespaceFile.Write(" $(($_.Group.Operation | Sort) -join ',')"); return }
        $EsxcliNamespaceFile.Write("`n$(if ($TabNum) { 1..$TabNum | % { "`t" } })$($_.Name)")
        $_.Group | % { $_.Path = $_.Path | Select -Skip 1 }
        Expand-Tree -Tree ($_.Group | Sort @{E={$_.Path.Count}}) -TabNum ($TabNum + 1)
    }
}
Expand-Tree -Tree $Commands
$EsxcliNamespaceFile.Close()</pre>

The reason I&#8217;ve used the .NET class instead of Add-Content / Out-File cmdlets is that the latter append the new line.
  
<a href="https://dl.dropboxusercontent.com/u/2398632/namespace.txt" title="EsxcliNamespaceTree" target="_blank">Here</a> is for the latest version 5.5.