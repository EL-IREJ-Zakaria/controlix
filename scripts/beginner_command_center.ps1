<#
Beginner PowerShell Command Center

This script is a beginner-friendly Windows PowerShell menu for common daily tasks.
It uses numbered options, simple prompts, color-coded messages, and confirmation
steps for sensitive actions such as deleting items or stopping processes.

Intended use:
- Save as a .ps1 file
- Run it in PowerShell on Windows
- Type a menu number and follow the prompts
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $Host.UI.RawUI.WindowTitle = 'Beginner PowerShell Command Center'
} catch {
    # Some hosts do not allow changing the window title.
}

function Write-Separator {
    Write-Host ('=' * 78) -ForegroundColor DarkGray
}

function Write-Title {
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    Write-Host $Text -ForegroundColor Cyan
}

function Write-SectionTitle {
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    Write-Host ''
    Write-Host $Text -ForegroundColor Magenta
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

function Pause-CommandCenter {
    Write-Host ''
    [void](Read-Host 'Press Enter to return to the main menu')
}

function Read-RequiredInput {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        [string]$Example = ''
    )

    while ($true) {
        $fullPrompt = if ([string]::IsNullOrWhiteSpace($Example)) {
            $Prompt
        } else {
            "$Prompt (Example: $Example)"
        }

        $value = Read-Host $fullPrompt
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value.Trim()
        }

        Write-WarningMessage 'Input cannot be empty. Please try again.'
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
            Write-WarningMessage 'Please type Y or N.'
            continue
        }

        switch ($answer.Trim().ToUpperInvariant()) {
            'Y' { return $true }
            'YES' { return $true }
            'N' { return $false }
            'NO' { return $false }
            default {
                Write-WarningMessage 'Please type Y or N.'
            }
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

function Show-Header {
    Clear-Host
    Write-Separator
    Write-Title 'Beginner PowerShell Command Center'
    Write-Host 'A simple, safe, and educational menu for everyday PowerShell tasks.' -ForegroundColor Gray
    Write-Host "Current location: $(Get-Location)" -ForegroundColor DarkGray
    Write-Host 'Tip: Type a number, press Enter, then follow the prompts.' -ForegroundColor DarkYellow
    Write-Separator
}

function Show-MainMenu {
    Show-Header

    Write-SectionTitle 'File and Folder Management'
    Write-MenuItem -Number '1' -Title 'Create folder' -Description 'Create a new folder. Example: test'
    Write-MenuItem -Number '2' -Title 'Create file' -Description 'Create a new empty file. Example: file.txt'
    Write-MenuItem -Number '3' -Title 'Delete file' -Description 'Delete a file after confirmation'
    Write-MenuItem -Number '4' -Title 'Delete folder' -Description 'Delete a folder and its content after confirmation'
    Write-MenuItem -Number '5' -Title 'Copy file' -Description 'Copy a file to a new path or name'
    Write-MenuItem -Number '6' -Title 'Rename or move file' -Description 'Rename a file or move it somewhere else'

    Write-SectionTitle 'Read and Write Files'
    Write-MenuItem -Number '7' -Title 'Read file content' -Description 'Show what is inside a file'
    Write-MenuItem -Number '8' -Title 'Write content to file' -Description 'Replace file content with new text'
    Write-MenuItem -Number '9' -Title 'Append content to file' -Description 'Add new text to the end of a file'

    Write-SectionTitle 'Useful System Commands'
    Write-MenuItem -Number '10' -Title 'Clear screen' -Description 'Clean the console window'
    Write-MenuItem -Number '11' -Title 'Display a message' -Description 'Show custom text on screen'
    Write-MenuItem -Number '12' -Title 'Show date' -Description 'Display the current date and time'
    Write-MenuItem -Number '13' -Title 'Show current user' -Description 'Display the signed-in Windows user'
    Write-MenuItem -Number '14' -Title 'Show computer name' -Description 'Display this PC name'

    Write-SectionTitle 'Network and Internet'
    Write-MenuItem -Number '15' -Title 'Ping a website' -Description 'Test if a website responds. Example: google.com'
    Write-MenuItem -Number '16' -Title 'Show IP configuration' -Description 'Display network adapter information'
    Write-MenuItem -Number '17' -Title 'Test network connection' -Description 'Run Test-NetConnection on a host'

    Write-SectionTitle 'Launch Programs'
    Write-MenuItem -Number '18' -Title 'Open Chrome' -Description 'Launch Google Chrome if installed'
    Write-MenuItem -Number '19' -Title 'Open Notepad' -Description 'Launch Windows Notepad'
    Write-MenuItem -Number '20' -Title 'Open current folder' -Description 'Open this folder in File Explorer'

    Write-SectionTitle 'Search and Help'
    Write-MenuItem -Number '21' -Title 'Show all commands' -Description 'List available PowerShell commands'
    Write-MenuItem -Number '22' -Title 'Show help for a command' -Description 'Example: Get-Help cd'
    Write-MenuItem -Number '23' -Title 'List all files recursively' -Description 'Show files in a folder and all subfolders'

    Write-SectionTitle 'Process Management'
    Write-MenuItem -Number '24' -Title 'Show running processes' -Description 'List active processes'
    Write-MenuItem -Number '25' -Title 'Stop a process' -Description 'Stop a process after confirmation. Example: notepad'

    Write-SectionTitle 'Exit'
    Write-MenuItem -Number '0' -Title 'Exit the script' -Description 'Close the Command Center'
    Write-Host ''
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
            # Try the next candidate.
        }
    }

    throw "$DisplayName was not found. Please make sure it is installed on this computer."
}

