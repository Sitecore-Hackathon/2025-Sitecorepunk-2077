# Advanced Dialogs
## Variable Settings
The Read-Variable command provides a way to prompt the user for information and then generate variables with those values.

Example: The following displays a dialog with a dropdown.

Note: The name selectedOption will result in a variable that contains the selected option.

```
$options = @{
    "A"="a"
    "B"="b"
}

$props = @{
    Parameters = @(
        @{Name="selectedOption"; Title="Choose an option"; Options=$options; Tooltip="Choose one."}
    )
    Title = "Option selector"
    Description = "Choose the right option."
    Width = 300
    Height = 300
    ShowHints = $true
}

Read-Variable @props
```


Button Name | Return Value
--- | ---
OK | ok
Cancel | cancel
< variables > | < selection >


### Supported Parameter Values

Key | Type | Description | Example
--- | --- | --- | ---
Name | string | Variable name | selectedOption
Value | bool string int float datetime Item | Value | $true
Title | string | Header or Label | "Choose an option"
Tooltip | string | Short description or tooltip | "Choose one."
Tab | string | Tab title | "Simple"
Placeholder | string | Textbox placeholder | "Search text..."
Lines | int | Line count | 3
Editor | string | Control type | "date time"
Domain | string | Domain name for security editor | "sitecore"
Options | string OrderedDictionary Hashtable | Data for checklist or dropdown | @{"Monday"=1;"Tuesday"=2}
Columns | int string | Number between 1 and 12 and string 'first' or 'last' | 6 first

### Editor Types
- bool
- check
- date
- date time
- droplist
- droptree
- email
- groupeddroplink
- groupeddroplist
- info
- item
- link
- marquee
- multilist
- multilist search
- multiple user
- multiple user role
- multiple role
- multitext
- number
- pass
- radio
- rule
- rule action
- tree
- treelist
- tristate
- time

## Confirmation Choice
The Confirmation Choice dialog allows for multiple combinations like that seen with a "Yes, Yes to all, No, No to all" scenario.

Example: The following displays a modal dialog with choices.

```
Show-ModalDialog -Control "ConfirmChoice" -Parameters @{btn_0="Yes - returns btn_0"; btn_1="No - returns btn_1"; btn_2="returns btn_2"; te="Have you downloaded SPE?"; cp="Important Questions"} -Height 120 -Width 650
```

Note: The hashtable keys should be incremented like btn_0, btn_1, and so on. The return value is the key name.

Button Name | Return Value
--- | ---
< first button > | btn_0
< second button > | btn_1
< third button > | btn_2



## Upload
The Upload dialog provides a way to upload files from a local filesystem to the media library or server filesystem.

Example: The following displays an advanced upload dialog.

```
Receive-File (Get-Item "master:\media library\Files") -AdvancedDialog
```

No return value.


## Download
The Download dialog provides a way to download files from the server to a local filesystem.

Example: The following displays a download dialog.

```
Get-Item -Path "master:\media library\Files\readme" | Send-File
```


## Field Editor
The Field Editor dialog offers a convenient way to present the user with fields to edit.

Example: The following displays a field editor dialog.

```
Get-Item "master:\content\home" | Show-FieldEditor -Name "*" -PreserveSections
```

Button Name | Return Value
--- | ---
OK | ok
Cancel | cancel


## File Browser
The File Browser is an obvious choice when you need to upload, download, or delete files.

Example: The following displays a file browser dialog for installation packages.

```
Show-ModalDialog -HandleParameters @{
    "h"="Create an Anti-Package"; 
    "t" = "Select a package that needs an anti-package"; 
    "ic"="People/16x16/box.png"; 
    "ok"="Pick";
    "ask"="";
    "path"= "packPath:$SitecorePackageFolder";
    "mask"="*.zip";
} -Control "Installer.Browse"
```

Button Name | Return Value
--- | ---
OK | < selected file >
Cancel | undetermined

Example: The following displays a simple file browser dialog.

```
Show-ModalDialog -HandleParameters @{
    "h"="FileBrowser";
} -Control "FileBrowser" -Width 500
```

Button Name | Return Value
--- | ---
OK | < selected file >
Cancel | undetermined


Example: The following displays a Sheer UI control without any additional parameters.

