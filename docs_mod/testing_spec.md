# S2J Package Dashboard - テスト仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、テスト戦略、テストレベル、テスト対象、テストデータ、実行環境および Release 前後に実施する検証内容を定義します。

## 目的

本仕様は、品質を継続的に保証するためのテスト戦略、テストレベル、テスト対象、テストデータ、実行環境および Release 前後に実施する検証内容を定義する。

## 非目的

本仕様は、CI Workflow の YAML、Runner 構成、Release 可否の判断そのものを定義しない。自動生成される生のテスト出力を本仕様に埋め込まない。

## 責務

何を、なぜ、どのレベルでテストするかを正本とする。

## 非責務

CI 上の実行方法は [`cicd.md`](./cicd.md)、Release 前後の Quality Gate は [`release.md`](./release.md)、生のテスト結果は [`test-results.md`](./test-results.md) とする。Viewport / リファレンス・デバイスは [`ui-viewport.md`](./ui-viewport.md)、横断 UI 振る舞いは [`ui.md`](./ui.md)、復元対象は [`application_state.md`](./application_state.md)、遷移の形式は [`state_machine.md`](./state_machine.md) を正本とする。機能の正本は各専門仕様とする。

## Testing Principles

S2J Package Dashboard のテストは、下記の原則に従う。

1. **Business Rule を最優先でテストする。**
2. **Pure Logic は可能な限り高速な Unit Test で検証する。**
3. **State Transition は網羅的に検証する。**
4. **外部 API に依存するテストと、依存しないテストを明確に分離する。**
5. **Network / Storage /キャッシュは Fake / Stub / Mock 等によって制御可能にする。**
6. **UI Test は User Behavior を中心に検証し、実装詳細に依存しない。**
7. **Snapshot Test は補助的に使用し、主要な Business Logic の検証には使用しない。**
8. **Platform-specific な UI と Platform-independent な Logic を別々に検証する。**
9. **Test は deterministic であることを優先する。**
10. **CI で継続的に実行可能であることを Test の設計条件とする。**

## Test Pyramid

基本的な Test Pyramid は下記とする。件数は Unit > Integration > UI / E2E > Manual とする。UI Test や E2E Test だけで Application Logic の品質を保証しない。

## Test Levels

Test Level は下記に分類する。

| Level | Target | Main Purpose |
| --- | --- | --- |
| Unit | Domain / Application / State | Logic correctness |
| Component | UI Component | Component behavior |
| Integration | Repository / API / Storage / キャッシュ | Boundary correctness |
| UI | Screen / Navigation | User interaction |
| E2E | Application Flow | User goal |
| Performance | Critical operations | Performance regression |
| Security | Credential / Data handling | Security regression |
| Manual | Real device / Store build | Release validation |

## Test Categories

Test は下記の Category を持つ。

* Functional
* Domain
* Application
* State
* Repository
* API
* Storage
* キャッシュ
* Navigation
* UI
* Accessibility
* Viewport
* Performance
* Security
* Regression
* Compatibility
* Release

## Test Naming

Test 名は「何を検証するか」が明確になるようにする。

基本形式: `subject_condition_expectedResult`
または: `given_condition_when_action_then_result`

例:

* `emptyPackageName_isRejected`
* `validPackageName_isAccepted`
* `refreshRequested_startsLoading`
* `packageLoaded_updatesState`
* `networkFailure_preservesExistingData`

Test 名だけで目的を理解できることを原則とする。

## Given / When / Then

Behavior Test では下記の構造を基本とする。

* Given: 初期状態
* When: Event / Action
* Then: Expected State / Result

例:

* Given:
    * Package が Loaded 状態
* When:
    * `RefreshRequested`
* Then:
    * Refreshing 状態になる
    * 既存 Package Data は保持される

## Unit Tests

### 1. Purpose

Unit Test は、外部 I/O に依存しない小さな単位の動作を検証する。

主な対象:

* Domain
* Value Object
* Entity
* Validation
* Business Rule
* Formatter
* Mapper
* Reducer
* State Transition
* Error Classification
* Statistics Calculation

### 2. Domain Tests

Domain Test は Business Rule を検証する。

例:

