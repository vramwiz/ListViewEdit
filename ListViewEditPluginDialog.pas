unit ListViewEditPluginDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ListViewEditPlugin,ListViewRTTIList;

//--------------------------------------------------------------------------//
//  �e�_�C�A���O�ɑΉ������{�t���[��                                      //
//--------------------------------------------------------------------------//
type
  TFrameListViewEditPluginDialog = class(TFrame)
    btnDialog: TButton;
    DlgColor: TColorDialog;
    LBox: TListBox;
    DlgFont: TFontDialog;
    DlgOpen: TOpenDialog;
    procedure btnDialogClick(Sender: TObject);
    procedure LBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure FrameResize(Sender: TObject);
  private
    { Private �錾 }
    FOwner     : TObject;                          // TListViewEditDialog���t�Q��
    FRtti      : TListViewRTTIItem;
    //FOnChange  : TNotifyEvent;
  protected
      //procedure DoChange();virtual;
  public
    { Public �錾 }
    property Rtti      : TListViewRTTIItem read FRtti;
  end;

//--------------------------------------------------------------------------//
//  �_�C�A���O�ҏW�v���O�C����b�N���X                                      //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginDialog = class(TListViewEditPlugin)
	private
		{ Private �錾 }
    procedure OnEditExit(Sender: TObject);
    procedure OnEditKeyPress(Sender: TObject; var Key: Char);
  protected
    // �_�C�A���O�p�t���[��
    FFrame : TFrameListViewEditPluginDialog;
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();virtual;abstract;
	public
		{ Public �錾 }
    constructor Create(); virtual;
    destructor Destroy;override;

  end;

//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� TColorDialog                                             //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginColorDialog = class(TListViewEditPluginDialog)
	private
		{ Private �錾 }
    procedure OnEditKeyPress(Sender: TObject; var Key: Char);
    function GetColorDialog: TColorDialog;
  protected
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();override;
	public
		{ Public �錾 }
    constructor Create(); override;

    property ColorDialog : TColorDialog read GetColorDialog;
  end;


//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� TColorDialog                                             //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginFontDialog = class(TListViewEditPluginDialog)
	private
		{ Private �錾 }
    function GetFontDialog: TFontDialog;
  protected
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();override;
	public
		{ Public �錾 }
    property FontDialog :  TFontDialog read GetFontDialog;
  end;

//--------------------------------------------------------------------------//
//  �ҏW�v���O�C�� FileOpenDialog                                           //
//--------------------------------------------------------------------------//
type
	TListViewEditOpenFileDialog = class(TListViewEditPluginDialog)
	private
		{ Private �錾 }
    function GetOpenDialog: TOpenDialog;
  protected
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();override;
	public
		{ Public �錾 }
    property OpenDialog : TOpenDialog read GetOpenDialog;
  end;



var
  ListViewEditPluginColorDialog    : TListViewEditPluginColorDialog;   // TColorDialog�ҏW�v���O�C��
  ListViewEditPluginColorDialogId  : Integer;                        // TColorDialog�ҏW�v���O�C��ID

  ListViewEditPluginFontDialog    : TListViewEditPluginFontDialog;     // TColorDialog�ҏW�v���O�C��
  ListViewEditPluginFontDialogId  : Integer;                         // TColorDialog�ҏW�v���O�C��ID

  ListViewEditPluginOpenDialog    : TListViewEditOpenFileDialog;        // TOpenDialog�ҏW�v���O�C��
  ListViewEditPluginOpenDialogId  : Integer;                         // TOpenDialog�ҏW�v���O�C��ID


// �F�������\����`��
procedure ListDrawColor(cv : TCanvas;Rect : TRect;aColor : TColor);


implementation

uses  ShlObj, ActiveX;

{$R *.dfm}


procedure TFrameListViewEditPluginDialog.FrameResize(Sender: TObject);
begin
  LBox.ItemHeight := Height;
end;

procedure ListDrawColor(cv : TCanvas;Rect : TRect;aColor : TColor);
var
  r : TRect;
  s : string;
  rgb,ir,ig,ib : Integer;
begin
  cv.Pen.Color := clBlack;
  cv.Brush.Color := aColor;
  r := Rect;
  r.Left := r.Left + 2;
  r.Top := r.Top + 2;
  r.Bottom := r.Top + 15;
  r.Width := 32;
  cv.Rectangle(r);

  rgb := ColorToRGB(aColor);
  ir := LOBYTE(LOWORD(rgb));
  ig := HIBYTE(LOWORD(rgb));
  ib := LOBYTE(HIWORD(rgb));
  s := Format('R%3.3d G%3.3d B%3.3d' ,[ir,ig,ib]);

  cv.Brush.Color := clWhite;
  cv.Font.Color := clBlack;
  cv.Brush.Style := bsClear;
  r := Rect;
  r.Left := r.Left + 40;
  r.Top := r.Top + 2;
  cv.TextRect(r,r.Left,r.Top,s);
