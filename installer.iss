[Setup]
AppName=custom_risk
AppVersion=1.0.0
DefaultDirName={autopf}\custom_risk
DefaultGroupName=custom_risk
OutputDir=c:\Users\Abdul\projects\World War 3\build\windows\x64\runner\Release
OutputBaseFilename=custom_risk_installer
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
DisableDirPage=no

[Files]
Source: "c:\Users\Abdul\projects\World War 3\build\windows\x64\runner\Release\custom_risk.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\Users\Abdul\projects\World War 3\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "c:\Users\Abdul\projects\World War 3\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\custom_risk"; Filename: "{app}\custom_risk.exe"
Name: "{autodesktop}\custom_risk"; Filename: "{app}\custom_risk.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\custom_risk.exe"; Description: "{cm:LaunchProgram,custom_risk}"; Flags: nowait postinstall skipifsilent
