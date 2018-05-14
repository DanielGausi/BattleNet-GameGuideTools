program ItemLinks;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  GuideForm in 'GuideForm.pas' {FGuide};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFGuide, FGuide);
  Application.Run;
end.
