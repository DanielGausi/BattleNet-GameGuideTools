unit GuideForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ComCtrls, ExtCtrls, StdCtrls,
  Menus;

type
  TFGuide = class(TForm)
    GuideMemo: TMemo;
    GroupBox1: TGroupBox;
    PopupMenu1: TPopupMenu;
    S1: TMenuItem;
    BtnReplaceLinks: TButton;
    cbRegion: TComboBox;
    //procedure cbExternalHTMLClick(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure BtnReplaceLinksClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    // procedure BtnTerminatorClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FGuide: TFGuide;

implementation

uses Main;

{$R *.dfm}

procedure TFGuide.BtnReplaceLinksClick(Sender: TObject);
var i: Integer;
    GuideText: String;
    baseURL, baseNewURL, linkURLOld, linkURLNew, veryOldURL: String;
    localNewLink, localOldLink: String;
    //doExternalLinks: Boolean;
begin
    if LegItems.Count = 0 then
    begin
        MessageDlg('Please get item links first. ' , mtInformation, [mbOK], 0);
        exit;
    end;

    {doExternalLinks := cbExternalHTML.Checked;
    if doExternalLinks and (
        (editHrefTerminator.Text = '')
        or
        (editHrefTerminator.Text = '_')
        or
        (editHrefTerminator.Text = '-')
        )
    then
    begin
        if MessageDlg('You want to correct links for an external guide, not on the Diablo 3 Forums, that''s fine.'
              +#13#13 +
              'However, your selected <href> terminator could cause some serious issues, creating a lot of invalid links.'
              +#13#10#13#10+
              'Do you want to continue?'
              , mtWarning, [mbYes, mbNo], 0, mbNo) = mrNo
        then
        begin
            doExternalLinks := False;
            exit;
        end;
    end;
    }

    // replace (very) old https tp new https
    GuideText := GuideMemo.Text;
    case cbRegion.ItemIndex of
        0: begin
            baseURL := 'eu.battle.net/d3/';
            baseNewURL := 'eu.diablo3.com/';
        end;
        1: begin
            baseURL := 'us.battle.net/d3/';
            baseNewURL := 'us.diablo3.com/';
        end;
        2: begin
            baseURL := 'kr.battle.net/d3/';
            baseNewURL := 'kr.diablo3.com/';
        end;
        3: begin
            baseURL := 'tw.battle.net/d3/';
            baseNewURL :=  'tw.diablo3.com/';
        end;
    end;
    veryOldURL := 'http://' + baseURL;
    linkURLNew := 'https://' + baseNewURL;
    GuideText := Stringreplace(GuideText, veryOldURL, linkURLNew, [rfReplaceAll]);

    // replace slightly newer guides
    case cbRegion.ItemIndex of
        0: baseURL := 'eu.diablo3.com/';
        1: baseURL := 'us.diablo3.com/';
        2: baseURL := 'kr.diablo3.com/';
        3: baseURL := 'tw.diablo3.com/';
    end;
    linkURLOld := 'http://' + baseURL;
    linkURLNew := 'https://' + baseURL;
    GuideText := Stringreplace(GuideText, linkURLOld, linkURLNew, [rfReplaceAll]);


    // replace battle.net with diablo3.com
    // old Link https://eu.battle.net/d3/de/item/the-cloak-of-the-garwulf-Unique_Cloak_002_p1
    // new Link https://eu.diablo3.com/de/item/the-cloak-of-the-garwulf-Unique_Cloak_002_p1
    GuideText := Stringreplace(GuideText, '.battle.net/d3/', '.diablo3.com/', [rfReplaceAll]);

    // replace item links
    for i := 0 to LegItems.Count -1 do
    begin
        // replace stand-alone links in D3-Forum-Code
        localNewLink := Copy(TLegItem(LegItems[i]).Link, 7, Length(TLegItem(LegItems[i]).Link)) + ' ';
        localOldLink := Copy(TLegItem(LegItems[i]).oldLink, 7, Length(TLegItem(LegItems[i]).oldLink)) + ' ';
        GuideText := StringReplace(GuideText, localOldLink, localNewLink, [rfReplaceAll]);

        // replace stand-alone links in D3-Forum-Code
        localNewLink := Copy(TLegItem(LegItems[i]).Link, 7, Length(TLegItem(LegItems[i]).Link)) + #13#10;
        localOldLink := Copy(TLegItem(LegItems[i]).oldLink, 7, Length(TLegItem(LegItems[i]).oldLink)) + #13#10;
        GuideText := StringReplace(GuideText, localOldLink, localNewLink, [rfReplaceAll]);

        // replace links within BB-Codes
        localNewLink := Copy(TLegItem(LegItems[i]).Link, 7, Length(TLegItem(LegItems[i]).Link)) + '[';
        localOldLink := Copy(TLegItem(LegItems[i]).oldLink, 7, Length(TLegItem(LegItems[i]).oldLink)) + '[';
        GuideText := StringReplace(GuideText, localOldLink, localNewLink, [rfReplaceAll]);

        // replace HREF (for external html guides)
        //if cbExternalHTML.Checked then // and doExternalLinks then
        //begin
            localNewLink := Copy(TLegItem(LegItems[i]).Link, 7, Length(TLegItem(LegItems[i]).Link)) + '"';
            localOldLink := Copy(TLegItem(LegItems[i]).oldLink, 7, Length(TLegItem(LegItems[i]).oldLink)) + '"';
            GuideText := StringReplace(GuideText, localOldLink, localNewLink, [rfReplaceAll]);

            localNewLink := Copy(TLegItem(LegItems[i]).Link, 7, Length(TLegItem(LegItems[i]).Link)) + '''';
            localOldLink := Copy(TLegItem(LegItems[i]).oldLink, 7, Length(TLegItem(LegItems[i]).oldLink)) + '''';
            GuideText := StringReplace(GuideText, localOldLink, localNewLink, [rfReplaceAll]);
        //end;
    end;

    GuideMemo.Text := GuideText;
end;

(*
procedure TFGuide.BtnTerminatorClick(Sender: TObject);
begin
    MessageDlg(
    'Usually, the deprecated item links are substrings of the new item links. ' +
    'I run a simple "StringReplace" on the guide text. To avoid creating invalid links like'  + #13#10
     + #13#10 +
     '<oldLink>-Unique_HandXBow_012_x1-Unique_HandXBow_012_x1-Unique_HandXBow_012_x1-Unique_HandXBow_012_x1,'+ #13#10
     + #13#10 +
     'I replace an old link only if it is directly followed by a harmless character. That means for guides in the official forums:' + #13#10 +
     '- a blank character " " ' + #13#10 +
     '- the beginning of a BBcode "["' + #13#10 +
     '- a line break.' + #13#10
     + #13#10 +
     'For guides on other sites, the correction of the html <href> tags is needed, which value is usually terminated with a double or single quote mark ( " or '' ). ' + #13#10
    , mtInformation, [mbOK], 0);
end;
*)

(*procedure TFGuide.cbExternalHTMLClick(Sender: TObject);
begin
    lblHRefTerminator.Enabled := cbExternalHTML.Checked;
    editHrefTerminator.Enabled := cbExternalHTML.Checked;
    BtnTerminator.Enabled := cbExternalHTML.Checked;
end;*)

procedure TFGuide.FormShow(Sender: TObject);
begin
    cbRegion.ItemIndex := MainForm.cbRegion.ItemIndex;
    FormStyle := fsNormal ;
end;

procedure TFGuide.S1Click(Sender: TObject);
begin
    GuideMemo.SelectAll;
end;

end.
