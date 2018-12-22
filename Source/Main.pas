﻿unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, StrUtils, ComCtrls, IdSSLOpenSSL, shlobj, ActiveX,
  ContNrs, VirtualTrees, Menus, Clipbrd, ShellApi, Buttons, ImgList,
  IniFiles, IdAuthentication, System.ImageList, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, PNGImage ;

type
    TLegItem = class
        Name: String;
        Link: String;
        oldLink: String;
        category: String;
        constructor create(aName, aLink, aCategory: String);
    end;

    TTreeData = record
      fLegItem : TLegItem;
    end;
    PTreeData = ^TTreeData;


  TMainForm = class(TForm)
    LegPopup: TPopupMenu;
    CopyURLtoclipboard1: TMenuItem;
    Search1: TMenuItem;
    grpBox_Main: TGroupBox;
    editSearch: TEdit;
    lblClipboard: TLabel;
    LegVST: TVirtualStringTree;
    PnlConfig: TPanel;
    grpBoxSettings: TGroupBox;
    lblProgress: TLabel;
    cbRegion: TComboBox;
    cbLanguage: TComboBox;
    BtGetItemLinks: TButton;
    cbAutoCopy: TCheckBox;
    cbStayOnTop: TCheckBox;
    BtnGenerateJS: TButton;
    BtnMinimize: TBitBtn;
    glyphs: TImageList;
    Clersearch1: TMenuItem;
    BtnGuides: TButton;
    N1: TMenuItem;
    Savelinks1: TMenuItem;
    SaveDialog1: TSaveDialog;
    cbGetPics: TCheckBox;
    grpBoxItem: TGroupBox;
    Image1: TImage;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtGetItemLinksClick(Sender: TObject);

    procedure LegVSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure CopyURLtoclipboard1Click(Sender: TObject);
    procedure cbRegionChange(Sender: TObject);
    procedure cbLanguageChange(Sender: TObject);
    procedure editSearchChange(Sender: TObject);
    procedure LegVSTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure LegVSTFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure Search1Click(Sender: TObject);
    procedure BtnGenerateJSClick(Sender: TObject);
    procedure cbStayOnTopClick(Sender: TObject);
    procedure LegVSTDblClick(Sender: TObject);
    procedure LegVSTKeyPress(Sender: TObject; var Key: Char);
    procedure BtnMinimizeClick(Sender: TObject);
    procedure Clersearch1Click(Sender: TObject);
    procedure BtnGuidesClick(Sender: TObject);
    procedure cbAutoCopyClick(Sender: TObject);
    procedure Savelinks1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure lblNameClick(Sender: TObject);
  private
    { Private-Deklarationen }

    LanguageCode: String;
    RegionCode: String;

    BASE_URL: AnsiString;//  'https://eu.battle.net/d3/de/item/';
    BASE_URL_Items: AnsiString;// = 'https://eu.battle.net/';

    //procedure parsePageForPictures(aSourceCode: String; destURLs, destNames: TStrings);
    procedure parsePageForItemLinks(aSourceCode: String; categorie: String; doDownloadPics: Boolean);

    function GuessOldLink(aNewLink: String): String;

    procedure CorrectBaseLinks;
    procedure DoSearch(aKeywords: String);

    procedure LoadItemsFromFile(aFilename: String);
    procedure SaveItemsToFile(aFilename: String);

    procedure SavePicToFile(aURL, aFilename: String);

  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;
  SlotList: TStringList;
  LegItems: TObjectList;

  DiabloPath: String;

const

  PICDIR = 'ItemPics';

  //LEG_MARKER = 'd3-icon-item-orange';
  //LEG_MARKER = 'class="column-item"';
  LEG_MARKER = ' legendary"';


  LEG_IMAGE_START = 'background-image: url(';
  LEG_IMAGE_END = ');';

  LEG_ITEM_LINK_BEGIN = '<a href="/';  // base-URL ends with "/", so we dont need the first "/" here
  LEG_ITEM_LINK_END = '"';

  TITLE_BEGIN = '<title>';
  TITLE_END = '</title>';


  GEM_MARKER = 'class="data-cell"';
  GEM_NAME_START = 'data-raw="';
  GEM_NAME_END = '">';


  LEG_NAME_START = 'class="d3-color-orange">';
  LEG_NAME_END = '</a>';

  //SET_MARKER = 'd3-icon-item-green';
  SET_MARKER = ' set"';
  SET_NAME_START = 'class="d3-color-green">';

  CSIDL_PERSONAL = $0005;


implementation

{$R *.dfm}

uses GuideForm;


function GetShellFolder(CSIDL: integer): string;
var
  pidl              : PItemIdList;
  FolderPath        : string;
  SystemFolder      : Integer;
  Malloc            : IMalloc;
