unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfMain = class(TForm)
    BitBtn1: TBitBtn;
    Timer1: TTimer;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Button3: TButton;
    Timer2: TTimer;
    Button4: TButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses IniFiles;

var
  MyRect: TRect;
  SL: TStringList;
  Flag: Boolean = False;

function GetPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result);
end;

function EqualsRect(A, B: TRect): Boolean;
begin
  Result := (A.Left = B.Left) and (A.Top = B.Top) and (A.Right = B.Right) and
    (A.Bottom = B.Bottom)
end;

procedure GetTitleList(SL: TStringList);
var
  Wnd: hwnd;
  Buff: array [0 .. 127] of char;
begin
  SL.Clear;
  Wnd := GetWindow(Application.handle, gw_hwndfirst);
  while Wnd <> 0 do
  begin
    if (Wnd <> Application.handle) and IsWindowVisible(Wnd) and
      (GetWindow(Wnd, gw_owner) = 0) and
      (GetWindowText(Wnd, Buff, SizeOf(Buff)) <> 0) then
    begin
      GetWindowText(Wnd, Buff, SizeOf(Buff));
      SL.Add(StrPas(Buff));
    end;
    Wnd := GetWindow(Wnd, gw_hwndnext);
  end;
end;

procedure SetWindow(ADescr: string; ARect: TRect);
var
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  if (HW <> 0) then
    SetWindowPos(HW, HWND_BOTTOM, ARect.Left, ARect.Top,
      ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, SWP_FRAMECHANGED);
end;

function GetWindowClassName(ADescr: string): string;
var
  Cs: array [0 .. 255] of char;
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  Windows.GetClassName(HW, Cs, 255);
  Result := StrPas(Cs);
end;

function GetWindow(ADescr: string): TRect;
var
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  Windows.GetWindowRect(HW, Result);
end;

function HasWindow(ADescr: string): Boolean;
var
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  Result := IsWindow(HW);
end;

procedure Load(ASection: string);
var
  F: TIniFile;
begin
  F := TIniFile.Create(GetPath + 'fman.ini');
  try
    if F.SectionExists(ASection) then
    begin
      MyRect.Left := F.ReadInteger(ASection, 'Left', 0);
      MyRect.Top := F.ReadInteger(ASection, 'Top', 0);
      MyRect.Right := F.ReadInteger(ASection, 'Right', 200);
      MyRect.Bottom := F.ReadInteger(ASection, 'Bottom', 200);
    end;
  finally
    F.Free;
  end;
end;

procedure Save(ASection: string);
var
  F: TIniFile;
begin
  if (GetWindowClassName(ASection) <> 'CabinetWClass') then
    Exit;
  F := TIniFile.Create(GetPath + 'fman.ini');
  try
    F.WriteInteger(ASection, 'Left', MyRect.Left);
    F.WriteInteger(ASection, 'Top', MyRect.Top);
    F.WriteInteger(ASection, 'Right', MyRect.Right);
    F.WriteInteger(ASection, 'Bottom', MyRect.Bottom);
  finally
    F.Free;
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
// var reg: tregistry;
begin
  SL := TStringList.Create;
  MyRect := Rect(100, 100, 300, 300);
  {
    reg := tregistry.create;
    reg.rootkey := hkey_local_machine;
    reg.lazywrite := false;
    reg.openkey('software\microsoft\windows\currentversion\run', false);
    reg.writestring('fman', application.exename);
    reg.closekey;
    reg.free;
  }
end;

procedure TfMain.BitBtn1Click(Sender: TObject);
begin
  ShowMessage(SL.Text);
end;

procedure TfMain.Timer1Timer(Sender: TObject);
var
  R: TRect;
begin
  GetTitleList(SL);
  if not HasWindow('Новая папка') then
    Exit;
  if not Flag then
  begin
    // Init
    Load('Новая папка');
    Button1Click(Sender);
    Flag := True;
    Exit;
  end;
  R := GetWindow('Новая папка');

  if not EqualsRect(R, MyRect) then
    Button2Click(Sender);

  Label1.Caption := Format('L: %d, T: %d, R: %d, B: %d',
    [R.Left, R.Top, R.Right, R.Bottom]);
  Label2.Caption := Format('L: %d, T: %d, R: %d, B: %d',
    [MyRect.Left, MyRect.Top, MyRect.Right, MyRect.Bottom]);
end;

procedure TfMain.Button1Click(Sender: TObject);
begin
  // Load
  if not HasWindow('Новая папка') then
    Exit;
  SetWindow('Новая папка', MyRect);
end;

procedure TfMain.Button2Click(Sender: TObject);
begin
  // Save
  if not HasWindow('Новая папка') then
    Exit;
  MyRect := GetWindow('Новая папка');
end;

procedure TfMain.Button3Click(Sender: TObject);
begin
  // Reset
  SetWindow('Новая папка', Rect(0, 0, 200, 200));
  Flag := False;
end;

procedure TfMain.Timer2Timer(Sender: TObject);
var
  I: Integer;
begin
  // Save to ini
  for I := 0 to SL.Count - 1 do
    if HasWindow(SL[I]) then
      Save(SL[I]);
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  SL.Free;
end;

procedure TfMain.Button4Click(Sender: TObject);
begin
  Close;
end;

end.