```
Show-ModalDialog -Control "SetIcon"
``

## Data List

The "Data List" is essentially a report viewer which supports custom actions, exporting, and filtering.

Example: The following displays a list view dialog with the child items under the Sitecore tree.

```
Get-Item -Path master:\* | Show-ListView -Property Name, DisplayName, ProviderPath, TemplateName, Language
```

## Results
The Results dialog resembles the Console but does not provide a prompt to the user. This is useful for when logging messages.

Example: The following displays a dialog with the all the information written to the ScriptSession output buffer.

```
for($i = 0; $i -lt 10; $i++) {
    Write-Verbose "Index = $($i)" -Verbose
}

Show-Result -Text
```


# Sample Report Scripts

## Get-TemplateUsageReport.ps1

```
<#
    .SYNOPSIS
       This Sitecore PowerShell Extensions report provides a list of templates and the number of occurrences of each under a given path in the Sitecore tree.
    
    .AUTHOR
        
#>

function Get-TemplateUsageInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [String]
        $Path,

        [Parameter(Mandatory = $false)]
        [String]
        $TemplateFilterContainsString
    )

    $hashtable = @{}

    Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Template.FullName.Contains($TemplateFilterContainsString) } | ForEach-Object {
        $templateId = $_.Template.Id;
        $currentCount = 1;
        if ($hashtable.Count -ne 0) {
            # Check if Template ID is present in the hashtable
            $keyExists = $hashtable.ContainsKey($templateId) 
            if ($keyExists -eq $true) {
                # Get current value
                $currentCount = $hashtable[$templateId]
                
                # Update the hashtable with a new incremented count.
                $newCount = $currentCount + 1;
                $hashtable.Remove($templateId)
                $hashtable.Add($templateId, $newCount)
            }
            else {
                # If the Template isn't in the hashtable, add the Template ID to the hashtable as the Name, with Value 0              
                $hashtable.Add($templateId, $currentCount)
            }
        }
        else {
            # If the Template isn't in the hashtable, add the Template ID to the hashtable as the Name, with Value 0
            $hashtable.Add($templateId, $currentCount)
        }
    }

    return $hashtable
}

<#
 # Dialog to select a path and enter a template filter.
 #>
$dialogProps = @{
    Title            = "Sitecore Template Usage Analysis"
    Description      = "Choose a content path to process."
    Width            = 450 
    Height           = 325
    OkButtonName     = "Continue"
    CancelButtonName = "Cancel"
    ShowHints        = $true
    Icon             = "office/32x32/template.png"
    Parameters       = @(
        @{ Name = "selectedPath"; Title = "Choose a Path to process"; Source = "DataSource=/sitecore/&DatabaseName=master&IncludeTemplatesForDisplay=Node,Folder,Template,Template Folder&IncludeTemplatesForSelection=Template"; editor = "droptree"; },
        @{ Name = "templateFilter"; Title = "Template must contain the following string (optional):"; editor = "text" }
    )
}

$result = Read-Variable @dialogProps

if ($result -ne "ok") {
    Exit
}

Write-Host "Processing path: '$($selectedPath.Paths.Path)'" -ForegroundColor Green

$templateData = Get-TemplateUsageInfo -Path $selectedPath.Paths.Path -TemplateFilterContainsString $templateFilter

$props = @{
    InfoTitle       = "Sitecore Template Usage Analysis"
    InfoDescription = "This report provides a list of templates and number of occurances of each under the path: '$($selectedPath.Paths.Path)'."
    PageSize        = 100
}

$templateData.GetEnumerator() | Sort-Object -Property Value -Descending | Show-ListView @props -Property @{ Label = "Number of Occurances"; Expression = { ($_.Value) } },
@{ Label = "Template ID"; Expression = { $_.Name } },
@{ Label = "Template Name"; Expression = { $(Get-Item -Path "master://$($_.Name)").Name } },
@{ Label = "Template Path"; Expression = { $(Get-Item -Path "master://$($_.Name)").Paths.Path } }

Close-Window

```

## Get-UniqueRenderingUsage.ps1

```
$path = "master:/sitecore/content/global"
$lang = "en"

function Assert-HasLayout {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [Sitecore.Data.Items.Item]$Item       
    )

    # Get the item's Final Layout 
    $layout = Get-Layout -FinalLayout -Item $Item

    # If a layout is present, assert true
    if ($layout) {
        return $true
    }

    # Item does not have a layout.  Exit
    Write-Host "Item has no layout."
    exit
}

