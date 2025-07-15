unit ListViewEditPluginDialogFolder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,Vcl.ExtCtrls,
  ShellApi,ShlObj,CommCtrl,System.Win.ComObj,Types,IOUtils,  Winapi.ActiveX,
  ListViewEditPluginDialog,ListViewRTTIList;

//--------------------------------------------------------------------------//
//  �t�H���_�I���_�C�A���O��\������ҏW�v���O�C��                          //
//--------------------------------------------------------------------------//
type
  TListViewEditPluginFolder = class(TPersistent)
  private
    { Private �錾 }
    FName        : string;
    //FPath        : string;
    FIndexIcon   : Integer;
    FIndexSelect : Integer;
    FIsChild     : Boolean;
    FPIDListFull : PItemIDList;
  public
    { Public �錾 }
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
//  �t�H���_��񃊃X�g���Ǘ�����N���X                                      //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginFolderList = class(TList)
	private
		{ Private �錾 }
    function GetItems(Index: Integer): TListViewEditPluginFolder;
	public
		{ Public �錾 }
    function Add() : TListViewEditPluginFolder;
    destructor Destroy;override;
    procedure Delete(i : Integer);
    procedure Clear();override;

    function GetFolder(Handle : THandle ; pList   : PItemIDList;FFlags : Cardinal) : Boolean;

		property Items[Index: Integer] : TListViewEditPluginFolder read GetItems ;default;

	end;

