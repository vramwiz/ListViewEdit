unit MainListViewRTTI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls, Vcl.ExtCtrls,ListViewRTTI;

type
  TPersistentData = class(TPersistent)
  private
    { Private 宣言 }
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
    { Public 宣言 }

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
    { Private 宣言 }
    FListView : TListViewRTTI;
    FData     : TPersistentData;
    procedure ShowData();
    procedure InitData();
  public
    { Public 宣言 }
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

// データ初期化
procedure TFormMain.InitData;
begin
  FData.Enabled  := True;
  FData.Level    := 1;
  FData.Text     := 'こんにちは世界';
  FData.NoEdit   := '編集不可の例';
  FData.NoView   := '非表示対象の例';
  FData.FontName := 'Segoe UI';

  FData.Filename := ParamStr(0);
  FData.Folder   := ExtractFilePath(FData.Filename);

  FData.Color    := clSkyBlue;
end;

// データの表示と編集開始
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

// ここから下は追加機能　最小限の実装には不要

procedure TFormMain.Button1Click(Sender: TObject);
begin
   FListView.RTTINames['Enabled'].Caption := '有効';
   FListView.RTTINames['Enabled'].Hint := '有効かどうか？';
   FListView.RTTINames['Level'].Caption := 'レベル';
   FListView.RTTINames['NoEdit'].Caption := '編集不可';
   FListView.RTTINames['Text'].Caption := 'テキスト';
   FListView.RTTINames['Color'].Caption := '色';
   FListView.RTTINames['FontName'].Caption := 'フォント';
   FListView.RTTINames['Filename'].Caption := 'ファイル名';
   FListView.RTTINames['Folder'].Caption := 'フォルダ名';
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
  FListView.RTTINames['Enabled'].Strings.Add('いいえ');
  FListView.RTTINames['Enabled'].Strings.Add('はい');
  FListView.RTTINames['Level'].EditType := ListViewEditPluginComboBoxId;
  FListView.RTTINames['Level'].Strings.Clear;
  FListView.RTTINames['Level'].Strings.Add('弱');
  FListView.RTTINames['Level'].Strings.Add('中');
  FListView.RTTINames['Level'].Strings.Add('強');
  FListView.Refresh;

end;

end.
