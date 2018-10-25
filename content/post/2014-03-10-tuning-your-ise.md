---
title: Tuning your ISE
date: 2014-03-10
categories:
  - PowerShell
tags:
  - add-on
  - certificate
  - code signing
  - github
  - ISE
  - remote session
  - snippet
  - store password
---
After being silent for a while it&#8217;s time to explode with some really great stuff!
  
Let&#8217;s start with the environment you develop the scripts in. There are several options out of there: free PowerGUI &#8211; very popular IDE but doesn&#8217;t look nice for me, Sapiens PowerShell Studio &#8211; seems to be a powerful tool but costs 389$ at the moment. So I look back to the ISE that is bundled with WMF 4.0. Some vital features missing, so we need to put in an effort to fill the blanks. But it&#8217;s not as hard as you might think. That&#8217;s the way to go!

**$Env:Path**
  
The first step is to customize your profile, which is loaded every time you start the ISE. The _$profile_ variable will suggest you the file location. Begin with filling the file by adding the necessary paths to $Env:Path variable, eg:
  
<span class="lang:ps decode:true  crayon-inline">$env:Path += &#8216;;C:\Program Files (x86)\EMC\Navisphere CLI;&#8217;</span>
  
There is another way to modify environment variables. For instance, this is how to add the path where ISE will search for modules:
  
