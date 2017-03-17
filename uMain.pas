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
    procedure BitBtn1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

var
  MyRect: TRect;
  SL: TStringList;

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

procedure TfMain.FormCreate(Sender: TObject);
begin
  SL := TStringList.Create;
  MyRect := Rect(100, 100, 300, 300);
end;

procedure TfMain.BitBtn1Click(Sender: TObject);
begin
  GetTitleList(SL);
  //if (SL.IndexOf('Новая папка') > -1) then
  if HasWindow('Новая папка') then
    ShowMessage(SL.Text);
end;

procedure TfMain.Timer1Timer(Sender: TObject);
var
  R: TRect;
begin
  R := GetWindow('Новая папка');
  Label1.Caption := Format('L: %d, T: %d, R: %d, B: %d',
    [R.Left, R.Top, R.Right, R.Bottom]);
  if (R.Left <> MyRect.Left) then
    Label2.Caption := 'SAVED'
      else Label2.Caption := '';
end;

procedure TfMain.Button1Click(Sender: TObject);
begin
  // Загр. текущ. поз.
  SetWindow('Новая папка', MyRect);
end;

procedure TfMain.Button2Click(Sender: TObject);
begin
  // Сохр.
  MyRect := GetWindow('Новая папка');
end;

end.
 