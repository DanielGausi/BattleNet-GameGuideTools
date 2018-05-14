object FGuide: TFGuide
  Left = 0
  Top = 0
  Caption = 'Rewrite a guide - correct deprecated links permanently'
  ClientHeight = 509
  ClientWidth = 698
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnShow = FormShow
  DesignSize = (
    698
    509)
  PixelsPerInch = 96
  TextHeight = 13
  object GuideMemo: TMemo
    Left = 0
    Top = 0
    Width = 504
    Height = 509
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      
        '1.) Paste your current guide here (but delete these lines before' +
        ', of course)'
      '2.) Click the button "Replace links"'
      
        '3.) Copy&Paste the new text from this window into your guide edi' +
        'tor'
      ''
      'Know issues:'
      '- Links to crafted items doesn'#39't work with the Tooltip JS'
      '- All links to Hellfire Amulets goes to to the INT version'
      
        '- There seems to be no link to Ramaladnis Gift in the game guide' +
        ' any more')
    PopupMenu = PopupMenu1
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object GroupBox1: TGroupBox
    Left = 513
    Top = 8
    Width = 177
    Height = 113
    Anchors = [akTop, akRight]
    Caption = 'Settings'
    TabOrder = 1
    object lblRegion: TLabel
      Left = 16
      Top = 18
      Width = 112
      Height = 13
      Caption = 'Region (for D3 Forums)'
    end
    object cbExternalHTML: TCheckBox
      Left = 16
      Top = 78
      Width = 90
      Height = 17
      Caption = 'Rewrite HTML'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbRegion: TComboBox
      Left = 16
      Top = 37
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = 'Europe'
      Items.Strings = (
        'Europe'
        'Americas & Southeast Asia'
        'Korea'
        'Taiwan')
    end
    object BtnWhat: TButton
      Left = 112
      Top = 74
      Width = 51
      Height = 25
      Caption = 'What?'
      TabOrder = 2
      OnClick = BtnTerminatorClick
    end
  end
  object BtnReplaceLinks: TButton
    Left = 577
    Top = 135
    Width = 113
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Replace links'
    TabOrder = 2
    OnClick = BtnReplaceLinksClick
  end
  object PopupMenu1: TPopupMenu
    Left = 160
    object S1: TMenuItem
      Caption = 'Select all'
      ShortCut = 16449
      OnClick = S1Click
    end
  end
end
