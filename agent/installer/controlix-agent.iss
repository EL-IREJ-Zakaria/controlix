#ifndef SourceRoot
  #error SourceRoot must be defined. Example: /DSourceRoot=C:\path\to\controlix\agent
#endif

#ifndef OutputDir
  #define OutputDir SourceRoot + "\installer-output"
#endif

#ifndef MyAppVersion
#define MyAppVersion "1.0.0"
#endif

#define MyAppName "Controlix Agent"
#define MyAppExeName "controlix-agent.exe"
#define MyAppPublisher "Controlix"

[Setup]
AppId={{6E4A6DE9-3E3F-4E44-A67B-6BBA41AA1D86}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern
Compression=lzma
SolidCompression=yes
OutputDir={#OutputDir}
OutputBaseFilename=controlix-agent-setup
UninstallDisplayIcon={app}\{#MyAppExeName}
ChangesAssociations=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "startupshortcut"; Description: "Launch Controlix Agent when I sign in"; GroupDescription: "Startup"

[Dirs]
Name: "{app}\data"
Name: "{app}\scripts"

[Files]
Source: "{#SourceRoot}\dist\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\dist\.env.example"; DestDir: "{app}"; DestName: ".env.example"; Flags: ignoreversion
Source: "{#SourceRoot}\dist\.env.example"; DestDir: "{app}"; DestName: ".env"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "{#SourceRoot}\dist\data\tasks.json"; DestDir: "{app}\data"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "{#SourceRoot}\dist\data\execution_logs.json"; DestDir: "{app}\data"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "{#SourceRoot}\SETUP.md"; DestDir: "{app}"; DestName: "SETUP.md"; Flags: ignoreversion

[Icons]
Name: "{group}\Controlix Agent"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\Edit Agent Config"; Filename: "notepad.exe"; Parameters: """{app}\.env"""; WorkingDir: "{app}"
Name: "{group}\Open Agent Folder"; Filename: "{win}\explorer.exe"; Parameters: """{app}"""
Name: "{userdesktop}\Controlix Agent"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; WorkingDir: "{app}"
Name: "{userstartup}\Controlix Agent"; Filename: "{app}\{#MyAppExeName}"; Tasks: startupshortcut; WorkingDir: "{app}"

[Run]
Filename: "notepad.exe"; Parameters: """{app}\.env"""; Description: "Open .env to review the shared secret"; Flags: postinstall skipifsilent unchecked
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Controlix Agent now"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent unchecked
