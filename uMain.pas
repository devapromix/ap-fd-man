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
    procedure BitBtn1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
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
  Result := (A.Left = B.Left) and (A.Top = B.Top)
    and (A.Right = B.Right) and (A.Bottom = B.Bottom)
end;

procedure GetTitleList(sl: TStringList);
var wnd: hwnd;
    buff: array [0..127] of char;
begin
sl.clear;
wnd := GetWindow(Application.handle, gw_hwndfirst);
while wnd <> 0 do
begin // Не показываем:
if (wnd <> Application.Handle) // Собственное окно
and IsWindowVisible(wnd) // Невидимые окна
and (GetWindow(wnd, gw_owner) = 0) // Дочерние окна
and (GetWindowText(wnd, buff, SizeOf(buff)) <> 0) then
begin
GetWindowText(wnd, buff, SizeOf(buff));
sl.Add(StrPas(buff));
end;
wnd := GetWindow(wnd, gw_hwndnext);
end;
end;

procedure SetWindow(ADescr: string; ARect: TRect);
var
  HW: HWND;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  if (HW <> 0) then
    SetWindowPos(HW, HWND_BOTTOM, ARect.Left, ARect.Top,
      ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, SWP_FRAMECHANGED);
end;

function GetWindow(ADescr: string): TRect;
var
  HW: HWND;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  Windows.GetWindowRect(HW, Result);
end;

function HasWindow(ADescr: string): Boolean;
var
  HW: HWND;
begin
  HW := FindWindow(nil, PAnsiChar(ADescr));
  Result := IsWindow(HW);
end;

procedure Load();
var
  F: TIniFile;
begin
  F := TIniFile.Create(GetPath + 'fman.ini');
  try
    if F.SectionExists('Новая папка') then
    begin
      MyRect.Left   := F.ReadInteger('Новая папка', 'Left', 0);
      MyRect.Top    := F.ReadInteger('Новая папка', 'Top', 0);
      MyRect.Right  := F.ReadInteger('Новая папка', 'Right', 200);
      MyRect.Bottom := F.ReadInteger('Новая папка', 'Bottom', 200);
    end;
  finally
    F.Free;
  end;
end;

procedure Save();
var
  F: TIniFile;
begin
  F := TIniFile.Create(GetPath + 'fman.ini');
  try
    F.WriteInteger('Новая папка', 'Left', MyRect.Left);
    F.WriteInteger('Новая папка', 'Top', MyRect.Top);
    F.WriteInteger('Новая папка', 'Right', MyRect.Right);
    F.WriteInteger('Новая папка', 'Bottom', MyRect.Bottom);
  finally
    F.Free;
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  SL := TStringList.Create;
  MyRect := Rect(100, 100, 300, 300);
end;

procedure TfMain.BitBtn1Click(Sender: TObject);
begin
  GetTitleList(SL);
  if HasWindow('Новая папка') then
    ShowMessage(SL.Text);
end;

procedure TfMain.Timer1Timer(Sender: TObject);
var
  R: TRect;
begin
  if not HasWindow('Новая папка') then Exit;
  if not Flag then
  begin
    // Зап. только раз
    Load();
    Button1Click(Sender);
    Flag := True;
    Exit;
  end;
  R := GetWindow('Новая папка');

  if not EqualsRect(R, MyRect) then Button2Click(Sender);

  Label1.Caption := Format('L: %d, T: %d, R: %d, B: %d',
    [R.Left, R.Top, R.Right, R.Bottom]);
  Label2.Caption := Format('L: %d, T: %d, R: %d, B: %d',
    [MyRect.Left, MyRect.Top, MyRect.Right, MyRect.Bottom]);
end;

procedure TfMain.Button1Click(Sender: TObject);
begin
  // Загр. текущ. поз.
  if not HasWindow('Новая папка') then Exit;
  SetWindow('Новая папка', MyRect);
end;

procedure TfMain.Button2Click(Sender: TObject);
begin
  // Сохр.
  if not HasWindow('Новая папка') then Exit;
  MyRect := GetWindow('Новая папка');
end;

procedure TfMain.Button3Click(Sender: TObject);
begin
  // Reset
  SetWindow('Новая папка', Rect(0, 0, 200, 200));
  Flag := False;
end;

procedure TfMain.Timer2Timer(Sender: TObject);
begin
  // Save to ini
  if not HasWindow('Новая папка') then Exit;
  Save();
end;

end.
 