//--------------------------------------------------------------------------//
//  �t�H���_�I���_�C�A���O                                                  //
//--------------------------------------------------------------------------//
type
  TFormListViewEditPluginFolder = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    procedure Panel1Resize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private �錾 }
    FFlags         : Cardinal;
    FTreeDir       : TTreeView;                 // �t�H���_�\��TreeView
    FHWDIamge      : THandle;                   // TreeView�Ɏg�p����摜�C���[�W�n���h��
    FClickDisabled : Boolean;                   // True:�c���[�W�J�^���钆�̓N���b�N�𖳌�
    FFolder        : string;                    // �J�[�\�������킹��t�H���_

    FOnClick   : TNotifyEvent;

    function GetFolderDesktop() : PItemIDList;

    function NodeExpand(Node : TTreeNode) : Boolean;

    function IndexOfFolderName(tns : TTreeNodes;const aFolderName : string) : Integer;
    function TreeNodetoPath(tn : TTreeNode) : string;
    // �����Ɂu\�v���Ȃ���΁u\�v��ǉ�
    function FolderNameLastMark(const aFolder : string) : string;

    procedure NodeSet(aNode : TTreeNode;d : TListViewEditPluginFolder);

    procedure OnTreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure OnTreeDeletion(Sender: TObject; Node: TTreeNode);
    procedure OnTreeClick(Sender: TObject);

    function GetFolder: string;
    // �w�肵���t�H���_�p�X�ɊY������c���[��W�J���đI����Ԃɂ���
    procedure SetFolder(const Value: string);
    // �t�H���_�����̍ċA�@����
    procedure SetFolderSub(const aPath : string;tnn : TTreeNode;sd : TStringDynArray;aLevel : Integer);
  protected
    procedure DoClick();
  public
    { Public �錾 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;

    function Execute() : Boolean;
    property Flags : Cardinal read FFlags write FFlags;
    property Folder : string read GetFolder write FFolder;

    property OnClick  : TNotifyEvent  read FOnClick write FOnClick;
  end;


//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� FolderOpenDialog                                         //
//--------------------------------------------------------------------------//
type
	TListViewEditFolderDlg2 = class(TListViewEditPluginDialog)
	private
		{ Private �錾 }
    FForm : TFormListViewEditPluginFolder;
  protected
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();override;
	public
		{ Public �錾 }
    constructor Create(); override;
    destructor Destroy;override;

    property Form : TFormListViewEditPluginFolder read FForm;
  end;


var
  ListViewEditFolderDialog2   : TListViewEditFolderDlg2;    // TOpenDialog�ҏW�v���O�C��
  ListViewEditFolderDialogId2  : Integer;                       // TOpenDialog�ҏW�v���O�C��ID


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
  DoEdited(aFolder);                         // �ҏW�����C�x���g����
  FFrame.Visible := False;                        // ��\��
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

// �t�H���_�\����\��
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
  SendMessage(FTreeDir.Handle,TV_FIRST+27,22,0); // ���X�g�s�̍������w��
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
    aFolders.GetFolder(Handle,nil,FFlags);                    // �f�X�N�g�b�v���̃t�H���_���擾

    for i := 0 to aFolders.Count-1 do begin               // �擾�����t�H���_�����[�v
      d := aFolders[i];                                   // �t�H���_�f�[�^���Q��
      n := FTreeDir.Items.AddChildObject(nil,d.FName,nil); // �f�X�N�g�b�v���Ƀc���[��ǉ�
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
  SendMessage(FTreeDir.Handle,TV_FIRST+27,22,0); // ���X�g�s�̍������w��
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
    aFolders.GetFolder(Handle,nil,FFlags);                    // �f�X�N�g�b�v���̃t�H���_���擾

    for i := 0 to aFolders.Count-1 do begin               // �擾�����t�H���_�����[�v
      d := aFolders[i];                                   // �t�H���_�f�[�^���Q��
      n := FTreeDir.Items.AddChildObject(nil,d.FName,nil); // �f�X�N�g�b�v���Ƀc���[��ǉ�
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

// �f�X�N�g�b�v�̃t�@�C������ID���X�g�̃|�C���^���擾
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

    for i := 0 to aFolders.Count-1 do begin               // �擾�����t�H���_�����[�v
      d := aFolders[i];                                   // �t�H���_�f�[�^���Q��
      n2 := FTreeDir.Items.AddChildObject(Node,d.FName,nil); // �f�X�N�g�b�v���Ƀc���[��ǉ�
      NodeSet(n2,d);
      if i mod 10 = 0 then begin                                  // �\���A�C�R�����Z�b�g
        Application.ProcessMessages;
      end;
    end;
    result := True;
  finally
    FTreeDir.Items.EndUpdate();
    aFolders.Free;
  end;
end;

// �c���[�\���ɕK�v�Ȑݒ�����s
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

// �c���[��������̃C�x���g
procedure TFormListViewEditPluginFolder.OnTreeDeletion(Sender: TObject; Node: TTreeNode);
begin
  FClickDisabled := True;
  if Node <> nil then CoTaskMemFree(Node.Data);
  Node.Data := nil;
end;

// �c���[��W�J�������̃C�x���g
procedure TFormListViewEditPluginFolder.OnTreeExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  FClickDisabled := True;
  //if Node.Level = 0 then exit;                          // ���[�g�t�H���_�͏������Ȃ�
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
    sf := FolderNameLastMark(Value);                // �����Ɂu\�v���Ȃ���Βǉ�

    sd := SplitString(sf,'\');                      // �u\�v�ŕ���
    //cnt := High(sd) + 1;                            // �w��p�X�����K�w���擾
    //s := '';
    tns := FTreeDir.Items;                          // �eTreeNodes���Q��
    i := IndexOfFolderName(tns,sd[0]+'\');          // �eTreeNodes�̉��ԂɈ�v����h���C�u�������邩
    if i = -1 then exit;                            // �Ȃ���Ώ������Ȃ�
    tn := tns[i];                                   // �Y��Node���Q��
    SetFolderSub(Value,tn,sd,1);                    // �ċA�@��Node���̊K�w��T��

    tn := FTreeDir.Selected;
    if tn<>nil then begin
      FTreeDir.TopItem := tn;
    end;

    FTreeDir.SetFocus;                              // �t�H�[�J�X���~�������Ȃ��������Ȃ�

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
  if aLevel > High(sd) then begin            // �����K�w���w��t�H���_�K�w�𒴂���Ƃ�
    FTreeDir.Selected := tnn;                // ��������Node��I����Ԃ�
    exit;                                    // �����I��
  end;

  sPath := '';                               // ����Path��������
  for j := 0 to aLevel do begin              // ���݂̊K�w���ɊY������Path���쐬
    if sd[j]= '' then begin                  // ����ȏ�Path�������ꍇ
      FTreeDir.Selected := tnn;              // ��������Node��I����Ԃ�
      exit;                                  // �����I��
    end;
    sPath := sPath + sd[j] + '\';            // ����Path�ɒǉ�
  end;

  tnn.Expand(False);                             // ��������Node��W�J���Ă���
  for j := 0 to tnn.Count-1 do begin             // �q�m�[�h�������[�v
    tn := tnn[j];                                // �q�m�[�h�Q��
    s := TreeNodetoPath(tn);                     // �m�[�h����Path���擾
    if CompareText(s,sPath) <> 0 then continue;  // ��v���Ȃ��ꍇ�͎��̃��[�v��
    SetFolderSub(aPath,tn,sd,aLevel+1);          // ���̃m�[�h�̎q�m�[�h����������
    break;                                       // ��x�K�w�ɓ����ďo�Ă��������͏I��������
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

// �t�H���_�����擾�����X�g�ɔ��f
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

  SHGetDesktopFolder(sf);                        // �f�X�N�g�b�v�̃��[�g�t�H���_���擾
  if pList = nil then begin                      // �f�X�N�g�b�v�̃t�H���_���̏ꍇ
    sf2 := IShellFolder2(sf);                    // �f�X�N�g�b�v�t�H���_���𔽉f
    pListC := nil;                               // ���[�g�t�H���_���� nil
  end
  else begin                                     // �f�X�N�g�b�v�ȊO�̃t�H���_���̏ꍇ
    pListC := ILClone(pList);                    // ���[�g�t�H���_�Ƃ��ăR�s�[
    if sf.BindToObject(pListC, nil,
                      IShellFolder,Pointer(sf2)) <> S_OK then begin // �擾���s�̏ꍇ
      if sf2 <> nil then sf2 := nil;                                // �m�ۂ��������������
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
    sf2.GetAttributesOf(1, pList2, f);                    // �t�H���_�̑������擾
    if (SFGAO_HASSUBFOLDER and f) <> 0 then begin         // ���̉��Ƀt�H���_������ꍇ
      d.FIsChild := True;                                 // �t�H���_���݃t���O���Z�b�g
    end;

  end;
  result := True;
end;

function TListViewEditPluginFolderList.GetItems(Index: Integer): TListViewEditPluginFolder;
begin
  result := inherited Items[Index];
end;


{ TExplorerVFolderItem }

// �t�@�C������ID���X�g����t�@�C���̏����擾
// pList : �t�H���_���[�v���̃t�H���_��������ID�|�C���^
// pListEx : ���[�g��nil �e�t�H���_������ID�|�C���^
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
    FPIDListFull := a.FPIDListFull;        // FPIDListFull�͉������Ȃ��̂Ń��X�g�������Ă�OK
  end
  else begin
    inherited;
  end;
end;

function TListViewEditPluginFolder.GetFileInfo(pList,pListEx: PItemIDList): Boolean;
  // �n���t�@�C�����̓t�@�C������ID���X�g�Ȃ̂� PIDL���w��
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

// �t�@�C���̃A�C�R���̃n���h�����擾
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

// �t�@�C���̃A�C�R���̃C���f�b�N�X�l���擾
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
