unit ListViewRTTIList;
{
  ListViewRTTIList.pas
  ---------------------------------------------------------------------------
  TListViewRTTI で使用される編集項目情報クラス TListViewRTTIItem を定義するユニット。

  本ユニットでは、RTTI を用いたオブジェクト編集機能の補助として、
  各セル（プロパティ項目）に対応する情報を保持・操作するための
  データクラス TListViewRTTIItem を提供しています。

  主な特徴：
    - プロパティ名（PName）、表示名（Caption）、値（Value）、補足（Hint）を保持
    - 編集タイプ（EditType）、型分類（TypeKind, TListViewRTTIType）により表示形式を制御
    - カスタム色（背景色・文字色）や補助データ（FData）なども対応
    - 編集スタイルに応じて文字列リスト（FStrings）を活用可能
    - 初期化用の AddCaption メソッドを提供

  この構造は、RTTI による自動列挙だけでなく、手動での項目追加・編集構成にも柔軟に対応します。

  RTTIベースの動的エディタやオブジェクトビューア構築の基礎要素として利用されます。
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,Vcl.StdCtrls,Vcl.ComCtrls,
  System.TypInfo,ListViewEx;

//--------------------------------------------------------------------------//
//  拡張TPersistentクラス（DefinePropertiesメソッドの強制公開）             //
//--------------------------------------------------------------------------//
type  TPersistentEx = class(TPersistent);


type   TListViewRTTIType = (rtNormal,rtBoolean,rtImitation,rtComponent,rtClass,rtCollection,rtRootClass);


type
  TListViewRTTIItem = class(TPersistent)
  private
    { Private 宣言 }
    FCaption   : string;                         // 値の名称
    FEditType  : Integer;                        // 編集方法
    FTypeKind  : TTypeKind;                      // 変数の型
    FTypeBool  : TListViewRTTIType;              // 変数の型※ Bool型判断専用
    FValue     : string;                         // 値
    FHint      : string;                         // ヒント
    FPName     : string;                         // プロパティ名
    FStrings   : TStringList;                    // 選択リストに使用する値
    FColorBack : TColor;                         // 背景色
    FColorFont : TColor;                         // 文字色
    FData: Pointer;                              // ListItemのData
    //FWidth     : Integer;                        // 列の横幅※横方向編集画面で使用

  protected
  public
    { Public 宣言 }
    constructor Create();
    destructor Destroy;override;

    // 変数名に該当する設定名ヒント編集方法を割り当てる
    procedure AddCaption(Caption : string;Hint : string = '';aType : Integer = 0;aColor : TColor = clBtnFace);

    property PName   : string read FPName write FPName;
    property Caption : string read FCaption write FCaption;
    property Hint    : string read FHint    write FHint;
    property Value   : string read FValue write FValue;
    property Data    : Pointer read FData write FData;

    property EditType  : Integer read FEditType write FEditType;
    property TypeKind : TTypeKind read FTypeKind;
    property TypeBool : TListViewRTTIType read FTypeBool;

    property ColorFont : TColor read FColorFont write FColorFont;
    property ColorBack : TColor read FColorBack write FColorBack;

    property Strings  : TStringList read FStrings;

  end;

//--------------------------------------------------------------------------//
//  行とRTTIを関連づけさせる                                                //
//--------------------------------------------------------------------------//
type
	TListViewRTTIItems = class(TList)
	private
		{ Private 宣言 }
    FObject  : TObject;                       // 環境設定データ
    FInfo    : PTypeInfo;                     // RTTI情報クラス
    FData    : PTypeData;                     // RTTIデータクラス
    FProps   : PPropList;
    function CheckRTTIType(aProp : PPropInfo) : TListViewRTTIType;
    function CheckImitationProperty(aObject : TObject) : Boolean;

    procedure GetRTTIInfo();
    procedure RTTIReadItem(i : Integer);
    function RTTIReadData(i : Integer) : string;


    function GetItems(Index: Integer): TListViewRTTIItem;
    function GetPName(PName: string): TListViewRTTIItem;
	public
		{ Public 宣言 }
    destructor Destroy;override;

    function Add() : TListViewRTTIItem;
    procedure Delete(Index : Integer);
    procedure Clear();override;

    function IndexOfPName(const PName : string) : Integer;
    // 変数名と値を渡してpublisedの変数に保存
    procedure RTTIWrite(const PropName,Value : string);
    // publishedのデータを読み込んで編集用のフレームを自動生成する
    procedure RTTIRead(aObject : TObject);

		property Items[Index: Integer] : TListViewRTTIItem read GetItems ;default;
    property PNames[PName : string] : TListViewRTTIItem read GetPName;

	end;

//--------------------------------------------------------------------------//
//  非表示の行の換算クラス                                                  //
//--------------------------------------------------------------------------//
type
	TListViewEditRTTIRows = class(TList)
	private
		{ Private 宣言 }
    function GetItems(Index: Integer): Integer;
	public
		{ Public 宣言 }

    procedure Add(const Row : Integer);
    function IndexOf(const Row : Integer) : Integer;
		property Items[Index: Integer] : Integer read GetItems ;default;
  end;


implementation

uses ListViewEditPlugin,ListViewEditPluginLib;


{ TConfigRTTIListViewItem }

destructor TListViewRTTIItems.Destroy;
begin
  Clear();
  inherited;
end;

function TListViewRTTIItems.Add: TListViewRTTIItem;
var
  d : TListViewRTTIItem;
begin
  d := TListViewRTTIItem.Create;
  inherited Add(d);
  result := d;
end;


function TListViewRTTIItems.CheckImitationProperty(
  aObject: TObject): Boolean;
var
  stm : TWriter;
  m : TStringStream;
  s : string;
begin
  result := False;
  if aObject = nil then exit;
  m := TStringStream.Create(s);
  stm := TWriter.Create(m,4096);
  try
    //result := False;
    TPersistentEx(aObject).DefineProperties(stm);
    stm.FlushBuffer;
    m.Seek(0, soFromBeginning);
    result := m.DataString <> '';
  finally
    m.Free;
    stm.Free;
  end;
end;

function TListViewRTTIItems.CheckRTTIType(
  aProp: PPropInfo): TListViewRTTIType;
var
  PName : string;
begin
  result := rtNormal;
  PName := string(aProp.Name);
  if (aProp.PropType^.Kind = tkClass) then begin
    if (CheckImitationProperty(GetObjectProp(FObject,aProp))) then begin
      // 偽プロパティの処理
      result := rtImitation;
    end
    else if GetObjectProp(FObject,PName) <> nil then begin
      // クラスの処理
      if GetObjectProp(FObject,PName) is TComponent then begin
        // TComponentからの派生クラスのとき
        result := rtComponent;
      end
      else begin
        // TComponent以外からの派生クラスのとき
        result := rtClass;
      end;
    end;
  end
  else if aProp.PropType^.Name = 'Boolean' then begin
    result := rtBoolean;
  end;
end;

procedure TListViewRTTIItems.Clear;
var
  i : Integer;
begin
  for i := 0 to Count-1 do begin
    Items[i].Free;
  end;
  inherited;
end;

procedure TListViewRTTIItems.Delete(Index: Integer);
begin
  Items[Index].Free;
  inherited Delete(Index);
end;

function TListViewRTTIItems.GetItems(Index: Integer): TListViewRTTIItem;
begin
  result := inherited Items[Index];
end;

function TListViewRTTIItems.GetPName(PName: string): TListViewRTTIItem;
var
  i : Integer;
  dr : TListViewRTTIItem;
begin
  i := IndexOfPName(PName);
  if i <> -1 then begin
    result := Items[i];
    exit;
  end;
  dr := Add();
  dr.FPName := PName;
  result := dr;
end;

procedure TListViewRTTIItems.GetRTTIInfo;
begin
  FInfo := FObject.ClassInfo;
  FData := GetTypeData(FInfo);

  GetMem(FProps,FData^.PropCount * SizeOf(PPropInfo));
  GetPropInfos(FInfo,FProps);
end;

function TListViewRTTIItems.IndexOfPName(const PName: string): Integer;
var
  i : Integer;
begin
  result := -1;
  for i := 0 to Count-1 do begin
    if Items[i].FPName = PName then begin
      result := i;
      exit;
    end;
  end;
end;

procedure TListViewRTTIItems.RTTIRead(aObject: TObject);
var
  i : Integer;
begin
  FObject := aObject;
  GetRTTIInfo();
  for i :=0  to FData^.PropCount-1 do begin
    if not IsStoredProp(FObject,FProps^[i]) then Continue;
    RTTIReadItem(i);
  end;
end;

function TListViewRTTIItems.RTTIReadData(i: Integer): string;
var
  s,PName : string;
begin
  s := '';
  PName := string(FProps^[i].Name);
  case CheckRTTIType(FProps^[i]) of
    rtBoolean : s := IntToStr(GetOrdProp(FObject,PName));                 // 真偽型の書き込み
    rtNormal  : begin
      case FProps^[i].PropType^.Kind of
        tkChar,
        tkWChar,
        tkInteger     : s := IntToStr( GetOrdProp(FObject,PName));       //  Integer型の書き込み
        tkInt64       : s := IntToStr(GetInt64Prop(FObject,FProps^[i])); //  Int64型の書き込み
        tkString      : s := GetStrProp(FObject,PName);                  //  短い文字列型の書き込み
        tkUString,
        tkLString,
        tkWString     : s := GetStrProp(FObject,PName);                  //  長い文字列型の書き込み
        tkEnumeration : s := IntToStr( GetOrdProp(FObject,PName));       //  列挙型の書き込み
        tkSet         : s := IntToStr(GetOrdProp(FObject,PName));        //  集合型の書き込み
        tkFloat       : s := FloatToStr(GetFloatProp(FObject,PName));    //  Float型の書き込み
      end;
    end;
  end;
  result := s;

end;

procedure TListViewRTTIItems.RTTIReadItem(i: Integer);
var
  s,PName : string;
  dr : TListViewRTTIItem;
begin
  PName := string(FProps^[i].Name);
  s := RTTIReadData(i);
  dr := PNames[PName];
  dr.FPName := PName;
  dr.FValue := s;
  //dr.DoRequestEdit();
  dr.FTypeKind := FProps^[i].PropType^.Kind;
  dr.FTypeBool := CheckRTTIType(FProps^[i]);
  //dr.EditType := 0;
  if dr.FTypeBool = rtBoolean then  dr.EditType := ListViewEditPluginBoolId;

  dr.FValue := dr.Value;
end;

//--------------------------------------------------------------------------//
//  クラス生成                                                              //
//--------------------------------------------------------------------------//
procedure TListViewRTTIItems.RTTIWrite(const PropName,  Value: string);
var
  i : Integer;
  p : PPropInfo;
begin
  i := IndexOfPName(PropName);
  if i = -1 then exit;
  p := FProps[i];
  case CheckRTTIType(p) of
    rtNormal: begin
      case p.PropType^.Kind of
        tkChar,
        tkWChar,
        tkInteger     : SetOrdProp(FObject,p,StrToIntDef(Value,0));       //  Integer型の読み込み
        tkUString,
        tkLString,
        tkWString,
        tkString      : SetStrProp(FObject,p,Value);                      //  String型の読み込み
        tkFloat       :  SetFloatProp(FObject,p,StrToFloatDef(Value,0));  //  Float型の読み込み
        tkInt64       :  SetInt64Prop(FObject,p, StrToInt64Def(Value,0)); //  Int64型の読み込み
        tkEnumeration : SetOrdProp(FObject,p, StrToIntDef(Value,0));      //  列挙型の読み込み
        tkSet         :   SetOrdProp(FObject,p,StrToIntDef(Value,0));     //  集合型の読み込み
        end;
      end;
    rtBoolean :    SetOrdProp(FObject,p,StrToIntDef(Value,0));           // Boolean型の読み込み
    else begin
    end;
  end;
end;

{ TListViewRTTIItem }


procedure TListViewRTTIItem.AddCaption(Caption, Hint: string; aType: Integer;  aColor: TColor);
begin
  FCaption := Caption;
  FHint := Hint;
  FEditType := aType;
  FColorBack := aColor;
end;

constructor TListViewRTTIItem.Create;
begin
  FStrings := TStringList.Create;
  FColorFont := clBlack;
  FColorBack := clBtnFace;
  FEditType := ListViewEditPluginEditId;
end;

destructor TListViewRTTIItem.Destroy;
begin
  FStrings.Free;
  inherited;
end;


{ TListViewEditRTTIRows }

procedure TListViewEditRTTIRows.Add(const Row: Integer);
begin
  inherited Add(Pointer(Row));
end;

function TListViewEditRTTIRows.GetItems(Index: Integer): Integer;
begin
  result := Integer(inherited Items[Index]);
end;

function TListViewEditRTTIRows.IndexOf(const Row: Integer): Integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to Count-1 do begin
    if Items[i] = Row then begin
      result := i;
      exit;
    end;
  end;
end;

end.
