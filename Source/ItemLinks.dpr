program ItemLinks;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  GuideForm in 'GuideForm.pas' {FGuide},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Diablo');
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFGuide, FGuide);
  Application.Run;
end.
