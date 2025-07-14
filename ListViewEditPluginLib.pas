unit ListViewEditPluginLib;
{
  ListViewEditPluginLib.pas
  ---------------------------------------------------------------------------
  ListViewEdit / ListViewRTTI 用の実用的なセル編集プラグイン群を定義するユニット。

  本ユニットでは、TListViewEditPlugin を継承した複数の具象プラグインを提供し、
  各セルに対して異なる編集スタイル（テキスト、選択式、読み取り専用など）を
  実際に実装するための基盤となります。

  含まれる主なクラス：

    - TListViewEditPluginEdit
        TEdit を使用した基本的な文字列編集プラグイン
        入力確定は OnEditExit や Enter キーで処理

    - TListViewEditPluginReadOnly
        編集コンポーネントを生成せず、セルを表示専用にするプラグイン

    - TListViewEditPluginCustomComboBox
        TComboBox を使用した選択式プラグイン
        高さ制御のためのサブクラス TListViewEditPluginComboBoxHeight を使用

  これらのプラグインは、ListView の各セルごとに動的に割り当てることで、
  柔軟で直感的な編集UIを構築することが可能です。
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,Vcl.ExtCtrls,
  ShellApi,ShlObj,CommCtrl,Menus, ListViewEditPlugin,ListViewRTTIList;

//--------------------------------------------------------------------------//
//  編集プラグイン TEdit                                                    //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginEdit = class(TListViewEditPlugin)
	private
		{ Private 宣言 }
    FEdit : TEdit;                            // 編集用TEdit
    procedure OnEditExit(Sender: TObject);
    procedure OnEditKeyPress(Sender: TObject; var Key: Char);
  protected
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public 宣言 }
    constructor Create(); virtual;
    destructor Destroy;override;
  end;

//--------------------------------------------------------------------------//
//  編集しないプラグイン                                                    //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginReadOnly = class(TListViewEditPlugin)
	private
		{ Private 宣言 }
  protected
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public 宣言 }
  end;

 // 高さを変えられるコンボボックス
type
  TListViewEditPluginComboBoxHeight = class(TComboBox)
  public
    procedure CreateParams(var Params: TCreateParams); override;
  end;

//--------------------------------------------------------------------------//
//  編集プラグイン TComboBox基礎クラス                                      //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginCustomComboBox = class(TListViewEditPlugin)
	private
		{ Private 宣言 }
    procedure OnCBoxExit(Sender: TObject);
  protected
    FCBox : TListViewEditPluginComboBoxHeight;
    procedure SetComboBox(Parent : TWinControl;var Component : TWinControl;r : TRect;Items : TStringList;ItemIndex : Integer);
	public
		{ Public 宣言 }
    constructor Create(); virtual;
    destructor Destroy;override;
  end;

//--------------------------------------------------------------------------//
//  編集プラグイン TComboBox Boolean専用                                    //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginBool = class(TListViewEditPluginCustomComboBox)
	private
		{ Private 宣言 }
    procedure OnCBoxChange(Sender: TObject);
  protected
    // 要素描画
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public 宣言 }
    constructor Create(); override;
  end;

//--------------------------------------------------------------------------//
//  編集プラグイン TComboBox                                                //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginComboBox = class(TListViewEditPluginCustomComboBox)
	private
		{ Private 宣言 }
    procedure OnCBoxChange(Sender: TObject);
  protected
    // 要素描画
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public 宣言 }
    constructor Create(); override;
  end;

//--------------------------------------------------------------------------//
//  編集プラグイン TComboBox  値は Items.Objectを採用する                   //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginComboBoxObject = class(TListViewEditPluginCustomComboBox)
	private
		{ Private 宣言 }
    procedure OnCBoxChange(Sender: TObject);
  protected
    // 要素描画
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public 宣言 }
    constructor Create(); override;
  end;

