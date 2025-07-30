unit ListViewEx;

{
  ListViewEx.pas
  ---------------------------------------------------------------------------
  �g�� ListView �R���|�[�l���g TListViewEx ���`���郆�j�b�g�B

  ���̃N���X�� Delphi �W���� TListView ���p�����A�ȉ��̂悤��
  �\���E����܂��̋@�\��ǉ��E�C�����Ă��܂��F

    - �s�̍������w��\�iItemHeight�j
    - �X�g���C�v��̔w�i�iRowColorStriped�j
    - �A�C�R���\���̗L���^�����ؑցiEnableIcons / DisableIcons�j
    - �I�[�i�[�h���[�`��̉��P�iDrawBack, OnSelfDrawItem�j
    - �S�I���^�S�����A�J�������̎��������Ȃǂ̃��[�e�B���e�B�ǉ�

  �܂��A�Z���P�ʂ̃A�N�Z�X (`Cells[ACol, ARow]`) ��A
  �X�N���[���o�[�̉���Ԃ̐��� (`SetHorzScrollBarVisible` �Ȃ�) �ɂ��Ή����Ă��܂��B

  ���̃R���|�[�l���g�� ListView �̕\���E���쐫�����コ����ړI�Ŏg�p���܂��B
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList,
  Vcl.ComCtrls,CommCtrl ;

//--------------------------------------------------------------------------//
//  TListView�ɕK�v�Œ���̋@�\ �T�C�Y�ύX������                            //
//--------------------------------------------------------------------------//

type
  TListViewEx = class(TListView)
  private
    { Private �錾 }
    FImages           : TImageList;          // ���X�g�r���[�Ŏg�p����C���[�W���X�g
    FRowColorStriped  : Boolean;             // �A�C�R���\���T�C�Y
    FItemHeight       : Integer;             // �s�̍���
    // �w�i�`��
    procedure DrawBack(cv : TCanvas;Item: TListItem;Rect: TRect; State: TOwnerDrawState);
    procedure SetRowColorStriped(const Value: Boolean);
    function GetItemHeight: Integer;
    procedure SetItemHeight(const Value: Integer);
    function GetImageSize: Integer;
    procedure SetImageSize(const Value: Integer);
    function GetCells(ACol, ARow: Integer): string;
    procedure SetCells(ACol, ARow: Integer; const Value: string);
    procedure SetHorzScrollBarVisible(const Value: Boolean);
    procedure SetVertScrollBarVisible(const Value: Boolean);
    // �w�肵���s���\�������悤�ɒ���
    procedure SetTopIndex(const Value : Integer);
    function GetTopIndex: Integer;
  protected
    procedure Resize; override;
    procedure DrawItem(Item: TListItem;Rect: TRect; State: TOwnerDrawState);override;
  public
    { Public �錾 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;

    procedure Clear();override;
    // �v�f�̑}��
    function Insert(Index: Integer): TListItem;

    // �A�C�R����\��
    procedure EnableIcons(ViewStyle: TViewStyle; IconSize: Integer);
    // �A�C�R�����\��
    procedure DisableIcons();
    // �S�I��
    procedure SelectAll();override;
    // �I������
    procedure SelectClear();
    // �J�����ʒu�������ɍ��킹��
    procedure AdjustColumnsToHeader();

    // �T�C�Y�ύX�����������ꍇ�Ɏw�肵����̉�����L�΂�
    procedure ColumnAlign(const aColmun : Integer);
    // �w�肵����̉������ő�܂ŐL�΂�
    procedure AutoAdjustColumnWidth(TargetColumn: Integer);
    // �w�肵����̍��[���W���擾
    function ColumnLeft(const aCol : Integer) : Integer;
    // �w�肵����̉E�[���W���擾
    function ColumnRight(const aCol : Integer) : Integer;
    // �g�p����摜�̃T�C�Y��ݒ�
    procedure SetImageSizeWH(const Width,Height : Integer);
    // ���X�g�̗v�f�����ւ���
    procedure Exchange(Index1,Index2 : Integer);
    // �摜���X�g
    property Images : TImageList read FImages;
    // �摜�̃T�C�Y
    property ImageSize: Integer read GetImageSize write SetImageSize;
    // ���ڂ̍���
    property ItemHeight : Integer read GetItemHeight write SetItemHeight;
    // �w�肵���C���f�b�N�X�l�̗v�f����ʓ��ɕ\�������悤�ɒ���
    property TopIndex : Integer read GetTopIndex write SetTopIndex;
    // TListView��Caption��SubItems��񎟌��z��Z�������Ƃ��Ĉ���
    property Cells[ACol, ARow: Integer] : string read GetCells write SetCells;
    // True:���ږ��ɔw�i�F��ς��� �����g�p�H
    property RowColorStriped : Boolean read FRowColorStriped write SetRowColorStriped;
    // �����X�N���[���o�[�\���ݒ�
    property HorzScrollBarVisible: Boolean write SetHorzScrollBarVisible;
    // �����X�N���[���o�[�\���ݒ�
    property VertScrollBarVisible: Boolean write SetVertScrollBarVisible;

  end;


implementation

uses ShellApi,Math;

{ TListViewEx }

//--------------------------------------------------------------------------//
//  �N���X����                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEx.Create(AOwner: TComponent);
begin
  inherited;
  FItemHeight := 24;
  BevelOuter := bvNone;
  BevelInner := bvNone;
  FImages := TImageList.Create(Self);
end;

//--------------------------------------------------------------------------//
//  �N���X�j��                                                              //
//--------------------------------------------------------------------------//
destructor TListViewEx.Destroy;
begin
  FImages.Free;
  inherited;
end;

//--------------------------------------------------------------------------//
//  Items�N���A�@���C���[�W���X�g�̃N���A���s���Ă���                       //
//--------------------------------------------------------------------------//
procedure TListViewEx.Clear;
begin
  inherited;
  FImages.Clear;
end;

procedure TListViewEx.EnableIcons(ViewStyle: TViewStyle; IconSize: Integer);
begin
  Self.ViewStyle := ViewStyle;
  SetImageSize(IconSize);
end;

procedure TListViewEx.DisableIcons;
begin
  LargeImages := nil;
  SmallImages := nil;
end;

procedure TListViewEx.SelectAll;
var
  I: Integer;
begin
  if not MultiSelect then Exit;
  for I := 0 to Items.Count - 1 do
    Items[I].Selected := True;
end;

procedure TListViewEx.SelectClear;
var
  I: Integer;
begin
  for I := 0 to Items.Count - 1 do
    Items[I].Selected := False;
end;

procedure TListViewEx.AdjustColumnsToHeader;
var
  i: Integer;
begin
  i := Columns.Count ;
  if i = 0 then exit;
  ListView_SetColumnWidth(Self.Handle, i, LVSCW_AUTOSIZE_USEHEADER);


  //for i := 0 to Columns.Count - 1 do
  //  ListView_SetColumnWidth(Handle, i, LVSCW_AUTOSIZE_USEHEADER);
end;


//--------------------------------------------------------------------------//
//  �w�肵���񕝂������T�C�Y�����Ƃ���                                      //
//--------------------------------------------------------------------------//
procedure TListViewEx.ColumnAlign(const aColmun: Integer);
begin
  ListView_SetColumnWidth(Self.Handle, aColmun, LVSCW_AUTOSIZE_USEHEADER);
end;

procedure TListViewEx.AutoAdjustColumnWidth(TargetColumn: Integer);
var
  TotalWidth, UsedWidth, i: Integer;
begin
  if not Assigned(Self) or (TargetColumn < 0) or (TargetColumn >= Self.Columns.Count) then Exit;

  // ListView�̃N���C�A���g�̈�̕����擾
  TotalWidth := Self.ClientWidth;

  // ���̗�̕������v
  UsedWidth := 0;
  for i := 0 to Self.Columns.Count - 1 do
  begin
    if i <> TargetColumn then
      UsedWidth := UsedWidth + Self.Column[i].Width;
  end;

  // �c��̕����v�Z���Ďw���ɐݒ�i�ŏ���10�Ȃǐ����t���ł��j
  Self.Column[TargetColumn].Width := Max(10, TotalWidth - UsedWidth);
end;

//--------------------------------------------------------------------------//
//  �w�肵����̍��[���W���擾                                              //
//--------------------------------------------------------------------------//
function TListViewEx.ColumnLeft(const aCol: Integer): Integer;
var
  i,x: Integer;
begin
  result := 0;
  if aCol = 0 then exit;
  x := 0;
  for i := 0 to aCol-1 do begin
    x := x + Columns[i].Width;
  end;
  result := x;
end;

//--------------------------------------------------------------------------//
//  �w�肵����̉E�[���W���擾                                              //
//--------------------------------------------------------------------------//
function TListViewEx.ColumnRight(const aCol: Integer): Integer;
var
  i,x: Integer;
begin
  result := 0;
  if aCol > Columns.Count-1 then exit;
  x := 0;
  for i := 0 to aCol do begin
    x := x + Columns[i].Width;
  end;
  result := x;
end;

procedure ExchangeList(ds1,  ds2 : TListItem);
var
  i: Integer;
  Caption: string;
  ImageIndex: Integer;
  Data: TObject;
  SubItems1, SubItems2: TStringList;
begin
  // Caption, ImageIndex, Data ��ޔ�
  Caption := ds1.Caption;
  ImageIndex := ds1.ImageIndex;
  Data := ds1.Data;

  // SubItems���ꎞ���X�g�ɃR�s�[
  SubItems1 := TStringList.Create;
  SubItems2 := TStringList.Create;
  try
    for i := 0 to ds1.SubItems.Count - 1 do
      SubItems1.AddObject(ds1.SubItems[i], ds1.SubItems.Objects[i]);
    for i := 0 to ds2.SubItems.Count - 1 do
      SubItems2.AddObject(ds2.SubItems[i], ds2.SubItems.Objects[i]);

    // ����ւ�
    ds1.Caption := ds2.Caption;
    ds1.ImageIndex := ds2.ImageIndex;
    ds1.Data := ds2.Data;
    ds1.SubItems.Assign(SubItems2);

    ds2.Caption := Caption;
    ds2.ImageIndex := ImageIndex;
    ds2.Data := Data;
    ds2.SubItems.Assign(SubItems1);

  finally
    SubItems1.Free;
    SubItems2.Free;
  end;
end;

//--------------------------------------------------------------------------//
//  �v�f�����ւ� ��TListView�͗v�f����ւ���Ή��̂���                    //
//--------------------------------------------------------------------------//
procedure TListViewEx.Exchange(Index1, Index2: Integer);
var
  i : Integer;
begin
  if Index1 > index2 then begin
    i := Index1;
    Index1 := Index2;
    Index2 := i;
  end;

  if Index1 < 0            then exit;
  if Index1 >= Items.Count then exit;
  if Index2 < 0            then exit;
  if Index2 >= Items.Count then exit;

  ExchangeList(Items[Index1],Items[Index2]);

end;

//--------------------------------------------------------------------------//
//  �Ǝ��̕`�揈���ł̔w�i�`��                                              //
//--------------------------------------------------------------------------//
procedure TListViewEx.DrawBack(cv: TCanvas; Item: TListItem; Rect: TRect;State: TOwnerDrawState);
const
  EvenColor = $F0F0F0;
  OddColor  = $FFFFFF;
begin
  cv.Brush.Style := bsSolid;
  if odSelected in State then begin
    cv.Brush.Color := clNavy;
    cv.Font.Color := clWhite;
  end
  else if odHotLight in State then begin
    cv.Brush.Color := clGradientInactiveCaption;
    cv.Font.Color := clWhite;
  end
  else begin
    if Item.Index mod 2 = 0 then begin
      cv.Brush.Color := EvenColor;
      cv.Font.Color := clBlack;
    end
    else begin
      cv.Brush.Color := OddColor;
      cv.Font.Color := clBlack;
    end;
  end;
  cv.FillRect(Rect);
end;

//--------------------------------------------------------------------------//
//  1�s���ɐF��ς���ꍇ�̕`�揈��                                         //
//--------------------------------------------------------------------------//
procedure TListViewEx.DrawItem(Item: TListItem; Rect: TRect;
  State: TOwnerDrawState);
var
  cv : TCanvas;
  i,x : Integer;
  s : string;
begin
  inherited;
  cv := TLIstView(Self).Canvas;

  DrawBack(cv,Item,Rect,State);
  x := 5;
  cv.Brush.Style := bsClear;
  for i := 0 to Columns.Count-1 do begin
    cv.Brush.Style := bsClear;
    if i = 0 then begin
      s := Item.Caption;
      cv.TextRect(Rect,Rect.Left+ x,Rect.Top + 2,s);
    end
    else begin
      s  := '';
      if i < item.SubItems.Count then begin
        s := Item.SubItems[i-1];
      end;
      cv.TextRect(Rect,Rect.Left+ x,Rect.Top + 2,s);
    end;
    x := x + Columns[i].Width;
  end;
end;

procedure TListViewEx.Resize;
begin
  inherited;
  AdjustColumnsToHeader();
end;

{
procedure TListViewEx.Resize;
var
  i, total, remain: Integer;
begin
  inherited;

  if ViewStyle <> vsReport then
    Exit;

  if Columns.Count = 0 then
    Exit;

  // �N���C�A���g�����瑼�̗�̕����������c������߂�
  total := 0;
  for i := 0 to Columns.Count - 2 do
    Inc(total, Columns[i].Width);

  remain := ClientWidth - total - GetSystemMetrics(SM_CXVSCROLL); // �X�N���[���o�[������

  if remain < 0 then
    remain := 0;

  Columns[Columns.Count - 1].Width := remain;
end;
}

//--------------------------------------------------------------------------//
//  �g�p����摜�T�C�Y�ݒ�                                                  //
//--------------------------------------------------------------------------//
procedure TListViewEx.SetImageSizeWH(const Width, Height: Integer);
begin
  LargeImages := nil;
  SmallImages := nil;
  FImages.Width := Width;
  FImages.Height := Height;
  LargeImages := Images;
  SmallImages := Images;
  //Invalidate;
end;
procedure TListViewEx.SetImageSize(const Value: Integer);
begin
  SetImageSizeWH(Value,Value);
end;


//--------------------------------------------------------------------------//
//  �s�̍����ݒ�                                                            //
//--------------------------------------------------------------------------//
procedure TListViewEx.SetItemHeight(const Value: Integer);
begin
  FItemHeight := Value;
  SetImageSizeWH(1,Value);
end;

//--------------------------------------------------------------------------//
//  �s�̍����擾                                                            //
//--------------------------------------------------------------------------//
function TListViewEx.GetItemHeight: Integer;
var
  R: TRect;
begin
  if Items.Count > 0 then
  begin
    if ListView_GetItemRect(Handle, 0, R, LVIR_BOUNDS) then
      Result := R.Bottom - R.Top
    else
      Result := Font.Height + 8; // �t�H�[���o�b�N�l
  end
  else
    Result := Font.Height + 8; // ���ڂ��Ȃ��ꍇ�̉�����
end;

function TListViewEx.GetTopIndex: Integer;
begin
  Result := ListView_GetTopIndex(Self.Handle);
end;

function TListViewEx.Insert(Index: Integer): TListItem;
var
  i: Integer;
  Item: TListItem;
begin
  // �����ɒǉ����āA������w��ʒu�܂ŉ����グ��
  Item := Items.Add;
  for i := Items.Count - 1 downto Index + 1 do
    Exchange(i, i - 1);
  Result := Items[Index]; // �}�����ꂽ�ʒu�ɂ��鍀�ڂ�Ԃ�
end;

function TListViewEx.GetImageSize: Integer;
begin
  result :=FImages.Width;
end;

//--------------------------------------------------------------------------//
//  True:�Ǝ��̕`�揈�����s��                                               //
//--------------------------------------------------------------------------//
procedure TListViewEx.SetRowColorStriped(const Value: Boolean);
begin
  OwnerDraw := Value;
end;

//--------------------------------------------------------------------------//
//  �w�肵���s���\�������悤�ɒ���                                        //
//--------------------------------------------------------------------------//
procedure TListViewEx.SetTopIndex(const Value: Integer);
begin
  if Value = -1 then exit;

  ItemFocused := Items[Value];                       // �w��s�̃t�H�[�J�X��L����
  Items[Value].MakeVisible(True);                    // �w�肵���s���\�������悤�X�N���[��
end;

//--------------------------------------------------------------------------//
//  �w�肵���s�Ɨ�̒l���擾                                                //
//--------------------------------------------------------------------------//
function TListViewEx.GetCells(ACol, ARow: Integer): string;
var
  t : TStrings;
begin
  result := '';
  if ACol < 0 then exit;
  if ACol > Columns.Count-1 then exit;
  if ARow < 0 then exit;
  if ARow > Items.Count-1 then exit;
  if ACol = 0 then begin
    result := Items[ARow].Caption;
  end
  else begin
    t := Items[ARow].SubItems;
    while ACol-1 >=t.Count do t.Add('');
    result := t[ACol-1];
  end;
end;

//--------------------------------------------------------------------------//
//  �w�肵���s�Ɨ�̒l��ݒ�                                                //
//--------------------------------------------------------------------------//
procedure TListViewEx.SetCells(ACol, ARow: Integer; const Value: string);
var
  t : TStrings;
begin
  if ACol < 0 then exit;
  if ACol > Columns.Count-1 then exit;
  if ARow < 0 then exit;
  if ARow > Items.Count-1 then exit;
  if ACol = 0 then begin
    Items[ARow].Caption := Value;
  end
  else begin
    t := Items[ARow].SubItems;
    while ACol-1 >=t.Count do t.Add('');
    t[ACol-1] := Value;;
  end;
end;

procedure TListViewEx.SetHorzScrollBarVisible(const Value: Boolean);
var
  si: TScrollInfo;
begin
  si.cbSize := SizeOf(si);
  si.fMask := SIF_RANGE or SIF_PAGE;
  if Value then begin
    si.nMin := 0;
    si.nMax := 100;
    si.nPage := 50;
  end
  else begin
    si.nMin := 0;
    si.nMax := 0;
    si.nPage := 0;
  end;
  SetScrollInfo(Handle, SB_HORZ, si, True);
end;

procedure TListViewEx.SetVertScrollBarVisible(const Value: Boolean);
var
  si: TScrollInfo;
begin
  si.cbSize := SizeOf(si);
  si.fMask := SIF_RANGE or SIF_PAGE;
  if Visible then begin
    si.nMin := 0;
    si.nMax := 100; // �C��
    si.nPage := 50;
  end
  else begin
    si.nMin := 0;
    si.nMax := 0;
    si.nPage := 0;
  end;
  SetScrollInfo(Handle,SB_VERT, si, True);end;

end.
