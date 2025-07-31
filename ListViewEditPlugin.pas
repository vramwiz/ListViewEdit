unit ListViewEditPlugin;
{
  ListViewEditPlugin.pas
  ---------------------------------------------------------------------------
  TListViewEdit / TListViewRTTI 用のセル編集プラグイン機構を提供するユニット。

  本ユニットは、セル編集時の表示や編集コンポーネントを拡張するための
  プラグインベースクラス `TListViewEditPlugin` を定義します。

  主な特徴：
    - 仮想メソッド `DoEditing` を通じて任意の編集コンポーネントを提供可能（要サブクラス実装）
    - 編集開始／描画処理のためのフック（`DoDraw`, `Draw`）
    - 編集確定時（`DoEdited`）およびキャンセル時（`DoEditCancel`）のイベント通知機構
    - 編集コンポーネントの親（Parent）や識別子（Id）の保持
    - 各プラグインを一括管理する `TListViewEditPluginList` も提供

  この機構により、セルごとに異なる編集UI（例：テキスト、コンボボックス、カレンダーなど）を
  動的に割り当てる柔軟な編集インターフェースを構築できます。
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,Vcl.StdCtrls,Vcl.ComCtrls,
  System.TypInfo,ListViewEx,ListViewRTTIList;

type TListViewEditPluginChanged = procedure(Sender : TObject;const EditStr : string) of object;

//--------------------------------------------------------------------------//
//  外部編集プラグインの基礎クラス                                          //
//--------------------------------------------------------------------------//
type
	TListViewEditPlugin = class(TPersistent)
	private
		{ Private 宣言 }
    FId           : Integer;                // プラグインID
    FParent       : TWinControl;            // プラグイン配置用親コンポーネント
    FOnEdited     : TListViewEditPluginChanged;   // 変更イベント
    FOnEditCancel : TNotifyEvent;           // 変更キャンセルイベント
  protected
    // 要素描画
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);virtual;
    // 編集開始
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect;dr : TListViewRTTIItem);virtual;abstract;
    // 編集完了
    procedure DoEdited(const EditStr : string);virtual;
    // 編集キャンセル
    procedure DoEditCancel();virtual;
	public
		{ Public 宣言 }
    procedure Draw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);
    property Id : Integer read FId;
    property Parent : TWinControl read FParent;
    // 変更イベント
    property OnEdited : TListViewEditPluginChanged read FOnEdited write FOnEdited;
    // 変更キャンセルイベント
    property OnEditCancel : TNotifyEvent read FOnEditCancel write FOnEditCancel;
  end;

//--------------------------------------------------------------------------//
//  外部編集プラグインリスト                                                //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginList = class(TList)
	private
		{ Private 宣言 }
    FParent       : TWinControl;            // プラグイン配置用親コンポーネント
    FOnEdited     : TListViewEditPluginChanged;   // 変更イベント
    FOnEditCancel : TNotifyEvent;           // 変更キャンセルイベント
    function GetItems(Index: Integer): TListViewEditPlugin;
	public
		{ Public 宣言 }
    destructor Destroy;override;
    // 編集開始
    procedure BeginEdit(Parent : TWinControl;var Component : TWinControl;EditType : Integer;r : TRect; dr : TListViewRTTIItem;aOnEdited : TListViewEditPluginChanged;aOnEditCancel : TNotifyEvent);

    procedure AddPlugin(EditType :  TListViewEditPlugin;var No : Integer);
    procedure Delete(Index : Integer);
    procedure Clear();override;
		property Items[Index: Integer] : TListViewEditPlugin read GetItems ;default;

	end;


var
  ListViewEditPlugins      : TListViewEditPluginList;      // 外部編集プラグインリスト

implementation

{ TListViewEditPluginList }

destructor TListViewEditPluginList.Destroy;
begin
  Clear();
  inherited;
end;

procedure TListViewEditPluginList.BeginEdit(Parent: TWinControl;
  var Component: TWinControl; EditType: Integer; r: TRect;
  dr: TListViewRTTIItem; aOnEdited: TListViewEditPluginChanged;
  aOnEditCancel: TNotifyEvent);
var
  i: Integer;
  d : TListViewEditPlugin;
begin
  FOnEdited := aOnEdited;
  FOnEditCancel := aOnEditCancel;
  for i := 0 to Count-1 do begin
    if i = EditType then begin
      d := Items[i];
      d.FParent := Parent;
      d.DoEditing(Parent,Component,r,dr);
      d.OnEdited := FOnEdited;
      d.OnEditCancel := FOnEditCancel;
    end;
  end;
end;

procedure TListViewEditPluginList.AddPlugin(EditType :  TListViewEditPlugin;var No : Integer);
begin
  if EditType<>nil then EditType.FId := Count;
  No := Count;
  FParent := FParent;
  inherited Add(EditType);
end;


procedure TListViewEditPluginList.Clear;
var
  i : Integer;
begin
  for i := 0 to Count-1 do begin
    Items[i].Free;
  end;
  inherited;
end;

procedure TListViewEditPluginList.Delete(Index: Integer);
begin
  Items[Index].Free;
  inherited Delete(Index);
end;

function TListViewEditPluginList.GetItems(Index: Integer): TListViewEditPlugin;
begin
  result := inherited Items[Index];
end;


{ TListViewEditType }

procedure TListViewEditPlugin.DoDraw(Canvas: TCanvas; r: TRect;dr : TListViewRTTIItem);
begin
  Canvas.TextRect(r,r.Left+2,r.Top+2,dr.Value);  // 手動で描画
end;

procedure TListViewEditPlugin.DoEditCancel();
begin
  if Assigned(FOnEditCancel) then begin
    FOnEditCancel(Self);
  end;
end;

procedure TListViewEditPlugin.DoEdited(const EditStr: string);
begin
  if Assigned(FOnEdited) then begin
    FOnEdited(Self,EditStr);
  end;
end;

procedure TListViewEditPlugin.Draw(Canvas: TCanvas; r: TRect;dr : TListViewRTTIItem);
begin
  DoDraw(Canvas,r,dr);
end;



end.
