unit ListViewEditPluginDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ListViewEditPlugin,ListViewRTTIList;

//--------------------------------------------------------------------------//
//  各ダイアログに対応する基本フレーム                                      //
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
    { Private 宣言 }
    FOwner     : TObject;                          // TListViewEditDialogを逆参照
    FRtti      : TListViewRTTIItem;
    //FOnChange  : TNotifyEvent;
  protected
      //procedure DoChange();virtual;
  public
    { Public 宣言 }
    property Rtti      : TListViewRTTIItem read FRtti;
  end;

//--------------------------------------------------------------------------//
//  ダイアログ編集プラグイン基礎クラス                                      //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginDialog = class(TListViewEditPlugin)
	private
		{ Private 宣言 }
    procedure OnEditExit(Sender: TObject);
    procedure OnEditKeyPress(Sender: TObject; var Key: Char);
  protected
    // ダイアログ用フレーム
    FFrame : TFrameListViewEditPluginDialog;
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();virtual;abstract;
	public
		{ Public 宣言 }
    constructor Create(); virtual;
    destructor Destroy;override;

  end;

//--------------------------------------------------------------------------//
//  編集プラグイン TColorDialog                                             //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginColorDialog = class(TListViewEditPluginDialog)
	private
		{ Private 宣言 }
    procedure OnEditKeyPress(Sender: TObject; var Key: Char);
    function GetColorDialog: TColorDialog;
  protected
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();override;
	public
		{ Public 宣言 }
    constructor Create(); override;

    property ColorDialog : TColorDialog read GetColorDialog;
  end;


//--------------------------------------------------------------------------//
//  編集プラグイン TColorDialog                                             //
//--------------------------------------------------------------------------//
type
	TListViewEditPluginFontDialog = class(TListViewEditPluginDialog)
	private
		{ Private 宣言 }
    function GetFontDialog: TFontDialog;
  protected
    procedure DoDraw(Canvas : TCanvas;r : TRect;dr : TListViewRTTIItem);override;
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();override;
	public
		{ Public 宣言 }
    property FontDialog :  TFontDialog read GetFontDialog;
  end;

//--------------------------------------------------------------------------//
//  編集プラグイン FileOpenDialog                                           //
//--------------------------------------------------------------------------//
type
	TListViewEditOpenFileDialog = class(TListViewEditPluginDialog)
	private
		{ Private 宣言 }
    function GetOpenDialog: TOpenDialog;
  protected
    procedure DoEditing(Parent : TWinControl;var Component : TWinControl;r : TRect; dr : TListViewRTTIItem);override;
    procedure DoOpenDialog();override;
	public
		{ Public 宣言 }
    property OpenDialog : TOpenDialog read GetOpenDialog;
  end;



var
  ListViewEditPluginColorDialog    : TListViewEditPluginColorDialog;   // TColorDialog編集プラグイン
  ListViewEditPluginColorDialogId  : Integer;                        // TColorDialog編集プラグインID

  ListViewEditPluginFontDialog    : TListViewEditPluginFontDialog;     // TColorDialog編集プラグイン
  ListViewEditPluginFontDialogId  : Integer;                         // TColorDialog編集プラグインID

  ListViewEditPluginOpenDialog    : TListViewEditOpenFileDialog;        // TOpenDialog編集プラグイン
  ListViewEditPluginOpenDialogId  : Integer;                         // TOpenDialog編集プラグインID


// 色を示す表示を描画
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
  cv.TextRect(Rect,Rect.Left+2,Rect.Top+2,aFontName);  // 手動で描画
end;

procedure ListDraw(cv : TCanvas;Rect : TRect;aFontName : string);
begin
  cv.TextRect(Rect,Rect.Left+2,Rect.Top+2,aFontName);  // 手動で描画
end;


//--------------------------------------------------------------------------//
//  描画イベント                                                            //
//--------------------------------------------------------------------------//
procedure TFrameListViewEditPluginDialog.LBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  TListViewEditPluginDialog(FOwner).DoDraw(LBox.Canvas,Rect,FRtti);
end;