begin
  Malloc := nil;
  FolderPath := '';
  SHGetMalloc(Malloc);
  if Malloc = nil then
  begin
    Result := FolderPath;
    Exit;
  end;
  try
    SystemFolder := CSIDL;
    if SUCCEEDED(SHGetSpecialFolderLocation(0, SystemFolder, pidl)) then
    begin
      SetLength(FolderPath, max_path);
      if SHGetPathFromIDList(pidl, PChar(FolderPath)) then
      begin
        SetLength(FolderPath, length(PChar(FolderPath)));
      end;
    end;
    Result := FolderPath;
  finally
    Malloc.Free(pidl);
  end;
end;




constructor TLegItem.create(aName, aLink, aCategory: String);
begin
    self.Name := aName;
    self.Link := aLink;
    self.category := aCategory;
end;

function AddVSTLegItem(AVST: TCustomVirtualStringTree; aNode: PVirtualNode; aLegItem: TLegItem): PVirtualNode;
var Data: PTreeData;
begin
  Result:= AVST.AddChild(aNode);

  Data:=AVST.GetNodeData(Result);
  Data^.fLegItem:=aLegItem;

  AVST.ValidateNode(Result,false);
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
    SlotList := TStringList.Create;
    //subDirs := TStringList.Create;

    lblClipboard.Caption := '';
    lblProgress.Caption := '';

    LegItems := TObjectList.Create(True);

    //BASE_URL_Gems := 'https://eu.diablo3.com/de/item/gem/';
    //BASE_URL := 'https://eu.battle.net/d3/de/item/';
    //BASE_URL_Items := 'https://eu.battle.net/';

    BASE_URL := 'https://eu.diablo3.com/de/item/';
    BASE_URL_Items := 'https://eu.diablo3.com/';

    SlotList.Add('gem');
    // armor
    SlotList.Add('helm');
    SlotList.Add('pauldrons');
    SlotList.Add('chest-armor');
    SlotList.Add('bracers');
    SlotList.Add('gloves');
    SlotList.Add('belt');
    SlotList.Add('pants');
    SlotList.Add('boots');
    SlotList.Add('cloak');
    SlotList.Add('spirit-stone');
    SlotList.Add('voodoo-mask');
    SlotList.Add('wizard-hat');
    SlotList.Add('mighty-belt');

    // 1-Hand-Waffen
    SlotList.Add('dagger');
    SlotList.Add('sword-1h');
    SlotList.Add('spear');
    SlotList.Add('mace-1h');
    SlotList.Add('axe-1h');
    SlotList.Add('flail-1h');
    SlotList.Add('fist-weapon');
    SlotList.Add('mighty-weapon-1h');
    SlotList.Add('ceremonial-knife');
    SlotList.Add('scythe-1h');

    // Nebenhand
    SlotList.Add('quiver');
    SlotList.Add('shield');
    SlotList.Add('crusader-shield');
    SlotList.Add('orb');
    SlotList.Add('mojo');
    SlotList.Add('phylactery');

    // 2-Hand-Waffen
    SlotList.Add('sword-2h');
    SlotList.Add('polearm');
    SlotList.Add('mace-2h');
    SlotList.Add('staff');
    SlotList.Add('axe-2h');
    SlotList.Add('flail-2h');
    SlotList.Add('daibo');
    SlotList.Add('mighty-weapon-2h');
    SlotList.Add('scythe-2h');

    // Distanz-Waffen
    SlotList.Add('crossbow');
    SlotList.Add('bow');
    SlotList.Add('hand-crossbow');
    SlotList.Add('wand');

    // Schmuck
    SlotList.Add('amulet');
    SlotList.Add('ring');

    DiabloPath := GetShellFolder(CSIDL_PERSONAL) + '\Diablo III';
    if NOT DirectoryExists(DiabloPath) then
    begin
        cbGetPics.Checked := False;
        cbGetPics.Enabled := False;
    end;

    //idhttp1.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    //TIdSSLIOHandlerSocketOpenSSL(idhttp1.IoHandler).SSLOptions.SSLVersions :=
    //    [sslvSSLv2, sslvTLSv1_2];

      //[sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
    //[sslvSSLv2, sslvSSLv23, sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];

    glyphs.GetBitmap(0, BtnMinimize.Glyph );
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
    SlotList.Free;
    LegItems.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
