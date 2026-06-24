<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>macOS アクセシビリティ API を使用して Chrome ネイティブの垂直タブサイドバーを切り替える Hammerspoon スクリプト</strong><br>
  キーボードショートカット、画面端マウスホバートリガー、または両方 — お好みで選択できます。
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README_ko.md">한국어</a> · <a href="README_es.md">Español</a> · <a href="README_pt-BR.md">Português</a> · <a href="README_ru.md">Русский</a> · <a href="README_fr.md">Français</a> · <a href="README_de.md">Deutsch</a>
</p>

---

## 概要

Chrome には組み込みの垂直タブサイドバーがありますが、切り替えるキーボードショートカットがありません。このスクリプトには、この問題を解決するための2つのバージョンが用意されています:

- **`init.lua`** — 3つの選択可能なスキームをサポート (キーボード / 画面端ホバー / 両方)
- **`init-keyboard-only.lua`** — キーボードショートカットのみ、マウス検出なし

Chrome のアクセシビリティツリー(`AXUIElement`)をトラバースして「Expand Tabs」/「Collapse Tabs」ボタンを見つけ、`AXPress` で押すことで動作します。[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) と同じアプローチです。

## デモ

https://github.com/user-attachments/assets/bcf2a76a-8028-4b63-bc8a-f0b9e1178a25

## 対応 Chrome ロケール

スクリプトは Chrome のアクセシビリティツリーにあるサイドバーボタンのラベルを照合して動作します。以下のロケールですぐに使用できます:

| 言語 | ロケール | タブを開く | タブを閉じる |
|------|----------|-----------|-------------|
| 英語 | `en` | Expand tabs | Collapse tabs |
| 繁体字中国語 | `zh-TW` / `zh-HK` | 展開分頁 | 收合分頁 |
| 簡体字中国語 | `zh-CN` | 展开标签页 | 收起标签页 |
| 日本語 | `ja` | タブを開く | タブを閉じる |
| 韓国語 | `ko` | 탭 펼치기 | 탭 접기 |
| ドイツ語 | `de` | Tabs maximieren | Tabs minimieren |
| スペイン語 | `es` | Mostrar pestañas | Ocultar pestañas |
| フランス語 | `fr` | Développer les onglets | Réduire les onglets |
| ポルトガル語 (ブラジル) | `pt-BR` | Mostrar guias | Ocultar guias |
| ロシア語 | `ru` | Развернуть вкладки | Свернуть вкладки |

他の言語を追加するには、お使いの Chrome ロケールのボタンラベルを確認し、`init.lua` の `SIDEBAR_LABELS` テーブルに追加してください。

## 必要要件

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- 垂直タブサイドバーが有効な Google Chrome
- Hammerspoon にアクセシビリティ権限が付与されていること

## Chrome で垂直タブサイドバーを有効にする

垂直タブサイドバーはデフォルトで無効になっています。有効にするには:

1. アドレスバーに `chrome://flags/#vertical-tabs` と入力してください
2. **Vertical tabs** を **Enabled** に変更してください
3. **Relaunch** をクリックして Chrome を再起動してください
4. 再起動後、タブバーの空白部分を右クリックしてオプションを確認してください

## インストール

1. Hammerspoon をインストールしてください:

   ```bash
   brew install --cask hammerspoon
   ```

2. バージョンを選択して Hammerspoon 設定にコピーしてください:

   **スキームバージョン** (3モード、デフォルト):
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **キーボード専用バージョン**:
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   既に `~/.hammerspoon/init.lua` がある場合は、内容を末尾に追加してください。

3. アクセシビリティ権限を付与してください:
   - システム設定 → プライバシーとセキュリティ → アクセシビリティ
   - Hammerspoon を追加して有効にする

4. Hammerspoon 設定をリロードしてください (メニューバーのアイコン → 「Reload Config」をクリック)

5. (オプション) Hammerspoon をログイン項目に追加して自動起動を設定してください:
   - システム設定 → 一般 → ログイン項目
   - Hammerspoon を追加

## スキーム (`init.lua`)

`init.lua` の先頭にある `SCHEME` 変数を編集してモードを選択:

| スキーム | 値 | トリガー |
|----------|-----|----------|
| キーボードのみ | `1` | `Cmd+S` でサイドバー切り替え |
| 画面端ホバーのみ | `2` | 画面左端にホバーで展開、380px 超えて移動で折りたたみ |
| キーボード + マウス | `3` | 両方のトリガーが有効 (デフォルト) |