var
  ListViewEditPluginHide             : TListViewEditPlugin;
  ListViewEditPluginHideId           : Integer;                 // 要素非表示

  ListViewEditPluginReadOnly         : TListViewEditPluginReadOnly;
  ListViewEditPluginReadOnlyId       : Integer;                 // 編集機能無し

  ListViewEditPluginEdit             : TListViewEditPluginEdit;   // TEdit編集プラグイン
  ListViewEditPluginEditId           : Integer;                 // TEdit編集プラグインID  ※たぶん0

  ListViewEditPluginBool             : TListViewEditPluginBool;
  ListViewEditPluginBoolId           : Integer;                 // TComboBoxを指定するときのID

  ListViewEditPluginComboBox         : TListViewEditPluginComboBox;
  ListViewEditPluginComboBoxId       : Integer;                 // TComboBoxを指定するときのID

  ListViewEditPluginComboBoxObject   : TListViewEditPluginComboBoxObject;
  ListViewEditPluginComboBoxObjectId : Integer;                 // TComboBoxを指定するときのID

implementation


{ TListViewEditTypeEdit }

//--------------------------------------------------------------------------//
//  クラス生成                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEditPluginEdit.Create;
begin
  FEdit := TEdit.Create(nil);
  FEdit.OnExit := OnEditExit;
  FEdit.OnKeyPress := OnEditKeyPress;
end;

//--------------------------------------------------------------------------//
//  クラス破棄                                                              //
//--------------------------------------------------------------------------//
destructor TListViewEditPluginEdit.Destroy;
begin
  //FEdit.Free;
  inherited;
end;

//--------------------------------------------------------------------------//
//  編集開始                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginEdit.DoEditing(Parent : TWinControl;var Component : TWinControl;r: TRect; dr : TListViewRTTIItem);
begin
  Component := FEdit;
  FEdit.Parent := Parent;
  FEdit.Left    := r.Left;
  FEdit.Top     := r.Top;
  FEdit.Width   := r.Width;
  FEdit.Height  := r.Height;
  FEdit.Anchors := [akLeft, akRight, akTop, akBottom];
  FEdit.Text    :=  dr.Value;
  FEdit.BevelOuter := bvNone;
  FEdit.BevelInner := bvNone;
  FEdit.SelectAll;
  FEdit.Visible := True;
  FEdit.SetFocus;
end;

//--------------------------------------------------------------------------//
//  フォーカス消失                                                          //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginEdit.OnEditExit(Sender: TObject);
begin
  FEdit.Visible := False;                   // 非表示
  DoEditCancel();                           // キャンセルイベント通知
end;

//--------------------------------------------------------------------------//
//  キー降下イベント                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginEdit.OnEditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #$0d : begin                            // エンターキー
      DoEdited(FEdit.Text);                 // 編集完了イベント発生
      FEdit.Visible := False;               // 非表示
      Key := #0;                            // キーを受け取り他で処理させない
    end;
    #$1b : begin                            // エスケープキー
      FEdit.Visible := False;               // 非表示
      DoEditCancel();                       // キャンセルイベント発生
      Key := #0;
    end;
  end;
end;


{ TListViewEditTypeCustomComboBox }

//--------------------------------------------------------------------------//
//  クラス生成                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEditPluginCustomComboBox.Create;
begin
  FCBox := TListViewEditPluginComboBoxHeight.Create(nil);
  FCBox.Style := csDropDownList;
  FCBox.OnExit := OnCBoxExit;
end;

//--------------------------------------------------------------------------//
//  クラス破棄                                                              //
//--------------------------------------------------------------------------//
destructor TListViewEditPluginCustomComboBox.Destroy;
begin
  //FCBox.Free;
  inherited;
end;


//--------------------------------------------------------------------------//
//  フォーカス消失イベント                                                  //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginCustomComboBox.OnCBoxExit(Sender: TObject);
begin
  FCBox.Visible := False;                   // 非表示
  DoEditCancel();                           // キャンセルイベント発生
end;


//--------------------------------------------------------------------------//
//  TComboBox設定                                                           //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginCustomComboBox.SetComboBox(Parent: TWinControl;
  var Component: TWinControl; r: TRect;Items : TStringList;
  ItemIndex: Integer);