* Package Identifier
    * Given: `vendor/package`
    * Then: valid Package Identifier として扱う

* Statistics
    * Given: daily/monthly/total download values
    * Then: 正しい Statistics Model が生成される

## Validation Tests

Validation は境界値を含めて検証する。

対象例:

* Empty String
* Whitespace
* Minimum Length
* Maximum Length
* Invalid Character
* Invalid URL
* Invalid Package Name
* Invalid Repository URL
* Invalid Statistics Value

境界値テストでは下記を原則とする。

* minimum - 1
* minimum
* minimum + 1

* maximum - 1
* maximum
* maximum + 1

## State Machine Tests

遷移の形式は [`state_machine.md`](./state_machine.md) を正本とする。本節は、Reducer を I/O なしで検証することと、下記を重点ケースとすることだけを定める。

* `(State, Event) -> (State, Effect*)` に対して同一 Input は同一 Output
* 既存データありの Error (データが消失しない)
* 既存データありの Refresh (Refresh 中に既存データが消失しない)
* Stale ≠ Error (キャッシュあり + Stale indication を Error と混同しない)

## Effect Tests

遷移の形式は [`state_machine.md`](./state_machine.md) を正本とする。本節は、Reducer Test で Network Request を実行せず、Effect Test では Fake Repository 等で Operation を検証することだけを定める。

## Use Case Tests

Use Case は User Goal 単位でテストする。

例:

* Load Package List
* Load Package Detail
* Refresh Package
* Search Packages
* Load Statistics
* Refresh Statistics
* Add Favorite
* Remove Favorite
* Authenticate
* Restore セッション

Button 単位の Test ではなく、「User Goal」が達成されることを検証する。

## Repository Tests

Repository は Domain / Application Layer と Infrastructure Layer の境界としてテストする。

対象:

* `PackageRepository`
* `StatisticsRepository`
* `AuthenticationRepository`
* `SettingsRepository`

### 1. Repository Contract

Repository Interface に対して Contract Test を定義する。

たとえば:

`loadPackage` について、

* Success
* Not Found
* Network Error
* Authentication Error
* Invalid Response
* Timeout
* Offline

を検証する。

## API Tests

API Test は Production API に直接依存しない。Test は Fake / Stub HTTP Response を API Client に渡す。

### 1. Packagist

Packagist API Client では下記を検証する。

* Package JSON parsing
* Package metadata mapping
* Statistics mapping
* Download count mapping
* Version mapping
* Maintainer mapping
* Invalid JSON
* Missing fields
* Unexpected fields
* HTTP error
* Timeout
* Rate-limit related error

### 2. GitHub

GitHub API Client では下記を検証する。

* Repository parsing
* Owner mapping
* Stars
* Forks
* Issues
* Pull Requests
* Repository URL
* Traffic data
* Invalid response
* Authentication error
* Rate limit
* Permission error

## API Fixture

API Test では Fixture を利用する。推奨構造:

```text
fixtures/
├── packagist/package.json
├── github/repository.json
└── domain/package.json, statistics.json
```

Fixture は実際の API Response をそのまま保存する場合と、Test に必要な最小構造を持つ Synthetic Fixture に分けてもよい。

Fixture に Credentials / Personal Information を含めない。

## API Contract Tests

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本節は、External API と Expected Contract と Application Model の互換を Contract Test で保護することだけを定める。API 仕様変更時は Application Model / Mapper / Fixture / API Specification を同時に見直す。

## Storage Tests

Storage Test は Persistent Data と Restorable State を分離する。

対象:

* Package Data
* Favorite Data
* Statistics Snapshot
* Application Preferences
* Restorable Navigation State

Credentials は通常の Application Storage に保存しないため、Storage Test の対象から除外する。

## キャッシュ Tests

キャッシュは下記の状態を検証する。

* Empty
* Fresh
* Stale
* Expired
* Corrupted
* Unavailable

キャッシュ状態の意味は [`cache_spec.md`](./cache_spec.md) を正本とする。本節は、Empty / Fresh / Stale / Expired / Corrupted / Unavailable を検証することだけを定める。Fresh ではキャッシュ済み Data を返し、Stale かつオンラインでは Refresh、オフラインではキャッシュを維持することを確認する。