$renderingsList = @()
# Get the current item based on context
$currentItem = Get-Item $path -Language $lang -Version Latest

# Ensure the item has a layout
Assert-HasLayout $currentItem > $null
Write-Host "Item has layout. Getting renderings..."

# Get the renderings from the FinalLayout
Get-Rendering  -FinalLayout -Item $currentItem | 
Foreach-Object {
     if($_.ItemId -ne ""){
        $renderingsList += $_.ItemId
     }
}

# Get the renderings from the FinalLayout
$childItems = Get-ChildItem -Path $path -Language $lang -Version Latest -Recurse 

$childItems | ForEach-Object {
    Get-Rendering  -FinalLayout -Item $_  | 
    Foreach-Object {
        if($_.ItemId -ne ""){
            if($renderingsList -notcontains $_.ItemId){
                $renderingsList += $_.ItemId
            }
        }
    }
}

$renderingsList | Foreach-Object { 
    Get-Item master: -Id $_   
}

Write-Host "`n>" $renderingsList.Count "renderings in use."

```


## # GetFinalRenderings.ps1
```
function Get-Items () {
	$items = Get-ChildItem -Path master:\sitecore\content\us\home -Recurse
	$finalItems = @()
	foreach ($item in $items) {

		$renderings = Get-Rendering -FinalLayout -Item $item
		$count = 0
		foreach ($rendering in $renderings) {
			if ($rendering.ItemId -eq "{3660FC1F-A924-477F-A39C-DF802503C21E}") {
				$count = $count + 1
			}
		}

		if ($count -gt 1) {
			$finalItems += $item
		}
	}
	$finalItems
}

$props = @{
	InfoTitle = "Duplicate Banner Renderings"
	InfoDescription = "Report for identifying items where Banner rendering is present more than once."
	PageSize = 100
}

Get-Items | Show-ListView @props -Property @{ Label = "Item ID"; Expression = { $_.Id } },
@{ Label = "Item Name"; Expression = { $_.Name } },
@{ Label = "Item Path"; Expression = { $_.Paths.Path } },
@{ Label = "Created"; Expression = { $_.__Created } },
@{ Label = "Updated"; Expression = { $_.__Updated } }

Close-Window
```


## IdentifyDeleteUnusedMediaItems.ps1
```
<#
    .SYNOPSIS
       Report for identifying unused/unreferenced media items.
       
       Will prompt user to delete all unused media items found.
       Selecting OK in the prompt will move the items to the Recycling Bin.
       Selecting Cancel in the prompt will simply show the report.
       
       A *manual* Smart Publish (inlcude subitems) on the root media library path will remove the deleted items from the Web DB.
       
       * Prerequisite: Links DB is rebuild
       
       ** USE WITH CAUTION! **
       DB backups highly recommended before mass deletion!
    
    .AUTHOR
        
#>

filter Skip-MissingReference {
    $linkDb = [Sitecore.Globals]::LinkDatabase
    if ($linkDb.GetReferrerCount($_) -eq 0) {
        $_
    }
}

function Get-Items () {
    # Change this to increase the days 
    $date = [datetime]::Today.AddDays(-30)

    $items = Get-ChildItem -Path "master:\sitecore\media library\User Defined" -Recurse | 
        Where-Object { $_.TemplateID -ne [Sitecore.TemplateIDs]::MediaFolder } |
        # Comment the line below to ignore dates
        Where-Object { $_.__Owner -ne "sitecore\admin" -and $_.__Updated -lt $date } |
        # The line below is to ignore any item paths
        Where-Object {$_.Paths.Path -notmatch "/sitecore/media library/User Defined/Services" } |
        Skip-MissingReference
        
    $finalItems = @()
    
    foreach ($item in $items) {
        $script:mediaItems.Add($item) > $null
        $finalItems += $item
    }  

    $finalItems
}

