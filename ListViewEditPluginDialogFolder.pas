unit ListViewEditPluginDialogFolder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,Vcl.ExtCtrls,
  ShellApi,ShlObj,CommCtrl,System.Win.ComObj,Types,IOUtils,  Winapi.ActiveX,
  ListViewEditPluginDialog,ListViewRTTIList;

//--------------------------------------------------------------------------//
//  フォルダ選択ダイアログを表示する編集プラグイン                          //
//--------------------------------------------------------------------------//
type
  TListViewEditPluginFolder = class(TPersistent)
  private
    { Private 宣言 }
    FName        : string;
    //FPath        : string;
    FIndexIcon   : Integer;
    FIndexSelect : Integer;
    FIsChild     : Boolean;
    FPIDListFull : PItemIDList;
  public
    { Public 宣言 }
    //constructor Create();
    //destructor Destroy;override;
    procedure Assign(Source : TPersistent);override;

    function GetFileInfo(pList,pListEx : PItemIDList) : Boolean;
    function GetImageIndex(p : PWideChar;Flags : Cardinal) : Integer;
    function GetImageIcon(pList: PItemIDList) : THandle;

    //procedure SetNode(n : TTreeNode);

    property Name : string read FName;
    property IndexIcon : Integer   read FIndexIcon;
    property IndexSelect : Integer read FIndexSelect;
    property PIDListFull : PItemIDList read FPIDListFull;
    property IsChild : Boolean read FIsChild;
  end;

//--------------------------------------------------------------------------//
//  フォルダ情報リストを管理するクラス                                      //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginFolderList = class(TList)
	private
		{ Private 宣言 }
    function GetItems(Index: Integer): TListViewEditPluginFolder;
	public
		{ Public 宣言 }
    function Add() : TListViewEditPluginFolder;
    destructor Destroy;override;
    procedure Delete(i : Integer);
    procedure Clear();override;

    function GetFolder(Handle : THandle ; pList   : PItemIDList;FFlags : Cardinal) : Boolean;

		property Items[Index: Integer] : TListViewEditPluginFolder read GetItems ;default;

	end;

