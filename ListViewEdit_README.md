# ListViewEdit - セル編集機能付き TListViewEx 拡張

この README は `ListViewEdit.pas` ユニットに関する説明です。

`TListViewEdit` は、`TListViewEx` を継承して作られた拡張コンポーネントであり、  
ListView の各セルに対して編集操作を提供する機能を追加しています。

## 主な機能

- **セル単位での編集機能**
  - 編集対象は `FEditIndex`（行）および `FEditColumn`（列）で指定されます。
  - 内部的に `TEdit` を重ねて表示し、ユーザー入力を可能にします。

- **編集スタイルの制御：`TListViewEditFixedStyle`**
  - `fsEditOnly` : 編集可能なのはセルのみ（アイテムは不可）
  - `fsVertical` : 行単位で固定し、縦方向だけ編集可
  - `fsHorizontal` : 横方向（列）だけ編集可
  - `fsVerticalFixedColumn` : 1列目など、特定列を編集不可に

- **編集イベントのフック**
  - `OnChanging(Sender, var EditStr, Column, Row)`：編集中の値を検査・変更可
  - `OnChange(Sender, EditStr, Column, Row)`：編集確定時に通知

- **編集対象セルの可否判定**
  - `IsFixedCell(aCol, aRow)` で固定セル（編集禁止）を判定

- **オーナードロー連携**
  - `DrawBack` や `OnSelfDrawItem` などと連携し、見た目の整合性を確保

## 想定用途

- 通常の TListView に Excel風のセル編集機能を付加したい場合
- 固定列や編集制御が必要なツール（例：設定エディタ、ログビューワなど）
- 編集後の値に対する動的処理（バリデーション／データ更新）が必要な場面