function Unpublish-Item {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Sitecore.Data.Items.Item]$Item
    )
    
    $Item.Editing.BeginEdit()
    $Item.Fields["__Never publish"].Value = '1'
    $Item.Editing.EndEdit() > $null

    Write-Host "    > Never Publish value set to 'true'. " -ForegroundColor Blue
    Write-Progress -Activity "Processing item" -Status "Running..."  -CurrentOperation "Never Publish value set to 'true'. ";
    Write-Host "    > Publishing item..." -ForegroundColor Blue
    Write-Progress -Activity "Processing item" -Status "Running..."   -CurrentOperation "Publishing item...";
    $publishJob = Publish-Item $Item -PublishMode Full -Recurse -AsJob -Target "web" > $null
    $publishJob = Publish-Item $Item -PublishMode Full -Recurse -AsJob -Target "prodweb" > $null
}

$props = @{
    InfoTitle       = "Unused Media Items Report"
    InfoDescription = "Report for identifying unused/unrefernced media items."
    PageSize        = 100
}

$script:mediaItems = New-Object System.Collections.ArrayList
# Counter to keep track of the updated content items.
$script:itemCount = 0

Get-Items | Show-ListView @props -Property @{ Label = "Item ID"; Expression = { $_.Id } },
@{ Label = "Item Name"; Expression = { $_.Name } },
@{ Label = "Item Path"; Expression = { $_.Paths.Path } },
@{ Label = "Created"; Expression = { $_.__Created } },
@{ Label = "Updated"; Expression = { $_.__Updated } }

if ($script:mediaItems.Count -eq 0) {
    Write-Warning "No unused media items found."
}
else {
    $continue = Show-Confirm -Title "Delete all unused media items?"
    if ($continue -eq 'yes') {
        Write-Host 'Deleting...'
        foreach ($i in $script:mediaItems) {
            Unpublish-Item $i
            $i | Remove-Item
            $script:itemCount += 1
        }
		
        Write-Host $script:itemCount 'media items deleted!'
    }
}

Close-Window
```


## IsArchivedReport.ps1

```
<#
.SYNOPSIS
Updates Professionals template items that have been marked as 'Never Publish', but not marked as 'Is Archived'
.AUTHOR
Written by  on July 11th 2017.
#>
#region static variables
# This is the ID of the professionals template
$script:professionalTemplateId = "{95E4650B-E8DB-4C07-A06D-A241513A8A25}" # Professionals Template ID
#endregion
function GetProfessionalsToSetIsArchiveValue ()
{
	$itemsWithMatchingTemplateIds = Get-Item -Path master: -Query "/sitecore/content//*[@@templateid='$professionalTemplateId']" -Language *
	Write-Host "Professionals marked as 'Never Publish' but not 'Is Archived':"
	foreach ($item in $itemsWithMatchingTemplateIds)
	{
		if($item.'__Never publish' -eq '1'){
    		if ($item.'__Hide version' -eq '1') {
    			if ($item.Fields['Is Archived'].Value -eq '' -or $item.Fields['Is Archived'].Value -eq '0') {
    				$script:professionals.Add($item) > $null
    				Write-Host $item.Name $item.ID
    			}
    		}
		}
	}
}
function SetIsArchivedFieldTrue ([Sitecore.Data.Items.Item]$contentItem)
{
    $admin = Get-User -Current #Get-User -Identity "sitecore\admin" 
    New-UsingBlock (New-Object Sitecore.Security.Accounts.UserSwitcher $admin) {
        $contentItem.Editing.BeginEdit()
    	$contentItem.Fields["Is Archived"].Value = 1
        $contentItem.Editing.EndEdit()
        $contentItem.Editing.BeginEdit()
    	$contentItem.'__Never publish' = '0'
        $contentItem.Editing.EndEdit()
        $contentItem.Editing.BeginEdit()
    	$contentItem.'__Hide version' = '0'
        $contentItem.Editing.EndEdit()
    	Publish-Item $contentItem -Target web -PublishMode Full
        #Publish-Item $contentItem -Target "staging" -PublishMode Full
    }
	Write-Host $contentItem.Name $contentItem.ID ' processed.'
}

# Declare a new ArrayList to add the IDs of the templates which use the workflow.
# An ArrayList is used instead of the the default PS Array because the latter is immutable and not efficient when working with large arrays.
$script:professionals = New-Object System.Collections.ArrayList
# Counter to keep track of the updated content items.
$script:itemCount = 0
GetProfessionalsToSetIsArchiveValue
if ($script:professionals.Count -eq 0)
{
	Write-Warning "No Professionals items found."
} else {
	$continue = Show-Confirm -Title "Proceed to process items?"
	if ($continue -eq 'yes') {
		Write-Host 'Processing...'
		foreach ($i in $script:professionals) {
			SetIsArchivedFieldTrue ($i)
		}
	}
}
Write-Host "Done." 