//--------------------------------------------------------------------------//
//  フォルダ選択ダイアログ                                                  //
//--------------------------------------------------------------------------//
type
  TFormListViewEditPluginFolder = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    procedure Panel1Resize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private 宣言 }
    FFlags         : Cardinal;
    FTreeDir       : TTreeView;                 // フォルダ表示TreeView
    FHWDIamge      : THandle;                   // TreeViewに使用する画像イメージハンドル
    FClickDisabled : Boolean;                   // True:ツリー展開／閉じる中はクリックを無効
    FFolder        : string;                    // カーソルを合わせるフォルダ

    FOnClick   : TNotifyEvent;

    function GetFolderDesktop() : PItemIDList;

    function NodeExpand(Node : TTreeNode) : Boolean;

    function IndexOfFolderName(tns : TTreeNodes;const aFolderName : string) : Integer;
    function TreeNodetoPath(tn : TTreeNode) : string;
    // 末尾に「\」がなければ「\」を追加
    function FolderNameLastMark(const aFolder : string) : string;

    procedure NodeSet(aNode : TTreeNode;d : TListViewEditPluginFolder);

    procedure OnTreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure OnTreeDeletion(Sender: TObject; Node: TTreeNode);
    procedure OnTreeClick(Sender: TObject);

    function GetFolder: string;
    // 指定したフォルダパスに該当するツリーを展開して選択状態にする
    procedure SetFolder(const Value: string);
    // フォルダ検索の再帰法処理
    procedure SetFolderSub(const aPath : string;tnn : TTreeNode;sd : TStringDynArray;aLevel : Integer);
  protected
    procedure DoClick();
  public
    { Public 宣言 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;

    function Execute() : Boolean;
    property Flags : Cardinal read FFlags write FFlags;
    property Folder : string read GetFolder write FFolder;

    property OnClick  : TNotifyEvent  read FOnClick write FOnClick;
  end;


//--------------------------------------------------------------------------//
//  編集プラグイン FolderOpenDialog                                         //
//--------------------------------------------------------------------------//
type
	TListViewEditFolderDlg2 = class(TListViewEditPluginDialog)
	private
		{ Private 宣言 }
    FForm : TFormListViewEditPluginFolder;
  protected
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();override;
	public
		{ Public 宣言 }
    constructor Create(); override;
    destructor Destroy;override;

    property Form : TFormListViewEditPluginFolder read FForm;
  end;


var
  ListViewEditFolderDialog2   : TListViewEditFolderDlg2;    // TOpenDialog編集プラグイン
  ListViewEditFolderDialogId2  : Integer;                       // TOpenDialog編集プラグインID


implementation

uses System.StrUtils,ListViewEditPlugin;

const FLAG_IMAGE_ICON = SHGFI_PIDL or
                        SHGFI_SYSICONINDEX or
                        SHGFI_SMALLICON;

{$R *.dfm}

{ TListViewEditFolderDlg2 }

constructor TListViewEditFolderDlg2.Create;
begin
  inherited;
  FForm := TFormListViewEditPluginFolder.Create(nil);
end;

destructor TListViewEditFolderDlg2.Destroy;
begin
  //FForm.Free;
  inherited;
end;

procedure TListViewEditFolderDlg2.DoEditing(Parent: TWinControl;
  var Component: TWinControl;r: TRect;dr: TListViewRTTIItem);
begin
  inherited;
  FForm.Left := r.Left;
  FForm.Top  := r.Top;
end;

procedure TListViewEditFolderDlg2.DoOpenDialog;
var
  aFolder :string;
begin
  aFolder := FFrame.Rtti.Value;
  FForm.Folder := aFolder;
  if FForm.ShowModal() <> mrOk then exit;
  aFolder := FForm.Folder;
  DoEdited(aFolder);                         // 編集完了イベント発生
  FFrame.Visible := False;                        // 非表示
end;


{ TListViewEditFolder }


constructor TFormListViewEditPluginFolder.Create(AOwner: TComponent);
begin
  inherited;
  FFlags :=  SHCONTF_INCLUDEHIDDEN or SHCONTF_FOLDERS;

  FTreeDir := TTreeView.Create(Self);
  FTreeDir.Parent := Self;
  FTreeDir.Align := alClient;
  FTreeDir.HideSelection := False;
  FTreeDir.OnExpanding := OnTreeExpanding;
  FTreeDir.OnDeletion := OnTreeDeletion;
  FTreeDir.OnClick := OnTreeClick;
end;

destructor TFormListViewEditPluginFolder.Destroy;
begin
  FTreeDir.Free;
  inherited;
end;

// フォルダ構成を表示
function TFormListViewEditPluginFolder.Execute: Boolean;
var
  pList    : PItemIDList;
  d : TListViewEditPluginFolder;
  i: Integer;
  n : TTreeNode;
  h : THandle;
  aFolders : TListViewEditPluginFolderList;
begin
  FTreeDir.Items.BeginUpdate;
  FTreeDir.Items.Clear;
  //FTreeDir.Perform(TVM_SETITEMHEIGHT, 50, 0);
  SendMessage(FTreeDir.Handle,TV_FIRST+27,22,0); // リスト行の高さを指定
  pList := GetFolderDesktop();
  d := TListViewEditPluginFolder.Create;
  try
    FHWDIamge := d.GetImageIcon(pList);
    h := FTreeDir.Handle;
    TreeView_SetImageList(h, FHWDIamge, TVSIL_NORMAL);

    d.GetFileInfo(pList,nil);
  finally
    d.Free;
  end;

  aFolders := TListViewEditPluginFolderList.Create;
  try
    aFolders.GetFolder(Handle,nil,FFlags);                    // デスクトップ下のフォルダを取得

    for i := 0 to aFolders.Count-1 do begin               // 取得したフォルダ数ループ
      d := aFolders[i];                                   // フォルダデータを参照
      n := FTreeDir.Items.AddChildObject(nil,d.FName,nil); // デスクトップ下にツリーを追加
      NodeSet(n,d);
    end;
    FTreeDir.Items[0].Expand(False);
    result := True;
  finally
    aFolders.Free;
  end;
  FTreeDir.Items.EndUpdate;
  FClickDisabled := False;
end;

function TFormListViewEditPluginFolder.FolderNameLastMark(const aFolder: string): string;
var
  s : string;
begin
  result := aFolder;
  s := Copy(aFolder,Length(aFolder),1);

  if s <> '\' then begin
    result := aFolder + '\';
  end;

end;

procedure TFormListViewEditPluginFolder.FormShow(Sender: TObject);
var
  pList    : PItemIDList;
  d : TListViewEditPluginFolder;
  i: Integer;
  n : TTreeNode;
  h : THandle;
  aFolders : TListViewEditPluginFolderList;
begin
  FTreeDir.Items.BeginUpdate;
  FTreeDir.Items.Clear;
  //FTreeDir.Perform(TVM_SETITEMHEIGHT, 50, 0);
  SendMessage(FTreeDir.Handle,TV_FIRST+27,22,0); // リスト行の高さを指定
  pList := GetFolderDesktop();
  d := TListViewEditPluginFolder.Create;
  try
    FHWDIamge := d.GetImageIcon(pList);
    h := FTreeDir.Handle;
    TreeView_SetImageList(h, FHWDIamge, TVSIL_NORMAL);

    d.GetFileInfo(pList,nil);
  finally
    d.Free;
  end;

  aFolders := TListViewEditPluginFolderList.Create;
  try
    aFolders.GetFolder(Handle,nil,FFlags);                    // デスクトップ下のフォルダを取得

    for i := 0 to aFolders.Count-1 do begin               // 取得したフォルダ数ループ
      d := aFolders[i];                                   // フォルダデータを参照
      n := FTreeDir.Items.AddChildObject(nil,d.FName,nil); // デスクトップ下にツリーを追加
      NodeSet(n,d);
    end;
    FTreeDir.Items[0].Expand(False);
  finally
    aFolders.Free;
  end;
  FTreeDir.Items.EndUpdate;
  SetFolder(FFolder);
  FClickDisabled := False;
end;

// デスクトップのファイル識別IDリストのポインタを取得
function TFormListViewEditPluginFolder.GetFolder: string;
var
  s : string;
  n : TTreeNode;
  pList    : PItemIDList;
  FolderPath: array[0..MAX_PATH] of Char;
begin
  n := FTreeDir.Selected;
  pList := PItemIDList(n.Data);
  SHGetPathFromIDList(pList, FolderPath);
  s := FolderPath;
  result := FolderNameLastMark(s);
end;

function TFormListViewEditPluginFolder.GetFolderDesktop: PItemIDList;
begin
  SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, result);
