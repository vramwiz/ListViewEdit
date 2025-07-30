unit MainListViewEditPro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls, Vcl.ExtCtrls,ListViewEdit;

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private �錾 }
    FListView : TListViewEdit;
    procedure ShowListBox();
    procedure ShowData(const Mode : Integer);
  public
    { Public �錾 }
  end;

var
  FormMain: TFormMain;

implementation

uses Vcl.ComCtrls,CommCtrl,ListViewEditPluginLib;

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FListView := TListViewEdit.Create(Self);
  FListView.Parent := Self;
  FListView.Align := alClient;
  FListView.ViewStyle := vsReport;
  FListView.RowSelect := true;

  FListView.FixedStyle := fsVerticalFixedColumn;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FListView.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ShowListBox();
  ShowData(3);
end;

procedure TFormMain.ListBox1Click(Sender: TObject);
var
  i : Integer;
begin
  i := ListBox1.ItemIndex;
  if i = -1 then exit;

  FListView.FixedStyle := TListViewEditFixedStyle(i);
  ShowData(i);
end;

procedure TFormMain.ShowData(const Mode: Integer);
var
  Column : TListColumn;
  Item : TListItem;
  i : Integer;
begin
  FListView.Columns.Clear;
  FListView.Items.Clear;
  if Mode <> 2 then begin
    Column :=  FListView.Columns.Add;
    Column.Caption := '����';
    Column.Width := 80;
    Column :=  FListView.Columns.Add;
    Column.Caption := '�l';
    Column.Width := 80;
    FListView.ColumnAlign(1);

    Item := FListView.Items.Add;
    Item.Caption := 'Default';
    Item.SubItems.Add('�����l�̃f�[�^');

    Item := FListView.Items.Add;
    Item.Caption := 'ReadOnly';
    Item.SubItems.Add('�\����p�̃f�[�^');

    Item := FListView.Items.Add;
    Item.Caption := 'Bool';
    Item.SubItems.Add('1');

    Item := FListView.Items.Add;
    Item.Caption := 'Bool2';
    Item.SubItems.Add('1');

    Item := FListView.Items.Add;
    Item.Caption := 'Combo';
    Item.SubItems.Add('1');

    Item := FListView.Items.Add;
    Item.Caption := 'ComboObj';
    Item.SubItems.Add('4');

  end
  else begin
    Column :=  FListView.Columns.Add;
    Column.Caption := 'Default';
    Column.Width := 80;
    Column :=  FListView.Columns.Add;
    Column.Caption := 'ReadOnly';
    Column.Width := 80;
    Column :=  FListView.Columns.Add;
    Column.Caption := 'Bool';
    Column.Width := 80;
    Column :=  FListView.Columns.Add;
    Column.Caption := 'Bool2';
    Column.Width := 80;
    Column :=  FListView.Columns.Add;
    Column.Caption := 'Combo';
    Column.Width := 80;
    Column :=  FListView.Columns.Add;
    Column.Caption := 'ComboObj';
    Column.Width := 80;

    Item := FListView.Items.Add;
    Item.Caption := '�����l�̃f�[�^';
    Item.SubItems.Add('�\����p�̃f�[�^');
    Item.SubItems.Add('1');
    Item.SubItems.Add('1');
    Item.SubItems.Add('1');
    Item.SubItems.Add('4');
  end;

  // �ҏW�^�C�v�Ƃ��ĕ\����p���w��
  FListView.Settings[1].EditType := ListViewEditPluginReadOnlyId;

  // �ҏW�^�C�v�Ƃ��Đ^�U�^���w��
  FListView.Settings[2].EditType := ListViewEditPluginBoolId;

  // �ҏW�^�C�v�Ƃ��Đ^�U�^���w��
  FListView.Settings[3].EditType := ListViewEditPluginBoolId;
  // ComboBox�̑I�������w��
  FListView.Settings[3].Strings.Clear;
  FListView.Settings[3].Strings.Add('������');
  FListView.Settings[3].Strings.Add('�͂�');

  // �ҏW�^�C�v�Ƃ���ComboBox���w��
  FListView.Settings[4].EditType := ListViewEditPluginComboBoxId;
  // ComboBox�̑I�������w��
  FListView.Settings[4].Strings.Clear;
  FListView.Settings[4].Strings.Add('�Ȃ�');
  FListView.Settings[4].Strings.Add('����');
  FListView.Settings[4].Strings.Add('����');

  // �ҏW�^�C�v�Ƃ���ComboBox���w��  �g�p����l�� AddObject�̒l
  FListView.Settings[5].EditType := ListViewEditPluginComboBoxObjectId;
  // ComboBox�̑I�������w��
  FListView.Settings[5].Strings.Clear;
  FListView.Settings[5].Strings.AddObject('1x1',Pointer(1));
  FListView.Settings[5].Strings.AddObject('2x2',Pointer(4));
  FListView.Settings[5].Strings.AddObject('3x3',Pointer(9));
end;

procedure TFormMain.ShowListBox;
begin
  ListBox1.Clear;
  ListBox1.Items.Add('fsEditOnly');
  ListBox1.Items.Add('fsVertical');
  ListBox1.Items.Add('fsHorizontal');
  ListBox1.Items.Add('fsVerticalFixedColumn');
  ListBox1.ItemIndex := 3;
end;

end.
