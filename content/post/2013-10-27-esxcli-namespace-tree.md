---
title: Esxcli namespace tree
date: 2013-10-27
categories:
  - PowerCLI
  - PowerShell
  - Scripting
draft: true
---

Every time a new ESXi version released I wonder what the functionality was added to `esxcli`. As you know, all available namespaces and commands can be retrieved by typing `esxcli command list` in the console. To make the output look pretty I've written a couple of lines of PoSH code that generates the handy namespaces tree view.

{{< highlight powershell >}}
$esxcli = Get-VMHost $Name | Get-EsxCli
$EsxcliNamespaceFile = [IO.File]::CreateText('C:\esxcli.txt')
$EsxcliNamespaceTree = $esxcli.esxcli.command.list()
$Commands = @()
foreach ($Namespace in $EsxcliNamespaceTree) {
  $Commands += @{
    Path = $Namespace.Namespace.Split('.')
    Operation = $Namespace.Command
  }
}
 
function Expand-Tree ($Tree, $TabNum = 0) {
  $Tree | Group -Property {@($_.Path)[0]} | Sort Name | % {
    if ($_.Group.Path -eq $null) {
      $EsxcliNamespaceFile.Write(" $(($_.Group.Operation | Sort) -join ',')")
      return
    }
    $EsxcliNamespaceFile.Write("`n$(if ($TabNum) { 1..$TabNum | % { "`t" } })$($_.Name)")
    $_.Group | % { $_.Path = $_.Path | Select -Skip 1 }
    Expand-Tree -Tree ($_.Group | Sort @{E={$_.Path.Count}}) -TabNum ($TabNum + 1)
  }
}
Expand-Tree -Tree $Commands
$EsxcliNamespaceFile.Close()
{{< /highlight >}}