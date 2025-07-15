object FrameListViewEditPluginDialog: TFrameListViewEditPluginDialog
  Left = 0
  Top = 0
  Width = 309
  Height = 23
  TabOrder = 0
  OnResize = FrameResize
  object btnDialog: TButton
    Left = 0
    Top = 0
    Width = 29
    Height = 23
    Align = alLeft
    Caption = '..'
    TabOrder = 0
    OnClick = btnDialogClick
  end
  object LBox: TListBox
    Left = 29
    Top = 0
    Width = 280
    Height = 23
    Style = lbOwnerDrawFixed
    Align = alClient
    ItemHeight = 15
    TabOrder = 1
    OnDrawItem = LBoxDrawItem
  end
  object DlgColor: TColorDialog
    Left = 144
    Top = 8
  end
  object DlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 208
    Top = 65531
  end
  object DlgOpen: TOpenDialog
    Left = 112
    Top = 65531
  end
end