<span class="lang:ps decode:true  crayon-inline ">[System.Environment]::SetEnvironmentVariable(&#8216;PSModulePath&#8217;,$env:PSModulePath + &#8220;;$ModuleDir&#8221;,&#8217;Machine&#8217;)</span>
  
Then you can Import all necessary modules and snap-ins, though in the recent PoSh versions they are auto-loaded.

**Snippets**
  
You can hide the default snippets
  
<span class="lang:ps decode:true  crayon-inline  crayon-selected">$psISE.Options.ShowDefaultSnippets = $false</span>
  
and import your own ones. If you wrapped them into the module, run this:
  
<span class="lang:ps decode:true  crayon-inline ">Import-IseSnippet -Module PurpleScreen</span>

**Help**
  
To keep the help docs up to date (say, max 4-weeks old), check the file, where the last help update date stored, and run Update-Help if necessary:

<pre class="expand:true lang:ps decode:true" title="Update-Help">$LastHelpUpdateFilePath = (Split-Path $profile -Parent) + '\Update-Help.date'
$UpdateHelpDate = Import-Clixml $LastHelpUpdateFilePath
if ($UpdateHelpDate -lt (Get-Date).AddDays(-28)) {
    Update-Help -ea SilentlyContinue
    Get-Date | Export-Clixml $LastHelpUpdateFilePath
}</pre>

**Passwords**
  
The next step is to take care of storing passwords in an easy yet secure way, so you have an access to them once ISE started. Windows provides you with the all necessary tools. First, execute the line below and enter your password. That will store the encrypted password string in the $PassDir folder (needs to be done only once). Windows handles the private key, which is your &#8216;profile&#8217;, thus the password can be decrypted only after you are authenticated.

<pre class="expand:true lang:ps decode:true" title="Save password">ConvertFrom-SecureString (Read-Host -Prompt 'Enter password:' -AsSecureString) |
Out-File -FilePath "$PassDir\resource-pass.txt"</pre>

Then you can load the password in the current session and compile the Credential object:

<pre class="expand:true lang:ps decode:true" title="Compiling credential object">$SecurePassword = ConvertTo-SecureString (gc "$PassDir\resource-pass.txt")
$ResourceCred = New-Object System.Management.Automation.PSCredential('DOMAIN\username', $SecurePassword)</pre>

**Text processing**
  
Next is to add some text-processing capabilities for some reason missing in the standard bundle and expose them with hotkey combinations (the functions&#8217; source code will be revealed in the next blog posts introducing my module). You may change hotkeys at your discretion, but keep in mind that some of them are already occupied with built-in ISE commands.

<pre class="expand:true lang:ps decode:true" title="Text processing">$CommentsMenu = $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add('Comments',$null,$null)
$CommentsMenu.Submenus.Add('Comment inline', {Comment-Inline}, 'Ctrl+Alt+I') | Out-Null
$CommentsMenu.Submenus.Add('Uncomment inline', {Uncomment-Inline}, 'Ctrl+Shift+I') | Out-Null
$CommentsMenu.Submenus.Add('Comment block', {Comment-Block}, 'Ctrl+Alt+B') | Out-Null
$CommentsMenu.Submenus.Add('Uncomment block', {Uncomment-Block}, 'Ctrl+Shift+B') | Out-Null

$LinesMenu = $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add('Lines',$null,$null)
$LinesMenu.Submenus.Add('Move line up', {MoveUp-Line}, 'Ctrl+Alt+Up') | Out-Null
$LinesMenu.Submenus.Add('Move line down', {MoveDown-Line}, 'Ctrl+Alt+Down') | Out-Null
$LinesMenu.Submenus.Add('Duplicate Line', {Duplicate-Line}, 'Ctrl+Alt+D') | Out-Null

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Find in opened files', {Find-InOpenedFiles}, 'Control+Alt+F') | Out-Null</pre>

Since we are VMware guys (aren&#8217;t we?), we need a hotkey for setting PowerCLI properties and connecting to multiple vCenter/vCloud servers (a couple of VIProperties as a bonus):

<pre class="expand:true lang:ps decode:true" title="VMware">$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add( 'Connect to vCenter/vCloud servers', {
    Add-PSSnapin VMware*
    Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Scope User -InvalidCertificateAction Ignore -Confirm:$false `
    -VMConsoleWindowBrowser 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' | Out-Null    
    Connect-VIServer 'vcenter-server-default' -Force -wa SilentlyContinue -AllLinked | ft @{N='vCenter connected (default)'; E={$_.Name}}
    Connect-VIServer 'vcenter-server-nondefault' -Force -NotDefault -wa SilentlyContinue | ft @{N='vCenter connected (nondefault)'; E={$_.Name}}
    Connect-CIServer 'vcloud-server-default' | ft @{N='vCloud connected (default)'; E={$_.Name}}
    Connect-CIServer 'vcloud-server-nondefault' -NotDefault | ft @{N='vCloud connected (nondefault)'; E={$_.Name}}
    New-VIProperty -Name VIServerName -ObjectType VIObjectCore -Value { if ( $args[0].UId -match '/VIserver=[\w]+@(.*):.*' ) { $Matches[1] } } | Out-Null
    New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty ‘Config.Tools.ToolsVersion’ | Out-Null
}, 'Control+Alt+V') | Out-Null</pre>

**Certificate**
  
Also you may need the certificate in hand to sign the scripts you write. If it&#8217;s been already imported in the cert store on your machine, just push it to the variable with:
  
<span class="lang:ps decode:true crayon-inline">$CodeSigningCert = gi Cert:\LocalMachine\my\<thumbprint></span>
  
To sign a script using the cert and publicly available timestamp server run
  
<span class="lang:ps decode:true  crayon-inline ">Set-AuthenticodeSignature -Certificate $CodeSigningCert -FilePath &#8220;$ScriptDir\PurpleScreen.psm1&#8221; -TimestampServer http://timestamp.globalsign.com/scripts/timestamp.dll</span>

**Remote sessions**
  
Need to connect to an interactive remote session / load cmdlets from remote session with a hotkey? That&#8217;s pretty easy (more on remote sessions, configurations, CredSSP, etc. in the separate post):

<pre class="expand:true lang:ps decode:true" title="Remote session">$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add( 'Open remote session to COMPUTER', {
    $CurrentTab = $psISE.CurrentPowerShellTab
    if ('COMPUTER' -notin @($psISE.PowerShellTabs.DisplayName)) {
        $psISE.PowerShellTabs.Add().DisplayName = 'COMPUTER'
    }
    $RemoteTab = $psISE.PowerShellTabs | ? DisplayName -eq COMPUTER
    while (-not $RemoteTab.CanInvoke) { Sleep 1 }
	$RemoteTab.Invoke({ Enter-PSSession -ComputerName COMPUTER -ConfigurationName SA -Authentication Credssp -Credential $Cred })
	$psISE.PowerShellTabs.SetSelectedPowerShellTab($CurrentTab)
}, 'Control+Alt+R') | Out-Null

$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add( 'Import EMC Storage Integrator cmdlets', {
    switch ($ESIPSToolkitSession.State) {
        $null {
            $ESIPSToolkitSession = New-PSSession -ComputerName COMPUTER -Credential $Cred -ConfigurationName ESI.Implicit -Authentication Credssp
            Import-PSSession $ESIPSToolkitSession -DisableNameChecking -Module ESIPSToolkit -ea SilentlyContinue -wa SilentlyContinue -AllowClobber
        }
        Opened { Disconnect-PSSession $ESIPSToolkitSession }
        Disconnected { Connect-PSSession $ESIPSToolkitSession }
        Broken { Get-PSSession | ? State -eq Broken | Remove-PSSession; $ESIPSToolkitSession = $null }
    }
}, 'Control+Alt+E') | Out-Null</pre>

You can see some handling of opened tabs here. The main thing I was missing was keeping the session state between ISE reloads. I&#8217;d like to pick up the things from where I left off by auto-loading all opened tabs and files from my previous session. This part was successfully implemented with Save-ISEState and Load-ISEState functions (stay in touch for PurpleScreen module).

<pre class="expand:true lang:ps decode:true" title="Save/load ISE state">$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Save ISE state', {Save-ISEState}, 'Control+Shift+S') | Out-Null
if ($psISE.PowerShellTabs.Count -eq 1) {
    $psISE.PowerShellTabs[0].DisplayName = 'LOCAL SESSION'
    Load-ISEState
    $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus + $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.SubMenus | ? { -not $_.SubMenus.Count } |
    Select @{N='Command'; E={$_.DisplayName}}, @{N='Shortcut'; E={ ($_.Shortcut.Modifiers.ToString().Split().TrimEnd(',') | Sort -Descending), $_.Shortcut.Key }}
}</pre>

It will also show all currently available command shortcuts for convenience.

**GitHub**
  
And in the end some really neat feature &#8211; GitHub integration! Press Ctrl+Alt+G to open GitHub tab with your project&#8217;s local repository (needs GitHub desktop app installed and repository configured)

<pre class="expand:true lang:ps decode:true">$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add( 'Open GitHub tab', {
    $CurrentTab = $psISE.CurrentPowerShellTab
    if ('GitHub' -notin @($psISE.PowerShellTabs.DisplayName)) {
        $psISE.PowerShellTabs.Add().DisplayName = 'GitHub'
    }
    $GitTab = $psISE.PowerShellTabs | ? DisplayName -eq GitHub
    while (-not $GitTab.CanInvoke) { Sleep 1 }
	$GitTab.Invoke({
        cd $ProjectPath
        & "c:\Users\$env:USERNAME\AppData\Local\GitHub\shell.ps1"
        $WindowTitle = $Host.UI.RawUI.WindowTitle
        & "$env:github_posh_git\profile.example.ps1"
        $Host.UI.RawUI.WindowTitle = $WindowTitle
    })
    $psISE.PowerShellTabs.SetSelectedPowerShellTab($CurrentTab)
}, 'Control+Alt+G') | Out-Null</pre>

That&#8217;s all for now!

Stay tuned and remember to follow the main rule &#8211; once written, share with a community!