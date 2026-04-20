<#
Beginner PowerShell Command Center - Premium Edition

This script is a more polished, menu-driven PowerShell console tool for beginners.
It adds:
- An ASCII banner
- Category-based sub-menus
- Clear labels and color-coded feedback
- Safe confirmations before risky actions
- Friendly prompts and comments for non-technical users

How to use:
1. Save this file as a .ps1 script
2. Run it in Windows PowerShell
3. Choose a category from the main menu
4. Choose an action inside that category
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $Host.UI.RawUI.WindowTitle = 'Beginner PowerShell Command Center - Premium Edition'
} catch {
    # Some PowerShell hosts do not allow changing the window title.
}

# ------------------------------------------------------------
# Visual helper functions
# These functions keep the interface clean and consistent.
# ------------------------------------------------------------

function Write-Rule {
    Write-Host ('=' * 90) -ForegroundColor DarkGray
}

function Write-SoftRule {
    Write-Host ('-' * 90) -ForegroundColor DarkGray
}

function Write-Info {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[INFO] $Message" -ForegroundColor Gray
}

function Write-Success {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-WarningMessage {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-SectionTitle {
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    Write-Host ''
    Write-Host $Text -ForegroundColor Magenta
}

function Write-MenuItem {
    param(
        [Parameter(Mandatory)]
        [string]$Number,
        [Parameter(Mandatory)]
        [string]$Title,
        [Parameter(Mandatory)]
        [string]$Description
    )

    Write-Host ("[{0,2}] " -f $Number) -ForegroundColor Yellow -NoNewline
    Write-Host $Title -ForegroundColor White -NoNewline
    Write-Host " - $Description" -ForegroundColor Gray
}

function Show-AsciiBanner {
    $bannerLines = @(
        '  ____                              _             ____                                  ',
        ' | __ )  ___  __ _ _ _ __  _ __   | |__  _   _  / ___|___  _ __ ___  _ __   __ _ _ __ ',
        ' |  _ \ / _ \/ _` | | `_ \| `_ \  | `_ \| | | | | |   / _ \| `_ ` _ \| `_ \ / _` | `_ \',
        ' | |_) |  __/ (_| | | | | | | | | | |_) | |_| | | |__| (_) | | | | | | |_) | (_| | | | |',
        ' |____/ \___|\__, |_|_| |_|_| |_| |_.__/ \__, |  \____\___/|_| |_| |_| .__/ \__,_|_| |_|',
        '             |___/                       |___/                         |_|                '
    )

    foreach ($line in $bannerLines) {
        Write-Host $line -ForegroundColor Cyan
    }

    Write-Host '                                Premium Edition' -ForegroundColor DarkCyan
}

function Show-PageHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        [Parameter(Mandatory)]
        [string]$Subtitle,
        [string]$Breadcrumb = 'Main Menu',
        [switch]$ShowBanner
    )

    Clear-Host

    if ($ShowBanner) {
        Show-AsciiBanner
        Write-Rule
    }

    Write-Host $Title -ForegroundColor Cyan
    Write-Host $Subtitle -ForegroundColor Gray
    Write-Host "Navigation: $Breadcrumb" -ForegroundColor DarkYellow
    Write-Host "User: $(whoami) | Computer: $(hostname) | Location: $(Get-Location)" -ForegroundColor DarkGray
    Write-Rule
}

# ------------------------------------------------------------
# Input and confirmation helper functions
# These make the tool safer and easier to use.
# ------------------------------------------------------------

function Pause-CommandCenter {
    Write-Host ''
    [void](Read-Host 'Press Enter to continue')
}

function Read-RequiredInput {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        [string]$Example = ''
    )

    while ($true) {
        $finalPrompt = if ([string]::IsNullOrWhiteSpace($Example)) {
            $Prompt
        } else {
            "$Prompt (Example: $Example)"
        }

        $value = Read-Host $finalPrompt
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value.Trim()
        }

        Write-WarningMessage 'This value cannot be empty. Please try again.'
    }
}

