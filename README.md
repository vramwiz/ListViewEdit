# ListViewEdit – Delphi用拡張 ListView コンポーネント集

このライブラリは、標準の `TListView` を拡張し、実用的なUI操作やデータ編集機能を強化する Delphi 用コンポーネント群です。

以下の3ユニットを中心に構成されています：

---

## 🧩 主なユニット

### 🔹 [ListViewEx](docs/ListViewEx.md)
- `TListViewEx` クラスを提供
- 標準 `TListView` の不具合修正と実用的な機能追加を行います（例：選択保持、描画安定化など）

### 🔹 [ListViewEdit](docs/ListViewEdit.md)
- `TListViewEdit` クラスを提供
- `ListViewEx` に編集機能を追加し、項目セルの編集を可能にします

### 🔹 [ListViewRTTI](docs/ListViewRTTI.md)
- `TListViewRTTI` クラスを提供
- Delphi の RTTI（実行時型情報）を利用して、オブジェクトプロパティの編集を自動化します

---

## 🗂 補助ユニット

- [ListViewRTTIList](docs/ListViewRTTIList.md)：RTTIで編集可能な項目リストの定義
- [ListViewEditPlugin](docs/ListViewEditPlugin.md)：編集用プラグインの仕組み（IFなどのベース）
- [ListViewEditPluginLib](docs/ListViewEditPluginLib.md)：一般的な編集UI（テキスト・選択肢・日付など）の具体実装

---

## 💡 利用シーン

- プロパティグリッド風のUIを自作したい
- データ構造に応じて編集UIを動的に生成したい
- 軽量でRTTI活用型の設定画面や一覧編集画面を作りたい

---

## 🔗 各ユニットの詳細

- ListView拡張クラス [ListViewEx.md](/ListViewEx.md)
- ListView編集クラス [ListViewEdit.md](/ListViewEdit.md)
- ListView変数自動表示設定クラス [ListViewRTTI.md](/ListViewRTTI.md)
- 実行時型情報リスト管理 [ListViewRTTIList.md](/ListViewRTTIList.md)
- ListViewEdit用プラグイン [ListViewEditPlugin.md](/ListViewEditPlugin.md)
- 標準プラグイン集 [ListViewEditPluginLib.md](/ListViewEditPluginLib.md)

---

## 📁 ディレクトリ構成（例）

```
ListViewEdit/
├─ README.md              ← このファイル
├─ docs/                  ← 各ユニットの説明ファイル（.md）
│   ├─ ListViewEx.md
│   ├─ ListViewEdit.md
│   ├─ ListViewRTTI.md
│   ├─ ListViewRTTIList.md
│   ├─ ListViewEditPlugin.md
│   └─ ListViewEditPluginLib.md
├─ src/                   ← 各 .pas/.dfm ファイル
│   ├─ ListViewEx.pas
│   ├─ ListViewEdit.pas
│   └─ ...
```

---

## 🛠 対応環境

- Delphi 10.x〜12.x
- Windowsアプリケーション（VCL）

---

## 📜 ライセンス

MITライセンス または プロジェクト独自ライセンスをここに記載
