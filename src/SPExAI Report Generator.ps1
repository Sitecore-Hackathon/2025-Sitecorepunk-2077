<#
    .SYNOPSIS
    Generates Sitecore PowerShell Extensions scripts using OpenAI GPT models based on user input, including report name, scope, and description (using natural language).

    .DESCRIPTION
    This script leverages OpenAI's API to create a Sitecore PowerShell script tailored to user specifications. 
    It prompts the user for details such as the report name, scope, and description, and then uses these inputs to generate a script via the OpenAI API. 
    The resulting script is stored as a Sitecore PowerShell script item within the Content Reports folder. 
    Additional context for the AI model is provided through a Knowledgebase field, and a System Prompt field is used to initialize the AI model.

    The script performs the following steps:
    1. Collects user input for the report name, scope, and description through a dialog.
    2. Uses the OpenAI API to generate a PowerShell script based on the user input.
    3. Saves the generated script as a Sitecore PowerShell script item in the specified folder.
    4. Provides an option to execute the saved report immediately.

    .NOTES
    The script requires valid API settings to be configured in Sitecore at `/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings`.
    Ensure the API Key, Model, System Prompt, and Knowledgebase fields are correctly set.
    The script checks for the presence of these settings and alerts the user if any are missing.
#>

function Invoke-OpenAIChat {
    param (
        [string]$userMessage
    )

    $url = "https://api.openai.com/v1/chat/completions"

    $headers = @{
        "Authorization"  = "Bearer $script:OPENAI_API_KEY"
        "Content-Type"   = "application/json"
    }

    # Combine system prompt with the knowledgebase content
    $systemPrompt = $script:OPENAI_SYSTEM_PROMPT -f $script:OPENAI_KNOWLEDGEBASE

    # User prompt
    $userPrompt =  "`nReport Name: $script:ReportName`nReport Scope: $($script:ReportScope.Paths.Path)`nReport Description: $script:ReportDescription"

    # Combine system and user prompts
    $systemPrompt += $userPrompt

    # Write system prompt:
    Write-Host "[User Prompt] $userPrompt"

    # Chat history
    $messages = @(
        @{ "role" = "system"; "content" = "$systemPrompt" }
    ) + ($chatHistory | ForEach-Object { @{ "role" = if ($_.Role -eq "You") { "user" } else { "assistant" }; "content" = $_.Message } }) + @(
        @{ "role" = "user"; "content" = $userMessage }
    )

    # Prepare the request body
    $body = @{
        "model"    = $script:OPENAI_API_MODEL
        "messages" = $messages
    } | ConvertTo-Json -Depth 3

    # Invoke the OpenAI API
    try{
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $body
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        Show-Alert "An error occurred while invoking the OpenAI API. Please check the API settings and try again."
        return
    }

    if ($response.choices[0].message.content -eq "") {
        Write-Host "An error occurred while generating the script. Please try again." -ForegroundColor Red
        Show-Alert "An error occurred while generating the script. Please try again."
        return
    }
    $assistantMessage = $response.choices[0].message.content
    $chatHistory += @{ Role = "Assistant"; Message = $assistantMessage }

    return $assistantMessage
}

# Global Host/Key script variables used for OpenAI API
$script:OPENAI_API_KEY = ""
$script:OPENAI_API_MODEL = ""
$script:OPENAI_SYSTEM_PROMPT = ""

# Settings item is located at `/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings`
$settingsItem = Get-Item "master://{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}"

# Check for Settings item
if ($null -eq $settingsItem) {
    Write-Host "API Settings item is missing: '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'.  Please check this path or reinstall the module." -ForegroundColor Red
    Show-Alert "'OpenAI API Settings' item is missing: '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'.  Please check this path or reinstall the module."
    Exit
}

# OpenAI API Key setting
if ($settingsItem.Fields["API Key"].Value -ne "") {
    $script:OPENAI_API_KEY = $settingsItem.Fields["API Key"].Value
}
else {
    Write-Host "API Key must be present on the 'API Settings' item. Please check the value on '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'.  ID: '{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}'" -ForegroundColor Red
    Show-Alert "API key must be present on the 'API Settings'  `n`nPlease check the value on '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'. `n`n ID: '{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}'"
    Exit 
}

# OpenAI API Model setting
if ($settingsItem.Fields["Model"].Value -ne "") {
    $script:OPENAI_API_MODEL = $settingsItem.Fields["Model"].Value
}
else {
    Write-Host "API Model must be present on the 'API Settings' item. Please check the value on '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'.  ID: '{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}'" -ForegroundColor Red
    Show-Alert "API Model must be present on the 'API Settings'  `n`nPlease check the value on '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'. `n`n ID: '{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}'"
    Exit 
}

