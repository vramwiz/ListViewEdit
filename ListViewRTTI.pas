unit ListViewRTTI;
{
  ListViewRTTI.pas
  ---------------------------------------------------------------------------
  ���s���^��� (RTTI) �Ɋ�Â����ҏW�Ή� ListView �R���|�[�l���g
  TListViewRTTI ���`���郆�j�b�g�B

  �{�N���X�� TListViewEdit ���p�����A�C�ӂ̃I�u�W�F�N�g���� RTTI �ɂ��
  �v���p�e�B�����擾���A����� ListView ��Ɏ����\���E�ҏW�\�ɂ��܂��B

  ��ȋ@�\�F
    - LoadFromObject �ɂ��ATObject �h���N���X�̃v���p�e�B�����X�g�\��
    - �Z���ҏW���̒l�́A�Y���I�u�W�F�N�g�̃v���p�e�B�ɔ��f�����
    - �C�ӂ̕\�����ǉ����� AddCaption ���\�b�h���
    - �ҏW�������ɒʒm����� OnDataChange �C�x���g�𑕔�
    - �ҏW���̓��������� DoChange ���I�[�o�[���C�h���Đ���

  �܂��ARTTI ���ڂ� RTTINames[�v���p�e�B��] �ŃA�N�Z�X�\�ł��B

  �{�R���|�[�l���g�́A�ݒ�G�f�B�^��f�o�b�O�p�̉����c�[���Ȃǂɂ����āA
  Delphi �I�u�W�F�N�g�̏�Ԃ����̂܂� GUI ��ő��삵������ʂŗL���ł��B
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,ListViewEdit, Vcl.Menus,Vcl.StdCtrls,Vcl.ComCtrls,
  System.TypInfo,ListViewEx,ListViewRTTIList;


//--------------------------------------------------------------------------//
//  ���s���^�������N���X��\���ҏW����N���X                            //
//--------------------------------------------------------------------------//
type
   TListViewRTTI = class(TListViewEdit)
  private
    { Private �錾 }
    FOnDataChange : TNotifyEvent;

    procedure SetColumn();

    procedure OnSelfResize(Sender: TObject);


    procedure SetFixedWidth(const Value: Integer);
    function GetRTTINames(Name: string): TListViewRTTIItem;

  protected
    // ���X�N���[���o�[��\��
    //procedure UpdateScrollBar;
    procedure DoChange(const EditStr : string;const aColumn,aIndex : Integer);override;
    //procedure DoDataType(const aColumn,aIndex : Integer;var DataType : Integer);virtual;

  public
    { Public �錾 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
    // �w�肵���I�u�W�F�N�g�������ɕҏW��ʂ��쐬
    procedure LoadFromObject(aObject : TObject);
    // �l�̂ݍX�V
    procedure Refresh();
    // �ϐ����ɊY������ݒ薼�q���g�ҏW���@�����蓖�Ă�
    function AddCaption(const PName,Caption : string;Hint : string = '';aType : Integer = 0) : TListViewRTTIItem;
    // ��ҏW�\���̕����w��
    property FixedWidth : Integer write SetFixedWidth;
    property RTTINames[Name : string] : TListViewRTTIItem read GetRTTINames;
    //
    property OnDataChange : TNotifyEvent read FOnDataChange write FOnDataChange;
  end;


implementation

uses ListViewEditPluginLib;

{ TListViewEditRtti }

//--------------------------------------------------------------------------//
//  �N���X����                                                              //
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
//  �N���X�j��                                                              //
//--------------------------------------------------------------------------//
destructor TListViewRTTI.Destroy;
begin
  inherited;
end;

//--------------------------------------------------------------------------//
//  �ҏW�����C�x���g                                                        //
//--------------------------------------------------------------------------//
procedure TListViewRTTI.DoChange(const EditStr: string;const aColumn,aIndex : Integer);
var
  dr : TListViewRTTIItem;
  s : string;
begin
  dr := FRowSettings[FVisibleIndexes[aIndex]];    // �^���N���X�Q��
  s := EditStr;                                   // �ҏW��̒l���擾
  FRowSettings.RttiWrite(dr.PName,s);             // ���s���^���ɒl����������
  dr.Value := s;                                 // ���s���^���N���X�ɏ�������
  //dr.DoRequestEdited();
  //DoDataChange();

end;


//--------------------------------------------------------------------------//
//  �N���X�̒l�ҏW�\��                                                      //
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
    FVisibleIndexes.Add(i);                   // ��\���������Z
  end;
  Refresh();
end;

//--------------------------------------------------------------------------//
//  �N���X�̒l�\���X�V                                                      //
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
    FVisibleIndexes.Add(i);                   // ��\���������Z
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
  HorzScrollBarVisible := False;                         // ���X�N���[���o�[��\��
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
//  �Œ�s�̐ݒ�                                                            //
//--------------------------------------------------------------------------//
procedure TListViewRTTI.SetColumn;
var
  dc : TListColumn;
begin
  Columns.Clear;                     // �J������������

  dc := Columns.Add;                 // �t�@�C�����̕\���ǉ�
  dc.Caption := '����';              // �\��̖��̂�ݒ�
  dc.Width := 160;                   // �\��̕���ݒ�

  dc := Columns.Add;                 // �t�@�C�����̕\���ǉ�
  dc.Caption := '�l';                // �\��̖��̂�ݒ�
  AdjustColumnsToHeader();
  //ColumnAlign(1);
end;

procedure TListViewRTTI.SetFixedWidth(const Value: Integer);
begin
  Columns[0].Width := Value;
end;



end.