var ini: TIniFile;
begin
    if DirectoryExists(DiabloPath) then
    begin
        ini := TInifile.Create(DiabloPath + '\GameGuideTools.ini');
        try
            cbRegion.ItemIndex := ini.ReadInteger('Settings', 'Region', 0);
            cbRegionChange(Nil);
            cbLanguage.ItemIndex := ini.ReadInteger('Settings', 'Language', 0);
            CorrectBaseLinks;
            cbStayOnTop.Checked := ini.ReadBool('Settings', 'StayOnTop', False);
            cbAutoCopy.Checked := ini.ReadBool('Settings', 'AutoCopy', True);
            if cbStayOnTop.Checked then
                SetWindowPos (MainForm.Handle, HWND_TOPMOST, -1, -1, -1, -1, SWP_NOMOVE + SWP_NOSIZE)
            else
                SetWindowPos (MainForm.Handle, HWND_NOTOPMOST, -1, -1, -1, -1, SWP_NOMOVE + SWP_NOSIZE);

            if ini.ReadBool('Settings', 'Minimzed', False) then
                BtnMinimize.Click;
        finally
            ini.Free;
        end;
        if FileExists(DiabloPath + '\GameGuideTool.items') then
            LoadItemsFromFile(DiabloPath + '\GameGuideTool.items');
    end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var ini: TIniFile;
begin
    if DirectoryExists(DiabloPath) then
    begin
        ini := TInifile.Create(DiabloPath + '\GameGuideTools.ini');
        try
            ini.WriteInteger('Settings', 'Region', cbRegion.ItemIndex);
            ini.WriteInteger('Settings', 'Language', cbLanguage.ItemIndex);
            ini.WriteBool('Settings', 'StayOnTop', cbStayOnTop.Checked);
            ini.WriteBool('Settings', 'AutoCopy', cbAutoCopy.Checked);
            ini.WriteBool('Settings', 'Minimzed', BtnMinimize.Tag = 1);
        finally
            ini.Free;
        end;
        SaveItemsToFile(DiabloPath + '\GameGuideTool.items');
    end;
end;


procedure TMainForm.SavePicToFile(aURL, aFilename: String);
var HttpClient: THttpClient;
    ms: TMemoryStream;
begin
    HttpClient := THttpClient.Create;
    try
        ms := TMemoryStream.Create;
        try
            HttpClient.Get(aURL, ms);
            ms.Position := 0;
            ms.SaveToFile(aFilename);
        finally
            ms.Free
        end;
    finally
        HttpClient.Free;
    end;
end;


procedure TMainForm.LoadItemsFromFile(aFilename: String);
var sl: TStringList;
    i: Integer;
    newItem: TLegItem;
begin
    if FileExists(aFilename) then
    begin
        LegItems.Clear;
        LegVST.Clear;

        sl := TStringList.Create;
        try
            sl.LoadFromFile(aFilename);
            if sl.Count > 4 then
            begin
                for i := 0 to (sl.Count-1) Div 4 do
                begin
                    newItem := TLegItem.create(sl[4*i], sl[4*i+2], sl[4*i + 1]);
                    newItem.oldLink := sl[4*i+3];
                    LegItems.Add(newItem);
                    AddVSTLegItem(LegVST, Nil, newItem);
                end;
            end;
        finally
            sl.Free;
        end;
    end;
end;

procedure TMainForm.SaveItemsToFile(aFilename: String);
var sl: TStringList;
    i: Integer;
begin
    sl := tStringList.Create;
    try
        for i := 0 to LegItems.Count - 1 do
        begin
            sl.Add(tLegitem(LegItems[i]).Name);
            sl.Add(tLegitem(LegItems[i]).category);
            sl.Add(tLegitem(LegItems[i]).Link);
            sl.Add(tLegitem(LegItems[i]).oldLink);
        end;
        sl.SaveToFile(aFileName);
    finally
        sl.free;
    end;
end;

procedure TMainForm.Savelinks1Click(Sender: TObject);
begin
    if SaveDialog1.Execute then
        SaveItemsToFile(SaveDialog1.FileName);
end;




procedure TMainForm.LegVSTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var Data: PTreeData;
    currentItem: TLegitem;
    picFilename: String;
begin
    if cbAutoCopy.Checked and assigned(Node) then
    begin
        Data := Sender.GetNodeData(Node);

        currentItem := Data^.fLegItem;

        grpBoxItem.Caption  := currentItem.Name;

        //lblName.Caption := currentItem.Name;
        //lblURL.Caption := currentItem.Link;
        //lblOldURL.Caption := currentItem.oldLink;

        picFilename := DiabloPath + '\' + PICDIR + '\' + currentItem.category + '\' + currentItem.Name + '.png';
        if FileExists(picFilename) then
            image1.Picture.LoadFromFile(picFilename)
        else
            image1.Picture.Assign(Nil);

        try
            ClipBoard.AsText := BASE_URL_Items + currentItem.Link;
            lblClipboard.Caption := 'Clipboard: ' + BASE_URL_Items + currentItem.Link;
        except
            //silent
        end;
    end else
    begin
        lblClipboard.Caption := '';
        image1.Picture.Assign(Nil);
    end;
