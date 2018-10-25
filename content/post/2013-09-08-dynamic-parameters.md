---
title: Dynamic parameters
date: 2013-09-08
categories:
  - PowerShell
  - Scripting
---
Today we gonna touch on dynamic parameters available in advanced functions. These are parameters that are added at run-time depending on the environment. The great example is the parameters that are dynamically exposed to the current parameter set of Get-Item cmdlet based on PS provider (FileSystem, Registry) used.
  
Faced it once you should have found out that simply adding such a parameter to the function means writing a bunch of code. Let&#8217;s make a life easier! I&#8217;d like to share with you short yet useful function I will actively utilize in my forthcoming scripts. Here it is:

<pre class="expand:true lang:ps decode:true" title="Add-DynamicParam">function Add-DynamicParam {
    Param (
        [Parameter(ValueFromPipeline,HelpMessage='Dictionary to add created dynamic parameter')]
        [System.Management.Automation.RuntimeDefinedParameterDictionary] $ParamDictionary,
        [Parameter(Mandatory)]
        [string] $ParameterName,
        [Parameter(Mandatory)]
        [type] $ParameterType,
        [string[]] $ParameterSetName = '__AllParameterSets',
        [ValidateScript({
            $AcceptedValues = ('Alias','AllowNull','AllowEmptyString','AllowEmptyCollection',`
                               'ValidateCount','ValidateLength','ValidatePattern','ValidateRange',`
                               'ValidateScript','ValidateSet','ValidateNotNull','ValidateNotNullOrEmpty')
            -not (Compare @($_.Keys) $AcceptedValues | ? SideIndicator -eq '&lt;=')
        })]
        [hashtable] $Options,
        [int] $Position,
        [string] $HelpMessage,
        [switch] $ValueFromPipeline,
        [switch] $ValueFromPipelineByPropertyName,        
        [switch] $Mandatory
    )
    $ParamAttribute = [System.Management.Automation.ParameterAttribute]@{
        ParameterSetName = $ParameterSetName; Mandatory = $Mandatory.IsPresent;
        ValueFromPipeline = $ValueFromPipeline.IsPresent;
        ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName.IsPresent
    }
    if ($HelpMessage) { $ParamAttribute.HelpMessage = $HelpMessage }
    if ($Position) { $ParamAttribute.Position = $Position }
    $ParamAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    $ParamAttributeCollection.Add($ParamAttribute)
    if ($Options) {
        foreach ($Option in $Options.GetEnumerator()) {
            $ParamOptions = New-Object System.Management.Automation.$($Option.Name)Attribute -ArgumentList $Option.Value
            $ParamAttributeCollection.Add($ParamOptions)
        }
    }
    $Param = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, $ParameterType, $ParamAttributeCollection)
    if (-not $ParamDictionary) { $ParamDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary }
    $ParamDictionary.Add($ParameterName, $Param)
    $ParamDictionary
}</pre>

One note is that parameters created with this function are not available in script&#8217;s body using the parameter&#8217;s name but are exposed via $PSBoundParameters variable.
  
All the parameter attributes can be set by passing its values in hashtable to _-Options_. Other common attributes (&#8216;mandatory&#8217; switch, position, accepting values from pipeline) are also available. To add multiple dynamic parameters you should pipe one function call to another. Braindead simple! Here is an example:

<pre class="expand:true lang:ps decode:true " title="DynamicParam usage">DynamicParam {
    if ($Status -eq 'Solved') {
        Add-DynamicParam -ParameterName Solution -ParameterType string -Mandatory -Options @{ValidateNotNullOrEmpty = $null} |
        Add-DynamicParam -ParameterName Effort -ParameterType int -Mandatory -Options @{ValidateSet = (1,2,3)}
    }
}
Process {
    $PSBoundParameters.Solution; $PSBoundParameters.Effort
}</pre>