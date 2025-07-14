unit MainListViewEx;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,ListViewEx, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private �錾 }
    FListView : TListViewEx;
  public
    { Public �錾 }
  end;

var
  FormMain: TFormMain;

implementation

uses Vcl.ComCtrls,CommCtrl ;

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FListView := TListViewEx.Create(Self);
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
  Column.Caption := '��1';
  Column.Width := 80;
  Column :=  FListView.Columns.Add;
  Column.Caption := '��2';
  Column.Width := 80;
  FListView.ColumnAlign(1);
  for i := 0 to 15 do begin
    Item := FListView.Items.Add;
    Item.Caption := '�s'+IntToStr(i+1);
    Item.SubItems.Add('�f�[�^'+IntToStr(i+1));
  end;

end;

procedure TFormMain.Button1Click(Sender: TObject);
var
  i : Integer;
begin
  i := FListView.ItemIndex;
  if i <= 0 then exit;
  FListView.Exchange(i,i-1);
  FListView.ItemIndex := i - 1;
end;

procedure TFormMain.Button2Click(Sender: TObject);
var
  i : Integer;
begin
  i := FListView.ItemIndex;
  if i = -1 then exit;
  if i >= FListView.Items.Count-1 then exit;
  FListView.Exchange(i,i+1);
  FListView.ItemIndex := i + 1;
end;

procedure TFormMain.Button3Click(Sender: TObject);
begin
  FListView.ItemIndex := 0;
  FListView.TopIndex := FListView.ItemIndex;
end;

procedure TFormMain.Button4Click(Sender: TObject);
begin
  FListView.ItemIndex := FListView.Items.Count-1;
  FListView.TopIndex := FListView.ItemIndex;
end;

procedure TFormMain.Button5Click(Sender: TObject);
var
  i : Integer;
  Item : TListItem;
begin
  i := FListView.ItemIndex;
  if i = -1 then i := 0;
  Item := FListView.Insert(i);
  Item.Caption := '�ǉ������v�f';
  Item.SubItems.Add('�ǉ������f�[�^');
end;



end.
