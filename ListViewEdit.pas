unit ListViewEdit;
{
  ListViewEdit.pas
  ---------------------------------------------------------------------------
  �Z���ҏW�@�\�t�� ListView �R���|�[�l���g TListViewEdit ���`���郆�j�b�g�B

  �{�N���X�� TListViewEx ���p�����AListView �̊e�Z���ɑ΂���
  �ҏW�����񋟂���@�\��ǉ����Ă��܂��B
  �ҏW�ɂ͓����I�� TEdit ���g�p���A�ҏW�J�n�^�I�����ɂ̓C�x���g�����
  ���[�U�[���ɕ�����E�s�E��C���f�b�N�X��ʒm���܂��B

  ��ȋ@�\�F
    - �Z���P�ʂł̕ҏW�C���^�[�t�F�[�X�̒ǉ��iFEditIndex / FEditColumn�j
    - �ҏW���̃X�^�C������iTListViewEditFixedStyle�j
        �EfsEditOnly               : �ҏW�Ώۂ̓Z���̂�
        �EfsVertical               : �s�����ɌŒ�
        �EfsHorizontal             : ������ɌŒ�
        �EfsVerticalFixedColumn    : ������ҏW�s��
    - �ҏW�m��^�ύX���C�x���g�̒ʒm�iFOnChange / FOnChanging�j
    - �ҏW�ΏۃZ���̌��o�A�ҏW�ʒu�̕␳�A�I�[�i�[�h���[�x��

  �ҏW�����̔��΂�ҏW�̈�̒����A�Œ��^�Z���̐���ȂǁA
  ���p�I�ȃO���b�h�ҏW�ɋ߂����쐫�� ListView �Ŏ������邱�Ƃ�ړI�Ƃ��Ă��܂��B
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,Vcl.ExtCtrls,
  ShellApi,ShlObj,CommCtrl,Menus, ListViewEx,ListViewRTTIList,ListViewEditPlugin;


type
  TListViewEditFixedStyle = (
    fsEditOnly,             // �@ �ҏW�̂݁i���X�g�����Ȃ��j
    fsVertical,             // �A �c���X�g�iListView�W���j
    fsHorizontal,           // �B �����X�g�i�\�v�Z�I�ȉ��ړ��j
    fsVerticalFixedColumn   // �C �c���X�g�{�Œ��i1��ڂ��Œ�j
  );

type TListViewEditChange = procedure(Sender : TObject;const EditStr : string;const aColumn,aIndex : Integer) of object;
type TListViewEditChanging = procedure(Sender : TObject;var EditStr : string;const aColumn,aIndex : Integer) of object;

//--------------------------------------------------------------------------//
//  �g��TListView�N���X ����v�f�ҏW�@�\��ǉ�                              //
//--------------------------------------------------------------------------//
type
  TListViewEdit = class(TListViewEx)
  private
    { Private �錾 }

    FEditIndex   : Integer;                        // �ҏW���̍s
    FEditColumn  : Integer;                        // �ҏW���̗�
    FProc        : TWndMethod;                     // �X�N���[����z�C�[��������󂯎��n���h��
    FFixedStyle  : TListViewEditFixedStyle;        // �Œ�s�Ȃǂ̃��C�A�E�g�ݒ�
    FOnChange    : TListViewEditChange;            //
    FOnChanging  : TListViewEditChanging;          //

    // �w�i�`��
    procedure DrawBack(cv : TCanvas;Item: TListItem;Rect: TRect; State: TOwnerDrawState);
    // �\�����̐擪�s�ʒu���擾
    function TopIndex() : Integer;
    function GetMouseClientPos: TPoint;
    function IsFixedCell(aCol,aRow : Integer) : Boolean;      // �w�肳�ꂽ��A�s���Œ�s�A�Œ��Ȃ̂�����
    // �ҏW�J�n���O�C�x���g�@��TListView�Ǝ��̃t�@�C�����ύX�C�x���g
    procedure OnSelfEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);

    // �}�E�X�J�[�\����̗���擾
    function GetColumn: Integer;

    function GetColumnRect(Index: Integer; out ALeft, ARight: Integer): Boolean;

    // �v���O�C������ҏW�����C�x���g���󂯎��
    procedure OnEditTypeEdited(Sender : TObject;const EditStr : string);
    // �v���O�C������ҏW�L�����Z���C�x���g���󂯎��
    procedure OnEditTypeEditCancel(Sender : TObject);
    function GetSettings(Index: Integer): TListViewRTTIItem;
    procedure SetFixedStyle(const Value: TListViewEditFixedStyle);
  protected
    FRowSettings    : TListViewRTTIItems;         // ���s���^��񃊃X�g
    FVisibleIndexes : TListViewEditRttiRows;      // ��\���s�̊��Z�N���X
    FPopMenu        : TPopupMenu;                 // �|�b�v���j���[���ꎞ�ۑ�
    FComponentEdit  : TWinControl;                // �ҏW�Ɏg�p���̃v���O�C��
    // �J�[�\���ʒu�̍s��Y���W�擾
    function GetEditTop() : Integer;
    // ���X�N���[���o�[�̌��݈ʒu���擾
    function GetScrollBarLeft() : Integer;
    // �Œ�s�@�\��̍������擾
    function GetListViewHeaderHeight(): Integer;
    // �E�C���h�E���b�Z�[�W���t�b�N
    procedure WMProc(var Msg:TMessage);
    procedure DoChanging(var EditStr : string;const aColumn,aIndex : Integer);virtual;
    // ���ʃN���X�Ƀf�[�^�ύX��ʒm
    procedure DoChange(const EditStr : string;const aColumn,aIndex : Integer);virtual;
    // �ҏW��������
    procedure EditChancel();
    // �J�[�\���ʒu�̕`��͈͂��擾
    function GetEditCellRect(AColumn, AIndex: Integer): TRect;
    // X���W�������擾
    function XToColumn(const X : Integer) : Integer;
    // �J�[�\���̗�ʒu���擾
    function GetColumAt(const X,Y : Integer) : Integer;
    // �w�肵���Z���ɑ΂���ҏW���@���擾
    function GetCellRTTI(aCol,aRow : Integer) : TListViewRTTIItem;
    // True : �l��ҏW��
    //property Edited : Boolean read FEdited;
    procedure KeyPress(var Key: Char); override;
    // �_�u���N���b�N�C�x���g
    procedure DblClick; override;
    // �}�E�X�ړ����ɌĂԏ��� �q���g�\���p
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DrawItem(Item: TListItem;Rect: TRect; State: TOwnerDrawState);override;
  public
    { Public �錾 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;

    // True :�ҏW�\�ŕҏW��Ԃֈڍs
    function EditBegin() : Boolean;virtual;
    // �w�肵�����ނ����[�ɂȂ�悤�ɃX�N���[���ʒu�𒲐�
    procedure ScrollToColumn(AColumn: Integer);
    // �\���͈͂Ɏ��܂��Ă��邩�m�F���ăX�N���[���ʒu�𒲐�
    procedure EnsureEditingColumnVisible(AColLeft, AColRight: Integer);
    // ���Ԗڂ̗�Ƀ}�E�X�J�[�\��������̂����擾
    property Column : Integer read GetColumn;
    property Settings[Index : Integer] : TListViewRTTIItem read GetSettings;
    // �Œ�s�Ȃǂ̃��C�A�E�g�ݒ�
    property FixedStyle: TListViewEditFixedStyle read FFixedStyle write SetFixedStyle;

    property OnChange : TListViewEditChange read FOnChange write fOnChange;
    property OnChanging : TListViewEditChanging read FOnChanging write FOnChanging;
  end;

implementation

uses ListViewEditPluginLib;


{ TListViewEx }

//--------------------------------------------------------------------------//
//  �N���X����                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEdit.Create(AOwner: TComponent);
begin
  inherited;
  FRowSettings    := TListViewRTTIItems.Create;
  FVisibleIndexes := TListViewEditRttiRows.Create;


  OnEditing := OnSelfEditing;
  OwnerDraw := True;

  FProc := WindowProc;
  WindowProc := WMProc;
end;

//--------------------------------------------------------------------------//
//  �N���X�j��                                                              //
//--------------------------------------------------------------------------//
procedure TListViewEdit.DblClick;
begin
  // ���N���X�����̃_�u���N���b�N�����i�ҏW�J�n�Ȃǁj
  EditBegin();                                      // �ҏW��Ԃֈڍs

  // ���[�U�[���ݒ肵���O���C�x���g���Ăԁi�p�����Ɠ��l�̓���j
  inherited;
end;

destructor TListViewEdit.Destroy;
begin
  FVisibleIndexes.Free;
  FRowSettings.Free;
  WindowProc := FProc;
  inherited;
end;

procedure TListViewEdit.DoChange(const EditStr: string; const aColumn,  aIndex: Integer);
begin
  if Assigned(FOnChange) then begin
    FOnChange(Self,EditStr,aColumn,aIndex);
  end;
end;

procedure TListViewEdit.DoChanging(var EditStr: string; const aColumn, aIndex: Integer);
begin
  if Assigned(FOnChanging) then begin
    FOnChanging(Self,EditStr,aColumn,aIndex);
  end;
end;

//--------------------------------------------------------------------------//
//  �v���O�C������̕ҏW�L�����Z���C�x���g                                  //
//--------------------------------------------------------------------------//
procedure TListViewEdit.OnEditTypeEditCancel(Sender: TObject);
begin
  EditChancel();
end;

//--------------------------------------------------------------------------//
//  �v���O�C������̕ҏW�����C�x���g                                        //
//--------------------------------------------------------------------------//
procedure TListViewEdit.OnEditTypeEdited(Sender: TObject;
  const EditStr: string);
begin
  Cells[FEditColumn,FEditIndex] := EditStr;           // �f�[�^�Ƃ��ĕۑ�
  DoChange(EditStr,FEditColumn,FEditIndex);           // ���ʃN���X�ɒʒm
  if FComponentEdit <> nil then begin                 // �ҏW���̃v���O�C��������ꍇ
    FComponentEdit.Visible := False;                  // �v���O�C�����\��
  end;
  PopupMenu := FPopMenu;                              // �|�b�v�A�b�v���j���[�����ɖ߂�
  //Self.SetFocus();                                    // ListView�Ƀt�H�[�J�X���ڂ�
  Refresh();                                          // �O�̂��ߍX�V
  //FEdited := False;                                   // �ҏW��Ԃ�����
end;

//--------------------------------------------------------------------------//
//  �t�H�[�J�X�����ȂǂŕҏW��Ԃ��L�����Z��                                //
//--------------------------------------------------------------------------//
procedure TListViewEdit.EditChancel;
begin
  if FComponentEdit <> nil then begin                 // �ҏW���̃v���O�C��������ꍇ
    FComponentEdit.Visible := False;                  // �v���O�C�����\��
  end;
  if FPopMenu<> nil then PopupMenu := FPopMenu;       // �|�b�v���j���[�𕜌�
  //Self.SetFocus();                                    // ListView�Ƀt�H�[�J�X���ڂ�
  //FEdited := False;                                   // �ҏW��Ԃ�����
end;


procedure TListViewEdit.EnsureEditingColumnVisible(AColLeft,  AColRight: Integer);
var
  ScrollLeft, AWidth: Integer;
begin
  //ScrollLeft  := Perform(LVM_GETORIGIN, 0, 0);
  ScrollLeft := GetScrollPos(Handle, SB_HORZ);
  AWidth := ClientWidth;

  // ListView�̃N���C�A���g�̈���ɗ񂪎��܂��Ă��邩�m�F
  if (AColLeft >= ScrollLeft) and (AColRight <= ScrollLeft + AWidth) then
    Exit; // �X�N���[���̕K�v�Ȃ�

  // �͂ݏo���Ă���̂ŃX�N���[���ʒu�𒲐�
  if AColLeft < ScrollLeft then
    Perform(LVM_SCROLL, -(ScrollLeft - AColLeft), 0) // ���ɃX�N���[���idx < 0�j
  else
    Perform(LVM_SCROLL, AColRight - (ScrollLeft + AWidth), 0); // �E�ɃX�N���[���idx > 0�j
end;

//--------------------------------------------------------------------------//
//  �ҏW��ԂɈڍs True:�ڍs���� False:�ڍs���s                             //
//--------------------------------------------------------------------------//
function TListViewEdit.EditBegin: Boolean;
var
  i,eType : Integer;
  ColLeft, ColRight: Integer;
  s : string;
  r : Trect;
  dr : TListViewRTTIItem;
begin
  result := False;
  FEditColumn := Column;                              // �}�E�X�ʒu�������擾
  FEditIndex := ItemIndex;
  if FEditColumn < 0 then exit;                       // �Œ�s�₻�̍��̏ꍇ�͔͈͊O�Ƃ���
  if (FFixedStyle = fsVerticalFixedColumn) and
     (FEditColumn = 0) then exit;                     // �������Œ��ݒ�ō���̏ꍇ�ҏW���Ȃ�

  // �J�����̕\���ʒu���擾�i�w�b�_�[��Rect�𗘗p�j
  if GetColumnRect(FEditColumn, ColLeft, ColRight) then
    EnsureEditingColumnVisible(ColLeft, ColRight);


  //if FEdited  then begin
    //if FEdit.Visible then EditOk();                 // �ҏW���̏ꍇ�A�ҏW���ʂ�L���ɂ��Ă���ҏW
  //end;

  r := GetEditCellRect(FEditColumn,FEditIndex);

  i := ItemIndex;
  if i = -1 then exit;

  s := Cells[FEditColumn,i];
  DoChanging(s,FEditColumn,FEditIndex);

  dr := GetCellRTTI(FEditColumn,i);
  dr.Value := s;
  dr.Data  := Items[i].Data;
  eType := dr.EditType;
  if eType = ListViewEditPluginReadOnlyId then exit;


  FPopMenu  := PopupMenu;                             // �|�b�v�A�b�v���j���[���ꎞ�Ҕ�
  Popupmenu := nil;                                   // �|�b�v�A�b�v���j���[�𖳌���

  ListViewEditPlugins.BeginEdit(Self,FComponentEdit,eType,r,dr,OnEditTypeEdited,OnEditTypeEditCancel);  // �ҏW�J�n
  //FEditTypes.Editing(Self,FComponentEdit,eType,r,dr);  // �ҏW�J�n
end;

//--------------------------------------------------------------------------//
//  X���W����Y���������擾                                               //
//--------------------------------------------------------------------------//
function TListViewEdit.XToColumn(const X: Integer): Integer;
var
  i,x1,x2: Integer;
begin
  result := -1;
  for i := 0 to Columns.Count-1 do begin
    x1 := ColumnLeft(i);
    x2 := ColumnRight(i);
    if x < x1 then continue;
    if x > x2 then continue;
    result := i;
    exit;
  end;
end;



function TListViewEdit.GetColumAt(const X, Y: Integer): Integer;
var
  i,xx : Integer;
begin
  result := -1;
  xx := -GetScrollBarLeft();                // ��l���X�N���[���o�[�̌��݈ʒu����擾
  for i := 0 to Columns.Count-1 do begin    // �񐔃��[�v
    xx := xx + Columns[i].Width;            // ��l�ɗ񕝂����Z
    if X < xx then begin                    // �J�[�\��������ɂ���ꍇ
      result := i;                          // �J�[�\���̗�ʒu�Ƃ��ĕԂ�
      exit;                                 // �����I��
    end;
  end;
end;

function TListViewEdit.GetColumn: Integer;
var
  p : TPoint;
begin
  P := GetMouseClientPos;
  result := GetColumAt(p.X,p.Y);                  // �}�E�X�ʒu�������擾
end;

function TListViewEdit.GetColumnRect(Index: Integer; out ALeft,  ARight: Integer): Boolean;
var
  i, X: Integer;
begin
  Result := False;
  if ViewStyle <> vsReport then Exit;
  if (Index < 0) or (Index >= Columns.Count) then Exit;

  X := -Perform(LVM_GETORIGIN, 0, 0); // �X�N���[������␳
  for i := 0 to Index - 1 do
    Inc(X, Columns[i].Width);

  ALeft  := X;
  ARight := X + Columns[Index].Width;
  Result := True;
end;

function TListViewEdit.GetEditCellRect(AColumn, AIndex: Integer): TRect;
var
  RowRect: TRect;
  ScrollX: Integer;
  ColLeft: Integer;
  Col: TListColumn;
begin
  Result := Rect(0, 0, 0, 0);

  if (AColumn < 0) or (AColumn >= Columns.Count) then Exit;
  if (AIndex < 0) or (AIndex >= Items.Count) then Exit;

  // �e�s�̋�`���擾
  if not ListView_GetItemRect(Handle, AIndex, RowRect, LVIR_BOUNDS) then Exit;

  // �X�N���[���ʒu�̕␳
  ScrollX := GetScrollPos(Handle, SB_HORZ);
  ColLeft := ColumnLeft(AColumn);

  Col := Columns[AColumn];

  Result.Left := ColLeft - ScrollX;
  Result.Top := RowRect.Top;
  Result.Right := Result.Left + Col.Width;
  Result.Bottom := RowRect.Bottom;
end;

function TListViewEdit.GetEditTop: Integer;
begin
  // �\��̍�������ʓr����
  result := (ItemIndex -  TopIndex) * (ItemHeight+1);
end;


//--------------------------------------------------------------------------//
//  �Œ�s�@�\��̍������擾                                                //
//--------------------------------------------------------------------------//
function TListViewEdit.GetListViewHeaderHeight(): Integer;
var
  Header_Handle: HWND;
  WindowPlacement: TWindowPlacement;
begin
  Header_Handle := ListView_GetHeader(Handle);
  FillChar(WindowPlacement, SizeOf(WindowPlacement), 0);
  WindowPlacement.Length := SizeOf(WindowPlacement);
  GetWindowPlacement(Header_Handle, @WindowPlacement);
  Result  := WindowPlacement.rcNormalPosition.Bottom -
    WindowPlacement.rcNormalPosition.Top;
end;


function TListViewEdit.GetMouseClientPos: TPoint;
begin
  GetCursorPos(Result);
  Result := ScreenToClient(Result);
end;

function TListViewEdit.GetSettings(Index: Integer): TListViewRTTIItem;
begin
  while Index >= FRowSettings.Count do FRowSettings.Add();
  result := FRowSettings[Index];
end;

//--------------------------------------------------------------------------//
//  ���X�N���[���o�[�̌��݈ʒu���擾                                        //
//--------------------------------------------------------------------------//
function TListViewEdit.GetScrollBarLeft: Integer;
var
  SInfo: TScrollInfo;
begin
  SInfo.cbSize := SizeOf(SInfo);
  SInfo.fMask := SIF_ALL;
  GetScrollInfo(Handle, SB_HORZ, SInfo);
  result := SInfo.nPos;
end;


function TListViewEdit.IsFixedCell(aCol, aRow: Integer): Boolean;
begin
  result := False;
  if (FFixedStyle = fsVerticalFixedColumn) and
     (aCol = 0) then result := True;                      // ���[�̕\��̏ꍇ
 // if (FFixedStyle = fsHorizontalFixedRow) and
 //    (aRow = 0) then result := True;                      // ���[�̕\��̏ꍇ

end;

//--------------------------------------------------------------------------//
//  �L�[�~���C�x���g                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEdit.KeyPress(var Key: Char);
var
  i : Integer;
begin
  inherited;

  i := ItemIndex;                                     // �s�J�[�\���ʒu�擾
  if i = -1 then exit;                                // ���I����������

  if Key <> #$0d then exit;                           // �G���^�[�ӊO�͖�����
  Key := #$0;                                         // �L�[���������Ȃ�

  EditBegin();                                        // �ҏW��Ԃֈڍs
end;

procedure TListViewEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  dl : TListItem;
  dr : TListViewRTTIItem;
  col : Integer;
begin
  inherited MouseMove(Shift, X, Y);    //

  ShowHint := False;                   // �q���g�\��������
  dl := GetItemAt(X,Y);                // �J�[�\����̃f�[�^���Q��
  if dl= nil then exit;                // �J�[�\����Ƀf�[�^�������ꍇ
  //dr := FRowSettings[dl.Index];        // �C���f�b�N�X�l�ɊY������f�[�^���Q��
  col := Column;
  if col = -1 then exit;

  dr := GetCellRTTI(col,dl.Index);
  Hint := dr.Hint;                    // �q���g�����蓖��
  if Hint <> '' then begin             // �q���g�������ꍇ�͏������Ȃ�
    ShowHint := True;                  // �q���g��\��������
  end;
end;

//--------------------------------------------------------------------------//
//  �`�揈���i�w�i�j                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEdit.DrawBack(cv: TCanvas; Item: TListItem; Rect: TRect;
  State: TOwnerDrawState);
var
  r : TRect;
  i : Integer;
begin
  cv.Brush.Style := bsSolid;
  if odSelected in State then begin
    cv.Brush.Color := clGradientActiveCaption;
    cv.Font.Color := clWhite;
  end
  else if odHotLight in State then begin
    cv.Brush.Color := clGradientInactiveCaption;
    cv.Font.Color := clWhite;
  end
  else begin
    cv.Brush.Color := clWhite;
    cv.Font.Color := clBlack;
  end;
  cv.FillRect(Rect);
  if FFixedStyle = fsVerticalFixedColumn then begin   // ���[���Œ�s�Ƃ���ꍇ
    r := Rect;
    if Columns.Count = 0 then exit;

    r.Right := Columns[0].Width;                      // ���[�̃Z���̕����擾
    r.Bottom := r.Bottom - 1;
    if FVisibleIndexes.Count = 0 then exit;
    i := FVisibleIndexes[Item.Index];
    if i = -1 then exit;

    cv.Brush.Color := Settings[i].ColorBack;
    cv.FillRect(r);
    cv.Pen.Color := clWhite;
    cv.Pen.Width := 1;
    cv.MoveTo(r.Left,r.Bottom);
    cv.LineTo(r.Left,r.Top);
    cv.LineTo(r.Right,r.Top);
    cv.Pen.Color := clDkGray;
    cv.LineTo(r.Right,r.Bottom);
    cv.LineTo(r.Left,r.Bottom);
  end;
end;

//--------------------------------------------------------------------------//
//  �`�揈��                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEdit.DrawItem(Item: TListItem; Rect: TRect;
  State: TOwnerDrawState);
