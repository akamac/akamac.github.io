function New-DynamicParam {
  param(
    [Parameter(ValueFromPipeline,
               HelpMessage='Dictionary to add created dynamic parameter')]
    [System.Management.Automation.RuntimeDefinedParameterDictionary] $ParamDictionary,
    [Parameter(Mandatory)]
    [string] $ParameterName,
    [Parameter(Mandatory)]
    [type] $ParameterType,
    [string[]] $ParameterSetName = '__AllParameterSets',
    [ValidateScript({
      $AcceptedValues = ('Alias','AllowNull','AllowEmptyString','AllowEmptyCollection',
                         'ValidateCount','ValidateLength','ValidatePattern',
                         'ValidateRange','ValidateScript','ValidateSet',
                         'ValidateNotNull','ValidateNotNullOrEmpty')
        -not (Compare @($_.Keys) $AcceptedValues | ? SideIndicator -eq '<=')
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
      $ParamOptions = New-Object System.Management.Automation.$($Option.Name)Attribute `
        -ArgumentList $Option.Value
      $ParamAttributeCollection.Add($ParamOptions)
    }
  }
  $Param = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName,
                                                                           $ParameterType,
                                                                           $ParamAttributeCollection)
  if (-not $ParamDictionary) {
    $ParamDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
  }
  $ParamDictionary.Add($ParameterName, $Param)
  $ParamDictionary
}