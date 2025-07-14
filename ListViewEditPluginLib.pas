unit ListViewEditPluginLib;
{
  ListViewEditPluginLib.pas
  ---------------------------------------------------------------------------
  ListViewEdit / ListViewRTTI �p�̎��p�I�ȃZ���ҏW�v���O�C���Q���`���郆�j�b�g�B

  �{���j�b�g�ł́ATListViewEditPlugin ���p�����������̋�ۃv���O�C����񋟂��A
  �e�Z���ɑ΂��ĈقȂ�ҏW�X�^�C���i�e�L�X�g�A�I�����A�ǂݎ���p�Ȃǁj��
  ���ۂɎ������邽�߂̊�ՂƂȂ�܂��B

  �܂܂���ȃN���X�F

    - TListViewEditPluginEdit
        TEdit ���g�p������{�I�ȕ�����ҏW�v���O�C��
        ���͊m��� OnEditExit �� Enter �L�[�ŏ���

    - TListViewEditPluginReadOnly
        �ҏW�R���|�[�l���g�𐶐������A�Z����\����p�ɂ���v���O�C��

    - TListViewEditPluginCustomComboBox
        TComboBox ���g�p�����I�����v���O�C��
        ��������̂��߂̃T�u�N���X TListViewEditPluginComboBoxHeight ���g�p

  �����̃v���O�C���́AListView �̊e�Z�����Ƃɓ��I�Ɋ��蓖�Ă邱�ƂŁA
  �_��Œ����I�ȕҏWUI���\�z���邱�Ƃ��\�ł��B
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,Vcl.ExtCtrls,
  ShellApi,ShlObj,CommCtrl,Menus, ListViewEditPlugin,ListViewRTTIList;

//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� TEdit                                                    //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginEdit = class(TListViewEditPlugin)
	private
		{ Private �錾 }
    FEdit : TEdit;                            // �ҏW�pTEdit
    procedure OnEditExit(Sender: TObject);
    procedure OnEditKeyPress(Sender: TObject; var Key: Char);
  protected
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public �錾 }
    constructor Create(); virtual;
    destructor Destroy;override;
  end;

//--------------------------------------------------------------------------//
//  �ҏW���Ȃ��v���O�C��                                                    //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginReadOnly = class(TListViewEditPlugin)
	private
		{ Private �錾 }
  protected
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public �錾 }
  end;

 // ������ς�����R���{�{�b�N�X
type
  TListViewEditPluginComboBoxHeight = class(TComboBox)
  public
    procedure CreateParams(var Params: TCreateParams); override;
  end;

//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� TComboBox��b�N���X                                      //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginCustomComboBox = class(TListViewEditPlugin)
	private
		{ Private �錾 }
    procedure OnCBoxExit(Sender: TObject);
  protected
    FCBox : TListViewEditPluginComboBoxHeight;
    procedure SetComboBox(Parent : TWinControl;var Component : TWinControl;r : TRect;Items : TStringList;ItemIndex : Integer);
	public
		{ Public �錾 }
    constructor Create(); virtual;
    destructor Destroy;override;
  end;

//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� TComboBox Boolean��p                                    //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginBool = class(TListViewEditPluginCustomComboBox)
	private
		{ Private �錾 }
    procedure OnCBoxChange(Sender: TObject);
  protected
    // �v�f�`��
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public �錾 }
    constructor Create(); override;
  end;

//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� TComboBox                                                //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginComboBox = class(TListViewEditPluginCustomComboBox)
	private
		{ Private �錾 }
    procedure OnCBoxChange(Sender: TObject);
  protected
    // �v�f�`��
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public �錾 }
    constructor Create(); override;
  end;

//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� TComboBox  �l�� Items.Object���̗p����                   //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginComboBoxObject = class(TListViewEditPluginCustomComboBox)
	private
		{ Private �錾 }
    procedure OnCBoxChange(Sender: TObject);
  protected
    // �v�f�`��
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
	public
		{ Public �錾 }
    constructor Create(); override;
  end;

var
  ListViewEditPluginHide             : TListViewEditPlugin;
  ListViewEditPluginHideId           : Integer;                 // �v�f��\��

  ListViewEditPluginReadOnly         : TListViewEditPluginReadOnly;
  ListViewEditPluginReadOnlyId       : Integer;                 // �ҏW�@�\����

  ListViewEditPluginEdit             : TListViewEditPluginEdit;   // TEdit�ҏW�v���O�C��
  ListViewEditPluginEditId           : Integer;                 // TEdit�ҏW�v���O�C��ID  �����Ԃ�0

  ListViewEditPluginBool             : TListViewEditPluginBool;
  ListViewEditPluginBoolId           : Integer;                 // TComboBox���w�肷��Ƃ���ID

  ListViewEditPluginComboBox         : TListViewEditPluginComboBox;
  ListViewEditPluginComboBoxId       : Integer;                 // TComboBox���w�肷��Ƃ���ID

  ListViewEditPluginComboBoxObject   : TListViewEditPluginComboBoxObject;
  ListViewEditPluginComboBoxObjectId : Integer;                 // TComboBox���w�肷��Ƃ���ID