```lua
local SCHEME = 3  -- 1 = キーボード, 2 = 画面端ホバー, 3 = 両方
```

Chrome が最前面のアプリでない場合、すべてのトリガーは自動的に無効になります。

## トリガー

| トリガー | アクション | スキーム |
|----------|-----------|----------|
| `Cmd+S` | サイドバー切り替え | 1 & 3 |
| 左端(0-2px)に0.15秒ホバー | サイドバー展開 | 2 & 3 |
| 左端から380px 超えてマウス移動 | サイドバー折りたたみ | 2 & 3 |

## デバッグ

| ショートカット | アクション |
|---------------|-----------|
| `Cmd+Alt+D` | サービスステータスを表示 |
| `Cmd+Alt+B` | Chrome の AX ボタンをすべてコンソールに出力 |
| `Cmd+Alt+R` | すべてのサービスを強制再起動 |

## 設定

### スキームセレクター(`init.lua`)

```lua
local SCHEME = 3  -- 1 = キーボード, 2 = 画面端ホバー, 3 = 両方
```

### 画面端ホバーのしきい値 (`init.lua`、スキーム 2 & 3)

```lua
local EDGE_THRESHOLD    = 2       -- 左端からのトリガー距離(ピクセル)
local EXIT_THRESHOLD    = 380     -- 折りたたみトリガーの左端からの距離(ピクセル)
local WAIT_TIME         = 0.15    -- ホバー待機時間(秒)
local MOUSE_POLL_INTERVAL = 0.05  -- マウス位置チェックの間隔(秒)
```

### 両バージョン共通

```lua
local DEBUG = true  -- コンソールにデバッグメッセージを出力
```

## キーボードショートカットのカスタマイズ

`init.lua` と `init-keyboard-only.lua` の両方で利用可能です。デフォルトのショートカットは `Cmd+S` で、Chrome の「ページを保存」ショートカットを上書きします。変更するには、`createKeyTap` 関数内のキー判定を編集してください:

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### 修飾キー

`flags.*` 条件を変更して希望の修飾キーの組み合わせを設定:

| 修飾キー | フラグ | 例 |
|----------|--------|-----|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

フラグを `true` に設定すると必須、`not flags.xxx` に設定すると除外になります。

### キーコード

`keycodes.map["s"]` を任意のキー名に変更。よく使う例:

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Return/Enter
keycodes.map["space"]   -- Space
keycodes.map["f1"]      -- F1
```

完全なキー名の一覧: Hammerspoon コンソールで `hs.keycodes.map` を実行してください。

### 例

**`Ctrl+Shift+B`**:
```lua
if flags.ctrl and not flags.cmd and flags.shift and not flags.alt
    and keyCode == keycodes.map["b"] then
```

**`Cmd+Alt+/`**:
```lua
if flags.cmd and not flags.ctrl and flags.alt and not flags.shift
    and keyCode == keycodes.map["/"] then
```

**`Cmd+Shift+Return`**:
```lua
if flags.cmd and not flags.ctrl and not flags.alt and flags.shift
    and keyCode == keycodes.map["return"] then
```

編集後、Hammerspoon 設定をリロードして適用してください。

## 仕組み

1. Chrome が最前面にあるとき、`eventtap` が `Cmd+S` を傍受 (スキーム 1 & 3)
2. マウス位置監視タイマー (50Hz) が左端のホバーと退出を検出 (スキーム 2 & 3)
3. 両方のトリガーによる `toggleSidebar()` の呼び出し（以下の処理を実行）:
   - `hs.axuielement.applicationElement()` による Chrome の AX ルート要素の取得
   - ウィンドウ内からの `AXDescription` が "Expand Tabs" または "Collapse Tabs" に一致するボタンの検索
   - 検出されたボタンへの `performAction("AXPress")` の実行
4. ウォッチドッグによるマウス位置監視タイマーの異常検出および自動再起動 (スキーム 2 & 3)
5. 誤動作防止のための猶予時間（Grace Period）による、アプリ切り替え時の誤トリガー防止

## ファイル

| ファイル | 説明 |
|----------|------|
| `init.lua` | 3スキームバージョン (キーボード / マウス / 両方) |
| `init-keyboard-only.lua` | キーボード専用バージョン、マウス検出なし |

## クレジット

- 原案:[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- Hammerspoon に適応し、画面端マウスホバートリガーを追加

## ライセンス

MIT
