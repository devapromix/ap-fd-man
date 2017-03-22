[Setup]
AppName=FMan
AppVersion=1.0
DefaultDirName={pf}\FMan
Compression=lzma2
SolidCompression=yes

[Files]
Source: "fman.exe"; DestDir: "{app}"

[Run]
Filename: "{app}\fman.exe"; WorkingDir: "{app}"; StatusMsg: "Запуск FMan..."; Flags: nowait;