end;

procedure TMainForm.LegVSTFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
    LegVSTChange(Sender, Node);
end;


procedure TMainForm.LegVSTDblClick(Sender: TObject);
var aNode: PVirtualNode;
    Data: PTreeData;
begin
    aNode := LegVST.FocusedNode;
    if assigned(aNode) then
    begin
        Data := LegVST.GetNodeData(aNode);
        shellexecute(handle, 'open',
        PChar(BASE_URL_Items + Data^.fLegItem.Link),
        nil,nil,sw_show)
    end;
end;

procedure TMainForm.LegVSTKeyPress(Sender: TObject; var Key: Char);
begin
    case ord(key) of
        vk_Return: LegVSTDblClick(Sender);
    end;
end;


procedure TMainForm.LegVSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var Data: PTreeData;
begin
        Data:=Sender.GetNodeData(Node);
        case Column of
            0: CellText := Data^.fLegItem.Name;
            1: CellText := Data^.fLegItem.Link;
            2: CellText := Data^.fLegItem.oldLink;
        end;
end;


procedure TMainForm.cbRegionChange(Sender: TObject);
begin
    case cbRegion.ItemIndex of
        0: begin
            cbLanguage.Items.Clear;
            cbLanguage.Items.Add('Deutsch');
            cbLanguage.Items.Add('English');
            cbLanguage.Items.Add('Español');
            cbLanguage.Items.Add('Français');
            cbLanguage.Items.Add('Italiano');
            cbLanguage.Items.Add('Polski');
            cbLanguage.Items.Add('Русский');
            cbLanguage.ItemIndex := 0;
        end;
        1: begin
            cbLanguage.Items.Clear;
            cbLanguage.Items.Add('English (US)');
            cbLanguage.Items.Add('Español (AL)');
            cbLanguage.Items.Add('Português (AL)');
            cbLanguage.ItemIndex := 0;
        end;
        2: begin
            cbLanguage.Items.Clear;
            cbLanguage.Items.Add('한국어');
            cbLanguage.ItemIndex := 0;
        end;
        3: begin
            cbLanguage.Items.Clear;
            cbLanguage.Items.Add('繁體中文');
            cbLanguage.ItemIndex := 0;
        end;
    end;
    CorrectBaseLinks;
end;


procedure TMainForm.CorrectBaseLinks;
begin
    case cbRegion.ItemIndex of
        0: begin
            regionCode := 'eu';
            case cbLanguage.ItemIndex of
                0: LanguageCode := 'de';
                1: LanguageCode := 'en';
                2: LanguageCode := 'es';
                3: LanguageCode := 'fr';
                4: LanguageCode := 'it';
                5: LanguageCode := 'pl';
                6: LanguageCode := 'ru';
            end;
        end;
        1: begin
            regionCode := 'us';
            case cbLanguage.ItemIndex of
                0: LanguageCode := 'en';
                1: LanguageCode := 'es';
                2: LanguageCode := 'pt';
            end;
        end;
        2: begin
            regionCode := 'kr';
            LanguageCode := 'ko';
        end;
        3: begin
            regionCode := 'tw';
            LanguageCode := 'zh';
        end;
    end;

    //BASE_URL_Gems := 'd3/' + LanguageCode + '/item/';
    //BASE_URL := 'https://' + regionCode + '.battle.net/d3/' + LanguageCode + '/item/';
    //BASE_URL_Items := 'https://' + regionCode + '.battle.net/';

    //https://eu.diablo3.com/de/item/gem/
    //BASE_URL_Gems := 'd3/' + LanguageCode + '/item/';
    BASE_URL := 'https://' + regionCode + '.diablo3.com/' + LanguageCode + '/item/';
    BASE_URL_Items := 'https://' + regionCode + '.diablo3.com/';
end;

procedure TMainForm.cbStayOnTopClick(Sender: TObject);
begin
    if cbStayOnTop.Checked then
        SetWindowPos (MainForm.Handle, HWND_TOPMOST, -1, -1, -1, -1, SWP_NOMOVE + SWP_NOSIZE)
    else
        SetWindowPos (MainForm.Handle, HWND_NOTOPMOST, -1, -1, -1, -1, SWP_NOMOVE + SWP_NOSIZE)
end;

procedure TMainForm.cbAutoCopyClick(Sender: TObject);
begin
    if not cbAutoCopy.Checked then
        self.lblClipboard.Caption := '';
end;

procedure TMainForm.cbLanguageChange(Sender: TObject);
begin
    CorrectBaseLinks;
end;


procedure TMainForm.Clersearch1Click(Sender: TObject);
begin
    editSearch.Text := '';
    self.editSearch.SetFocus;
