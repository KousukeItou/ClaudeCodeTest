# トラックパッドジェスチャ検出 PoC

## 概要

この PoC（Proof of Concept）は、macOS上でトラックパッドジェスチャをリアルタイムで検出するコア機能を実装したものです。要件定義書に基づき、最も重要なジェスチャ検出機能に焦点を当てています。

## 機能

### 実装済み機能
- ✅ 3-5本指スワイプジェスチャ検出（上下左右）
- ✅ ピンチイン/ピンチアウト検出
- ✅ 回転ジェスチャ検出（時計回り/反時計回り）
- ✅ マルチフィンガータップ検出
- ✅ リアルタイムジェスチャ分析
- ✅ SwiftUIベースのテスト用GUI
- ✅ 包括的な単体テスト

### 技術仕様
- **対象OS**: macOS 14.0以降
- **言語**: Swift 5.10
- **フレームワーク**: SwiftUI, AppKit
- **低レベルAPI**: MultitouchSupport.framework（非公開API）

## アーキテクチャ

```
┌─────────────────┐
│   SwiftUI GUI   │
└─────────┬───────┘
          │
┌─────────▼───────┐
│ GestureListener │ ←── コアエンジン
└─────────┬───────┘
          │
┌─────────▼───────┐
│ MultitouchBridge│ ←── Objective-C ブリッジ
└─────────┬───────┘
          │
┌─────────▼───────┐
│MultitouchSupport│ ←── システムフレームワーク
└─────────────────┘
```

## コアアルゴリズム

### ジェスチャ検出ロジック

1. **タッチデータ収集**
   ```swift
   MTRegisterContactFrameCallback(device, mtCallback)
   ```

2. **フィンガートラッキング**
   - 各指の位置座標を時系列で追跡
   - 指ごとにユニークIDで管理

3. **ジェスチャ分析**
   - **スワイプ**: 全指の移動ベクトルの平均と閾値比較
   - **ピンチ**: 指間距離の変化率計算
   - **回転**: 三角関数による角度変化検出
   - **タップ**: 最大移動距離による判定

4. **優先度制御**
   ```
   指本数多い > ピンチ/回転 > スワイプ > タップ
   ```

## ファイル構成

```
TrackpadGesturePoC/
├── TrackpadGesturePoCApp.swift      # メインアプリエントリポイント
├── ContentView.swift                # SwiftUI GUI
├── GestureListener.swift            # コアジェスチャ検出エンジン
├── MultitouchBridge.h/.m           # Objective-C ブリッジ
├── TrackpadGesturePoC-Bridging-Header.h
└── Assets.xcassets/                # アプリリソース

TrackpadGesturePoCTests/
└── TrackpadGesturePoCTests.swift   # 単体テストスイート
```

## ビルドと実行

### 前提条件
- macOS 14.0以降
- Xcode 15.0以降
- Apple Silicon Mac（推奨）

### ビルド手順

1. **Xcodeでプロジェクトを開く**
   ```bash
   open TrackpadGesturePoC.xcodeproj
   ```

2. **ターゲット設定**
   - Product > Scheme > TrackpadGesturePoC を選択
   - Deployment Target: macOS 14.0

3. **ビルド**
   ```
   ⌘ + B (Build)
   ```

4. **実行**
   ```
   ⌘ + R (Run)
   ```

### Swift Package Manager (代替)
```bash
swift build
swift test
swift run
```

## テスト

### 単体テスト実行
```bash
# Xcode内で
⌘ + U

# コマンドラインで
swift test
```

### テストカバレッジ
- GestureListener 初期化/状態管理
- ジェスチャタイプ分類
- MultitouchBridge 統合
- タッチデータ構造体

## 使用方法

1. **アプリ起動**
   - GUI上の「開始」ボタンをクリック

2. **ジェスチャテスト**
   - トラックパッド上で3-5本指でスワイプ
   - ピンチイン/アウト
   - 回転ジェスチャ
   - マルチフィンガータップ

3. **結果確認**
   - GUI上のログエリアでリアルタイム表示
   - コンソールログでデバッグ情報確認

## 制限事項

### 現在の制限
- MultitouchSupport.framework の非公開API依存
- macOS標準ジェスチャ抑止機能は未実装（PoC範囲外）
- キーボードイベント生成機能は未実装（PoC範囲外）

### 開発環境での注意
- 非公開APIのため、一部環境では動作しない可能性
- シミュレーション機能により基本動作確認可能

## パフォーマンス

### 目標値（要件定義書準拠）
- CPU使用率: < 1% (平均)
- メモリ使用量: < 50 MiB
- レイテンシ: < 60ms（ジェスチャ終了→検出）

### 実測値
- 実機での性能測定が必要（今後のタスク）

## セキュリティ考慮事項

### 権限要求
```xml
<!-- 将来の実装で必要 -->
<key>com.apple.security.device.input-monitoring</key>
<true/>
```

### Sandboxing
- 非公開API使用のため、App Sandboxは無効
- 自己署名での配布想定

## 次のステップ（PoC後の開発）

1. **ジェスチャ抑止機能**
   - Mission Control抑止API調査
   - OS設定による代替方案

2. **キーボードイベント生成**
   - CGEventCreateKeyboardEvent統合
   - ルールエンジン実装

3. **設定管理UI**
   - ジェスチャ→キーマッピング設定
   - JSON設定インポート/エクスポート

4. **パフォーマンス最適化**
   - メモリ使用量削減
   - CPU使用率最適化

## 参考資料

- **要件定義書**: トラックパッドジェスチャ→キーボード入力変換アプリ v3
- **Apple Developer Documentation**: Event Handling Guide
- **MultitouchSupport.framework**: 非公開API仕様（逆引き解析）

---

**注記**: この PoC は要件定義書の最もコアな機能に焦点を当てた実装です。完全なアプリケーション実装には追加開発が必要です。