//--------------------------------------------------------------------------//
//  「..」クリックイベント                                                  //
//--------------------------------------------------------------------------//
procedure TFrameListViewEditPluginDialog.btnDialogClick(Sender: TObject);
begin
  TListViewEditPluginDialog(FOwner).DoOpenDialog();
end;



{ TListViewEditPluginColorDialog }

//--------------------------------------------------------------------------//
//  クラス生成                                                              //
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
//  編集開始                                                                //
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
  DoEdited(IntToStr(FFrame.Color));                 // 編集完了イベント発生
  FFrame.Visible := False;                        // 非表示
end;

function TListViewEditPluginColorDialog.GetColorDialog: TColorDialog;
begin
  result := FFrame.DlgColor;
end;

//--------------------------------------------------------------------------//
//  キー降下イベント                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginColorDialog.OnEditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #$0d : begin                            // エンターキー
      DoEdited(IntToStr(FFrame.Color));                 // 編集完了イベント発生
      FFrame.Visible := False;               // 非表示
      Key := #0;                            // キーを受け取り他で処理させない
    end;
    #$1b : begin                            // エスケープキー
      FFrame.Visible := False;               // 非表示
      DoEditCancel();                       // キャンセルイベント発生
      Key := #0;
    end;
  end;
end;

{ TListViewEditPluginDialog }

//--------------------------------------------------------------------------//
//  クラス生成                                                              //
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
//  クラス破棄                                                              //
//--------------------------------------------------------------------------//
destructor TListViewEditPluginDialog.Destroy;
begin

  inherited;
end;

//--------------------------------------------------------------------------//
//  描画イベント                                                            //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginDialog.DoDraw(Canvas: TCanvas; r: TRect;dr: TListViewRTTIItem);
begin
  Canvas.TextRect(r,r.Left+2,r.Top+2,dr.Value);  // 手動で描画
end;

//--------------------------------------------------------------------------//
//  編集開始                                                                //
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
//  フォーカス消失                                                          //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginDialog.OnEditExit(Sender: TObject);
begin
  FFrame.Visible := False;                   // 非表示
  DoEditCancel();                           // キャンセルイベント通知
end;

//--------------------------------------------------------------------------//
//  キー降下イベント                                                        //
//--------------------------------------------------------------------------//
procedure TListViewEditPluginDialog.OnEditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #$0d : begin                            // エンターキー
      DoEdited(FFrame.FRtti.Value);         // 編集完了イベント発生
      FFrame.Visible := False;              // 非表示
      Key := #0;                            // キーを受け取り他で処理させない
    end;
    #$1b : begin                            // エスケープキー
      FFrame.Visible := False;              // 非表示
      DoEditCancel();                       // キャンセルイベント発生
      Key := #0;
    end;
  end;
end;

{ TListViewEditPluginFontDialog }

procedure TListViewEditPluginFontDialog.DoDraw(Canvas: TCanvas; r: TRect;dr: TListViewRTTIItem);
begin
  Canvas.Font.Name := dr.Value;
  Canvas.TextRect(r,r.Left+2,r.Top+2,dr.Value);  // 手動で描画
end;

//--------------------------------------------------------------------------//
//  編集開始                                                                //
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
  DoEdited(FFrame.DlgFont.Font.Name);             // 編集完了イベント発生
  FFrame.Visible := False;                        // 非表示
end;

function TListViewEditPluginFontDialog.GetFontDialog: TFontDialog;
begin
  result := FFrame.DlgFont;
end;

{ TListViewEditTypeEdit }

//--------------------------------------------------------------------------//
//  編集開始                                                                //
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
  FFrame.DlgOpen.Title := 'ファイルの選択';
  if not FFrame.DlgOpen.Execute() then exit;
  DoEdited(FFrame.DlgOpen.FileName);              // 編集完了イベント発生
  FFrame.Visible := False;                        // 非表示
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