end;

procedure ListDrawFont(cv : TCanvas;Rect : TRect;aFontName : string);
begin
  cv.Font.Name := aFontName;
  cv.TextRect(Rect,Rect.Left+2,Rect.Top+2,aFontName);  // �蓮�ŕ`��
end;

procedure ListDraw(cv : TCanvas;Rect : TRect;aFontName : string);
begin
  cv.TextRect(Rect,Rect.Left+2,Rect.Top+2,aFontName);  // �蓮�ŕ`��
end;


//--------------------------------------------------------------------------//
//  �`��C�x���g                                                            //
//--------------------------------------------------------------------------//
procedure TFrameListViewEditPluginDialog.LBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  TListViewEditPluginDialog(FOwner).DoDraw(LBox.Canvas,Rect,FRtti);
end;


//--------------------------------------------------------------------------//
//  �u..�v�N���b�N�C�x���g                                                  //
//--------------------------------------------------------------------------//
procedure TFrameListViewEditPluginDialog.btnDialogClick(Sender: TObject);
begin
  TListViewEditPluginDialog(FOwner).DoOpenDialog();
end;



{ TListViewEditPluginColorDialog }

//--------------------------------------------------------------------------//
//  �N���X����                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEditPluginColorDialog.Create;
begin
  inherited;
  FFrame.OnKeyPress := OnEditKeyPress;
  //FFrame.OnChange := OnChange;
end;

procedure TListViewEditPluginColorDialog.DoDraw(Canvas: TCanvas; r: TRect;dr: TListViewRTTIItem);
var
  c : TColor;
begin
  c := StrToIntDef(dr.Value,0);
  ListDrawColor(Canvas,r,c);
end;

//--------------------------------------------------------------------------//
//  �ҏW�J�n                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginColorDialog.DoEditing(Parent : TWinControl;var Component : TWinControl;r: TRect; dr : TListViewRTTIItem);
begin
  inherited;
  FFrame.Color := StrToIntDef(dr.Value,0);
end;

procedure TListViewEditPluginColorDialog.DoOpenDialog;
begin
  FFrame.DlgColor.Color := StrToIntDef(FFrame.FRtti.Value,0);
  if not FFrame.DlgColor.Execute() then exit;
  FFrame.Color := FFrame.DlgColor.Color;
  //FFrame.DoChange();
  DoEdited(IntToStr(FFrame.Color));                 // �ҏW�����C�x���g����
  FFrame.Visible := False;                        // ��\��
end;

function TListViewEditPluginColorDialog.GetColorDialog: TColorDialog;
begin
  result := FFrame.DlgColor;
end;

//--------------------------------------------------------------------------//
//  �L�[�~���C�x���g                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginColorDialog.OnEditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #$0d : begin                            // �G���^�[�L�[
      DoEdited(IntToStr(FFrame.Color));                 // �ҏW�����C�x���g����
      FFrame.Visible := False;               // ��\��
      Key := #0;                            // �L�[���󂯎�葼�ŏ��������Ȃ�
    end;
    #$1b : begin                            // �G�X�P�[�v�L�[
      FFrame.Visible := False;               // ��\��
      DoEditCancel();                       // �L�����Z���C�x���g����
      Key := #0;
    end;
  end;
end;

{ TListViewEditPluginDialog }

//--------------------------------------------------------------------------//
//  �N���X����                                                              //
//--------------------------------------------------------------------------//
constructor TListViewEditPluginDialog.Create;
begin
  FFrame := TFrameListViewEditPluginDialog.Create(nil);
  FFrame.FOwner := Self;
  FFrame.OnExit := OnEditExit;
  FFrame.OnKeyPress := OnEditKeyPress;
  //FFrame.OnChange := OnChange;
end;

//--------------------------------------------------------------------------//
//  �N���X�j��                                                              //
//--------------------------------------------------------------------------//
destructor TListViewEditPluginDialog.Destroy;
begin

  inherited;
end;

//--------------------------------------------------------------------------//
//  �`��C�x���g                                                            //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginDialog.DoDraw(Canvas: TCanvas; r: TRect;dr: TListViewRTTIItem);
begin
  Canvas.TextRect(r,r.Left+2,r.Top+2,dr.Value);  // �蓮�ŕ`��
end;