function Read-OptionalInput {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt
    )

    $value = Read-Host $Prompt
    if ([string]::IsNullOrWhiteSpace($value)) {
        return ''
    }

    return $value.Trim()
}

function Read-Confirmation {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    while ($true) {
        $answer = Read-Host "$Message [Y/N]"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            Write-WarningMessage 'Please answer with Y or N.'
            continue
        }

        switch ($answer.Trim().ToUpperInvariant()) {
            'Y' { return $true }
            'YES' { return $true }
            'N' { return $false }
            'NO' { return $false }
            default { Write-WarningMessage 'Please answer with Y or N.' }
        }
    }
}

function Resolve-DisplayPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    try {
        return (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    } catch {
        return $Path
    }
}

function Invoke-MenuAction {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Action
    )

    try {
        & $Action
    } catch {
        Write-ErrorMessage $_.Exception.Message
    } finally {
        Pause-CommandCenter
    }
}

function Start-KnownProgram {
    param(
        [Parameter(Mandatory)]
        [string]$DisplayName,
        [Parameter(Mandatory)]
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        $looksLikePath = $candidate.Contains('\') -or $candidate.Contains('/')

        if ($looksLikePath) {
            if (Test-Path -LiteralPath $candidate) {
                Start-Process -FilePath $candidate -ErrorAction Stop
                Write-Success "$DisplayName started successfully."
                return
            }
            continue
        }

        try {
            Start-Process -FilePath $candidate -ErrorAction Stop
            Write-Success "$DisplayName started successfully."
            return
        } catch {
            # Try the next possible program location.
        }
    }

    throw "$DisplayName was not found on this computer."
}

# ------------------------------------------------------------
# Action functions
# Each function performs one user action from a menu.
# ------------------------------------------------------------

function Invoke-CreateFolder {
    Invoke-MenuAction {
        $folderPath = Read-RequiredInput -Prompt 'Enter the folder name or path' -Example 'test'

        if (Test-Path -LiteralPath $folderPath) {
            Write-WarningMessage "That path already exists: $(Resolve-DisplayPath -Path $folderPath)"
            return
        }

        $newFolder = New-Item -ItemType Directory -Path $folderPath -ErrorAction Stop
        Write-Success "Folder created: $($newFolder.FullName)"
    }
}

function Invoke-CreateFile {
    Invoke-MenuAction {
        $filePath = Read-RequiredInput -Prompt 'Enter the file name or path' -Example 'file.txt'

        if (Test-Path -LiteralPath $filePath) {
            Write-WarningMessage "That file already exists: $(Resolve-DisplayPath -Path $filePath)"
            return
        }

        $newFile = New-Item -ItemType File -Path $filePath -ErrorAction Stop
        Write-Success "File created: $($newFile.FullName)"
    }
}

function Invoke-DeleteFile {
    Invoke-MenuAction {
        $filePath = Read-RequiredInput -Prompt 'Enter the file to delete' -Example 'file.txt'

        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            throw 'The file was not found.'
        }

        $displayPath = Resolve-DisplayPath -Path $filePath
        Write-WarningMessage "You are about to permanently delete this file: $displayPath"

        if (-not (Read-Confirmation -Message 'Do you want to continue?')) {
            Write-Info 'File deletion cancelled.'
            return
        }

        Remove-Item -LiteralPath $filePath -ErrorAction Stop
        Write-Success "File deleted: $displayPath"
    }
}

function Invoke-DeleteFolder {
    Invoke-MenuAction {
        $folderPath = Read-RequiredInput -Prompt 'Enter the folder to delete' -Example 'dossier'

        if (-not (Test-Path -LiteralPath $folderPath -PathType Container)) {
            throw 'The folder was not found.'
        }

        $displayPath = Resolve-DisplayPath -Path $folderPath
        $itemCount = @(Get-ChildItem -LiteralPath $folderPath -Force -Recurse -ErrorAction Stop).Count

        Write-WarningMessage "You are about to permanently delete this folder: $displayPath"
        Write-WarningMessage "Items inside the folder: $itemCount"

        if (-not (Read-Confirmation -Message 'Do you want to continue?')) {
            Write-Info 'Folder deletion cancelled.'
            return
        }

        Remove-Item -LiteralPath $folderPath -Recurse -Force -ErrorAction Stop
        Write-Success "Folder deleted: $displayPath"
    }
}

