program ListViewEditSamplePro;

uses
  Vcl.Forms,
  MainListViewEditPro in 'MainListViewEditPro.pas' {FormMain},
  ListViewEx in 'ListViewEx.pas',
  ListViewEdit in 'ListViewEdit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
