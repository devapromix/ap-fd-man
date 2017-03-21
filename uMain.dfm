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
    Left = 280
    Top = 8
    Width = 113
    Height = 57
    AutoSize = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 280
    Top = 80
    Width = 113
    Height = 57
    AutoSize = False
    WordWrap = True
  end
  object Button4: TButton
    Left = 280
    Top = 144
    Width = 115
    Height = 17
    Caption = 'Close'
    TabOrder = 0
    OnClick = Button4Click
  end
  object RichEdit1: TRichEdit
    Left = 8
    Top = 8
    Width = 265
    Height = 153
    PlainText = True
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object SaveTimer: TTimer
    Interval = 5000
    OnTimer = SaveTimerTimer
    Left = 40
    Top = 8
  end
  object MainTimer: TTimer
    Interval = 250
    OnTimer = MainTimerTimer
    Left = 8
    Top = 8
  end
end
