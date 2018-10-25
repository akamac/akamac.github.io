---
title: MySQL database manipulation from PowerShell
date: 2014-05-09
categories:
  - PowerShell
  - Scripting
tags:
  - connector
  - MySQL
  - NET
---
Download <a title="MySQL Connector/NET" href="http://dev.mysql.com/downloads/connector/net/" target="_blank">MySQL Connector/NET</a> first.

<pre class="expand:true lang:ps decode:true" title="Access MySQL db from PowerShell">Add-Type -Path 'C:\Program Files (x86)\MySQL\MySQL Connector Net 6.8.3\Assemblies\v4.5\MySql.Data.dll'
$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=&lt;FQDN&gt;;uid=&lt;user&gt;;pwd=&lt;password&gt;;database=&lt;db&gt;'}
$Connection.Open()

$Command = $Connection.CreateCommand()
$Command.CommandText = "SELECT .. FROM .. WHERE .."
$Reader = $Command.ExecuteReader()

while ($Reader.Read()) {
    # $Reader array variable represents the table row
}

$Reader.Close()
$Connection.Close()</pre>

&nbsp;