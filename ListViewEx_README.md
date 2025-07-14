# ListViewEx - 拡張 TListView コンポーネント

この README は `ListViewEx.pas` ユニットに関する説明です。

`TListViewEx` は Delphi 標準の `TListView` を拡張したカスタムコンポーネントです。  
主に表示・描画・操作面の機能を強化し、より柔軟なリストビュー表現を可能にします。

## 主な機能

- **行の高さを設定可能**：`ItemHeight` プロパティにより、各行の高さをカスタマイズできます。
- **ストライプ背景**：`RowColorStriped` を有効にすると、奇数・偶数行で背景色を分けられます。
- **アイコン表示制御**：`EnableIcons(ViewStyle, IconSize)` および `DisableIcons()` によって、表示スタイルとアイコンサイズを柔軟に切り替え可能です。
- **オーナードロー対応の描画処理**：`DrawBack` および `OnSelfDrawItem` によって、独自の背景描画が行えます。
- **選択ユーティリティ**：
  - `SelectAll()`：すべての項目を選択
  - `SelectClear()`：選択解除
- **カラム操作**
  - `AdjustColumnsToHeader()`：カラム幅をヘッダーに合わせて調整
  - `ColumnAlign()` / `AutoAdjustColumnWidth()`：カラムの表示位置調整と自動幅調整

## 補助プロパティ／メソッド

- `Cells[ACol, ARow]`：セル単位での文字列アクセス（行・列インデックス）
- スクロールバーの表示制御（`SetHorzScrollBarVisible`, `SetVertScrollBarVisible`）

## 利用目的

このユニットは、標準 `TListView` の不足を補い、以下のような用途で利用されます：

- 高度なデータ表示の要件がある管理ツール
- 行単位での強調表示やカスタム背景描画が必要なログビューア等
- 列幅の自動調整や選択処理の補助が求められるUI部品