begin
  Component := FCBox;                       // 編集用コンポーネントとして登録
  FCBox.Parent := Parent;                   // ComboBoxを指定されたオブジェクトに配置

  FCBox.Items.BeginUpdate();
  FCBox.Left        := r.Left;              // 左側位置合わせ
  FCBox.Top         := r.Top;               // 上側位置合わせ
  FCBox.Width       := r.Width;             // 横幅位置合わせ
  FCBox.Height      := r.Height;            // 高さ位置合わせ
  FCBox.ItemHeight  := r.Height;            // 項目の高さ位置合わせ
  FCBox.Items.Assign(Items);                // 選択要素を登録
  FCBox.ItemIndex   := ItemIndex;           // 選択中とする要素指定
  FCBox.Visible     := True;                // 表示
  if not FCBox.DroppedDown then begin
    FCBox.DroppedDown := True;                // ドロップダウンリスト表示
  end;
  FCBox.Items.EndUpdate();
  FCBox.SetFocus;                           // フォーカス状態とする

end;

{ TListViewEditTypeBool }

//--------------------------------------------------------------------------//
//  クラス生成                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEditPluginBool.Create;
begin
  inherited;
  FCBox.OnChange := OnCBoxChange;
end;

//--------------------------------------------------------------------------//
//  描画イベント                                                           //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginBool.DoDraw(Canvas: TCanvas; r: TRect;dr : TListViewRTTIItem);
var
  s: string;
  i : Integer;
begin
  i := StrToIntDef(dr.Value,-1);            // 現在値を 0 1で取得
  s := '';

  if dr.Strings.Count = 2 then begin        // 項目リストに要素の指定がある場合
    if i <> -1 then begin
      s := dr.Strings[i];                     // 要素の表示を採用
    end;
  end
  else begin                                // 要素の指定がない場合
    if i = 0 then s := 'false';             // 0:false
    if i = 1 then s := 'true';              // 1:true
  end;
  Canvas.TextRect(r,r.Left+2,r.Top+2,s);    // 手動で描画
end;

//--------------------------------------------------------------------------//
//  編集開始                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginBool.DoEditing(Parent: TWinControl;var Component: TWinControl;r: TRect; dr : TListViewRTTIItem);
var
  i : Integer;
  ts : TStringList;
begin

  ts := TStringList.Create;
  try
    if dr.Strings.Count = 2 then begin        // 項目リストに要素の指定がある場合
      ts.Assign(dr.Strings);                  // 指定の要素を採用
    end
    else begin                                // 要素の指定がない場合
      ts.Add('false');                        // 0:false
      ts.Add('true');                         // 1:true
    end;

    i := StrToIntDef(dr.Value,0);             // true false状態を取得

    SetComboBox(Parent,Component,r,ts,i);     // ComboBox設定
  finally
    ts.Free;
  end;
end;

//--------------------------------------------------------------------------//
//  要素選択イベント                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginBool.OnCBoxChange(Sender: TObject);
var
  s : string;
begin
  s := IntToStr(FCBox.ItemIndex);           // 選択状態を文字で取得
  DoEdited(s);                              // 編集完了イベント発生
  FCBox.Visible := False;
end;


{ TComboBoxHeight }

procedure TListViewEditPluginComboBoxHeight.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // デフォルトではCBS_DROPDOWNが設定されているはずなので
  // これにオーナー描画スタイルを追加する
  Params.Style := Params.Style or CBS_OWNERDRAWFIXED;
end;

{ TListViewEditTypeComboBox }

constructor TListViewEditPluginComboBox.Create;
begin
  inherited;
  FCBox.OnChange := OnCBoxChange;
end;

//--------------------------------------------------------------------------//
//  描画イベント                                                           //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBox.DoDraw(Canvas: TCanvas; r: TRect; dr: TListViewRTTIItem);
var
  s: string;
  i : Integer;