```

## LanguageDiscrepancyTool.ps1
```
function Get-MissingLanguageVersions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Item]$Item,

        [Parameter(Mandatory = $true)]
        [string]$SourceLanguage,

        [Parameter(Mandatory = $true)]
        [string]$TargetLanguage

    )
    $items = Get-ChildItem -Language $SourceLanguage -Version Latest -Path $Item.Paths.Path -Recurse | Where-Object { ((Confirm-NoLanguageVersion -Item $_ -Language $TargetLanguage) -and (Confirm-IsLatest($_))) } #| Sort-Object __Updated -descending
    $items
}

function Confirm-NoLanguageVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Item]$Item,

        [Parameter(Mandatory = $true)]
        [string]$Language

    )
  
    $tempitem = Get-Item -Path $Item.Paths.Path -Language $Language
    if ($tempitem.Versions.Count -eq 0) {
        return $true
    }
    return $false
}


function Confirm-IsLatest($current) {
    $latest = Get-Item master: -Id $current.ID -Version Latest
    if ($latest.Version.Number -ne $current.Version.Number) {
        return $false;
    }
    return $true;
}

# Get the current context item
#$ContextItem = Get-Item "master:/sitecore/content/Components" -Version Latest 
$ContextItem = Get-Item "."


# Obtain context item's language versions
$siteLangOptions = New-Object System.Collections.Specialized.OrderedDictionary
foreach ($lang in $ContextItem.Languages) {
    $tempitem = Get-Item -Path $ContextItem.Paths.Path -Language $lang
    if ($tempitem.Versions.Count -gt 0) {
        $siteLangOptions.Add($lang.Name, $lang.Name)
    }
}

# Window with options to select language and fields to translate
$dialogProps = @{
    Parameters       = @(
        @{ Name = "fromLanguage"; Title = "Source Language"; options = $siteLangOptions; editor = "radio" }
        @{ Name = "toLanguage"; Title = "Target Language"; options = $siteLangOptions; editor = "radio" }
    )
    Description      = "Language versions missing in a specific part of the tree" 
    Title            = "Language Discrepency Tool" 
    OkButtonName     = "Continue" 
    CancelButtonName = "Cancel"
    Width            = 550 
    Height           = 280 
    Icon             = "office/32x32/compare_versions.png"
}

# Wait for user input from options menu
$dialogResult = Read-Variable @dialogProps
if ($dialogResult -ne "ok") {
    # Exit if cancelled
    Exit
}

$tableProps = @{
    InfoTitle       = "Language Discrepency Report"
    InfoDescription = "Language versions missing in a specific part of the tree"
    PageSize        = 100
}
# Get and display the report in a ListView. 
Get-MissingLanguageVersions -Item $ContextItem -SourceLanguage $fromLanguage -TargetLanguage $toLanguage | Show-ListView @tableProps

```


## LastestItemsUpdated.ps1
```
<# .SYNOPSIS Lists all items based on a selection and the last updated #>
 
#gets the user full name based on the username
function Get-UserFullName($username){
     
    #Gets the user based on the username i.e. sitecore\diego should return the full name for the user diego
    $user = Get-User -Identity $username
     
    if($user.Profile.FullName){
        #returns the fullname
        return $user.Profile.FullName
    }else{
        #full name is not available on the user. Returns the username instead
        return $username   
    }
}
 
#CMDLET to check whether an item has layout or not. Used to determine whether it's a component or not
function Has-Layout{
     [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [Sitecore.Data.Items.Item]$Item       
    )
 
    $layout = Get-Layout -FinalLayout -Item $Item
     
    #Get-Layout returns the layout item. If null means that no presentation is set on the FinalLayout
    if($layout){
        return $Item;
    }
         
    return "";
}
 
$language = $null
 
$database = "master"
 
$root = Get-Item -Language $language.Name -Path "$($database):\content\MySite\Home"
 
