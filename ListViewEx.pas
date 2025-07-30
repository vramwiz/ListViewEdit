unit ListViewEx;

{
  ListViewEx.pas
  ---------------------------------------------------------------------------
  拡張 ListView コンポーネント TListViewEx を定義するユニット。

  このクラスは Delphi 標準の TListView を継承し、以下のような
  表示・操作まわりの機能を追加・修正しています：

    - 行の高さを指定可能（ItemHeight）
    - ストライプ状の背景（RowColorStriped）
    - アイコン表示の有効／無効切替（EnableIcons / DisableIcons）
    - オーナードロー描画の改善（DrawBack, OnSelfDrawItem）
    - 全選択／全解除、カラム幅の自動調整などのユーティリティ追加

  また、セル単位のアクセス (`Cells[ACol, ARow]`) や、
  スクロールバーの可視状態の制御 (`SetHorzScrollBarVisible` など) にも対応しています。

  このコンポーネントは ListView の表示・操作性を向上させる目的で使用します。
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList,
  Vcl.ComCtrls,CommCtrl ;

//--------------------------------------------------------------------------//
//  TListViewに必要最低限の機能 サイズ変更を実装                            //
//--------------------------------------------------------------------------//

type
  TListViewEx = class(TListView)
  private
    { Private 宣言 }
    FImages           : TImageList;          // リストビューで使用するイメージリスト
    FRowColorStriped  : Boolean;             // アイコン表示サイズ
    FItemHeight       : Integer;             // 行の高さ
    // 背景描画
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
    // 指定した行が表示されるように調整
    procedure SetTopIndex(const Value : Integer);
    function GetTopIndex: Integer;
  protected
    procedure Resize; override;
    procedure DrawItem(Item: TListItem;Rect: TRect; State: TOwnerDrawState);override;
  public
    { Public 宣言 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;

    procedure Clear();override;
    // 要素の挿入
    function Insert(Index: Integer): TListItem;

    // アイコンを表示
    procedure EnableIcons(ViewStyle: TViewStyle; IconSize: Integer);
    // アイコンを非表示
    procedure DisableIcons();
    // 全選択
    procedure SelectAll();override;
    // 選択解除
    procedure SelectClear();
    // カラム位置を横幅に合わせる
    procedure AdjustColumnsToHeader();

    // サイズ変更が発生した場合に指定した列の横幅を伸ばす
    procedure ColumnAlign(const aColmun : Integer);
    // 指定した列の横幅を最大まで伸ばす
    procedure AutoAdjustColumnWidth(TargetColumn: Integer);
    // 指定した列の左端座標を取得
    function ColumnLeft(const aCol : Integer) : Integer;
    // 指定した列の右端座標を取得
    function ColumnRight(const aCol : Integer) : Integer;
    // 使用する画像のサイズを設定
    procedure SetImageSizeWH(const Width,Height : Integer);
    // リストの要素を入れ替える
    procedure Exchange(Index1,Index2 : Integer);
    // 画像リスト
    property Images : TImageList read FImages;
    // 画像のサイズ
    property ImageSize: Integer read GetImageSize write SetImageSize;
    // 項目の高さ
    property ItemHeight : Integer read GetItemHeight write SetItemHeight;
    // 指定したインデックス値の要素が画面内に表示されるように調整
    property TopIndex : Integer read GetTopIndex write SetTopIndex;
    // TListViewのCaptionやSubItemsを二次元配列セル処理として扱う
    property Cells[ACol, ARow: Integer] : string read GetCells write SetCells;
    // True:項目毎に背景色を変える ※未使用？
    property RowColorStriped : Boolean read FRowColorStriped write SetRowColorStriped;
    // 水平スクロールバー表示設定
    property HorzScrollBarVisible: Boolean write SetHorzScrollBarVisible;
    // 垂直スクロールバー表示設定
    property VertScrollBarVisible: Boolean write SetVertScrollBarVisible;

  end;


implementation

uses ShellApi,Math;

{ TListViewEx }

//--------------------------------------------------------------------------//
//  クラス生成                                                              //
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
//  クラス破棄                                                              //
//--------------------------------------------------------------------------//
destructor TListViewEx.Destroy;
begin
  FImages.Free;
  inherited;
end;

//--------------------------------------------------------------------------//
//  Itemsクリア　※イメージリストのクリアも行っている                       //
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
//  指定した列幅を自動サイズ調整とする                                      //
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

  // ListViewのクライアント領域の幅を取得
  TotalWidth := Self.ClientWidth;

  // 他の列の幅を合計
  UsedWidth := 0;
  for i := 0 to Self.Columns.Count - 1 do
  begin
    if i <> TargetColumn then
      UsedWidth := UsedWidth + Self.Column[i].Width;
  end;

  // 残りの幅を計算して指定列に設定（最小幅10など制限付きでも可）
  Self.Column[TargetColumn].Width := Max(10, TotalWidth - UsedWidth);
end;

//--------------------------------------------------------------------------//
//  指定した列の左端座標を取得                                              //
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
//  指定した列の右端座標を取得                                              //
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
  // Caption, ImageIndex, Data を退避
  Caption := ds1.Caption;
  ImageIndex := ds1.ImageIndex;
  Data := ds1.Data;

  // SubItemsを一時リストにコピー
  SubItems1 := TStringList.Create;
  SubItems2 := TStringList.Create;
  try
    for i := 0 to ds1.SubItems.Count - 1 do
      SubItems1.AddObject(ds1.SubItems[i], ds1.SubItems.Objects[i]);
    for i := 0 to ds2.SubItems.Count - 1 do
      SubItems2.AddObject(ds2.SubItems[i], ds2.SubItems.Objects[i]);

    // 入れ替え
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
//  要素を入れ替え ※TListViewは要素入れ替え非対応のため                    //
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
//  独自の描画処理での背景描画                                              //
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
//  1行毎に色を変える場合の描画処理                                         //
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

  // クライアント幅から他の列の幅を引いた残りを求める
  total := 0;
  for i := 0 to Columns.Count - 2 do
    Inc(total, Columns[i].Width);

  remain := ClientWidth - total - GetSystemMetrics(SM_CXVSCROLL); // スクロールバー分調整

  if remain < 0 then
    remain := 0;

  Columns[Columns.Count - 1].Width := remain;
end;
}

//--------------------------------------------------------------------------//
//  使用する画像サイズ設定                                                  //
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
//  行の高さ設定                                                            //
//--------------------------------------------------------------------------//
procedure TListViewEx.SetItemHeight(const Value: Integer);
begin
  FItemHeight := Value;
  SetImageSizeWH(1,Value);
end;

//--------------------------------------------------------------------------//
//  行の高さ取得                                                            //
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
      Result := Font.Height + 8; // フォールバック値
  end
  else
    Result := Font.Height + 8; // 項目がない場合の仮高さ
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
  // 末尾に追加して、それを指定位置まで押し上げる
  Item := Items.Add;
  for i := Items.Count - 1 downto Index + 1 do
    Exchange(i, i - 1);
  Result := Items[Index]; // 挿入された位置にある項目を返す
end;

function TListViewEx.GetImageSize: Integer;
begin
  result :=FImages.Width;
end;

//--------------------------------------------------------------------------//
//  True:独自の描画処理を行う                                               //
//--------------------------------------------------------------------------//
procedure TListViewEx.SetRowColorStriped(const Value: Boolean);
begin
  OwnerDraw := Value;
end;

//--------------------------------------------------------------------------//
//  指定した行が表示されるように調整                                        //
//--------------------------------------------------------------------------//
procedure TListViewEx.SetTopIndex(const Value: Integer);
begin
  if Value = -1 then exit;

  ItemFocused := Items[Value];                       // 指定行のフォーカスを有効に
  Items[Value].MakeVisible(True);                    // 指定した行が表示されるようスクロール
end;

//--------------------------------------------------------------------------//
//  指定した行と列の値を取得                                                //
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
//  指定した行と列の値を設定                                                //
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
    si.nMax := 100; // 任意
    si.nPage := 50;
  end
  else begin
    si.nMin := 0;
    si.nMax := 0;
    si.nPage := 0;
  end;
  SetScrollInfo(Handle,SB_VERT, si, True);end;

end.
