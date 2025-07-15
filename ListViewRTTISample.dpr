program ListViewRTTISample;

uses
  Vcl.Forms,
  MainListViewRTTI in 'MainListViewRTTI.pas' {FormMain},
  ListViewEx in 'ListViewEx.pas',
  ListViewEdit in 'ListViewEdit.pas',
  ListViewRTTI in 'ListViewRTTI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
