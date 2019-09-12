object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Diablo 3: Game Guide Tools'
  ClientHeight = 367
  ClientWidth = 696
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PopupMenu = LegPopup
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpBox_Main: TGroupBox
    Left = 0
    Top = 95
    Width = 696
    Height = 272
    Align = alClient
    Caption = 'Legendary Items'
    TabOrder = 0
    ExplicitWidth = 631
    ExplicitHeight = 264
    DesignSize = (
      696
      272)
    object lblClipboard: TLabel
      Left = 151
      Top = 23
      Width = 383
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = '____________________________________________'
      ExplicitWidth = 370
    end
    object editSearch: TEdit
      Left = 8
      Top = 20
      Width = 137
      Height = 21
      TabOrder = 0
      TextHint = 'Search'
      OnChange = editSearchChange
    end
    object LegVST: TVirtualStringTree
      Left = 0
      Top = 47
      Width = 473
      Height = 220
      Anchors = [akLeft, akTop, akRight, akBottom]
      Header.AutoSizeIndex = 0
      Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
      PopupMenu = LegPopup
      TabOrder = 1
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnChange = LegVSTChange
      OnDblClick = LegVSTDblClick
      OnFocusChanged = LegVSTFocusChanged
      OnGetText = LegVSTGetText
      OnKeyPress = LegVSTKeyPress
      ExplicitWidth = 408
      ExplicitHeight = 212
      Columns = <
        item
          Position = 0
          Text = 'Name'
          Width = 183
        end
        item
          Position = 1
          Text = 'URL'
          Width = 198
        end
        item
          Position = 2
          Text = 'Old URL (guessed)'
          Width = 188
        end>
    end
    object grpBoxItem: TGroupBox
      Left = 479
      Top = 47
      Width = 214
      Height = 194
      Anchors = [akTop, akRight]
      Caption = 'Item information'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      ExplicitLeft = 414
      object Image1: TImage
        Left = 13
        Top = 18
        Width = 188
        Height = 146
      end
    end
    object cbURLSyntax: TComboBox
      Left = 540
      Top = 20
      Width = 145
      Height = 21
      Anchors = [akTop, akRight]
      ItemIndex = 1
      TabOrder = 3
      Text = 'Forums (Trust Level 1)'
      OnChange = cbURLSyntaxChange
      Items.Strings = (
        'Pure URL'
        'Forums (Trust Level 1)'
        'Forums (Trust Level 3)')
      ExplicitLeft = 475
    end
  end
  object PnlConfig: TPanel
    Left = 0
    Top = 0
    Width = 696
    Height = 95
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 631
    DesignSize = (
      696
      95)
    object grpBoxSettings: TGroupBox
      Left = 0
      Top = 0
      Width = 661
      Height = 95
      Align = alLeft
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Configuration'
      TabOrder = 0
      ExplicitWidth = 596
      DesignSize = (
        661
        95)
      object lblProgress: TLabel
        Left = 16
        Top = 73
        Width = 120
        Height = 13
        Caption = '____________________'
      end
      object cbRegion: TComboBox
        Left = 16
        Top = 24
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'Europe'
        OnChange = cbRegionChange
        Items.Strings = (
          'Europe'
          'Americas & Southeast Asia'
          'Korea'
          'Taiwan')
      end
      object cbLanguage: TComboBox
        Left = 184
        Top = 24
        Width = 113
        Height = 21
        ItemIndex = 0
        TabOrder = 1
        Text = 'Deutsch'
        OnChange = cbLanguageChange
        Items.Strings = (
          'Deutsch'
          'English'
          'Espa'#241'ol'
          'Fran'#231'ais'
          'Italiano'
          'Polski'
          #1056#1091#1089#1089#1082#1080#1081)
      end
      object BtGetItemLinks: TButton
        Left = 303
        Top = 22
        Width = 138
        Height = 25
        Caption = 'Get item links'
        TabOrder = 2
        OnClick = BtGetItemLinksClick
      end
      object cbAutoCopy: TCheckBox
        Left = 16
        Top = 51
        Width = 145
        Height = 17
        Caption = 'Always copy to Clipboard'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = cbAutoCopyClick
      end
      object cbStayOnTop: TCheckBox
        Left = 184
        Top = 50
        Width = 97
        Height = 17
        Caption = 'Stay on Top'
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnClick = cbStayOnTopClick
      end
      object BtnGenerateJS: TButton
        Left = 557
        Top = 53
        Width = 93
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Create JS'
        TabOrder = 5
        Visible = False
        OnClick = BtnGenerateJSClick
        ExplicitLeft = 492
      end
      object BtnGuides: TButton
        Left = 557
        Top = 22
        Width = 93
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Rewrite guide'
        TabOrder = 6
        OnClick = BtnGuidesClick
        ExplicitLeft = 492
      end
      object cbGetPics: TCheckBox
        Left = 303
        Top = 50
        Width = 129
        Height = 17
        Caption = 'Download item graphics'
        TabOrder = 7
      end
    end
    object BtnMinimize: TBitBtn
      Left = 667
      Top = 4
      Width = 24
      Height = 15
      Hint = 'Show/Hide configuration'
      Anchors = [akTop, akRight]
      Layout = blGlyphTop
      Margin = 0
      ParentShowHint = False
      ShowHint = True
      Spacing = 0
      TabOrder = 1
      OnClick = BtnMinimizeClick
      ExplicitLeft = 602
    end
  end
  object LegPopup: TPopupMenu
    Left = 24
    Top = 168
    object CopyURLtoclipboard1: TMenuItem
      Caption = 'Copy URL to clipboard'
      ShortCut = 16451
      OnClick = CopyURLtoclipboard1Click
    end
    object Search1: TMenuItem
      Caption = 'Search'
      ShortCut = 113
      OnClick = Search1Click
    end
    object Clersearch1: TMenuItem
      Caption = 'Clear search'
      ShortCut = 27
      OnClick = Clersearch1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Savelinks1: TMenuItem
      Caption = 'Save links'
      OnClick = Savelinks1Click
    end
  end
  object glyphs: TImageList
    Height = 8
    Width = 13
    Left = 152
    Top = 160
    Bitmap = {
      494C01010200080004000D000800FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000340000000800000001002000000000008006
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000034000000080000000100010000000000400000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFC000000000FFFFFFC000000000
      E03FEFC000000000F07FC7C000000000F8FF83C000000000FDFF01C000000000
      FFFFFFC000000000FFFFFFC00000000000000000000000000000000000000000
      000000000000}
  end
  object SaveDialog1: TSaveDialog
    Left = 16
    Top = 224
  end
end