var
  cv : TCanvas;
  i,j,x,xh,ScrollX : Integer;
  s : string;
  dt : TListViewRTTIItem;
  r : TRect;
begin
  if not(Canvas.HandleAllocated) or not(Self.HandleAllocated) then exit;

  ScrollX := GetScrollPos(Self.Handle, SB_HORZ);
  cv := TLIstView(Self).Canvas;                   // �`��L�����o�X�Q��
  DrawBack(cv,Item,Rect,State);                     // �J�[�\���ɍ��킹�Ĕw�i�`��
  x := 5;                                           // �}�[�W�����w��
  cv.Brush.Style := bsClear;
  i := Item.Index;

  xh := 0;
  if SmallImages<>nil then begin
    if Items[i].ImageIndex < Images.Count then begin
      r := Item.DisplayRect(drIcon);
      SmallImages.Draw(Self.Canvas, R.Left, R.Top, Item.ImageIndex);
      xh := r.Width + 4;
    end;
  end;

  i := Item.Index;

  for j := 0 to Columns.Count-1 do begin            // �񐔃��[�v
    dt := GetCellRTTI(j,i);                         // �����l�^���̍s���Q��
    dt.Value := Cells[j,i];
    r := Rect;                                      // �`��͈͂��Q��
    r.Left := ColumnLeft(j) - ScrollX;
    if j = 0 then r.Left := r.Left + xh;
    r.Right := ColumnRight(j) - ScrollX - 8;        // ���[�}�[�W����ݒ�

    if IsFixedCell(j,i) then begin                  // ���[�̕\��̏ꍇ
      cv.Font.Color  := dt.ColorFont;               // �F�ݒ�𔽉f
      //cv.Brush.Color := dt.ColorBack;
      cv.Brush.Style := bsClear;
      s := Item.Caption;

      if dt.Caption<>'' then s := dt.Caption;       // �\�肪�ݒ肳��Ă���Ύ擾

      cv.TextRect(r,r.Left+x,r.Top+2,s);            // �\���`��
    end
    else begin                                      // �\��ł͖����ꍇ

      cv.Font.Color  := clBlack;
      //cv.Brush.Color := clWhite;
      cv.Brush.Style := bsClear;

      s := Cells[j,Item.Index];
      dt.Value := s;
      //cv.TextRect(r,r.Left+x,r.Top+2,s);            // �\���`��
      dt.Data := Items[i].Data;
      ListViewEditPlugins[dt.EditType].Draw(cv,r,dt);   // �ҏW�v���O�C�����̕`�揈��
  end;
    x := x + Columns[j].Width;                      // �`��ʒu������
  end;