# OpenAI System Prompt setting
if ($settingsItem.Fields["System Prompt"].Value -ne "") {
    $script:OPENAI_SYSTEM_PROMPT = $settingsItem.Fields["System Prompt"].Value
}
else {
    Write-Host "System Prompt must be present on the 'API Settings' item. Please check the value on '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'.  ID: '{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}'" -ForegroundColor Red
    Show-Alert "System Prompt must be present on the 'API Settings'  `n`nPlease check the value on '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'. `n`n ID: '{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}'"
    Exit 
}

# OpenAI Knowledgebase field
if ($settingsItem.Fields["Knowledgebase"].Value -ne "") {
    $script:OPENAI_KNOWLEDGEBASE = $settingsItem.Fields["Knowledgebase"].Value
}
else {
    Write-Host "Knowledgebase must be present on the 'API Settings' item. Please check the value on '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'.  ID: '{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}'" -ForegroundColor Red
    Show-Alert "Knowledgebase must be present on the 'API Settings'  `n`nPlease check the value on '/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings'. `n`n ID: '{DDEAB7C1-4CDC-4FA8-B055-B62E954B170F}'"
    Exit 
}

$chatHistory = @()

# Get the current context item
$rootItem = Get-Item "."

Write-Host "Root Item: $($rootItem.Paths.Path)" -ForegroundColor Green

# Open a dialog to collect user input for the report
$dialogProps = @{
    Parameters  = @(
        @{ Name = "ReportName"; Title = "Report Name"; Editor = "text"; Tooltip = "Enter a name for your report." },
        @{ Name = "ReportScope"; Title = "Report Scope (Root Location)"; Editor = "droptree"; Source = "$($rootItem.Paths.Path)"; Tooltip = "Select a root item." },
        @{ Name = "ReportDescription"; Title = "Describe Your Report"; Editor = "multiline text"; Lines = 3; Tooltip = "Example: 'Show all articles created in the last 30 days with author names.'"}
    )
    Title       = "New AI-Generated PowerShell Report"
    Description = "Describe the report you want to generate in natural language."
    ShowHints   = $true
}

$dialogResult = Read-Variable @dialogProps
if ($dialogResult -eq "cancel") { exit }

# Assign variables from dialog
$script:ReportName = $ReportName
$script:ReportScope = $ReportScope
$script:ReportDescription = $ReportDescription

# Ensure a valid report name
if (-not $script:ReportName) {
    Write-Host "Report Name is required!" -ForegroundColor Red
    Show-Alert "Report Name is required!"
    exit
}

# Check if Report Name already exists before generating
$reportFolderPath = "/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/Content Reports/Reports/SPExAI Generated"
$reportItemPath = "$reportFolderPath/$script:ReportName"

if (Test-Path -Path "master:$reportItemPath") {
    Write-Host "A report with this name already exists. Choose a different name." -ForegroundColor Red
    Show-Alert "A report with this name already exists. Choose a different name."
    exit
}

# Start the timer
$startTime = $(get-date)

# Use AI to Generate PowerShell Script
Write-Host "Generating AI-powered script for report: $($script:ReportName)..." -ForegroundColor Green
$generatedScript = Invoke-OpenAIChat -userMessage $script:OPENAI_SYSTEM_PROMPT 

if (-not $generatedScript) {
    Write-Host "SPExAI did not return a valid script. Try again." -ForegroundColor Red
    Show-Alert "SPExAI did not return a valid script. Try again."
    exit
}

Write-Host "Script generated successfully." -ForegroundColor Green
$elapsedTime = $(get-date) - $startTime
$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
Write-Host "> Completed in: $totalTime" -ForegroundColor Green

# Create the report as a Sitecore PowerShell Script item
Write-Host "Saving report script..." -ForegroundColor Green
$reportItem = New-Item -Path "master:$reportFolderPath" -Name $script:ReportName -ItemType "{DD22F1B3-BD87-4DB2-9E7D-F7A496888D43}"
if ($reportItem) {
    $reportItem.Editing.BeginEdit()
    $reportItem.Fields["Script"].Value = $generatedScript
    $reportItem.Editing.EndEdit()
}

Write-Host "Report script saved at $reportItemPath" -ForegroundColor Green

$continue = Show-ModalDialog -Control "ConfirmChoice" -Parameters @{ btn_0 = "Open Script Item"; btn_1 = "Run Report"; btn_2 = "Close"; te = "What would you like to do?"; cp = "Choose an option" } -Height 120 -Width 400
if ($continue -eq "btn_0") {
    Show-Application `
    -Application "Content Editor" `
    -Parameter @{id ="$($reportItem.ID)"; fo="$($reportItem.ID)"; 
                 la="$($reportItem.Language.Name)"; vs="$($reportItem.Version.Number)";
                 sc_content="$($reportItem.Database.Name)"}
} elseif ($continue -eq "btn_1") {
    Invoke-Script -Path "master:$reportItemPath"
} elseif ($continue -eq "btn_2") {
    Write-Host "Exiting..."
    Close-Window
    exit
}