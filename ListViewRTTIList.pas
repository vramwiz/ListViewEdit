unit ListViewRTTIList;
{
  ListViewRTTIList.pas
  ---------------------------------------------------------------------------
  TListViewRTTI �Ŏg�p�����ҏW���ڏ��N���X TListViewRTTIItem ���`���郆�j�b�g�B

  �{���j�b�g�ł́ARTTI ��p�����I�u�W�F�N�g�ҏW�@�\�̕⏕�Ƃ��āA
  �e�Z���i�v���p�e�B���ځj�ɑΉ��������ێ��E���삷�邽�߂�
  �f�[�^�N���X TListViewRTTIItem ��񋟂��Ă��܂��B

  ��ȓ����F
    - �v���p�e�B���iPName�j�A�\�����iCaption�j�A�l�iValue�j�A�⑫�iHint�j��ێ�
    - �ҏW�^�C�v�iEditType�j�A�^���ށiTypeKind, TListViewRTTIType�j�ɂ��\���`���𐧌�
    - �J�X�^���F�i�w�i�F�E�����F�j��⏕�f�[�^�iFData�j�Ȃǂ��Ή�
    - �ҏW�X�^�C���ɉ����ĕ����񃊃X�g�iFStrings�j�����p�\
    - �������p�� AddCaption ���\�b�h���

  ���̍\���́ARTTI �ɂ�鎩���񋓂����łȂ��A�蓮�ł̍��ڒǉ��E�ҏW�\���ɂ��_��ɑΉ����܂��B

  RTTI�x�[�X�̓��I�G�f�B�^��I�u�W�F�N�g�r���[�A�\�z�̊�b�v�f�Ƃ��ė��p����܂��B
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,Vcl.StdCtrls,Vcl.ComCtrls,
  System.TypInfo,ListViewEx;

//--------------------------------------------------------------------------//
//  �g��TPersistent�N���X�iDefineProperties���\�b�h�̋������J�j             //
//--------------------------------------------------------------------------//
type  TPersistentEx = class(TPersistent);


type   TListViewRTTIType = (rtNormal,rtBoolean,rtImitation,rtComponent,rtClass,rtCollection,rtRootClass);


type
  TListViewRTTIItem = class(TPersistent)
  private
    { Private �錾 }
    FCaption   : string;                         // �l�̖���
    FEditType  : Integer;                        // �ҏW���@
    FTypeKind  : TTypeKind;                      // �ϐ��̌^
    FTypeBool  : TListViewRTTIType;              // �ϐ��̌^�� Bool�^���f��p
    FValue     : string;                         // �l
    FHint      : string;                         // �q���g
    FPName     : string;                         // �v���p�e�B��
    FStrings   : TStringList;                    // �I�����X�g�Ɏg�p����l
    FColorBack : TColor;                         // �w�i�F
    FColorFont : TColor;                         // �����F
    FData: Pointer;                              // ListItem��Data
    //FWidth     : Integer;                        // ��̉������������ҏW��ʂŎg�p

  protected
  public
    { Public �錾 }
    constructor Create();
    destructor Destroy;override;

    // �ϐ����ɊY������ݒ薼�q���g�ҏW���@�����蓖�Ă�
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
//  �s��RTTI���֘A�Â�������                                                //
//--------------------------------------------------------------------------//
type
	TListViewRTTIItems = class(TList)
	private
		{ Private �錾 }
    FObject  : TObject;                       // ���ݒ�f�[�^
    FInfo    : PTypeInfo;                     // RTTI���N���X
    FData    : PTypeData;                     // RTTI�f�[�^�N���X
    FProps   : PPropList;
    function CheckRTTIType(aProp : PPropInfo) : TListViewRTTIType;
    function CheckImitationProperty(aObject : TObject) : Boolean;

    procedure GetRTTIInfo();
    procedure RTTIReadItem(i : Integer);
    function RTTIReadData(i : Integer) : string;


    function GetItems(Index: Integer): TListViewRTTIItem;
    function GetPName(PName: string): TListViewRTTIItem;
	public
		{ Public �錾 }
    destructor Destroy;override;

    function Add() : TListViewRTTIItem;
    procedure Delete(Index : Integer);
    procedure Clear();override;

    function IndexOfPName(const PName : string) : Integer;
    // �ϐ����ƒl��n����publised�̕ϐ��ɕۑ�
    procedure RTTIWrite(const PropName,Value : string);
    // published�̃f�[�^��ǂݍ���ŕҏW�p�̃t���[����������������
    procedure RTTIRead(aObject : TObject);

		property Items[Index: Integer] : TListViewRTTIItem read GetItems ;default;
    property PNames[PName : string] : TListViewRTTIItem read GetPName;

	end;

//--------------------------------------------------------------------------//
//  ��\���̍s�̊��Z�N���X                                                  //
//--------------------------------------------------------------------------//
type
	TListViewEditRTTIRows = class(TList)
	private
		{ Private �錾 }
    function GetItems(Index: Integer): Integer;
	public
		{ Public �錾 }

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
      // �U�v���p�e�B�̏���
      result := rtImitation;
    end
    else if GetObjectProp(FObject,PName) <> nil then begin
      // �N���X�̏���
      if GetObjectProp(FObject,PName) is TComponent then begin
        // TComponent����̔h���N���X�̂Ƃ�
        result := rtComponent;
      end
      else begin
        // TComponent�ȊO����̔h���N���X�̂Ƃ�
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
    rtBoolean : s := IntToStr(GetOrdProp(FObject,PName));                 // �^�U�^�̏�������
    rtNormal  : begin
      case FProps^[i].PropType^.Kind of
        tkChar,
        tkWChar,
        tkInteger     : s := IntToStr( GetOrdProp(FObject,PName));       //  Integer�^�̏�������
        tkInt64       : s := IntToStr(GetInt64Prop(FObject,FProps^[i])); //  Int64�^�̏�������
        tkString      : s := GetStrProp(FObject,PName);                  //  �Z��������^�̏�������
        tkUString,
        tkLString,
        tkWString     : s := GetStrProp(FObject,PName);                  //  ����������^�̏�������
        tkEnumeration : s := IntToStr( GetOrdProp(FObject,PName));       //  �񋓌^�̏�������
        tkSet         : s := IntToStr(GetOrdProp(FObject,PName));        //  �W���^�̏�������
        tkFloat       : s := FloatToStr(GetFloatProp(FObject,PName));    //  Float�^�̏�������
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
//  �N���X����                                                              //
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
        tkInteger     : SetOrdProp(FObject,p,StrToIntDef(Value,0));       //  Integer�^�̓ǂݍ���
        tkUString,
        tkLString,
        tkWString,
        tkString      : SetStrProp(FObject,p,Value);                      //  String�^�̓ǂݍ���
        tkFloat       :  SetFloatProp(FObject,p,StrToFloatDef(Value,0));  //  Float�^�̓ǂݍ���
        tkInt64       :  SetInt64Prop(FObject,p, StrToInt64Def(Value,0)); //  Int64�^�̓ǂݍ���
        tkEnumeration : SetOrdProp(FObject,p, StrToIntDef(Value,0));      //  �񋓌^�̓ǂݍ���
        tkSet         :   SetOrdProp(FObject,p,StrToIntDef(Value,0));     //  �W���^�̓ǂݍ���
        end;
      end;
    rtBoolean :    SetOrdProp(FObject,p,StrToIntDef(Value,0));           // Boolean�^�̓ǂݍ���
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
