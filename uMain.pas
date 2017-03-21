unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls;

type
  TWnRec = record
    Flag: Boolean;
    Rect: TRect;
  end;

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
    Label3: TLabel;
    RichEdit1: TRichEdit;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    WnRecArr: array of TWnRec;
    Flag: Boolean;
    MyRect: TRect;
    SL, LastSL: TStringList;
    procedure AddLog(S: string);
    procedure Load(ASection: string);
    procedure Save(ASection: string);
    procedure SaveToIni(ASection: string);
    procedure LoadFromIni(ASection: string);
    function EqualsRect(A, B: TRect): Boolean;
    function GetPath: string;
    function GetWindowClassName(ADescr: string): string;
    procedure GetTitleList(SL: TStringList);
    procedure CheckTitleList(var S: string);
    function HasWindow(ADescr: string): Boolean;
    function GetWindow(ADescr: string): TRect;
    procedure SetWindow(ADescr: string; ARect: TRect);
    procedure AddWnRecElem();
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses IniFiles;

function TfMain.GetPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result);
end;

function TfMain.EqualsRect(A, B: TRect): Boolean;
begin
  Result := (A.Left = B.Left) and (A.Top = B.Top) and (A.Right = B.Right) and
    (A.Bottom = B.Bottom)
end;

function TfMain.GetWindowClassName(ADescr: string): string;
var
  Cs: array [0 .. 255] of char;
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  Windows.GetClassName(HW, Cs, 255);
  Result := StrPas(Cs);
end;

procedure TfMain.GetTitleList(SL: TStringList);
var
  Wnd: hwnd;
  Buff: array [0 .. 127] of char;
begin
  SL.Clear;
  Wnd := Windows.GetWindow(Application.handle, gw_hwndfirst);
  while Wnd <> 0 do
  begin
    if (Wnd <> Application.handle) and IsWindowVisible(Wnd) and
      (Windows.GetWindow(Wnd, gw_owner) = 0) and
      (GetWindowText(Wnd, Buff, SizeOf(Buff)) <> 0) then
    begin
      GetWindowText(Wnd, Buff, SizeOf(Buff));
      if (GetWindowClassName(StrPas(Buff)) = 'CabinetWClass') then
      SL.Add(StrPas(Buff));
    end;
    Wnd := Windows.GetWindow(Wnd, gw_hwndnext);
  end;
end;

procedure TfMain.CheckTitleList(var S: string);
var
  I: Integer;
begin
  S := '';
  for I := 0 to SL.Count - 1 do
  begin
    if (LastSL.IndexOf(SL[I]) = -1)
      and (GetWindowClassName(SL[I]) = 'CabinetWClass') then
    begin
      LastSL.Append(SL[I]);
      S := Trim(SL[I]);
      Exit;
    end;
  end;
end;

procedure TfMain.SetWindow(ADescr: string; ARect: TRect);
var
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  if (HW <> 0) then
    SetWindowPos(HW, HWND_BOTTOM, ARect.Left, ARect.Top,
      ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, SWP_FRAMECHANGED);
end;

function TfMain.GetWindow(ADescr: string): TRect;
var
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  Windows.GetWindowRect(HW, Result);
end;

function TfMain.HasWindow(ADescr: string): Boolean;
var
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  Result := IsWindow(HW)
    and (GetWindowClassName(ADescr) = 'CabinetWClass');
end;

procedure TfMain.Load(ASection: string);
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

procedure TfMain.Save(ASection: string);
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
  SetLength(WnRecArr, 0);

  Flag := False;
  SL := TStringList.Create;
  LastSL := TStringList.Create;
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

procedure TfMain.FormDestroy(Sender: TObject);
begin
  LastSL.Free;
  SL.Free;
end;

procedure TfMain.LoadFromIni(ASection: string);
begin
  if not HasWindow(ASection) then Exit;
  SetWindow(ASection, MyRect);
end;

procedure TfMain.SaveToIni(ASection: string);
begin
  if not HasWindow(ASection) then Exit;
  MyRect := GetWindow(ASection);
end;

procedure TfMain.Timer1Timer(Sender: TObject);
var
  R: TRect;
  S: string;
begin
  GetTitleList(SL);
  CheckTitleList(S);

  if (S = '') then Exit;

  if not HasWindow(S) then Exit;
  if not Flag then
  begin
    // Init
    Load(S);
    LoadFromIni(S);
    Flag := True;
    Exit;
  end;
  R := GetWindow(S);

  // Save
  if not EqualsRect(R, MyRect) then
  begin
    SaveToIni(S);
    AddLog(Format('Папка "%s" [L: %d, T: %d, R: %d, B: %d].',
    [S, R.Left, R.Top, R.Right, R.Bottom]));
  end;

//  Label1.Caption := Format('L: %d, T: %d, R: %d, B: %d',
//    [R.Left, R.Top, R.Right, R.Bottom]);
//  Label2.Caption := Format('L: %d, T: %d, R: %d, B: %d',
//    [MyRect.Left, MyRect.Top, MyRect.Right, MyRect.Bottom]);
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

procedure TfMain.AddWnRecElem;
begin

end;

procedure TfMain.Button4Click(Sender: TObject);
begin
  Close;
end;

procedure TfMain.AddLog(S: string);
begin
  RichEdit1.Lines.Add(S);
end;

end.