end;

procedure TListViewEdit.OnSelfEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := False;          // ���[�̃Z�����N���b�N�����ŕҏW�ɂȂ�̂�}�~
  //FEdited := True;
end;


function TListViewEdit.GetCellRTTI(aCol, aRow: Integer): TListViewRTTIItem;
begin
  if FFixedStyle = fsHorizontal then begin
    if FVisibleIndexes.Count = 0 then begin
      result := Settings[aCol];          // �ҏW���@���擾
    end
    else begin
      while aCol >= FRowSettings.Count do FRowSettings.Add();
      result := Settings[FVisibleIndexes[aCol]];          // �ҏW���@���擾
    end;
  end
  else begin
    if FVisibleIndexes.Count = 0 then begin
      while aRow >= FRowSettings.Count do FRowSettings.Add();
      result := Settings[aRow];          // �ҏW���@���擾
    end
    else begin
      result := Settings[FVisibleIndexes[aRow]];          // �ҏW���@���擾
    end;
  end;
end;


procedure TListViewEdit.ScrollToColumn(AColumn: Integer);
var
  HeaderHandle: HWND;
  i, TargetX: Integer;
begin
  if not HandleAllocated then Exit;

  HeaderHandle := FindWindowEx(Handle, 0, 'SysHeader32', nil);
  if HeaderHandle = 0 then Exit;

  TargetX := 0;
  for i := 0 to AColumn - 1 do
  begin
    if ListView_GetColumnWidth(Handle, i) > 0 then
      Inc(TargetX, ListView_GetColumnWidth(Handle, i));
  end;

  ListView_Scroll(Handle, TargetX - GetScrollPos(Handle, SB_HORZ), 0);
