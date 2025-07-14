unit ListViewRTTI;
{
  ListViewRTTI.pas
  ---------------------------------------------------------------------------
  実行時型情報 (RTTI) に基づいた編集対応 ListView コンポーネント
  TListViewRTTI を定義するユニット。

  本クラスは TListViewEdit を継承し、任意のオブジェクトから RTTI により
  プロパティ情報を取得し、それを ListView 上に自動表示・編集可能にします。

  主な機能：
    - LoadFromObject により、TObject 派生クラスのプロパティをリスト表示
    - セル編集時の値は、該当オブジェクトのプロパティに反映される
    - 任意の表示列を追加する AddCaption メソッドを提供
    - 編集完了時に通知される OnDataChange イベントを装備
    - 編集時の内部処理は DoChange をオーバーライドして制御

  また、RTTI 項目は RTTINames[プロパティ名] でアクセス可能です。

  本コンポーネントは、設定エディタやデバッグ用の可視化ツールなどにおいて、
  Delphi オブジェクトの状態をそのまま GUI 上で操作したい場面で有効です。
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,ListViewEdit, Vcl.Menus,Vcl.StdCtrls,Vcl.ComCtrls,
  System.TypInfo,ListViewEx,ListViewRTTIList;


//--------------------------------------------------------------------------//
//  実行時型情報を持つクラスを表示編集するクラス                            //
//--------------------------------------------------------------------------//
type
   TListViewRTTI = class(TListViewEdit)
  private
    { Private 宣言 }
    FOnDataChange : TNotifyEvent;

    procedure SetColumn();

    procedure OnSelfResize(Sender: TObject);


    procedure SetFixedWidth(const Value: Integer);
    function GetRTTINames(Name: string): TListViewRTTIItem;

  protected
    // 横スクロールバー非表示
    //procedure UpdateScrollBar;
    procedure DoChange(const EditStr : string;const aColumn,aIndex : Integer);override;
    //procedure DoDataType(const aColumn,aIndex : Integer;var DataType : Integer);virtual;

  public
    { Public 宣言 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
    // 指定したオブジェクト情報を元に編集画面を作成
    procedure LoadFromObject(aObject : TObject);
    // 値のみ更新
    procedure Refresh();
    // 変数名に該当する設定名ヒント編集方法を割り当てる
    function AddCaption(const PName,Caption : string;Hint : string = '';aType : Integer = 0) : TListViewRTTIItem;
    // 非編集表示の幅を指定
    property FixedWidth : Integer write SetFixedWidth;
    property RTTINames[Name : string] : TListViewRTTIItem read GetRTTINames;
    //
    property OnDataChange : TNotifyEvent read FOnDataChange write FOnDataChange;
  end;


implementation

uses ListViewEditPluginLib;

{ TListViewEditRtti }

//--------------------------------------------------------------------------//
//  クラス生成                                                              //
//--------------------------------------------------------------------------//
constructor TListViewRTTI.Create(AOwner: TComponent);
begin
  inherited;

  FixedStyle := fsVerticalFixedColumn;
  ColumnClick := False;
  DoubleBuffered := True;
  RowSelect := True;
  ViewStyle := vsReport;

  OnResize := OnSelfResize;

end;

//--------------------------------------------------------------------------//
//  クラス破棄                                                              //
//--------------------------------------------------------------------------//
destructor TListViewRTTI.Destroy;
begin
  inherited;
end;

//--------------------------------------------------------------------------//
//  編集完了イベント                                                        //
//--------------------------------------------------------------------------//
procedure TListViewRTTI.DoChange(const EditStr: string;const aColumn,aIndex : Integer);
var
  dr : TListViewRTTIItem;
  s : string;
begin
  dr := FRowSettings[FVisibleIndexes[aIndex]];    // 型情報クラス参照
  s := EditStr;                                   // 編集後の値を取得
  FRowSettings.RttiWrite(dr.PName,s);             // 実行時型情報に値を書き込み
  dr.Value := s;                                 // 実行時型情報クラスに書き込み
  //dr.DoRequestEdited();
  //DoDataChange();

end;


//--------------------------------------------------------------------------//
//  クラスの値編集表示                                                      //
//--------------------------------------------------------------------------//
procedure TListViewRTTI.LoadFromObject(aObject: TObject);
var
  i : Integer;
begin
  ViewStyle := vsReport;
  SetColumn();
  Items.Clear;
  Clear();
  FRowSettings.RttiRead(aObject);
  FVisibleIndexes.Clear;
  for i := 0 to FRowSettings.Count-1 do begin
    if  FRowSettings[i].EditType = 0 then continue;
    FVisibleIndexes.Add(i);                   // 非表示分を換算
  end;
  Refresh();
end;

//--------------------------------------------------------------------------//
//  クラスの値表示更新                                                      //
//--------------------------------------------------------------------------//
procedure TListViewRTTI.Refresh;
var
  i,ii : Integer;
  dl : TListItem;
begin
  Items.BeginUpdate();
  FVisibleIndexes.Clear;
  for i := 0 to FRowSettings.Count-1 do begin
    if  FRowSettings[i].EditType = 0 then continue;
    FVisibleIndexes.Add(i);                   // 非表示分を換算
  end;
  for i := 0 to FVisibleIndexes.Count-1 do begin
    if i >= Items.Count then begin
      dl := Items.Add();
    end
    else begin
      dl := Items[i];
    end;
    ii := FVisibleIndexes[i];
    dl.Caption := '';
    dl.Caption := FRowSettings[ii].PName;
    dl.SubItems.Clear;
    dl.SubItems.Add(FRowSettings[ii].Value);
  end;
  Items.EndUpdate();
  HorzScrollBarVisible := False;                         // 横スクロールバー非表示
  inherited;
end;


function TListViewRTTI.AddCaption(const PName, Caption: string; Hint: string; aType: Integer) : TListViewRTTIItem;
var
  dr : TListViewRTTIItem;
begin
  dr := RTTINames[PName];
  dr.AddCaption(Caption,Hint,aType);
  result := dr;
end;



function TListViewRTTI.GetRTTINames(Name: string): TListViewRTTIItem;
var
  i : Integer;
  d : TListViewRTTIItem;
begin
  i := FRowSettings.IndexOfPName(Name);
  if i <> -1 then begin
    result := FRowSettings[i];
    exit;
  end;
  d := FRowSettings.Add();
  d.PName := Name;
  result := d;
end;


procedure TListViewRTTI.OnSelfResize(Sender: TObject);
begin
  //ColumnAlign(1);
end;

//--------------------------------------------------------------------------//
//  固定行の設定                                                            //
//--------------------------------------------------------------------------//
procedure TListViewRTTI.SetColumn;
var
  dc : TListColumn;
begin
  Columns.Clear;                     // カラムを初期化

  dc := Columns.Add;                 // ファイル名の表題を追加
  dc.Caption := '名称';              // 表題の名称を設定
  dc.Width := 160;                   // 表題の幅を設定

  dc := Columns.Add;                 // ファイル名の表題を追加
  dc.Caption := '値';                // 表題の名称を設定
  AdjustColumnsToHeader();
  //ColumnAlign(1);
end;

procedure TListViewRTTI.SetFixedWidth(const Value: Integer);
begin
  Columns[0].Width := Value;
end;



end.
