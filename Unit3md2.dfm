object Form1: TForm1
  Left = 207
  Top = 225
  Width = 1088
  Height = 577
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 16
    Top = 16
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
  object Memo1: TMemo
    Left = 640
    Top = 16
    Width = 361
    Height = 433
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 0
    Visible = False
  end
  object Panel1: TPanel
    Left = 664
    Top = 456
    Width = 185
    Height = 41
    Caption = 'DONE'
    Color = clPurple
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -31
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = Panel1Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 1008
    Top = 32
  end
end