end;

function TFormListViewEditPluginFolder.IndexOfFolderName(tns : TTreeNodes;const aFolderName: string): Integer;
var
  i: Integer;
  tn : TTreeNode;
  aPath : string;
begin
  result := -1;
  for i := 0 to tns.Count-1 do begin
    tn := tns[i];
    aPath := TreeNodetoPath(tn);

    if CompareText(aPath,aFolderName) = 0 then begin
    //if aPath = aFolderName then begin
      result := i;
      exit;
    end;
  end;

end;

function TFormListViewEditPluginFolder.TreeNodetoPath(tn: TTreeNode): string;
var
  p : PItemIDList;
  sTbl: array[0..MAX_PATH] of WideChar;
  str : string;
begin
  p := PItemIDList(tn.Data);
  SHGetPathFromIDList(p,sTbl);
  str := sTbl;
  result := FolderNameLastMark(str);
end;


function TFormListViewEditPluginFolder.NodeExpand(Node: TTreeNode): Boolean;
var
  p : PItemIDList;
  i : Integer;
  n2 : TTreeNode;
  d : TListViewEditPluginFolder;
  aFolders : TListViewEditPluginFolderList;
begin
  aFolders := TListViewEditPluginFolderList.Create;
  FTreeDir.Items.BeginUpdate();
  try
    p := PItemIDList(Node.Data);
    aFolders.GetFolder(Handle,p,FFlags);

    for i := 0 to aFolders.Count-1 do begin               // 取得したフォルダ数ループ
      d := aFolders[i];                                   // フォルダデータを参照
      n2 := FTreeDir.Items.AddChildObject(Node,d.FName,nil); // デスクトップ下にツリーを追加
      NodeSet(n2,d);
      if i mod 10 = 0 then begin                                  // 表示アイコンをセット
        Application.ProcessMessages;
      end;
    end;
    result := True;
  finally
    FTreeDir.Items.EndUpdate();
    aFolders.Free;
  end;
end;

// ツリー表示に必要な設定を実行
procedure TFormListViewEditPluginFolder.NodeSet(aNode: TTreeNode; d: TListViewEditPluginFolder);
begin
  aNode.ImageIndex    := d.FIndexIcon;
  aNode.SelectedIndex := d.FIndexSelect;
  aNode.HasChildren   := d.FIsChild;
  aNode.Data          := d.FPIDListFull;
end;

procedure TFormListViewEditPluginFolder.OnTreeClick(Sender: TObject);
begin
  if FClickDisabled then begin
    FClickDisabled := False;
    exit;
  end;

  DoClick();
end;

// ツリーを閉じた時のイベント
procedure TFormListViewEditPluginFolder.OnTreeDeletion(Sender: TObject; Node: TTreeNode);
begin
  FClickDisabled := True;
  if Node <> nil then CoTaskMemFree(Node.Data);
  Node.Data := nil;