function Invoke-CopyFile {
    Invoke-MenuAction {
        $sourcePath = Read-RequiredInput -Prompt 'Enter the source file' -Example 'file.txt'
        $destinationPath = Read-RequiredInput -Prompt 'Enter the destination path or file name' -Example 'copie.txt'

        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            throw 'The source file was not found.'
        }

        Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -ErrorAction Stop
        Write-Success "File copied to: $(Resolve-DisplayPath -Path $destinationPath)"
    }
}

function Invoke-RenameOrMoveFile {
    Invoke-MenuAction {
        $sourcePath = Read-RequiredInput -Prompt 'Enter the current file path' -Example 'file.txt'
        $destinationPath = Read-RequiredInput -Prompt 'Enter the new file name or destination path' -Example 'new.txt'

        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            throw 'The source file was not found.'
        }

        Move-Item -LiteralPath $sourcePath -Destination $destinationPath -ErrorAction Stop
        Write-Success "File renamed or moved to: $(Resolve-DisplayPath -Path $destinationPath)"
    }
}

function Invoke-ReadFile {
    Invoke-MenuAction {
        $filePath = Read-RequiredInput -Prompt 'Enter the file to read' -Example 'file.txt'

        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            throw 'The file was not found.'
        }

        Write-Host ''
        Write-SoftRule
        Write-Host "Content of: $(Resolve-DisplayPath -Path $filePath)" -ForegroundColor Cyan
        Write-SoftRule
        Get-Content -LiteralPath $filePath -ErrorAction Stop | Out-Host
        Write-SoftRule
    }
}

function Invoke-WriteFile {
    Invoke-MenuAction {
        $filePath = Read-RequiredInput -Prompt 'Enter the file to write to' -Example 'file.txt'
        $content = Read-RequiredInput -Prompt 'Enter the text to write' -Example 'Hello'

        if (Test-Path -LiteralPath $filePath) {
            Write-WarningMessage 'This action will replace the current content of the file.'
            if (-not (Read-Confirmation -Message 'Do you want to overwrite the file?')) {
                Write-Info 'Write action cancelled.'
                return
            }
        }

        Set-Content -LiteralPath $filePath -Value $content -Encoding UTF8 -ErrorAction Stop
        Write-Success "Content written to: $(Resolve-DisplayPath -Path $filePath)"
    }
}

function Invoke-AppendFile {
    Invoke-MenuAction {
        $filePath = Read-RequiredInput -Prompt 'Enter the file to append to' -Example 'file.txt'
        $content = Read-RequiredInput -Prompt 'Enter the text to append' -Example 'Hi'

        Add-Content -LiteralPath $filePath -Value $content -Encoding UTF8 -ErrorAction Stop
        Write-Success "Content appended to: $(Resolve-DisplayPath -Path $filePath)"
    }
}

function Invoke-ClearScreen {
    Invoke-MenuAction {
        Clear-Host
        Write-Success 'The console screen was cleared.'
    }
}

function Invoke-DisplayMessage {
    Invoke-MenuAction {
        $message = Read-RequiredInput -Prompt 'Enter the message to display' -Example 'Hello'
        Write-Host ''
        Write-Host $message -ForegroundColor Cyan
        Write-Success 'Your message was displayed.'
    }
}

function Invoke-ShowDate {
    Invoke-MenuAction {
        Write-Host ''
        Write-Host (Get-Date) -ForegroundColor Green
        Write-Success 'Current date and time displayed.'
    }
}

function Invoke-ShowCurrentUser {
    Invoke-MenuAction {
        Write-Host ''
        Write-Host (whoami) -ForegroundColor Green
        Write-Success 'Current user displayed.'
    }
}

