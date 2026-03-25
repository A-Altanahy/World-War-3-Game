[Setup]
AppName=World War III
AppVersion=1.1.0
DefaultDirName={autopf}\World War III
DefaultGroupName=World War III
OutputDir=c:\Users\Abdul\projects\World War 3\Installers
OutputBaseFilename=WWIII_Installer_v1.1
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
DisableDirPage=no

[Files]
Source: "c:\Users\Abdul\projects\World War 3\build\windows\x64\runner\Release\WWIII.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\Users\Abdul\projects\World War 3\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "c:\Users\Abdul\projects\World War 3\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\World War III"; Filename: "{app}\WWIII.exe"
Name: "{autodesktop}\World War III"; Filename: "{app}\WWIII.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\WWIII.exe"; Description: "{cm:LaunchProgram,World War III}"; Flags: nowait postinstall skipifsilent