end;

// ツリーを展開した時のイベント
procedure TFormListViewEditPluginFolder.OnTreeExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  FClickDisabled := True;
  //if Node.Level = 0 then exit;                          // ルートフォルダは処理しない
  NodeExpand(Node);
end;


procedure TFormListViewEditPluginFolder.SetFolder(const Value: string);
var
  sd : TStringDynArray;
  i : Integer;
  sf : string;
  tns : TTreeNodes;
  tn : TTreeNode;
begin
  FTreeDir.Items.BeginUpdate;
  try
    sf := FolderNameLastMark(Value);                // 末尾に「\」がなければ追加

    sd := SplitString(sf,'\');                      // 「\」で分解
    //cnt := High(sd) + 1;                            // 指定パスが何階層か取得
    //s := '';
    tns := FTreeDir.Items;                          // 親TreeNodesを参照
    i := IndexOfFolderName(tns,sd[0]+'\');          // 親TreeNodesの何番に一致するドライブ名があるか
    if i = -1 then exit;                            // なければ処理しない
    tn := tns[i];                                   // 該当Nodeを参照
    SetFolderSub(Value,tn,sd,1);                    // 再帰法でNode内の階層を探す

    tn := FTreeDir.Selected;
    if tn<>nil then begin
      FTreeDir.TopItem := tn;
    end;

    FTreeDir.SetFocus;                              // フォーカスが欲しいがなぜか得られない

  finally
    FTreeDir.Items.EndUpdate;
  end;
end;


procedure TFormListViewEditPluginFolder.SetFolderSub(const aPath: string; tnn: TTreeNode;
  sd: TStringDynArray; aLevel: Integer);
var
  j : Integer;
  tn : TTreeNode;
  s,sPath : string;
begin
  Application.ProcessMessages;
  if aLevel > High(sd) then begin            // 処理階層が指定フォルダ階層を超えるとき
    FTreeDir.Selected := tnn;                // 処理中のNodeを選択状態に
    exit;                                    // 処理終了
  end;

  sPath := '';                               // 検索Pathを初期化
  for j := 0 to aLevel do begin              // 現在の階層数に該当するPathを作成
    if sd[j]= '' then begin                  // それ以上Pathが無い場合
      FTreeDir.Selected := tnn;              // 処理中のNodeを選択状態に
      exit;                                  // 処理終了
    end;
    sPath := sPath + sd[j] + '\';            // 検索Pathに追加
  end;

  tnn.Expand(False);                             // 処理するNodeを展開しておく
  for j := 0 to tnn.Count-1 do begin             // 子ノード数分ループ
    tn := tnn[j];                                // 子ノード参照
    s := TreeNodetoPath(tn);                     // ノードからPathを取得
    if CompareText(s,sPath) <> 0 then continue;  // 一致しない場合は次のループへ
    SetFolderSub(aPath,tn,sd,aLevel+1);          // そのノードの子ノードを処理する
    break;                                       // 一度階層に入って出てきた処理は終了させる
  end;

end;

procedure TFormListViewEditPluginFolder.Panel1Resize(Sender: TObject);
begin
  btnOk.Width := ClientWidth div 2;
end;


procedure TFormListViewEditPluginFolder.DoClick;
begin
  if Assigned(FOnClick) then begin
    FOnClick(Self);
  end;
end;


{ TListViewEditPluginFolderItems }

destructor TListViewEditPluginFolderList.Destroy;
begin
  Clear();
  inherited;
end;

function TListViewEditPluginFolderList.Add: TListViewEditPluginFolder;
var
  d : TListViewEditPluginFolder;
begin
  d := TListViewEditPluginFolder.Create;
  inherited Add(d);
  result := d;
end;

procedure TListViewEditPluginFolderList.Clear;
var
  i : Integer;
begin
  for i := 0 to Count-1 do begin
    Items[i].Free;
  end;

  inherited;
end;

procedure TListViewEditPluginFolderList.Delete(i: Integer);
begin
  Items[i].Free;
  inherited;
end;

// フォルダ情報を取得しリストに反映
function TListViewEditPluginFolderList.GetFolder(Handle : THandle ; pList    : PItemIDList;FFlags : Cardinal): Boolean;
var
  pList2,pListC    : PItemIDList;
  Fetched      : Cardinal;
  d : TListViewEditPluginFolder;
  sf  : IShellFolder;
  sf2 : IShellFolder2;
  eList  : IEnumIDList;
  f : Cardinal;
begin
  result := False;

  SHGetDesktopFolder(sf);                        // デスクトップのルートフォルダを取得
  if pList = nil then begin                      // デスクトップのフォルダ情報の場合
    sf2 := IShellFolder2(sf);                    // デスクトップフォルダ情報を反映
    pListC := nil;                               // ルートフォルダ情報は nil
  end
  else begin                                     // デスクトップ以外のフォルダ情報の場合
    pListC := ILClone(pList);                    // ルートフォルダとしてコピー
    if sf.BindToObject(pListC, nil,
                      IShellFolder,Pointer(sf2)) <> S_OK then begin // 取得失敗の場合
      if sf2 <> nil then sf2 := nil;                                // 確保したメモリを解放
      if pListC   <> nil then CoTaskMemFree(pListC);
      exit;
    end;
  end;

  Clear;
  if (sf2.EnumObjects(Handle,FFlags, eList)) <> S_OK then exit;

  while (eList.Next(1, pList2, Fetched) = S_OK) do begin
    d := Add();
    d.GetFileInfo(pList2,pListC);
    f := SFGAO_HASSUBFOLDER;
    sf2.GetAttributesOf(1, pList2, f);                    // フォルダの属性を取得
    if (SFGAO_HASSUBFOLDER and f) <> 0 then begin         // その下にフォルダがある場合
      d.FIsChild := True;                                 // フォルダ存在フラグをセット
    end;

  end;
  result := True;
end;

function TListViewEditPluginFolderList.GetItems(Index: Integer): TListViewEditPluginFolder;
begin
  result := inherited Items[Index];
end;


{ TExplorerVFolderItem }

// ファイル識別IDリストからファイルの情報を取得
// pList : フォルダループ内のフォルダ情報を示すIDポインタ
// pListEx : ルートはnil 親フォルダを示すIDポインタ
procedure TListViewEditPluginFolder.Assign(Source: TPersistent);
var
  a : TListViewEditPluginFolder;
begin
  if Source is TListViewEditPluginFolder then begin
    a := TListViewEditPluginFolder(Source);
    FName    :=  a.FName;
    //FPath    :=  a.FPath;

    FIndexIcon   := a.FIndexIcon;
    FIndexSelect := a.FIndexSelect;
    FIsChild     := a.FIsChild;
    FPIDListFull := a.FPIDListFull;        // FPIDListFullは解放されないのでリストが消えてもOK
  end
  else begin
    inherited;
  end;
end;

function TListViewEditPluginFolder.GetFileInfo(pList,pListEx: PItemIDList): Boolean;
  // 渡すファイル名はファイル識別IDリストなので PIDLを指定
const
  FLAG_DISPLAYNAME = SHGFI_DISPLAYNAME or SHGFI_PIDL;
  FLAG_ICON = SHGFI_PIDL or SHGFI_SYSICONINDEX;
  FLAG_ICON_SELECT = SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_OPENICON;
var
  pList2 : PItemIDList;
  aInfo   : TSHFileInfo;
  p : PWideChar;
begin
  pList2 := ILCombine(pListEx, pList);
  FPIDListFull := pList2;

  p := Pointer(pList2);
  FillChar(aInfo, SizeOf(SHFileInfo), #0);
  SHGetFileInfo(p,0, aInfo,SizeOf(aInfo), FLAG_DISPLAYNAME);
  FName := aInfo.szDisplayName;
  FIndexIcon := GetImageIndex(p, FLAG_ICON);
  FIndexSelect := GetImageIndex(p, FLAG_ICON_SELECT);
  result := True;
end;

// ファイルのアイコンのハンドルを取得
function TListViewEditPluginFolder.GetImageIcon(pList: PItemIDList): THandle;
const
  FLAG = SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_SMALLICON;
var
  aInfo   : TSHFileInfo;
  p : PWideChar;
begin
  FillChar(aInfo, SizeOf(aInfo), #0);
  p := Pointer(pList);
  result := SHGetFileInfo(p,0,aInfo,SizeOf(aInfo),FLAG);
end;

// ファイルのアイコンのインデックス値を取得
function TListViewEditPluginFolder.GetImageIndex(p: PWideChar;Flags : Cardinal): Integer;
var
  aInfo   : TSHFileInfo;
begin
  FillChar(aInfo, SizeOf(SHFileInfo), #0);
  SHGetFileInfo(p,0,aInfo,SizeOf(aInfo),Flags);
  result := aInfo.iIcon;
end;

initialization

  ListViewEditFolderDialog2 := TListViewEditFolderDlg2.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditFolderDialog2,ListViewEditFolderDialogId2);

end.