$settings = @{
    Title = "Report Filter"
    Width = "600"
    Height = "600"
    OkButtonName = "Proceed"
    CancelButtonName = "Abort"
    Description = "Filter the results for items last updated"
    Parameters = @(
         
        @{ Name = "root"; Title="Choose the report root"; 
        Source="DataSource=/sitecore/content/MySite&DatabaseName=master&IncludeTemplatesForDisplay=My Template&IncludeTemplatesForSelection=My Template"; 
        editor="droptree"; Mandatory=$true;},
        @{ Name = "language"; Title="Pick One Language"; 
        Source="DataSource=/sitecore/system/Languages&DatabaseName=master"; 
        editor="droplist"; Mandatory=$true;}
         
    )
}
 
$result = Read-Variable @settings
if($result -ne "ok") {
    Exit
}
 

$items = Get-ChildItem -Language $language.Name -Path $root.ProviderPath -Recurse | Where-Object {  (Has-Layout $_) -ne "" } |  Sort-Object __Updated -descending
 
if($items.Count -eq 0) {
    Show-Alert "No items found for the path provided"
} else {
    $props = @{
        Title = "Items Last Updated Report"
        InfoTitle = "Items last updated"
        InfoDescription = "Lists all items last updated "
        PageSize = 25
    }
     
    $items |
        Show-ListView @props -Property @{Label="Name"; Expression={$_.DisplayName} },
            @{Label="Path"; Expression={$_.ItemPath} },
            @{Label="Updated"; Expression={$_.__Updated} },
            @{Label="Updated by"; Expression={Get-UserFullName($_."__Updated by") } },
            @{Label="Created by"; Expression={$_."__Created by"} }
             
}
Close-Window

```

Get-IsPublished.ps1
```
function Get-IsPublished {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Item]
        $Item
    )
    
    $webDbItem = Get-Item web: -Id $_.ID

    if ($null -ne $webDbItem) {
        return "YES"
    }else{
        return "NO"
    }
}
```

Get-MultilistFieldDisplayNames.ps1
```
function Get-MultilistFieldDisplayNames {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Item]$Item,
        
        [Parameter(Mandatory = $true)]
        [string]$FieldName,
        
        [Parameter(Mandatory = $true)]
        [string]$DisplayNameField
    )

    $displayNames = @()
    $invalidCount = 0

    if ($Item.Fields[$FieldName] -and $Item.Fields[$FieldName].Value -ne "") {
        $taxonomyIds = $Item.Fields[$FieldName].Value -split "\|"

        foreach ($id in $taxonomyIds) {
            $taxonomyItem = Get-Item -Path master: -ID $id
            if ($taxonomyItem -ne $null) {
                $displayName = $taxonomyItem.Fields[$DisplayNameField].Value
                
                if ($displayName -eq "" -or $displayName.TrimEnd('/').Split('(').Count -ne 2) {
                    $invalidCount += 1
                }

                $displayNames += $displayName
            }
        }
    }

    if ($invalidCount -gt 0) {
        return $displayNames -join ", "
    }

    return $null
}

```


Get-ItemSitecoreContentEditorLink.ps1
```
function Get-ItemSitecoreCELink {
    [CmdletBinding()]
    param( 
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Sitecore.Data.Items.Item]$Item        
    )
    $path = "sitecore/shell/applications/content-editor?id=$($Item.Id)&amp;vs=$($Item.Versions.Version)&amp;la=$($Item.Language)&amp;fo=$($Item.Id)&amp;sc_content=master&amp;ic=Apps%2F48x48%2FPencil.png&amp;he=Content%20Editor&amp;cl=0"
    return "https://yourcmurl.com/$path"
}
```


Get-ItemUrl.ps1
```
function Get-ItemUrl($itemToProcess) {
    $hostName = "https://www.sitedomain.com/"

    foreach($node in [Sitecore.Configuration.Factory]::GetConfigNodes("settings/setting") | Where-Object { $_.Name -eq "hostname"})  { 
        $hostName = [Sitecore.Xml.XmlUtil]::GetAttribute("value", $node) + "/"
    }
    [Sitecore.Context]::SetActiveSite("sitename")
    $urlop = New-Object ([Sitecore.Links.UrlOptions]::DefaultOptions)
    $urlop.AddAspxExtension = $false
    $urlop.AlwaysIncludeServerUrl = $true
    $linkUrl = [Sitecore.Links.LinkManager]::GetItemUrl($itemToProcess, $urlop)
    $linkUrl = $linkUrl -replace "http://localhost/", $hostName
    $linkUrl
}