function Invoke-ShowComputerName {
    Invoke-MenuAction {
        Write-Host ''
        Write-Host (hostname) -ForegroundColor Green
        Write-Success 'Computer name displayed.'
    }
}

function Invoke-PingHost {
    Invoke-MenuAction {
        $target = Read-RequiredInput -Prompt 'Enter the website or host to ping' -Example 'google.com'

        Write-Info "Pinging $target. Please wait..."
        Test-Connection -ComputerName $target -Count 4 -ErrorAction Stop |
            Select-Object Address, IPV4Address, ResponseTime, @{
                Name = 'Status'
                Expression = {
                    if ($_.StatusCode -eq 0) { 'Success' } else { "StatusCode $($_.StatusCode)" }
                }
            } |
            Format-Table -AutoSize |
            Out-Host
        Write-Success 'Ping finished.'
    }
}

function Invoke-ShowIpConfig {
    Invoke-MenuAction {
        Write-Host ''
        ipconfig | Out-Host
        Write-Success 'IP configuration displayed.'
    }
}

function Invoke-TestNetworkConnection {
    Invoke-MenuAction {
        $target = Read-RequiredInput -Prompt 'Enter the host to test' -Example 'google.com'

        Write-Info "Testing network connection to $target. Please wait..."
        Test-NetConnection -ComputerName $target -ErrorAction Stop | Out-Host
        Write-Success 'Network test finished.'
    }
}

function Invoke-OpenChrome {
    Invoke-MenuAction {
        Start-KnownProgram -DisplayName 'Google Chrome' -Candidates @(
            'chrome.exe',
            "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
            "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
            "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
        )
    }
}

function Invoke-OpenNotepad {
    Invoke-MenuAction {
        Start-KnownProgram -DisplayName 'Notepad' -Candidates @('notepad.exe')
    }
}

function Invoke-OpenCurrentFolder {
    Invoke-MenuAction {
        $currentFolder = (Get-Location).Path
        Start-Process -FilePath 'explorer.exe' -ArgumentList $currentFolder -ErrorAction Stop
        Write-Success "Opened current folder: $currentFolder"
    }
}

function Invoke-ShowAllCommands {
    Invoke-MenuAction {
        Get-Command |
            Sort-Object Name |
            Select-Object Name, CommandType, Source |
            Format-Table -AutoSize |
            Out-Host -Paging
        Write-Success 'Command list displayed.'
    }
}

function Invoke-ShowHelpForCommand {
    Invoke-MenuAction {
        $commandName = Read-RequiredInput -Prompt 'Enter the command name to learn about' -Example 'cd'

        Get-Help -Name $commandName -Full -ErrorAction Stop | Out-Host -Paging
        Write-Success "Help displayed for command: $commandName"
    }
}

function Invoke-ListRecursiveFiles {
    Invoke-MenuAction {
        $searchPath = Read-OptionalInput -Prompt 'Enter a folder path, or press Enter to use the current folder'
        if ([string]::IsNullOrWhiteSpace($searchPath)) {
            $searchPath = (Get-Location).Path
        }

        if (-not (Test-Path -LiteralPath $searchPath -PathType Container)) {
            throw 'The folder to search was not found.'
        }

        Get-ChildItem -LiteralPath $searchPath -Recurse -File -ErrorAction Stop |
            Select-Object FullName, Length, LastWriteTime |
            Format-Table -AutoSize |
            Out-Host -Paging
        Write-Success "Recursive file list displayed for: $(Resolve-DisplayPath -Path $searchPath)"
    }
}

function Invoke-ShowProcesses {
    Invoke-MenuAction {
        Get-Process |
            Sort-Object ProcessName |
            Select-Object Id, ProcessName, @{
                Name = 'MemoryMB'
                Expression = { [math]::Round($_.WorkingSet64 / 1MB, 2) }
            } |
            Format-Table -AutoSize |
            Out-Host -Paging
        Write-Success 'Running processes displayed.'
    }
}

