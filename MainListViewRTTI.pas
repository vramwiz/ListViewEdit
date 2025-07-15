unit MainListViewRTTI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls, Vcl.ExtCtrls,ListViewRTTI;

type
  TPersistentData = class(TPersistent)
  private
    { Private �錾 }
    FEnabled           : Boolean;
    FLevel             : Integer;
    FFilename          : string;
    FNoEdit            : string;
    FNoView            : string;
    FText              : string;
    FColor             : TColor;
    FFontName          : string;
    FFolder            : string;
  public
    { Public �錾 }

 published
    property Enabled  : Boolean read FEnabled  write FEnabled;
    property Level    : Integer read FLevel    write FLevel;
    property NoEdit   : string  read FNoEdit   write FNoEdit;
    property NoView   : string  read FNoView   write FNoView;
    property Text     : string  read FText     write FText;
    property FontName : string  read FFontName write FFontName;
    property Filename : string  read FFilename write FFilename;
    property Folder   : string  read FFolder   write FFolder;
    property Color    : TColor  read FColor    write FColor;
  end;

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private �錾 }
    FListView : TListViewRTTI;
    FData     : TPersistentData;
    procedure ShowData();
    procedure InitData();
  public
    { Public �錾 }
  end;

var
  FormMain: TFormMain;

implementation

uses Vcl.ComCtrls,CommCtrl,ListViewEditPluginLib,ListViewEditPluginDialog,ListViewEditPluginDialogFolder;

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FData := TPersistentData.Create;
  FListView := TListViewRTTI.Create(Self);
  FListView.Parent := Self;
  FListView.Align := alClient;

  InitData();
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FListView.Free;
  FData.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ShowData;
end;

// �f�[�^������
procedure TFormMain.InitData;
begin
  FData.Enabled  := True;
  FData.Level    := 1;
  FData.Text     := '����ɂ��͐��E';
  FData.NoEdit   := '�ҏW�s�̗�';
  FData.NoView   := '��\���Ώۂ̗�';
  FData.FontName := 'Segoe UI';

  FData.Filename := ParamStr(0);
  FData.Folder   := ExtractFilePath(FData.Filename);

  FData.Color    := clSkyBlue;
end;

// �f�[�^�̕\���ƕҏW�J�n
procedure TFormMain.ShowData();
begin
  FListView.RTTINames['NoView'].EditType := ListViewEditPluginHideId;
  FListView.RTTINames['NoEdit'].EditType := ListViewEditPluginReadOnlyId;
  FListView.RTTINames['Filename'].EditType := ListViewEditPluginOpenDialogId;
  FListView.RTTINames['Folder'].EditType := ListViewEditFolderDialogId2;
  FListView.RTTINames['Color'].EditType := ListViewEditPluginColorDialogId;
  FListView.RTTINames['FontName'].EditType := ListViewEditPluginFontDialogId;

  FListView.LoadFromObject(FData);
end;

// �������牺�͒ǉ��@�\�@�ŏ����̎����ɂ͕s�v

procedure TFormMain.Button1Click(Sender: TObject);
begin
   FListView.RTTINames['Enabled'].Caption := '�L��';
   FListView.RTTINames['Enabled'].Hint := '�L�����ǂ����H';
   FListView.RTTINames['Level'].Caption := '���x��';
   FListView.RTTINames['NoEdit'].Caption := '�ҏW�s��';
   FListView.RTTINames['Text'].Caption := '�e�L�X�g';
   FListView.RTTINames['Color'].Caption := '�F';
   FListView.RTTINames['FontName'].Caption := '�t�H���g';
   FListView.RTTINames['Filename'].Caption := '�t�@�C����';
   FListView.RTTINames['Folder'].Caption := '�t�H���_��';
   FListView.Refresh;
end;

procedure TFormMain.Button2Click(Sender: TObject);
begin
  FListView.RTTINames['Enabled'].ColorFont   := clBlack;
  FListView.RTTINames['Enabled'].ColorBack   := clMoneyGreen;

  FListView.RTTINames['Level'].ColorFont     := clWhite;
  FListView.RTTINames['Level'].ColorBack     := clNavy;

  FListView.RTTINames['NoEdit'].ColorFont    := clBlack;
  FListView.RTTINames['NoEdit'].ColorBack    := clSkyBlue;

  FListView.RTTINames['Text'].ColorFont      := clWhite;
  FListView.RTTINames['Text'].ColorBack      := clWebPink;

  FListView.RTTINames['Color'].ColorFont     := clBlack;
  FListView.RTTINames['Color'].ColorBack     := clSkyBlue;

  FListView.RTTINames['FontName'].ColorFont  := clWhite;
  FListView.RTTINames['FontName'].ColorBack  := clTeal;

  FListView.RTTINames['Filename'].ColorFont  := clBlack;
  FListView.RTTINames['Filename'].ColorBack  := clYellow;

  FListView.RTTINames['Folder'].ColorFont    := clBlack;
  FListView.RTTINames['Folder'].ColorBack    := clGray;

  FListView.Refresh;
end;



procedure TFormMain.Button3Click(Sender: TObject);
begin
  FListView.RTTINames['Enabled'].Strings.Clear;
  FListView.RTTINames['Enabled'].Strings.Add('������');
  FListView.RTTINames['Enabled'].Strings.Add('�͂�');
  FListView.RTTINames['Level'].EditType := ListViewEditPluginComboBoxId;
  FListView.RTTINames['Level'].Strings.Clear;
  FListView.RTTINames['Level'].Strings.Add('��');
  FListView.RTTINames['Level'].Strings.Add('��');
  FListView.RTTINames['Level'].Strings.Add('��');
  FListView.Refresh;

end;

end.
