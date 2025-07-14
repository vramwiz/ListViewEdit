# ListViewEditPluginLib - 実用セル編集プラグイン実装集

この README は `ListViewEditPluginLib.pas` ユニットに関する説明です。

本ユニットは、`TListViewEditPlugin` を基底とした **実用的なセル編集プラグインの実装群** を提供します。  
各クラスは `ListViewEdit` または `ListViewRTTI` によるセル編集に対して、  
具体的な編集インターフェースを提供するために設計されています。

## 含まれる主なクラスと機能

### `TListViewEditPluginEdit`

- 編集UIに `TEdit` を使用するベーシックなテキスト入力プラグイン
- `DoEditing()` を通じて `TEdit` を生成・配置
- `OnEditExit`, `OnEditKeyPress` により編集確定をハンドリング

### `TListViewEditPluginReadOnly`

- 編集コンポーネントを一切生成せず、表示専用セルを実現
- `DoEditing()` の内部処理を最小限にし、編集不可を明示

### `TListViewEditPluginCustomComboBox`

- 編集UIとして `TComboBox` を使用する選択式プラグイン
- 高さ調整を行うための拡張コンボボックスクラス
  - `TListViewEditPluginComboBoxHeight` を使用し、ドロップダウンの見た目を安定化

## 想定用途

- テキスト入力、選択式入力、非編集セルの混在が求められるアプリケーション
- 各プロパティやセルごとに異なる入力方式を実現したい設定画面・エディタ
- `TListViewRTTI` による動的バインディングと併用して、RTTIベースの編集UIを強化

