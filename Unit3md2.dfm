object Form1: TForm1
  Left = 207
  Top = 225
  Width = 937
  Height = 599
  Caption = 'Fun md2'
  Color = 14544605
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    921
    540)
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 16
    Top = 8
    Width = 617
    Height = 521
    OnMouseDown = Image1MouseDown
  end
  object Image2: TImage
    Left = 16
    Top = 456
    Width = 617
    Height = 81
    OnMouseDown = Image2MouseDown
  end
  object Panel2: TPanel
    Left = 648
    Top = 16
    Width = 273
    Height = 521
    Anchors = [akTop, akRight]
    Caption = 'Panel2'
    TabOrder = 0
    object Panel1: TPanel
      Left = 48
      Top = 456
      Width = 185
      Height = 41
      Caption = 'SAVE'
      Color = clPurple
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -31
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = Panel1Click
    end
    object Memo1: TMemo
      Left = 8
      Top = 8
      Width = 273
      Height = 433
      Lines.Strings = (
        'Memo1')
      ScrollBars = ssVertical
      TabOrder = 1
      Visible = False
    end
    object Memo2: TMemo
      Left = 8
      Top = 24
      Width = 257
      Height = 417
      BevelInner = bvLowered
      BevelOuter = bvRaised
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      Lines.Strings = (
        'Num1 - '#1074#1088#1072#1097#1077#1085#1080#1077
        'Num7 - '
        'Num9 - next figure'
        'Num5 - down size'
        'Num8 - up size'
        'Up - prev vertex'
        'Down - next vertex'
        'Left - prev cadr'
        'Right - next cadr'
        'Num0 - '
        'Space - ')
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 1008
    Top = 32
  end
  object MainMenu1: TMainMenu
    Left = 56
    Top = 32
    object here1: TMenuItem
      Caption = 'here'
      OnClick = here1Click
    end
    object header1: TMenuItem
      Caption = 'header'
      OnClick = header1Click
    end
    object textcoord1: TMenuItem
      Caption = 'textcoord'
    end
    object treugi1: TMenuItem
      Caption = 'treugi'
    end
    object cadrs1: TMenuItem
      Caption = 'cadrs'
    end
    object GLdata1: TMenuItem
      Caption = 'GL-data'
    end
  end
end
