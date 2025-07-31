unit ListViewEditPlugin;
{
  ListViewEditPlugin.pas
  ---------------------------------------------------------------------------
  TListViewEdit / TListViewRTTI �p�̃Z���ҏW�v���O�C���@�\��񋟂��郆�j�b�g�B

  �{���j�b�g�́A�Z���ҏW���̕\����ҏW�R���|�[�l���g���g�����邽�߂�
  �v���O�C���x�[�X�N���X `TListViewEditPlugin` ���`���܂��B

  ��ȓ����F
    - ���z���\�b�h `DoEditing` ��ʂ��ĔC�ӂ̕ҏW�R���|�[�l���g��񋟉\�i�v�T�u�N���X�����j
    - �ҏW�J�n�^�`�揈���̂��߂̃t�b�N�i`DoDraw`, `Draw`�j
    - �ҏW�m�莞�i`DoEdited`�j����уL�����Z�����i`DoEditCancel`�j�̃C�x���g�ʒm�@�\
    - �ҏW�R���|�[�l���g�̐e�iParent�j�⎯�ʎq�iId�j�̕ێ�
    - �e�v���O�C�����ꊇ�Ǘ����� `TListViewEditPluginList` ����

  ���̋@�\�ɂ��A�Z�����ƂɈقȂ�ҏWUI�i��F�e�L�X�g�A�R���{�{�b�N�X�A�J�����_�[�Ȃǁj��
  ���I�Ɋ��蓖�Ă�_��ȕҏW�C���^�[�t�F�[�X���\�z�ł��܂��B
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,Vcl.StdCtrls,Vcl.ComCtrls,
  System.TypInfo,ListViewEx,ListViewRTTIList;

type TListViewEditPluginChanged = procedure(Sender : TObject;const EditStr : string) of object;

//--------------------------------------------------------------------------//
//  �O���ҏW�v���O�C���̊�b�N���X                                          //
//--------------------------------------------------------------------------//
type
	TListViewEditPlugin = class(TPersistent)
	private
		{ Private �錾 }
    FId           : Integer;                // �v���O�C��ID
    FParent       : TWinControl;            // �v���O�C���z�u�p�e�R���|�[�l���g
    FOnEdited     : TListViewEditPluginChanged;   // �ύX�C�x���g
    FOnEditCancel : TNotifyEvent;           // �ύX�L�����Z���C�x���g
  protected
    // �v�f�`��
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);virtual;
    // �ҏW�J�n
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect;dr : TListViewRTTIItem);virtual;abstract;
    // �ҏW����
    procedure DoEdited(const EditStr : string);virtual;
    // �ҏW�L�����Z��
    procedure DoEditCancel();virtual;
	public
		{ Public �錾 }
    procedure Draw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);
    property Id : Integer read FId;
    property Parent : TWinControl read FParent;
    // �ύX�C�x���g
    property OnEdited : TListViewEditPluginChanged read FOnEdited write FOnEdited;
    // �ύX�L�����Z���C�x���g
    property OnEditCancel : TNotifyEvent read FOnEditCancel write FOnEditCancel;
  end;

//--------------------------------------------------------------------------//
//  �O���ҏW�v���O�C�����X�g                                                //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginList = class(TList)
	private
		{ Private �錾 }
    FParent       : TWinControl;            // �v���O�C���z�u�p�e�R���|�[�l���g
    FOnEdited     : TListViewEditPluginChanged;   // �ύX�C�x���g
    FOnEditCancel : TNotifyEvent;           // �ύX�L�����Z���C�x���g
    function GetItems(Index: Integer): TListViewEditPlugin;
	public
		{ Public �錾 }
    destructor Destroy;override;
    // �ҏW�J�n
    procedure BeginEdit(Parent : TWinControl;var Component : TWinControl;EditType : Integer;r : TRect; dr : TListViewRTTIItem;aOnEdited : TListViewEditPluginChanged;aOnEditCancel : TNotifyEvent);

    procedure AddPlugin(EditType :  TListViewEditPlugin;var No : Integer);
    procedure Delete(Index : Integer);
    procedure Clear();override;
		property Items[Index: Integer] : TListViewEditPlugin read GetItems ;default;

	end;


var
  ListViewEditPlugins      : TListViewEditPluginList;      // �O���ҏW�v���O�C�����X�g

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
  Canvas.TextRect(r,r.Left+2,r.Top+2,dr.Value);  // �蓮�ŕ`��
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