begin
  i := StrToIntDef(dr.Value,-1);            // 現在値を 0 1で取得
  if i < 0 then exit;
  if i > dr.Strings.Count-1 then exit;
  s := dr.Strings[i];                     // 要素の表示を採用
  Canvas.TextRect(r,r.Left+2,r.Top+2,s);    // 手動で描画

end;

//--------------------------------------------------------------------------//
//  編集開始                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBox.DoEditing(Parent: TWinControl;
  var Component: TWinControl;r: TRect;dr: TListViewRTTIItem);
var
  i : Integer;
begin
  i := StrToIntDef(dr.Value,0);             // 状態を取得
  if i > dr.Strings.Count-1 then i := -1;

  SetComboBox(Parent,Component,r,dr.Strings,i);
end;

//--------------------------------------------------------------------------//
//  要素選択イベント                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBox.OnCBoxChange(Sender: TObject);
var
  s : string;
begin
  s := IntToStr(FCBox.ItemIndex);           // 選択状態を文字で取得
  DoEdited(s);                              // 編集完了イベント発生
end;


{ TListViewEditTypeComboBoxObject }

constructor TListViewEditPluginComboBoxObject.Create;
begin
  inherited;
  FCBox.OnChange := OnCBoxChange;
end;

//--------------------------------------------------------------------------//
//  描画イベント                                                           //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBoxObject.DoDraw(Canvas: TCanvas; r: TRect; dr: TListViewRTTIItem);
var
  s: string;
  i,v : Integer;
begin
  v := StrToIntDef(dr.Value,-1);             // 現在値を取得
  i := dr.Strings.IndexOfObject(TObject(v)); // リストの値から検索
  if i = -1 then exit;
  if i > dr.Strings.Count-1 then exit;
  s := dr.Strings[i];                        // 要素の表示を採用
  Canvas.TextRect(r,r.Left+2,r.Top+2,s);     // 手動で描画
end;

//--------------------------------------------------------------------------//
//  編集開始                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBoxObject.DoEditing(Parent: TWinControl;
  var Component: TWinControl;r: TRect;dr: TListViewRTTIItem);
var
  i,v : Integer;
begin
  v := StrToIntDef(dr.Value,0);             // 状態を取得
  i := dr.Strings.IndexOfObject(TObject(v)); // リストの値から検索
  SetComboBox(Parent,Component,r,dr.Strings,i);
end;

//--------------------------------------------------------------------------//
//  要素選択イベント                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBoxObject.OnCBoxChange(Sender: TObject);
var
  s : string;
  i,v : Integer;
begin
  i := FCBox.ItemIndex;
  v := Integer(FCBox.Items.Objects[i]);     // 選択アイテムのオブジェクト取得
  s := IntToStr(v);                         // オブジェクトを文字化
  DoEdited(s);                              // 編集完了イベント発生
end;

{ TListViewEditTypeEditNo }

procedure TListViewEditPluginReadOnly.DoEditing(Parent: TWinControl;
  var Component: TWinControl;r: TRect;dr: TListViewRTTIItem);
begin

end;

initialization
  ListViewEditPlugins := TListViewEditPluginList.Create;

  ListViewEditPluginHide := TListViewEditPluginEdit.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginHide,ListViewEditPluginHideId);

  ListViewEditPluginReadOnly := TListViewEditPluginReadOnly.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginReadOnly,ListViewEditPluginReadOnlyId);

  ListViewEditPluginEdit := TListViewEditPluginEdit.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginEdit,ListViewEditPluginEditId);

  ListViewEditPluginBool := TListViewEditPluginBool.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginBool,ListViewEditPluginBoolId);

  ListViewEditPluginComboBox := TListViewEditPluginComboBox.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginComboBox,ListViewEditPluginComboBoxId);

  ListViewEditPluginComboBoxObject := TListViewEditPluginComboBoxObject.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginComboBoxObject,ListViewEditPluginComboBoxObjectId);


finalization
  ListViewEditPlugins.Free;

end.
