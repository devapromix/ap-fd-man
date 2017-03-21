unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls;

type
  TfMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    SaveTimer: TTimer;
    Button4: TButton;
    RichEdit1: TRichEdit;
    MainTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure SaveTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure MainTimerTimer(Sender: TObject);
  private
    { Private declarations }
    SL, LastSL: TStringList;
    procedure AddLog(S: string);
    procedure Save(ASection: string);
    function EqualsRect(A, B: TRect): Boolean;
    function GetPath: string;
    function GetWindowClassName(ADescr: string): string;
    procedure GetTitleList(SL: TStringList);
    procedure CheckTitleList(var S: string);
    function HasWindow(ADescr: string): Boolean;
    function GetWindow(ADescr: string): TRect;
    procedure SetWindow(ADescr: string; ARect: TRect);
    function LoadWindowCoords(ASection: string; var Flag: Boolean): TRect;
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
      Break;
    end;
  end;
  Label1.Caption := SL.Text;
  LastSL.Assign(SL);
  Label2.Caption := LastSL.Text;
end;

procedure TfMain.SetWindow(ADescr: string; ARect: TRect);
var
  HW: hwnd;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  if (HW <> 0) then
    SetWindowPos(HW, HWND_BOTTOM, ARect.Left, ARect.Top,
      ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, SWP_FRAMECHANGED);
  // Зап. в лог
  AddLog(Format('%s >> L:%d,T:%d,R:%d,B:%d>',
    [ADescr, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom]));
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

function TfMain.LoadWindowCoords(ASection: string; var Flag: Boolean): TRect;
var
  F: TIniFile;
begin
  Result.Left := 0;
  Result.Top := 0;
  Result.Right := 150;
  Result.Bottom := 300;
  Flag := False;
  try
    F := TIniFile.Create(GetPath + 'fman.ini');
    try
      if F.SectionExists(ASection) then
      begin
        Result.Left := F.ReadInteger(ASection, 'Left', 0);
        Result.Top := F.ReadInteger(ASection, 'Top', 0);
        Result.Right := F.ReadInteger(ASection, 'Right', 150);
        Result.Bottom := F.ReadInteger(ASection, 'Bottom', 300);
        Flag := True;
      end;
    finally
      F.Free;
    end;
  except

  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
// var reg: tregistry;
begin
  SL := TStringList.Create;
  LastSL := TStringList.Create;
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

procedure TfMain.Save(ASection: string);
var
  F: TIniFile;
  R: TRect;
begin
  // Сохр. поз. и размер окна в файл
  if (GetWindowClassName(ASection) <> 'CabinetWClass') then Exit;
  R := GetWindow(ASection);
  F := TIniFile.Create(GetPath + 'fman.ini');
  try
    F.WriteInteger(ASection, 'Left', R.Left);
    F.WriteInteger(ASection, 'Top', R.Top);
    F.WriteInteger(ASection, 'Right', R.Right);
    F.WriteInteger(ASection, 'Bottom', R.Bottom);
  finally
    F.Free;
  end;
end;

procedure TfMain.SaveTimerTimer(Sender: TObject);
var
  I: Integer;
begin
  // Сохр. поз. и разм. всех окон
  for I := 0 to SL.Count - 1 do
    if HasWindow(SL[I]) then
      Save(SL[I]);
end;

procedure TfMain.Button4Click(Sender: TObject);
begin
  // Закрыть
  Close;
end;

procedure TfMain.AddLog(S: string);
begin
  // Запись
  RichEdit1.Lines.Add(S);
end;

procedure TfMain.MainTimerTimer(Sender: TObject);
var
  R, L: TRect;
  B: Boolean;
  S: string;
begin
  // Осн. таймер
  GetTitleList(SL);
  // Если появилось новое окно
  CheckTitleList(S);
  if (S = '') or not HasWindow(S) then Exit;
  // Загр. положение папки
  R := GetWindow(S);
  // Загр. посл. положение папки
  L := LoadWindowCoords(S, B);
  // Сравниваем
  if EqualsRect(R, L) then Exit;
  // Устанавливаем окно в коорд
  if B then SetWindow(S, L);
end;

end.