## キャッシュ Consistency

同一 Package について、

* Memory キャッシュ
* Persistent キャッシュ
* Remote API

の優先順位と更新規則が正しいことを検証する。

キャッシュ更新中に Application State が不整合にならないことを確認する。

## Authentication Tests

許可状態とライフサイクルは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本節は、Unauthenticated → Requested → Authenticating → Authenticated、および Authenticating → Failed → Unauthenticated を検証することだけを定める。

Credential 本体を Test Log に出力しない。

## Credential Storage Tests

保存 HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本節は、Save / Load / Update / Delete / Missing / Invalid を実 Token なしで検証し、本体を Test Log に出さないことだけを定める。

## Navigation Tests

行き先と戻り方は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本節は、Navigation Semantics を検証し、パスに Domain Object 全体を保持せず Identifier 等の軽量な値で復元できることだけを定める。

## State Restoration Tests

復元対象と禁止対象は [`application_state.md`](./application_state.md) を正本とする。本節は、再起動後に Restorable State から安全に初期状態を再構築できることを検証することだけを定める。

## UI Component Tests

Reusable Component は Component 単位でテストする。

対象例:

* PackageCard
* StatisticsChart
* LoadingView
* ErrorView
* EmptyStateView
* SourceList
* About Window

Test では、

* 正しい Data が表示される
* Action が Event に変換される
* Empty State が表示される
* Error State が表示される
* Accessibility Information が提供される

ことを検証する。

## Screen Tests

Screen Test は Screen の状態と User Interaction を検証する。

主要 Screen:

* Package List
* Package Detail
* Statistics
* Settings
* Authentication

Screen Test は可能な限り Fake Repository / deterministic State を使用する。

## UI Tests

iOS / iPadOS では UI Test に XCTest / XCUIAutomation を使用する。