implementation


{ TListViewEditTypeEdit }

//--------------------------------------------------------------------------//
//  �N���X����                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEditPluginEdit.Create;
begin
  FEdit := TEdit.Create(nil);
  FEdit.OnExit := OnEditExit;
  FEdit.OnKeyPress := OnEditKeyPress;
end;

//--------------------------------------------------------------------------//
//  �N���X�j��                                                              //
//--------------------------------------------------------------------------//
destructor TListViewEditPluginEdit.Destroy;
begin
  //FEdit.Free;
  inherited;
end;

//--------------------------------------------------------------------------//
//  �ҏW�J�n                                                                //
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
//  �t�H�[�J�X����                                                          //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginEdit.OnEditExit(Sender: TObject);
begin
  FEdit.Visible := False;                   // ��\��
  DoEditCancel();                           // �L�����Z���C�x���g�ʒm
end;

//--------------------------------------------------------------------------//
//  �L�[�~���C�x���g                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginEdit.OnEditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #$0d : begin                            // �G���^�[�L�[
      DoEdited(FEdit.Text);                 // �ҏW�����C�x���g����
      FEdit.Visible := False;               // ��\��
      Key := #0;                            // �L�[���󂯎�葼�ŏ��������Ȃ�
    end;
    #$1b : begin                            // �G�X�P�[�v�L�[
      FEdit.Visible := False;               // ��\��
      DoEditCancel();                       // �L�����Z���C�x���g����
      Key := #0;
    end;
  end;
end;


{ TListViewEditTypeCustomComboBox }

//--------------------------------------------------------------------------//
//  �N���X����                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEditPluginCustomComboBox.Create;
begin
  FCBox := TListViewEditPluginComboBoxHeight.Create(nil);
  FCBox.Style := csDropDownList;
  FCBox.OnExit := OnCBoxExit;
end;

//--------------------------------------------------------------------------//
//  �N���X�j��                                                              //
//--------------------------------------------------------------------------//
destructor TListViewEditPluginCustomComboBox.Destroy;
begin
  //FCBox.Free;
  inherited;
end;


//--------------------------------------------------------------------------//
//  �t�H�[�J�X�����C�x���g                                                  //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginCustomComboBox.OnCBoxExit(Sender: TObject);
begin
  FCBox.Visible := False;                   // ��\��
  DoEditCancel();                           // �L�����Z���C�x���g����
end;


//--------------------------------------------------------------------------//
//  TComboBox�ݒ�                                                           //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginCustomComboBox.SetComboBox(Parent: TWinControl;
  var Component: TWinControl; r: TRect;Items : TStringList;
  ItemIndex: Integer);
begin
  Component := FCBox;                       // �ҏW�p�R���|�[�l���g�Ƃ��ēo�^
  FCBox.Parent := Parent;                   // ComboBox���w�肳�ꂽ�I�u�W�F�N�g�ɔz�u

  FCBox.Items.BeginUpdate();
  FCBox.Left        := r.Left;              // �����ʒu���킹
  FCBox.Top         := r.Top;               // �㑤�ʒu���킹
  FCBox.Width       := r.Width;             // �����ʒu���킹
  FCBox.Height      := r.Height;            // �����ʒu���킹
  FCBox.ItemHeight  := r.Height;            // ���ڂ̍����ʒu���킹
  FCBox.Items.Assign(Items);                // �I��v�f��o�^
  FCBox.ItemIndex   := ItemIndex;           // �I�𒆂Ƃ���v�f�w��
  FCBox.Visible     := True;                // �\��
  if not FCBox.DroppedDown then begin
    FCBox.DroppedDown := True;                // �h���b�v�_�E�����X�g�\��
  end;
  FCBox.Items.EndUpdate();
  FCBox.SetFocus;                           // �t�H�[�J�X��ԂƂ���

end;

{ TListViewEditTypeBool }

//--------------------------------------------------------------------------//
//  �N���X����                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEditPluginBool.Create;
begin
  inherited;
  FCBox.OnChange := OnCBoxChange;
end;

//--------------------------------------------------------------------------//
//  �`��C�x���g                                                           //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginBool.DoDraw(Canvas: TCanvas; r: TRect;dr : TListViewRTTIItem);
var
  s: string;
  i : Integer;
begin
  i := StrToIntDef(dr.Value,-1);            // ���ݒl�� 0 1�Ŏ擾
  s := '';

  if dr.Strings.Count = 2 then begin        // ���ڃ��X�g�ɗv�f�̎w�肪����ꍇ
    if i <> -1 then begin
      s := dr.Strings[i];                     // �v�f�̕\�����̗p
    end;
  end
  else begin                                // �v�f�̎w�肪�Ȃ��ꍇ
    if i = 0 then s := 'false';             // 0:false
    if i = 1 then s := 'true';              // 1:true
  end;
  Canvas.TextRect(r,r.Left+2,r.Top+2,s);    // �蓮�ŕ`��
end;

