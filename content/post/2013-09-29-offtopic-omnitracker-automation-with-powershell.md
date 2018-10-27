---
title: OmniTracker automation
date: 2013-09-29
categories:
  - PowerShell
tags:
  - omnitracker
draft: true
---

Few words outside the virtualization world yet PoSH scripting related.
  
I've been working for a while in the company that uses [Omnitracker](http://www.omninet.de/index.php) as a helpdesk and incident management solution. Using its web interface as well as thick client isn't the best experience. And when it comes to do it on a regular basis it turns to a nightmare especially for a scripting guy like me. So what should we do in this situation? Yep, exactly! Automate it!
  
As others the first thing I've tried is to call Google for help. What was my surprise when I saw nothing relevant at all in the first few pages except the Linkedin profile of a guy who should have the desired skills. Wow, the power of social networks in action! Take a challenge!
  
Looking through the manuals I've stumbled on the doc describing the automation interface. Good catch! C# there, so the PoSH isn't far away. It turned out simple enough and after few tries I've managed to get it work. Couple of functions produced can be found below. As Omnitracker heavily relies on cusmomization most likely you won't find it working in your environment but this functions should give you a tip how to handle the objects in OT. 

```powershell
function Set-OtTicket {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string[]] $TicketN,
        [Parameter(Mandatory)]
        [ValidateSet('Rejected','InfoRequest','InProgress','Solved')]
        [string] $Status,
        [string] $Server,
        [int] $Port = 5085,
        [System.Management.Automation.PSCredential] $Credential = Get-Credential,
        [string] $Folder
    )
    DynamicParam {
        switch -Regex ($Status) {
            'Rejected|InfoRequest' {
                Add-DynamicParam -ParameterName Comment -ParameterType string -Mandatory
            }
            'InProgress' {
                Add-DynamicParam -ParameterName EndDate -ParameterType DateTime -Mandatory |
                Add-DynamicParam -ParameterName Comment -ParameterType string
            }
            'Solved' {
                Add-DynamicParam -ParameterName Solution -ParameterType string -Mandatory `
                -Options @{ValidateNotNullOrEmpty = $null} |
                Add-DynamicParam -ParameterName Effort -ParameterType float -Mandatory |
                Add-DynamicParam -ParameterName Comment -ParameterType string
            }
        }
    }
    Begin {
        $otApp = New-Object -ComObject OtAut.OtApplication
        $otSession = $otApp.MakeSession($Server, $Port, $Credential.UserName, $Credential.GetNetworkCredential().Password)
    }
    Process {
        $otFolders = $otSession.RequestFolders
        $otFolder = ($otFolders | ? Path -eq $Folder)
        $otFilter = $otFolder.MakeFilter()
        $otFilter.SetSearchExpression("Number:I-$TicketN")
        $otFilter.Save()
        $otRequests = $otFolder.Search($otFilter, $true) # recursive
        $OtRequest = $otRequests.Item(0)
        $OtRequest.Unlock()
 
        $StatusHt = @{Rejected='Rejected'; InfoRequest='Запрос информации'}
 
        $State = $otRequest.UserFields | ? { $_.Definition.Label -eq 'State' }
        switch -Regex ($Status) {
            'Rejected|InfoRequest' {                
                $State.Value = $StatusHt.$Status
            }
            'InProgress' {
                $State.Value = 'In progress'
                $Terms = $otRequest.UserFields | ? { $_.Definition.Label -eq 'Срок решения' }
                $Terms.Value = $PSBoundParameters.EndDate.ToShortDateString()
            }
            'Solved' {
                $State.Value = 'In progress'
                $Terms = $otRequest.UserFields | ? { $_.Definition.Label -eq 'Срок решения' }
                $Terms.Value = (Get-Date).AddDays(1).ToShortDateString()
 
                $otRequest.Save($true, $null, $true)
 
                $Solution_ = $otRequest.UserFields | ? { $_.Definition.Label -eq 'Solution Description'}
                $Solution_.Value = $PSBoundParameters.Solution # formatted text
                $Effort_ = $otRequest.UserFields | ? { $_.Definition.Label -eq 'Effort'}
                $Effort_.Value = $PSBoundParameters.Effort
       
                $Terms.Value = (Get-Date).ToShortDateString()
                $State.Value = 'Solved'
            }
            '.*' {
                if ($PSBoundParameters.Comment) {
                    $Comments = $otRequest.UserFields | ? { $_.Definition.Label -eq 'Comments' }
                    $OtMemoSections = $Comments.TValue
                    $OtMemoSections.Add($PSBoundParameters.Comment)
                    $Comments.TValue = $OtMemoSections
                }
            }
        }
        $otRequest.Save($true, $null, $true)
    }
    End { $otSession.Logoff() }
}
```