Apple は現在、Swift Testing を新規のコードレベルテストに推奨しつつ、UI Test および Performance Test については XCTest を使用する方針を示している。([XCTest | Apple Developer Documentation](https://developer.apple.com/documentation/xctest/))

UI Test では下記を検証する。

* Application Launch
* Navigation
* User Interaction
* Search
* Refresh
* Package Selection
* Statistics Selection
* Error Recovery
* Deep Link
* State Restoration

## Android UI Tests

Android / Jetpack Compose 対応後は Compose UI Testing を使用する。

Compose Test は Semantics を利用して UI Element を検索し、Assertion / Action を実行する。

Android では UI Test を Screen 全体だけでなく、必要に応じて Component / Composable 単位でも実施する。([Common patterns | Jetpack Compose | Android Developers](https://developer.android.com/develop/ui/compose/testing/common-patterns))

## Cross-platform Test Strategy

KMP 対応後も、すべての Test を Shared Code に移動することを目的としない。

### Shared Test Candidates

* Domain Rule
* Validation
* Entity
* Value Object
* Statistics Calculation
* State
* Event
* Reducer
* Use Case
* Repository Contract
* Error Classification

### Platform-specific Test Candidates

* SwiftUI
* Compose
* Navigation UI
* Keychain
* Android Keystore
* SwiftData
* Room
* Platform Lifecycle
* Platform Accessibility
* Platform-specific UI

## Adaptive UI Tests

Adaptive UI は重要な Test Category とする。

Test 対象:

* Compact
* Medium
* Expanded

および:

* Portrait
* Landscape

## Viewport Integrity Tests

Viewport の確認項目と Test Matrix は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、Viewport Integrity を明示的な Test Category として扱い、Portrait ↔ Landscape および Compact ↔ Expanded を Test Case とすることだけを定める。

## Accessibility Tests

Accessibility は UI Test の一部として扱う。

対象:

* VoiceOver
* Dynamic Type
* Accessibility Label
* Accessibility Value
* Accessibility Hint
* Button Role
* Image Description
* Contrast
* Focus Order
* Keyboard Navigation where applicable

Accessibility identifier と表示文言を混同しない。

UI Test は可能な限り安定した Accessibility Identifier / Semantic Identifier を使用する。

## Localization Tests

Localization 対応後は下記を検証する。

* Japanese
* English
* Long Text
* Pluralization
* Date / Number Formatting
* Currency Formatting where applicable

特に UI の固定幅による Text Truncation を検証する。

## Error Handling Tests

Error は Application Error Model に変換されることを検証する。

代表的な Error:

* NetworkUnavailable
* Timeout
* Unauthorized
* Forbidden
* NotFound
* RateLimited
* InvalidResponse
* DecodingFailure
* StorageFailure
* Unknown

同一 Error を複数 Layer が異なる意味で表示しない。

## Offline Tests

Offline Test は必須とする。キャッシュ利用は [`cache_spec.md`](./cache_spec.md)、見え方は [`ui.md`](./ui.md) を正本とする。本節は、Online で Load したあと Offline で Open Package してもキャッシュ済み Data と Stale indication が使え、既存データを破棄しないことだけを定める。

## Concurrency Tests

非同期処理について下記を検証する。

* Duplicate Request
* Request Cancellation
* Out-of-order Response
* Latest Request Wins
* Stale Response Ignored
* Refresh Coalescing
* Concurrent Package Requests

例: Request A と B が並行し、Response が B → A の順でも Latest Request Wins / Stale Response Ignored になること。

この場合、古い Response A が最新 State を上書きしないことを検証する。

## Performance Tests

体感上の遅延禁止は [`ui.md`](./ui.md) を正本とする。本節は測る対象を定める。

対象:

* Application Launch
* Package List Rendering
* Package Detail Rendering
* JSON Decoding
* キャッシュ Read
* キャッシュ Write
* Statistics Calculation
* Search / Filtering
* Large Package List

Performance Regression を検知できるよう、代表的な Benchmark を維持する。

## Memory Tests

解放方針は [`cache_spec.md`](./cache_spec.md)、Chart 再描画用データを捨てたとしても、履歴を消さないことは [`ui.md`](./ui.md) を正本とする。本節は、下記状態で使用量が連続増加しないことを検証する。

* Large Package List
* Large Statistics Dataset
* Repeated Navigation
* Repeated Refresh
* Rotation
* Background / Foreground

List ↔ Detail の繰り返しで Memory が継続的に増加しないことを確認する。

## Network Tests

Network Test では下記を再現可能にする。

* Slow Network
* Offline
* Timeout
* Connection Reset
* HTTP Error
* Rate Limit
* Partial Response
* Invalid Response

Production API に対する無制限の Test Request を CI から実行しない。

## Real API Tests

Real API を使用する Test は通常の CI Test Suite と分離し、明示的に Trigger する。Unit / Integration は External Dependency を持たない。

Real API Test は下記の場合に限定する。

* 手動実行
* Scheduled Test
* Release Candidate validation
* API Contract verification

API Rate Limit を考慮する。

## Test Data

Test Data は下記の原則に従う。

1. Deterministic
2. Minimal
3. Reusable
4. Readable
5. No Secrets
6. No Personal Information
7. No Production Credentials

Test Data の生成は Factory / Fixture Builder を使用してよい。

## Test Isolation

各 Test は可能な限り独立させる。

Test 間で下記を共有しない。

* Mutable Global State
* Persistent User Data
* Authentication セッション
* Network State
* キャッシュ State

必要な状態は Test ごとに明示的に生成する。

## Test Doubles

外部依存を制御するため、下記を使用する。

* Stub
* Fake
* Mock
* Spy
* Fixture

基本方針:

* Fake: Repository / Storage
* Stub: API Response
* Mock: Interaction verification が必要な場合
* Spy: Call Count / Argument verification
* Fixture: Deterministic Data

Mock の過剰利用は避ける。

## Testable Architecture

Testability を Architecture の要件とする。

層の依存方向は [`architecture.md`](./architecture.md) を正本とする。本節は、Domain / Application が具体的な API Client や Storage Implementation に直接依存しないことを Testability の要件とすることだけを定める。

## Regression Tests

Bug Fix を行った場合、原則として Regression Test を追加する。流れは Bug → Root Cause → Regression Test → Fix → CI とする。「修正しただけ」で完了せず、同じ Bug が再発した場合に CI が検知できる状態を目指す。

## Security Tests

漏洩面は [`security_spec.md`](./security_spec.md) を正本とする。本節は、Credential Storage / Logging / Fixture / Snapshot / Test Artifact / Source に Token を残さないことを検証することだけを定める。

## Snapshot Tests

Snapshot Test は必要に応じて使用する。

対象例:

* Complex Component
* Typography
* Layout
* Empty State
* Error State
* Dark Mode
* Localization

ただし Snapshot Test を Business Logic Test の代替として使用しない。

Snapshot の更新は意図した UI Change と同時に行う。

## Test Tags

Test Suite は下記のような Tag / Category を持たせてもよい。

* unit
* integration
* ui
* e2e
* network
* security
* performance
* release

CI では必要に応じて Test Category を分離して実行する。

Swift Testing は Test の Grouping / Tagging / Parameterization 等をサポートしているため、Test Suite の整理に利用できる。([Swift Testing | Apple Developer Documentation](https://developer.apple.com/documentation/testing/))

## CI Test Pipeline

いつどの Job が走るかは [`cicd.md`](./cicd.md) を正本とする。本節は、CI 上で Unit Test を早い段階に置き Fast Feedback を優先することだけを定める。

## Pull Request Tests

いつどの Check を要求するかは [`cicd.md`](./cicd.md) を正本とする。本節は、Pull Request で最低限検証するテスト内容を定義する。

* Build
* Unit Test
* Integration Test
* Lint
* Documentation Check
* Security Check

変更内容に応じて UI Test / Device Test を追加する。

## Main Branch Tests

`main` でいつどの Job が走るかは [`cicd.md`](./cicd.md) を正本とする。本節は、Merge 後に検証するテスト内容を定義する。

* Full Unit Test
* Integration Test
* UI Test
* Build
* Static Analysis
* Security Check
* Documentation Check

Release に必要な Platform Build が成功することを確認する。

## Release Candidate Tests

出荷可否は [`release.md`](./release.md)、実行タイミングは [`cicd.md`](./cicd.md) を正本とする。本節は、RC で通常の CI より広く、Unit / Integration / UI / Device / Accessibility / Viewport / Performance / Security を検証することだけを定める。RC で使う Build Configuration は [`release.md`](./release.md) を正本とする。

## Release Tests

出荷ゲートは [`release.md`](./release.md) を正本とする。本節は、Production 直前に検証するテスト内容を定義する。

* Real Device Test
* iPhone Test
* iPad Test
* Portrait Test
* Landscape Test
* Accessibility Smoke Test
* Offline Test
* Authentication Test
* Package API Test
* Statistics Test

Android Support 後は Android Device / Window Size Test を追加する。

## Post-release Smoke Test

実施必須は [`release.md`](./release.md) を正本とする。本節は、Production 後に Launch → Package List → Detail → Statistics → Refresh → GitHub Repository → Navigation を確認することだけを定める。

重大な Failure が確認された場合は [`release.md`](./release.md) の Incident / Hotfix Process に従う。

## Test Failure Policy

Test Failure を検知した場合、Investigate した後で Test Failure / Product Bug / Environment Failure / Flaky Test に分類する。Flaky Test を「無視して Retry」するだけの運用は禁止する。Flaky Test は Issue として記録し、原因を調査する。

## Flaky Test

Flaky Test とは、同一 Code / Environment に対して結果が安定しない Test と定義する。

代表例:

* Timing Dependency
* Race Condition
* Network Dependency
* Shared State
* Random Data
* Device-specific behavior

Flaky Test は、`Retry`

だけで CI Pass として扱わない。

## Test Coverage

Coverage は品質の唯一の指標としない。

Coverage ではなく、Business Risk / State Space / Failure Modes / Critical User Flows にもとづく Risk-based Test Design を重視する。

特に下記は高い Test Coverage を目標とする。

* Domain Rules
* State Machine
* Statistics Calculation
* Validation
* Authentication State
* キャッシュ Rules
* Error Handling
* Repository Contract

## Critical パス

Critical パスは `## Post-release Smoke Test` の操作順を正本とする。本節は、その Flow を Release Candidate / Production Smoke Test で必ず確認することだけを定める。

## Test Matrix

初期 Test Matrix:

| Area | iPhone | iPad | Android |
| --- | --- | --- | --- |
| Launch | Required | Required | Future |
| Package List | Required | Required | Future |
| Package Detail | Required | Required | Future |
| Statistics | Required | Required | Future |
| Navigation | Required | Required | Future |
| Rotation | Required | Required | Future |
| Viewport | Required | Required | Future |
| Accessibility | Required | Required | Future |
| Offline | Required | Required | Future |
| Authentication | Required | Required | Future |

Android は Android 実装開始時に具体的な Device / Window Size Matrix を定義する。

## Device Matrix

検証対象デバイスは [`ui-viewport.md`](./ui-viewport.md) の Reference Devices を正本とする。本節は、初期 Release Validation で iPhone / iPad の Portrait / Landscape を必須とすることだけを定める。

## Test Environment

Test Environment は下記を記録する。

* OS Version
* Xcode Version
* Swift Version
* SDK Version
* Dependency Versions
* Device Model
* Device OS
* CI Runner

Test Failure の再現性を確保するため、Release Test では Toolchain Version を固定する。

## Test Artifact

CI は必要に応じて下記の Test Artifact を保存する。

* Test Result
* XCTest Result Bundle
* UI Test Screenshot
* UI Test Video
* Coverage Report
* Performance Result
* Build Log
* Failure Log

Artifact に Credentials / Personal Information を含めない。

## Test Documentation

Test の追加・変更が Application Behavior に影響する場合、関連する Specification も更新する。

特に必要に応じて下記を同期する。

* [`testing_spec.md`](./testing_spec.md)
* [`domain_rules.md`](./domain_rules.md)
* [`state_machine.md`](./state_machine.md)
* [`use_cases.md`](./use_cases.md)
* [`screen_spec.md`](./screen_spec.md)
* [`ui-viewport.md`](./ui-viewport.md)
* [`release.md`](./release.md)
* [`CHANGELOG.md`](../CHANGELOG.md)

公開ドキュメントに影響する場合は `docs/` も更新する。

## Test Specification Traceability

重要な Requirement / Use Case は Test に追跡可能であることが望ましい。対応は Requirement → Use Case → State Transition → Test とする。例: `UC-PKG-001` の Load Package 遷移を `PackageLoadTests` に結ぶ。Test 名または Test Metadata に Requirement / Use Case ID を付与してもよい。

## Test IDs

重要な Test Case には ID を付与してよい。

例:

* TC-PKG-001
* TC-PKG-002
* TC-STAT-001
* TC-AUTH-001
* TC-NAV-001
* TC-VIEWPORT-001

ID は Test の内部実装ではなく、Specification / Issue / Release Checklist との Traceability に使用する。

## MVP Test Scope

対象機能は [`use_cases.md`](./use_cases.md) の MVP ユースケースを正本とする。本節は、MVP で必須とするテスト種別を定義する。機能一覧は再掲しない。

### Required

* Domain Unit Test
* Application Unit Test
* State Machine Test
* Validation Test
* Repository Test
* API Fixture Test
* キャッシュ Test
* Error Handling Test
* Navigation Test
* iOS UI Test
* iPad UI Test
* Viewport Test
* Offline Test
* Authentication Test
* Real Device Smoke Test
* CI Test

### Future

* Android UI Test
* KMP Shared Test
* Performance Benchmark
* Snapshot Test
* Extended Accessibility Test
* Automated Store Validation
* Extended Device Matrix
* Automated Real API Contract Test

## Testing Architecture

件数配分は `## Test Pyramid`、レベルは `## Test Levels` を正本とする。本仕様は、Unit の主対象を Domain / Application / State Machine / Validation / Statistics / キャッシュ Rules とし、Test Doubles で外部境界を制御することだけを定める。

## Final Testing Policy

Coverage 件数ではなく、Domain Rule / Application Behavior / State Transition / External Boundary / User Interaction / Release Quality を適切な Test Level で検証することを基本とする。Platform-specific UI と Platform-independent Logic を分離して Test し、将来の KMP / Android でも Business Logic Test を再利用できる構造を維持する。

## Relationship with CI/CD and Release

何をテストするかは本仕様、いつ Job が走るかは [`cicd.md`](./cicd.md)、Release 前後の Quality Gate は [`release.md`](./release.md) を正本とする。
