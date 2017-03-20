object fMain: TfMain
  Left = 614
  Top = 542
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'FMan'
  ClientHeight = 168
  ClientWidth = 399
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMinimized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 264
    Top = 0
    Width = 105
    Height = 57
    AutoSize = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 264
    Top = 72
    Width = 105
    Height = 57
    AutoSize = False
    WordWrap = True
  end
  object Label3: TLabel
    Left = 128
    Top = 72
    Width = 105
    Height = 57
    AutoSize = False
    WordWrap = True
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Win List'
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 1
  end
  object Button2: TButton
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 2
  end
  object Button3: TButton
    Left = 8
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Reset'
    TabOrder = 3
  end
  object Button4: TButton
    Left = 320
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Timer1: TTimer
    Interval = 250
    OnTimer = Timer1Timer
    Left = 192
    Top = 24
  end
  object Timer2: TTimer
    Interval = 10000
    OnTimer = Timer2Timer
    Left = 224
    Top = 24
  end
end