function Invoke-StopProcess {
    Invoke-MenuAction {
        $processName = Read-RequiredInput -Prompt 'Enter the process name to stop' -Example 'notepad'
        $matchingProcesses = @(Get-Process -Name $processName -ErrorAction Stop)

        Write-WarningMessage "You are about to stop $($matchingProcesses.Count) process(es) named '$processName'."
        $matchingProcesses |
            Select-Object Id, ProcessName, MainWindowTitle |
            Format-Table -AutoSize |
            Out-Host

        if (-not (Read-Confirmation -Message 'Do you want to continue?')) {
            Write-Info 'Stop process action cancelled.'
            return
        }

        Stop-Process -Name $processName -ErrorAction Stop
        Write-Success "Process stopped: $processName"
    }
}

# ------------------------------------------------------------
# Sub-menu functions
# Each category has its own loop and its own "Back" option.
# ------------------------------------------------------------

function Show-FileAndFolderMenu {
    while ($true) {
        Show-PageHeader `
            -Title 'File and Folder Management' `
            -Subtitle 'Create, copy, rename, or delete files and folders safely.' `
            -Breadcrumb 'Main Menu > File and Folder Management'

        Write-MenuItem -Number '1' -Title 'Create folder' -Description 'Example: create a folder named test'
        Write-MenuItem -Number '2' -Title 'Create file' -Description 'Example: create file.txt'
        Write-MenuItem -Number '3' -Title 'Delete file' -Description 'Delete one file after confirmation'
        Write-MenuItem -Number '4' -Title 'Delete folder' -Description 'Delete a folder and all content after confirmation'
        Write-MenuItem -Number '5' -Title 'Copy file' -Description 'Copy one file to another path'
        Write-MenuItem -Number '6' -Title 'Rename or move file' -Description 'Change file name or location'
        Write-Host ''
        Write-MenuItem -Number '0' -Title 'Back to main menu' -Description 'Return to the main category list'
        Write-Host ''

        $choice = Read-Host 'Choose an option in this category'
        switch ($choice.Trim()) {
            '1' { Invoke-CreateFolder }
            '2' { Invoke-CreateFile }
            '3' { Invoke-DeleteFile }
            '4' { Invoke-DeleteFolder }
            '5' { Invoke-CopyFile }
            '6' { Invoke-RenameOrMoveFile }
            '0' { return }
            default {
                Write-WarningMessage 'Invalid choice. Please choose a number shown in the menu.'
                Pause-CommandCenter
            }
        }
    }
}

function Show-ReadWriteMenu {
    while ($true) {
        Show-PageHeader `
            -Title 'Read and Write Files' `
            -Subtitle 'Read file content, replace content, or add new lines to a file.' `
            -Breadcrumb 'Main Menu > Read and Write Files'

        Write-MenuItem -Number '1' -Title 'Read file content' -Description 'Show what is inside a file'
        Write-MenuItem -Number '2' -Title 'Write content to file' -Description 'Replace current file content with new text'
        Write-MenuItem -Number '3' -Title 'Append content to file' -Description 'Add new text to the end of a file'
        Write-Host ''
        Write-MenuItem -Number '0' -Title 'Back to main menu' -Description 'Return to the main category list'
        Write-Host ''

        $choice = Read-Host 'Choose an option in this category'
        switch ($choice.Trim()) {
            '1' { Invoke-ReadFile }
            '2' { Invoke-WriteFile }
            '3' { Invoke-AppendFile }
            '0' { return }
            default {
                Write-WarningMessage 'Invalid choice. Please choose a number shown in the menu.'
                Pause-CommandCenter
            }
        }
    }
}

