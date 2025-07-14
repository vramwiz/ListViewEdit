# ListViewRTTIList - RTTI項目情報クラスユニット

この README は `ListViewRTTIList.pas` ユニットに関する説明です。

`TListViewRTTIItem` は、`TListViewRTTI` コンポーネントで使用される  
各プロパティ（セル）に関する情報を保持・管理するためのデータクラスです。

## 主な役割

- **RTTI で抽出されたプロパティ情報を1項目ごとに保持**
  - `PName`：プロパティ名（内部名）
  - `Caption`：表示名（UI表示用）
  - `Value`：現在の値（文字列形式）
  - `Hint`：補足説明（ツールチップなどに表示）

- **表示・編集制御に関する属性**
  - `EditType`：編集タイプ（0=テキスト、1=選択式など）
  - `TypeKind`：型の種別（TTypeKind）
  - `TypeBool`：分類（rtNormal / rtBoolean / rtComponent など）

- **装飾・動作補助**
  - `FStrings`：選択肢候補などに使用される文字列リスト
  - `FColorBack` / `FColorFont`：セルの背景色・文字色の個別指定
  - `FData`：任意の関連データへのポインタ

- **初期化支援**
  - `AddCaption()` メソッドにより、項目の基本情報を一括で設定可能

## 想定用途

- RTTIベースの編集UIにおいて、各行（または列）の属性を表現
- カスタムプロパティビューア、オブジェクト設定画面のデータ定義
- 項目の装飾や補足情報、型判別に基づく表示ロジックの支援