while ($true) {
    Show-MainMenu
    $selection = Read-Host 'Choose a menu number'

    if ([string]::IsNullOrWhiteSpace($selection)) {
        Write-WarningMessage 'Please enter a menu number.'
        Pause-CommandCenter
        continue
    }

    switch ($selection.Trim()) {
        '1' {
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
        '2' {
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
        '3' {
            Invoke-MenuAction {
                $filePath = Read-RequiredInput -Prompt 'Enter the file to delete' -Example 'file.txt'

                if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
                    throw 'The file was not found.'
                }

                $displayPath = Resolve-DisplayPath -Path $filePath
                Write-WarningMessage "You are about to delete this file: $displayPath"
                if (-not (Read-Confirmation -Message 'Do you want to continue?')) {
                    Write-Info 'Deletion cancelled.'
                    return
                }

                Remove-Item -LiteralPath $filePath -ErrorAction Stop
                Write-Success "File deleted: $displayPath"
            }
        }
        '4' {
            Invoke-MenuAction {
                $folderPath = Read-RequiredInput -Prompt 'Enter the folder to delete' -Example 'dossier'

                if (-not (Test-Path -LiteralPath $folderPath -PathType Container)) {
                    throw 'The folder was not found.'
                }

                $displayPath = Resolve-DisplayPath -Path $folderPath
                $itemCount = @(Get-ChildItem -LiteralPath $folderPath -Force -Recurse -ErrorAction Stop).Count
                Write-WarningMessage "You are about to delete this folder and everything inside it: $displayPath"
                Write-WarningMessage "Items inside this folder: $itemCount"
                if (-not (Read-Confirmation -Message 'Do you want to continue?')) {
                    Write-Info 'Folder deletion cancelled.'
                    return
                }

                Remove-Item -LiteralPath $folderPath -Recurse -Force -ErrorAction Stop
                Write-Success "Folder deleted: $displayPath"
            }
        }
        '5' {
            Invoke-MenuAction {
                $sourcePath = Read-RequiredInput -Prompt 'Enter the source file' -Example 'file.txt'
                $destinationPath = Read-RequiredInput -Prompt 'Enter the destination file or path' -Example 'copie.txt'

                if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
                    throw 'The source file was not found.'
                }

                Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -ErrorAction Stop
                Write-Success "File copied to: $(Resolve-DisplayPath -Path $destinationPath)"
            }
        }
        '6' {
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
        '7' {
            Invoke-MenuAction {
                $filePath = Read-RequiredInput -Prompt 'Enter the file to read' -Example 'file.txt'

                if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
                    throw 'The file was not found.'
                }

                Write-Host ''
                Write-Separator
                Write-Title "Content of: $(Resolve-DisplayPath -Path $filePath)"
                Write-Separator
                Get-Content -LiteralPath $filePath -ErrorAction Stop | Out-Host
                Write-Separator
            }
        }
        '8' {
            Invoke-MenuAction {
                $filePath = Read-RequiredInput -Prompt 'Enter the file to write to' -Example 'file.txt'
                $content = Read-RequiredInput -Prompt 'Enter the text to write' -Example 'Hello'

                if (Test-Path -LiteralPath $filePath) {
                    Write-WarningMessage 'This action will replace the current file content.'
                    if (-not (Read-Confirmation -Message 'Do you want to overwrite the file?')) {
                        Write-Info 'Write action cancelled.'
                        return
                    }
                }

                Set-Content -LiteralPath $filePath -Value $content -Encoding UTF8 -ErrorAction Stop
                Write-Success "Content written to: $(Resolve-DisplayPath -Path $filePath)"
            }
        }
        '9' {
            Invoke-MenuAction {
                $filePath = Read-RequiredInput -Prompt 'Enter the file to append to' -Example 'file.txt'
                $content = Read-RequiredInput -Prompt 'Enter the text to append' -Example 'Hi'

                Add-Content -LiteralPath $filePath -Value $content -Encoding UTF8 -ErrorAction Stop
                Write-Success "Content appended to: $(Resolve-DisplayPath -Path $filePath)"
            }
        }
        '10' {
            Invoke-MenuAction {
                Clear-Host
                Write-Success 'The console screen was cleared.'
            }
        }
        '11' {
            Invoke-MenuAction {
                $message = Read-RequiredInput -Prompt 'Enter the message to display' -Example 'Hello'
                Write-Host ''
                Write-Host $message -ForegroundColor Cyan
                Write-Success 'Your message was displayed.'
            }
        }
        '12' {
            Invoke-MenuAction {
                $currentDate = Get-Date
                Write-Host ''
                Write-Host $currentDate -ForegroundColor Green
                Write-Success 'Current date and time displayed.'
            }
        }
        '13' {
            Invoke-MenuAction {
                $currentUser = whoami
                Write-Host ''
                Write-Host $currentUser -ForegroundColor Green
                Write-Success 'Current user displayed.'
            }
        }
        '14' {
            Invoke-MenuAction {
                $computerName = hostname
                Write-Host ''
                Write-Host $computerName -ForegroundColor Green
                Write-Success 'Computer name displayed.'
            }
        }
        '15' {
            Invoke-MenuAction {
                $target = Read-RequiredInput -Prompt 'Enter the website or host to ping' -Example 'google.com'

                Write-Info "Pinging $target. Please wait..."
                Test-Connection -ComputerName $target -Count 4 -ErrorAction Stop |
                    Format-Table Address, IPV4Address, ResponseTime, Status -AutoSize |
                    Out-Host
                Write-Success 'Ping finished.'
            }
        }
        '16' {
            Invoke-MenuAction {
                Write-Host ''
                ipconfig | Out-Host
                Write-Success 'IP configuration displayed.'
            }
        }
        '17' {
            Invoke-MenuAction {
                $target = Read-RequiredInput -Prompt 'Enter the host to test' -Example 'google.com'

                Write-Info "Testing network connection to $target. Please wait..."
                Test-NetConnection -ComputerName $target -ErrorAction Stop | Out-Host
                Write-Success 'Network test finished.'
            }
        }
        '18' {
            Invoke-MenuAction {
                Start-KnownProgram -DisplayName 'Google Chrome' -Candidates @(
                    'chrome.exe',
                    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
                    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                    "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
                )
            }
        }
        '19' {
            Invoke-MenuAction {
                Start-KnownProgram -DisplayName 'Notepad' -Candidates @('notepad.exe')
            }
        }
        '20' {
            Invoke-MenuAction {
                $currentFolder = (Get-Location).Path
                Start-Process -FilePath 'explorer.exe' -ArgumentList $currentFolder -ErrorAction Stop
                Write-Success "Opened current folder: $currentFolder"
            }
        }
        '21' {
            Invoke-MenuAction {
                Get-Command |
                    Sort-Object Name |
                    Select-Object Name, CommandType, Source |
                    Format-Table -AutoSize |
                    Out-Host -Paging
                Write-Success 'Command list displayed.'
            }
        }
        '22' {
            Invoke-MenuAction {
                $commandName = Read-RequiredInput -Prompt 'Enter the command name to learn about' -Example 'cd'

                Get-Help -Name $commandName -Full -ErrorAction Stop | Out-Host -Paging
                Write-Success "Help displayed for command: $commandName"
            }
        }
        '23' {
            Invoke-MenuAction {
                $searchPath = Read-OptionalInput -Prompt 'Enter a folder path to search, or press Enter to use the current folder'
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
        '24' {
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
        '25' {
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
        '0' {
            Show-Header
            Write-Success 'Thank you for using the Beginner PowerShell Command Center.'
            break
        }
        default {
            Write-WarningMessage 'Invalid menu choice. Please enter a number shown in the menu.'
            Pause-CommandCenter
        }
    }
}