function Show-SystemMenu {
    while ($true) {
        Show-PageHeader `
            -Title 'Useful System Commands' `
            -Subtitle 'Simple information and console actions for everyday use.' `
            -Breadcrumb 'Main Menu > Useful System Commands'

        Write-MenuItem -Number '1' -Title 'Clear screen' -Description 'Clean the console window'
        Write-MenuItem -Number '2' -Title 'Display a message' -Description 'Show a custom message on screen'
        Write-MenuItem -Number '3' -Title 'Show date' -Description 'Display the current date and time'
        Write-MenuItem -Number '4' -Title 'Show current user' -Description 'Display the signed-in user'
        Write-MenuItem -Number '5' -Title 'Show computer name' -Description 'Display the PC name'
        Write-Host ''
        Write-MenuItem -Number '0' -Title 'Back to main menu' -Description 'Return to the main category list'
        Write-Host ''

        $choice = Read-Host 'Choose an option in this category'
        switch ($choice.Trim()) {
            '1' { Invoke-ClearScreen }
            '2' { Invoke-DisplayMessage }
            '3' { Invoke-ShowDate }
            '4' { Invoke-ShowCurrentUser }
            '5' { Invoke-ShowComputerName }
            '0' { return }
            default {
                Write-WarningMessage 'Invalid choice. Please choose a number shown in the menu.'
                Pause-CommandCenter
            }
        }
    }
}

function Show-NetworkMenu {
    while ($true) {
        Show-PageHeader `
            -Title 'Network and Internet' `
            -Subtitle 'Test connectivity, check IP information, and inspect network access.' `
            -Breadcrumb 'Main Menu > Network and Internet'

        Write-MenuItem -Number '1' -Title 'Ping a website' -Description 'Example: google.com'
        Write-MenuItem -Number '2' -Title 'Show IP configuration' -Description 'Display network adapter details'
        Write-MenuItem -Number '3' -Title 'Test network connection' -Description 'Run Test-NetConnection on a host'
        Write-Host ''
        Write-MenuItem -Number '0' -Title 'Back to main menu' -Description 'Return to the main category list'
        Write-Host ''

        $choice = Read-Host 'Choose an option in this category'
        switch ($choice.Trim()) {
            '1' { Invoke-PingHost }
            '2' { Invoke-ShowIpConfig }
            '3' { Invoke-TestNetworkConnection }
            '0' { return }
            default {
                Write-WarningMessage 'Invalid choice. Please choose a number shown in the menu.'
                Pause-CommandCenter
            }
        }
    }
}

function Show-LaunchMenu {
    while ($true) {
        Show-PageHeader `
            -Title 'Launch Programs' `
            -Subtitle 'Open common applications or the current folder with one choice.' `
            -Breadcrumb 'Main Menu > Launch Programs'

        Write-MenuItem -Number '1' -Title 'Open Chrome' -Description 'Launch Google Chrome if installed'
        Write-MenuItem -Number '2' -Title 'Open Notepad' -Description 'Launch Windows Notepad'
        Write-MenuItem -Number '3' -Title 'Open current folder' -Description 'Open the current folder in File Explorer'
        Write-Host ''
        Write-MenuItem -Number '0' -Title 'Back to main menu' -Description 'Return to the main category list'
        Write-Host ''

        $choice = Read-Host 'Choose an option in this category'
        switch ($choice.Trim()) {
            '1' { Invoke-OpenChrome }
            '2' { Invoke-OpenNotepad }
            '3' { Invoke-OpenCurrentFolder }
            '0' { return }
            default {
                Write-WarningMessage 'Invalid choice. Please choose a number shown in the menu.'
                Pause-CommandCenter
            }
        }
    }
}

function Show-SearchHelpMenu {
    while ($true) {
        Show-PageHeader `
            -Title 'Search and Help' `
            -Subtitle 'Explore available commands, read help, and search for files.' `
            -Breadcrumb 'Main Menu > Search and Help'

        Write-MenuItem -Number '1' -Title 'Show all commands' -Description 'List available PowerShell commands'
        Write-MenuItem -Number '2' -Title 'Show help for a command' -Description 'Example: Get-Help cd'
        Write-MenuItem -Number '3' -Title 'List all files recursively' -Description 'Show files in a folder and all subfolders'
        Write-Host ''
        Write-MenuItem -Number '0' -Title 'Back to main menu' -Description 'Return to the main category list'
        Write-Host ''

        $choice = Read-Host 'Choose an option in this category'
        switch ($choice.Trim()) {
            '1' { Invoke-ShowAllCommands }
            '2' { Invoke-ShowHelpForCommand }
            '3' { Invoke-ListRecursiveFiles }
            '0' { return }
            default {
                Write-WarningMessage 'Invalid choice. Please choose a number shown in the menu.'
                Pause-CommandCenter
            }
        }
    }
}