//--------------------------------------------------------------------------//
//  �ҏW�J�n                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginBool.DoEditing(Parent: TWinControl;var Component: TWinControl;r: TRect; dr : TListViewRTTIItem);
var
  i : Integer;
  ts : TStringList;
begin

  ts := TStringList.Create;
  try
    if dr.Strings.Count = 2 then begin        // ���ڃ��X�g�ɗv�f�̎w�肪����ꍇ
      ts.Assign(dr.Strings);                  // �w��̗v�f���̗p
    end
    else begin                                // �v�f�̎w�肪�Ȃ��ꍇ
      ts.Add('false');                        // 0:false
      ts.Add('true');                         // 1:true
    end;

    i := StrToIntDef(dr.Value,0);             // true false��Ԃ��擾

    SetComboBox(Parent,Component,r,ts,i);     // ComboBox�ݒ�
  finally
    ts.Free;
  end;
end;

//--------------------------------------------------------------------------//
//  �v�f�I���C�x���g                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginBool.OnCBoxChange(Sender: TObject);
var
  s : string;
begin
  s := IntToStr(FCBox.ItemIndex);           // �I����Ԃ𕶎��Ŏ擾
  DoEdited(s);                              // �ҏW�����C�x���g����
  FCBox.Visible := False;
end;


{ TComboBoxHeight }

procedure TListViewEditPluginComboBoxHeight.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // �f�t�H���g�ł�CBS_DROPDOWN���ݒ肳��Ă���͂��Ȃ̂�
  // ����ɃI�[�i�[�`��X�^�C����ǉ�����
  Params.Style := Params.Style or CBS_OWNERDRAWFIXED;
end;

{ TListViewEditTypeComboBox }

constructor TListViewEditPluginComboBox.Create;
begin
  inherited;
  FCBox.OnChange := OnCBoxChange;
end;

//--------------------------------------------------------------------------//
//  �`��C�x���g                                                           //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBox.DoDraw(Canvas: TCanvas; r: TRect; dr: TListViewRTTIItem);
var
  s: string;
  i : Integer;
begin
  i := StrToIntDef(dr.Value,-1);            // ���ݒl�� 0 1�Ŏ擾
  if i < 0 then exit;
  if i > dr.Strings.Count-1 then exit;
  s := dr.Strings[i];                     // �v�f�̕\�����̗p
  Canvas.TextRect(r,r.Left+2,r.Top+2,s);    // �蓮�ŕ`��

end;

//--------------------------------------------------------------------------//
//  �ҏW�J�n                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBox.DoEditing(Parent: TWinControl;
  var Component: TWinControl;r: TRect;dr: TListViewRTTIItem);
var
  i : Integer;
begin
  i := StrToIntDef(dr.Value,0);             // ��Ԃ��擾
  if i > dr.Strings.Count-1 then i := -1;

  SetComboBox(Parent,Component,r,dr.Strings,i);
end;

//--------------------------------------------------------------------------//
//  �v�f�I���C�x���g                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBox.OnCBoxChange(Sender: TObject);
var
  s : string;
begin
  s := IntToStr(FCBox.ItemIndex);           // �I����Ԃ𕶎��Ŏ擾
  DoEdited(s);                              // �ҏW�����C�x���g����
end;


{ TListViewEditTypeComboBoxObject }

constructor TListViewEditPluginComboBoxObject.Create;
begin
  inherited;
  FCBox.OnChange := OnCBoxChange;
end;

//--------------------------------------------------------------------------//
//  �`��C�x���g                                                           //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBoxObject.DoDraw(Canvas: TCanvas; r: TRect; dr: TListViewRTTIItem);
var
  s: string;
  i,v : Integer;
begin
  v := StrToIntDef(dr.Value,-1);             // ���ݒl���擾
  i := dr.Strings.IndexOfObject(TObject(v)); // ���X�g�̒l���猟��
  if i = -1 then exit;
  if i > dr.Strings.Count-1 then exit;
  s := dr.Strings[i];                        // �v�f�̕\�����̗p
  Canvas.TextRect(r,r.Left+2,r.Top+2,s);     // �蓮�ŕ`��
end;

//--------------------------------------------------------------------------//
//  �ҏW�J�n                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBoxObject.DoEditing(Parent: TWinControl;
  var Component: TWinControl;r: TRect;dr: TListViewRTTIItem);
var
  i,v : Integer;
begin
  v := StrToIntDef(dr.Value,0);             // ��Ԃ��擾
  i := dr.Strings.IndexOfObject(TObject(v)); // ���X�g�̒l���猟��
  SetComboBox(Parent,Component,r,dr.Strings,i);
end;

//--------------------------------------------------------------------------//
//  �v�f�I���C�x���g                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginComboBoxObject.OnCBoxChange(Sender: TObject);
var
  s : string;
  i,v : Integer;
begin
  i := FCBox.ItemIndex;
  v := Integer(FCBox.Items.Objects[i]);     // �I���A�C�e���̃I�u�W�F�N�g�擾
  s := IntToStr(v);                         // �I�u�W�F�N�g�𕶎���
  DoEdited(s);                              // �ҏW�����C�x���g����
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
