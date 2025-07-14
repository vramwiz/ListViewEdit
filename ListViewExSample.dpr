program ListViewExSample;

uses
  Vcl.Forms,
  MainListViewEx in 'MainListViewEx.pas' {FormMain},
  ListViewEx in 'ListViewEx.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
