# ListViewRTTI - 実行時型情報 (RTTI) 対応 TListViewEdit 拡張

この README は `ListViewRTTI.pas` ユニットに関する説明です。

`TListViewRTTI` は、`TListViewEdit` を継承し、任意のオブジェクトのプロパティ情報を  
RTTI（実行時型情報）を用いて ListView 上に自動展開・編集可能にするコンポーネントです。

## 主な機能

- **オブジェクトからの自動列挙と編集**
  - `LoadFromObject(aObject: TObject)` により、対象オブジェクトのプロパティを自動的に列挙し表示
  - 編集内容は対象プロパティに即時反映される（RTTI 経由で更新）

- **編集処理とイベント**
  - 編集完了時に `OnDataChange` イベントで通知
  - 編集値の反映処理は `DoChange(EditStr, Column, Index)` にて制御可能（オーバーライド対応）

- **表示カスタマイズ**
  - `AddCaption(PName, Caption, Hint, aType)` により、RTTIに依存せず任意の列を追加可能
  - `RTTINames[Name]` で特定のプロパティ情報にアクセス可能（インデクサ）

- **補助機能**
  - `Refresh()`：表示の再構築（再バインド）
  - `FixedWidth` プロパティによる列幅固定設定
  - 自動列調整・カラムの幅配置は内部で `SetColumn()` などにより制御

## 想定用途

- 開発ツールやデバッグ用ユーティリティ
- オブジェクトの状態をGUI上で直接編集できるプロパティビューア
- 設定ファイル・構造体データのインスペクタUI