//--------------------------------------------------------------------------//
//  �ҏW�J�n                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginDialog.DoEditing(Parent: TWinControl;
  var Component: TWinControl;r: TRect;dr: TListViewRTTIItem);
begin
  Component      := FFrame;
  FFrame.Visible := False;
  FFrame.Parent  := Parent;
  FFrame.Left    := r.Left;
  FFrame.Top     := r.Top;
  FFrame.Width   := r.Width;
  FFrame.Height  := r.Height;
  FFrame.Anchors := [akLeft, akRight, akTop, akBottom];
  FFrame.BevelOuter := bvNone;
  FFrame.BevelInner := bvNone;
  FFrame.FRtti   := dr;
  FFrame.Visible := True;
  FFrame.SetFocus;
  if FFrame.LBox.Count = 0 then begin
    FFrame.LBox.Items.Add('');
  end;
  FFrame.LBox.Items.Strings[0] := '';
end;


//--------------------------------------------------------------------------//
//  �t�H�[�J�X����                                                          //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginDialog.OnEditExit(Sender: TObject);
begin
  FFrame.Visible := False;                   // ��\��
  DoEditCancel();                           // �L�����Z���C�x���g�ʒm
end;

//--------------------------------------------------------------------------//
//  �L�[�~���C�x���g                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginDialog.OnEditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #$0d : begin                            // �G���^�[�L�[
      DoEdited(FFrame.FRtti.Value);         // �ҏW�����C�x���g����
      FFrame.Visible := False;              // ��\��
      Key := #0;                            // �L�[���󂯎�葼�ŏ��������Ȃ�
    end;
    #$1b : begin                            // �G�X�P�[�v�L�[
      FFrame.Visible := False;              // ��\��
      DoEditCancel();                       // �L�����Z���C�x���g����
      Key := #0;
    end;
  end;
end;

{ TListViewEditPluginFontDialog }

procedure TListViewEditPluginFontDialog.DoDraw(Canvas: TCanvas; r: TRect;dr: TListViewRTTIItem);
begin
  Canvas.Font.Name := dr.Value;
  Canvas.TextRect(r,r.Left+2,r.Top+2,dr.Value);  // �蓮�ŕ`��
end;

//--------------------------------------------------------------------------//
//  �ҏW�J�n                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginFontDialog.DoEditing(Parent : TWinControl;var Component : TWinControl;r: TRect; dr : TListViewRTTIItem);
begin
  FFrame.Font.Name   := dr.Value;
  inherited;
  //FFrame.OnChange := OnChange;
end;


procedure TListViewEditPluginFontDialog.DoOpenDialog;
begin
  FFrame.DlgFont.Font.Name := FFrame.FRtti.Value;
  if not FFrame.DlgFont.Execute() then exit;
  DoEdited(FFrame.DlgFont.Font.Name);             // �ҏW�����C�x���g����
  FFrame.Visible := False;                        // ��\��
end;

function TListViewEditPluginFontDialog.GetFontDialog: TFontDialog;
begin
  result := FFrame.DlgFont;
end;

{ TListViewEditTypeEdit }

//--------------------------------------------------------------------------//
//  �ҏW�J�n                                                                //
//--------------------------------------------------------------------------//
procedure TListViewEditOpenFileDialog.DoEditing(Parent : TWinControl;var Component : TWinControl;r: TRect; dr : TListViewRTTIItem);
begin
  inherited;
  FFrame.DlgOpen.FileName := dr.Value;
end;

procedure TListViewEditOpenFileDialog.DoOpenDialog;
begin
  FFrame.DlgOpen.InitialDir := ExtractFilePath(FFrame.FRtti.Value);
  FFrame.DlgOpen.FileName := ExtractFileName(FFrame.FRtti.Value);
  FFrame.DlgOpen.Title := '�t�@�C���̑I��';
  if not FFrame.DlgOpen.Execute() then exit;
  DoEdited(FFrame.DlgOpen.FileName);              // �ҏW�����C�x���g����
  FFrame.Visible := False;                        // ��\��
end;

function TListViewEditOpenFileDialog.GetOpenDialog: TOpenDialog;
begin
  result := FFrame.DlgOpen;
end;



initialization

  ListViewEditPluginColorDialog := TListViewEditPluginColorDialog.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginColorDialog,ListViewEditPluginColorDialogId);

  ListViewEditPluginFontDialog := TListViewEditPluginFontDialog.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginFontDialog,ListViewEditPluginFontDialogId);

  ListViewEditPluginOpenDialog := TListViewEditOpenFileDialog.Create();
  ListViewEditPlugins.AddPlugin(ListViewEditPluginOpenDialog,ListViewEditPluginOpenDialogId);


finalization



end.