function Show-ProcessMenu {
    while ($true) {
        Show-PageHeader `
            -Title 'Process Management' `
            -Subtitle 'Inspect running processes or stop one after confirmation.' `
            -Breadcrumb 'Main Menu > Process Management'

        Write-MenuItem -Number '1' -Title 'Show running processes' -Description 'List active processes with memory usage'
        Write-MenuItem -Number '2' -Title 'Stop a process' -Description 'Stop a process safely after confirmation'
        Write-Host ''
        Write-MenuItem -Number '0' -Title 'Back to main menu' -Description 'Return to the main category list'
        Write-Host ''

        $choice = Read-Host 'Choose an option in this category'
        switch ($choice.Trim()) {
            '1' { Invoke-ShowProcesses }
            '2' { Invoke-StopProcess }
            '0' { return }
            default {
                Write-WarningMessage 'Invalid choice. Please choose a number shown in the menu.'
                Pause-CommandCenter
            }
        }
    }
}

# ------------------------------------------------------------
# Main menu loop
# This is the entry point of the script.
# ------------------------------------------------------------

while ($true) {
    Show-PageHeader `
        -Title 'Beginner PowerShell Command Center' `
        -Subtitle 'Choose a category first, then choose an action inside that category.' `
        -Breadcrumb 'Main Menu' `
        -ShowBanner

    Write-SectionTitle 'Categories'
    Write-MenuItem -Number '1' -Title 'File and Folder Management' -Description 'Create, copy, rename, move, and delete items'
    Write-MenuItem -Number '2' -Title 'Read and Write Files' -Description 'Read text files, replace text, or append new text'
    Write-MenuItem -Number '3' -Title 'Useful System Commands' -Description 'Simple console and system information tools'
    Write-MenuItem -Number '4' -Title 'Network and Internet' -Description 'Ping hosts, check IP settings, and test connectivity'
    Write-MenuItem -Number '5' -Title 'Launch Programs' -Description 'Open Chrome, Notepad, or the current folder'
    Write-MenuItem -Number '6' -Title 'Search and Help' -Description 'View commands, command help, and recursive file lists'
    Write-MenuItem -Number '7' -Title 'Process Management' -Description 'View processes or stop a process safely'

    Write-SectionTitle 'Exit'
    Write-MenuItem -Number '0' -Title 'Exit the script' -Description 'Close the Premium Command Center'
    Write-Host ''

    $selection = Read-Host 'Choose a category number'
    if ([string]::IsNullOrWhiteSpace($selection)) {
        Write-WarningMessage 'Please enter a menu number.'
        Pause-CommandCenter
        continue
    }

    switch ($selection.Trim()) {
        '1' { Show-FileAndFolderMenu }
        '2' { Show-ReadWriteMenu }
        '3' { Show-SystemMenu }
        '4' { Show-NetworkMenu }
        '5' { Show-LaunchMenu }
        '6' { Show-SearchHelpMenu }
        '7' { Show-ProcessMenu }
        '0' {
            Show-PageHeader `
                -Title 'Beginner PowerShell Command Center' `
                -Subtitle 'Session closed.' `
                -Breadcrumb 'Exit' `
                -ShowBanner
            Write-Success 'Thank you for using the Premium Command Center.'
            break
        }
        default {
            Write-WarningMessage 'Invalid choice. Please choose a number shown in the menu.'
            Pause-CommandCenter
        }
    }
}