end;

procedure TMainForm.CopyURLtoclipboard1Click(Sender: TObject);
var aNode: PVirtualNode;
    Data: PTreeData;
begin
    aNode := LegVST.FocusedNode;
    if assigned(aNode) then
    begin
        Data := LegVST.GetNodeData(aNode);
        try
            Clipboard.AsText := BASE_URL_Items + Data^.fLegItem.Link;
        except
            // silent
        end;
    end;
end;


procedure TMainForm.BtnMinimizeClick(Sender: TObject);
begin
    if BtnMinimize.Tag = 0 then
    begin
        PnlConfig.Height := 19;
        grpBoxSettings.Enabled := False;
        //Progressbar1.Visible := False;
        BtnMinimize.Tag := 1;
        BtnMinimize.Glyph := Nil;
        glyphs.GetBitmap(1, BtnMinimize.Glyph );
    end else
    begin
        PnlConfig.Height := 95;
        grpBoxSettings.Enabled := True;
        //Progressbar1.Visible := True;
        BtnMinimize.Tag := 0;
        BtnMinimize.Glyph := Nil;
        glyphs.GetBitmap(0, BtnMinimize.Glyph );
    end;
end;

procedure TMainForm.BtGetItemLinksClick(Sender: TObject);
var s: String;
  i: Integer;
  utf8: utf8String;
  ms: TMemoryStream;
  mostRecentScan: String;
  newTitleStart, newTitleEnd : Integer;

  HttpClient: THttpClient;
begin
    if LegItems.Count > 0 then
    begin
        if MessageDlg('This will delete the current item information and rescan the Diablo 3 website.'
              +#13#10#13#10+
              'Do you want to continue?'
              , mtInformation, [mbYes, mbNo], 0) = mrNo
        then
            exit;
    end;

    LegVST.Clear;
    LegItems.Clear;

    mostRecentScan := '';
    //IdHTTP1.Request.ContentType := 'charset=utf-8';

    HttpClient := THttpClient.Create;
    try
        ms := TMemoryStream.Create;
        try
            //for i := 0 to 4 do
            for i := 0 to SlotList.Count - 1 do
            begin

                Caption := BASE_URL + SlotList[i] + '/';

                lblProgress.Caption := Format('Scanning %d/%d ... %s', [i+1, SlotList.Count, mostRecentScan]);

                //'Scanning ' +  + ' ... ' + mostRecentScan;
                Application.ProcessMessages;

                ms.Clear;

                HttpClient.Get(BASE_URL + SlotList[i] + '/', ms);

                utf8 := '';
                Setlength(utf8, ms.size);
                ms.Position := 0;

                ms.ReadBuffer(PAnsiChar(utf8)^, ms.Size);

                s := UTF8ToString(utf8);
                // get the current title of the Page
                newTitleStart := PosEx(TITLE_BEGIN, s, 1) + length(TITLE_BEGIN);
                newTitleEnd := PosEx(TITLE_END, s, newTitleStart); // + length(TITLE_END);
                mostRecentScan := Copy(s, newTitleStart, newTitleEnd - newTitleStart);

                //ms.Position := 0;
                //ms.SaveToFile('F:\Eigene Dateien (Daniel)\Diablo III\pic-downloads\' + mostRecentScan);

                parsePageForItemLinks(s, SlotList[i], cbGetPics.Checked);
                Application.ProcessMessages;
            end;
        finally
            ms.Free;
        end;
    finally
        HttpClient.Free;
    end;

    if assigned(LegVST.GetFirst(False)) then
        LegVST.Selected[0] := True;
    LegVST.FocusedNode := LegVST.GetFirst;

    lblProgress.Caption := 'Scanning complete, ' + IntToStr(Legitems.Count) + ' items found.';
end;


procedure TMainForm.BtnGenerateJSClick(Sender: TObject);
var i: Integer;
    sl: TStringList;
    localNewLink, localOldLink: String;
begin

    if Legitems.Count = 0 then
        MessageDlg('Please get item links first. ' , mtInformation, [mbOK], 0)
    else
    begin
        // This is a helper method to create the Userscript for the forums.
        // not needed for guide writers
        // (button is invisible. To use it, make also the LogForm visible!)
        sl := tStringList.Create;
        try
            for i := 0 to LegItems.Count - 1 do
            begin
                localNewLink := Copy(TLegItem(LegItems[i]).Link, 7, Length(TLegItem(LegItems[i]).Link));
                localOldLink := Copy(TLegItem(LegItems[i]).oldLink, 7, Length(TLegItem(LegItems[i]).oldLink));
                sl.Add(Format('if (aLinks[i].href.endsWith("%s")) {', [localOldLink]));
                sl.Add(Format('aLinks[i].href = aLinks[i].href.replace("%s", "%s");', [localOldLink, localNewLink]));
                sl.Add('} else ')
            end;
            Clipboard.AsText := sl.Text;
        finally
            sl.Free
        end;
        MessageDlg('Some part of the code for a userscript (Greasemonkey) has been copied to the Clipboard.' , mtInformation, [mbOK], 0);
    end;