end;

procedure TListViewEdit.SetFixedStyle(const Value: TListViewEditFixedStyle);
begin
  FFixedStyle := Value;
end;

//--------------------------------------------------------------------------//
//  �\�����̐擪�s�ʒu���擾                                                //
//--------------------------------------------------------------------------//
function TListViewEdit.TopIndex: Integer;
var
  SInfo: TScrollInfo;
begin
  SInfo.cbSize := SizeOf(SInfo);
  SInfo.fMask := SIF_ALL;
  GetScrollInfo(Handle, SB_VERT, SInfo);
  //result := SInfo.nPos - 1;
  result := SInfo.nPos;             // 2022/4/30
end;


//--------------------------------------------------------------------------//
//  �E�C���h�E���b�Z�[�W���t�b�N                                            //
//--------------------------------------------------------------------------//
procedure TListViewEdit.WMProc(var Msg: TMessage);
begin
  FProc(Msg);                             // ���̃v���Z�X�ɂ�����
  //FormSyncroh2.MsgDebug(IntToHex(Msg.Msg,4));             // ���f�o�b�O�p

  case Msg.Msg of                         // �ҏW�L�����Z�����삩���f
    WM_HSCROLL    : EditChancel;          // �X�N���[��
    WM_VSCROLL    : EditChancel;          // �X�N���[��
    WM_SIZE       : EditChancel;          // �T�C�Y�ύX
    WM_MOUSEWHEEL : EditChancel;          // �}�E�X�z�C�[��
    //else FormMain.MsgDebug(Msg.Msg);
  end;
end;


end.
