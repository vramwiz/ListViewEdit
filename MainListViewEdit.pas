unit MainListViewEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls, Vcl.ExtCtrls,ListViewEdit;

type
  TFormMain = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private 宣言 }
    FListView : TListViewEdit;
  public
    { Public 宣言 }
  end;

var
  FormMain: TFormMain;

implementation

uses Vcl.ComCtrls,CommCtrl ;

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FListView := TListViewEdit.Create(Self);
  FListView.Parent := Self;
  FListView.Align := alClient;
  FListView.ViewStyle := vsReport;
  FListView.RowSelect := true;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FListView.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
var
  Column : TListColumn;
  Item : TListItem;
  i : Integer;
begin
  FListView.Columns.Clear;
  Column :=  FListView.Columns.Add;
  Column.Caption := '列1';
  Column.Width := 80;
  Column :=  FListView.Columns.Add;
  Column.Caption := '列2';
  Column.Width := 80;
  FListView.ColumnAlign(1);
  for i := 0 to 15 do begin
    Item := FListView.Items.Add;
    Item.Caption := '行'+IntToStr(i+1);
    Item.SubItems.Add('データ'+IntToStr(i+1));
  end;

end;

end.