end;

procedure TMainForm.BtnGuidesClick(Sender: TObject);
begin
    FGuide.Show;
end;

procedure TMainForm.parsePageForItemLinks(aSourceCode: String; categorie: String; doDownloadPics: Boolean);
var newURLStart, newURLend, newNameStart, newNameEnd: Integer;
    picURLStart, picURLEnd: Integer;
    tmpPos1: Integer;
    tmpLeg, tmpSet: Integer;
    offset: Integer;
    newFound: Boolean;
    newName, newURL, currentDir, picURL: String;
    newItem: TLegItem;
begin
    offset := 1;
    newFound := True;

    //ShowMessage(aSourceCode);

    if doDownloadPics and DirectoryExists(DiabloPath) then
    begin
        currentDir := DiabloPath + '\' + PICDIR + '\' + categorie;
        // cancel Pic download if subdir can't be created
        doDownloadPics := ForceDirectories(currentDir);
    end;
    {
    DiabloPath := GetShellFolder(CSIDL_PERSONAL) + '\Diablo III';
    if NOT DirectoryExists(DiabloPath) then
    begin
        cbGetPics.Checked := False;
        cbGetPics.Enabled := False;
    end;
    }

    if categorie = 'gem' then
    begin
        // Gems are special
        repeat
            tmpPos1 := PosEx(GEM_MARKER ,aSourceCode, offset);

            {
          GEM_NAME_START = 'data-raw="';
          GEM_NAME_END = '">';
            }
            if tmpPos1 > 1 then
            begin

                newNameStart := PosEx(GEM_NAME_START, aSourceCode, tmpPos1) + length(GEM_NAME_START);
                newNameEnd   := PosEx(GEM_NAME_END, aSourceCode, newNameStart);
                newName := Copy(aSourceCode, newNameStart, newNameEnd - newNameStart);
                newName := StringReplace(newName, '{d}', '', [rfReplaceAll]);
                newName := StringReplace(newName, '&#39;', '', [rfReplaceAll]);
                newName := Copy(newName, 0, Length(newName) Div 2);

                newURLStart := PosEx(LEG_ITEM_LINK_BEGIN, aSourceCode, newNameEnd) + length(LEG_ITEM_LINK_BEGIN);
                newURLend := PosEx(LEG_ITEM_LINK_END, aSourceCode, newURLStart);
                newURL := Copy(aSourceCode, newURLStart, newURLend - newURLStart);


                // cancel when the regular gems begins
                if pos('recipe', newURL) > 0 then
                begin
                    newFound := False;
                    // the first regular gem (without a recipe) has already been added. delete it now.
                    LegItems.Delete(LegItems.Count-1);
                    LegVST.DeleteNode(LegVST.GetLast(Nil));
                end else
                begin
                    picURLStart := PosEx(LEG_IMAGE_START, aSourceCode, tmpPos1) + length(LEG_IMAGE_START);
                    picURLEnd := PosEx(LEG_IMAGE_END, aSourceCode, picURLStart);
                    picURL := Copy(aSourceCode, picURLStart, picURLEnd - picURLStart);
                    SavePicToFile(picURL, currentDir + '\' + newName + '.png');

                    newItem := TLegItem.create(newName, newURL, categorie);
                    newItem.oldLink := GuessOldLink(newItem.Link);
                    LegItems.Add(newItem);
                    AddVSTLegItem(LegVST, Nil, newItem);
                    offset := tmpPos1 + 50;
                end;
            end else
            begin
                newFound := False;
            end;
            // no "set-gems" available
        until not newFound

    end else

    begin
        repeat
            tmpPos1 := PosEx(LEG_MARKER ,aSourceCode, offset);
            {
             LEG_MARKER = ' legendary"';

              LEG_IMAGE_START = 'background-image: url(';
              LEG_IMAGE_END = ');';

              LEG_ITEM_LINK_BEGIN = '<a href="/';  // base-URL ends with "/", so we dont need the first "/" here
              LEG_ITEM_LINK_END = '"';

              TITLE_BEGIN = '<title>';
              TITLE_END = '</title>';

              GEM_NAME_START = 'data-raw="';
              GEM_NAME_END = '">';

              LEG_NAME_START = 'class="d3-color-orange">';
              LEG_NAME_END = '</a>';

              SET_MARKER = 'd3-icon-item-green';
              SET_NAME_START = 'class="d3-color-green">';

            }
            if tmpPos1 > 1 then
            begin
               newURLStart := PosEx(LEG_ITEM_LINK_BEGIN, aSourceCode, tmpPos1) + length(LEG_ITEM_LINK_BEGIN);
               newURLend := PosEx(LEG_ITEM_LINK_END, aSourceCode, newURLStart);
               newURL := Copy(aSourceCode, newURLStart, newURLend - newURLStart);

               newNameStart := PosEx(LEG_NAME_START, aSourceCode, newURLend) + length(LEG_NAME_START);
               newNameEnd   := PosEx(LEG_NAME_END, aSourceCode, newNameStart);
               newName := Copy(aSourceCode, newNameStart, newNameEnd - newNameStart);
               newName := StringReplace(newName, '{d}', '', [rfReplaceAll]);
               newName := StringReplace(newName, '&#39;', '', [rfReplaceAll]);

               picURLStart := PosEx(LEG_IMAGE_START, aSourceCode, tmpPos1) + length(LEG_IMAGE_START);
               picURLEnd := PosEx(LEG_IMAGE_END, aSourceCode, picURLStart);
               picURL := Copy(aSourceCode, picURLStart, picURLEnd - picURLStart);
               SavePicToFile(picURL, currentDir + '\' + newName + '.png');

               newItem := TLegItem.create(newName, newURL, categorie);
               newItem.oldLink := GuessOldLink(newItem.Link);
               LegItems.Add(newItem);
               AddVSTLegItem(LegVST, Nil, newItem);

               offset := tmpPos1 + 50;
            end else
            begin
              newFound := False;
            end;
        until not newFound;
    end;

    // Sets
    newFound := True;
    offset := 1;
    repeat
        tmpPos1 := PosEx(SET_MARKER ,aSourceCode, offset);
        if tmpPos1 > 1 then
        begin
             newURLStart := PosEx(LEG_ITEM_LINK_BEGIN, aSourceCode, tmpPos1) + length(LEG_ITEM_LINK_BEGIN);
             newURLend := PosEx(LEG_ITEM_LINK_END, aSourceCode, newURLStart);
             newURL := Copy(aSourceCode, newURLStart, newURLend - newURLStart);

             newNameStart := PosEx(SET_NAME_START, aSourceCode, newURLend) + length(SET_NAME_START);
             newNameEnd   := PosEx(LEG_NAME_END, aSourceCode, newNameStart);
             newName := Copy(aSourceCode, newNameStart, newNameEnd - newNameStart);
             newName := StringReplace(newName, '{d}', '', [rfReplaceAll]);
             newName := StringReplace(newName, '&#39;', '', [rfReplaceAll]);

             picURLStart := PosEx(LEG_IMAGE_START, aSourceCode, tmpPos1) + length(LEG_IMAGE_START);
             picURLEnd := PosEx(LEG_IMAGE_END, aSourceCode, picURLStart);
             picURL := Copy(aSourceCode, picURLStart, picURLEnd - picURLStart);
             SavePicToFile(picURL, currentDir + '\' + newName + '.png');


             newItem := TLegItem.create(newName, newURL, categorie);
             newItem.oldLink := GuessOldLink(newItem.Link);
             LegItems.Add(newItem);
             AddVSTLegItem(LegVST, Nil, newItem);

             offset := tmpPos1 + 50;
         end else
         begin
            newFound := False;
         end;
    until not newFound;
end;

function TMainForm.GuessOldLink(aNewLink: String): String;
var p: Integer;
begin
    result := aNewLink;

    // remove the new "unique_..." stuff
    p := pos('Unique_', result);
    if p > 0 then
    begin
        result := Copy(result, 0, p-2);
    end;

    // remove the Patch version
    if AnsiEndsText('-P1', result) then
        result := Copy(result, 0, length(result)-3);

    if AnsiEndsText('-P2', result) then
        result := Copy(result, 0, length(result)-3);
    if AnsiEndsText('-P3', result) then
        result := Copy(result, 0, length(result)-3);
    if AnsiEndsText('-P4', result) then
        result := Copy(result, 0, length(result)-3);
    if AnsiEndsText('-P5', result) then
        result := Copy(result, 0, length(result)-3);

    if AnsiEndsText('-P61', result) then
        result := Copy(result, 0, length(result)-4);

    if AnsiEndsText('-P11', result) then
        result := Copy(result, 0, length(result)-4);
    if AnsiEndsText('-P12', result) then
        result := Copy(result, 0, length(result)-4);

    if AnsiEndsText('-P21', result) then
        result := Copy(result, 0, length(result)-4);

    if AnsiEndsText('-P41', result) then
        result := Copy(result, 0, length(result)-4);
    if AnsiEndsText('-P42', result) then
        result := Copy(result, 0, length(result)-4);
    if AnsiEndsText('-P43', result) then
        result := Copy(result, 0, length(result)-4);

end;


procedure TMainForm.lblNameClick(Sender: TObject);
begin

end;

(*
procedure TMainForm.parsePageForPictures(aSourceCode: String; destURLs, destNames: TStrings);
var newURLStart, newURLend, newNameStart, newNameEnd: Integer;
    tmpPos1: Integer;
    offset: Integer;
    tmpName, tmpUrl: String;
    newFound: Boolean;
begin
    offset := 1;
    newFound := True;

    repeat
         tmpPos1 := PosEx(LEG_MARKER ,aSourceCode, offset);
         if tmpPos1 > 1 then
         begin
             newURLStart := PosEx(LEG_IMAGE_START, aSourceCode, tmpPos1) + length(LEG_IMAGE_START);
             newURLend := PosEx(LEG_IMAGE_End, aSourceCode, newURLStart);
             destURLs.Add(Copy(aSourceCode, newURLStart, newURLend - newURLStart));

             newNameStart := PosEx(LEG_NAME_START, aSourceCode, newURLend) + length(LEG_NAME_START);
             newNameEnd   := PosEx(LEG_NAME_END, aSourceCode, newNameStart);
             destNames.Add(Copy(aSourceCode, newNameStart, newNameEnd - newNameStart));

             offset := tmpPos1 + 50;
         end else
         begin
            newFound := False;
         end;
    until not newFound;

    // Sets
    newFound := True;
    offset := 1;
    repeat
        tmpPos1 := PosEx(SET_MARKER ,aSourceCode, offset);
        if tmpPos1 > 1 then
        begin
             newURLStart := PosEx(LEG_IMAGE_START, aSourceCode, tmpPos1) + length(LEG_IMAGE_START);
             newURLend := PosEx(LEG_IMAGE_End, aSourceCode, newURLStart);
             destURLs.Add(Copy(aSourceCode, newURLStart, newURLend - newURLStart));

             newNameStart := PosEx(SET_NAME_START, aSourceCode, newURLend) + length(SET_NAME_START);
             newNameEnd   := PosEx(LEG_NAME_END, aSourceCode, newNameStart);
             destNames.Add(Copy(aSourceCode, newNameStart, newNameEnd - newNameStart));

             offset := tmpPos1 + 50;
         end else
         begin
            newFound := False;
         end;
    until not newFound;
end;
*)

procedure TMainForm.Search1Click(Sender: TObject);
begin
    self.editSearch.SetFocus;
end;

function Explode(const Separator, S: String): TStringList;
var
  SepLen: Integer;
  F, P: PChar;
  tmpstr: String;
begin
  result := TStringList.Create;
  if (S = '') then Exit;
  if Separator = '' then
  begin
    Result.Add(S);
    Exit;
  end;
  SepLen := Length(Separator);
  P := PChar(S);
  while P^ <> #0 do
  begin
    F := P;
    P := StrPos(P, PChar(Separator));
    if (P = nil) then P := StrEnd(F);
    SetString(tmpstr, F, P - F);
    Result.Add(tmpstr);
    if P^ <> #0 then Inc(P, SepLen);
  end;
end;

function ItemMatch(aLegItem: TLegItem; aKeys: TStringList): Boolean;
var i: integer;
begin
    result := True;
    for i := 0 to aKeys.Count-1 do
    begin
        if (not AnsiContainsText(aLegItem.Name, aKeys[i]))
            AND
            (not AnsiContainsText(aLegItem.Link, aKeys[i]))
        then
        begin
            result := False;
            break;
        end;
    end;
end;

procedure TMainForm.DoSearch(aKeywords: String);
var sl: TStringlist;
    i: Integer;
begin
    sl := Explode(' ', editSearch.Text);
    LegVST.Clear;

    for i := 0 to LegItems.Count - 1 do
    begin
        if ItemMatch(TLegItem(LegItems[i]), sl) then
            AddVSTLegItem(LegVST, Nil, TLegItem(LegItems[i]));
    end;
    sl.Free;
end;

procedure TMainForm.editSearchChange(Sender: TObject);
var i: Integer;
begin
    if Length(editSearch.Text) >= 1 then
        DoSearch(editSearch.Text)
    else
    begin
        LegVST.Clear;
        for i := 0 to LegItems.Count-1 do
            AddVSTLegItem(LegVST, Nil, TLegItem(LegItems[i]));
    end;

    LegVST.FocusedNode := LegVST.GetFirst;

    if not assigned(LegVST.FocusedNode) then
    begin
        grpBoxItem.Caption := 'Item information';
        image1.Picture.Assign(Nil);
    end;
end;


end.