```

Get-FormattedDate.ps1
```
function Get-FormattedDate ($RawDateValue) {
 [CmdletBinding()]
    param( 
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RawDateValue        
    )

    $date = [datetime]::ParseExact($RawDateValue, "yyyyMMddTHHmmssZ", [System.Globalization.CultureInfo]::CurrentCulture)
    if ($date -ne $null) {
        return Get-Date $date -Format "MM/dd/yyyy"
    }
    else { return "" }
}

$reportItems | Sort-Object $_.Name | Show-ListView @props -Property @{ Label = "Item Name"; Expression = { $_.Name } },
@{ Label = "Item ID"; Expression = { $_.Id } },
@{ Label = "Dave Value"; Expression = { Get-FormattedDate $_.Fields["Custom Date Field"].Value } }

```

Get-LinkFieldUrl.ps1
```
function Get-LinkFieldUrl {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Sitecore.Data.Items.Item]$Item        
    )
    # Regular expression to extract the URL
    $regex = '<link\s+url="([^"]+)"'

    $linkFieldValue = $Item.Fields["My Link Field"].Value;
    if ($linkFieldValue -ne "") {
        if ($linkFieldValue -match $regex) {
            $urlValue = $matches[1]
            return $urlValue
        } 
    }
}
```

Get-WorkflowNames.ps1
```
function Get-WorkflowName($id) {
    return (Get-Item "master://$id").Name
}

function Get-WorkflowStateName($id) {
    return (Get-Item "master://$id").Name
}

# Example usage in show list view props
$reportItems | Show-ListView @props -Property @{Label = "Name"; Expression = { $_.DisplayName } },
@{Label = "Workflow"; Expression = { Get-WorkflowName($_."__Workflow") } },
@{Label = "Workflow State"; Expression = {  Get-WorkflowStateName($_."__Workflow state") } },
Close-Window
```


DroptreeCheckAndSet.ps1
```
# Prompt the user for the root path to process using a droptree dialog
$dialogProps = @{
    Title            = "AudioUrlReport - Select Report Scope"
    Description      = "Choose the root path to scan for Article items with an Audio Url populated. Default is '/sitecore/content/Global/Home'."
    Width            = 450 
    Height           = 300
    OkButtonName     = "Continue"
    CancelButtonName = "Cancel"
    ShowHints        = $true
    Parameters       = @(
        @{
            Name   = "selectedPath"; 
            Title  = "Select Root Path";
            Source = "/sitecore/content/Global/Home"
            Editor = "droptree";
            Tooltip = "Select the root path for the scan."
        }
    )
}

$result = Read-Variable @dialogProps
if ($result -ne "ok") { Exit }

$rootPath = $selectedPath.Paths.Path
Write-Host "Path: $rootPath"
if($rootPath  -eq "" -or $rootPath -eq $null){
     $rootPath  = $dialogProps.Parameters.Source
}

Write-Host "Path: $rootPath"

```

# Example of Generally Expected Report Structure
```
<#.SYNOPSIS
   Brief summary of the script's purpose.
#>

# Dialog for scope selection
$dialogProps = @{
    Title = "Report Scope Selection"
    Description = "Select the root path for this report."
    Parameters = @(
        @{
            Name = "selectedPath"
            Title = "Root Path"
            Source = "/sitecore/content"
            Editor = "droptree"
        }
    )
}
$result = Read-Variable @dialogProps

if ($result -ne "ok" -or [string]::IsNullOrEmpty($selectedPath)) {
    Write-Host "No path selected, exiting."
    Exit
}

Write-Host "Selected path: $selectedPath"

# Main logic and item retrieval
$items = Get-ChildItem -Path "master:/$selectedPath" -Recurse | Where-Object { $_.TemplateName -eq "DesiredTemplate" }

# Displaying results
$items | Show-ListView -Property @{
    Label="Item Name"; Expression={$_.Name}
}, @{
    Label="Item ID"; Expression={$_.ID}
}, @{
    Label="Path"; Expression={$_.Paths.Path}
}, @{
    Label="Created"; Expression={$_.__Created}
}, @{
    Label="Updated"; Expression={$_.__Updated}
}

```