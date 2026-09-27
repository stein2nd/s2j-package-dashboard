# S2J Package Dashboard - アプリケーション詳細仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、アプリケーション全体の統合の見取り図を定義します。

## 目的

本仕様は、S2J Package Dashboard のアプリケーション全体に関する統合の見取り図です。残すのは、仕様階層、競合時の優先順位、変更時の確認範囲です。

## 非目的

本仕様は、個別仕様の本文を再定義しません。状態・ユースケース・ナビゲーション等の詳細を、ここに持ちません。ファイルの名簿を、持ちません。

## 責務

仕様階層、競合時の優先、変更時に見る正本の範囲を、定義します。

## 非責務

ファイルの名簿は [`specs.md`](./specs.md)、分割方針は [`spec_structure.md`](./spec_structure.md)、プロダクト定義は [`overview.md`](./overview.md)、実用最小限の製品 (MVP) の優先ユースケースは [`use_cases.md`](./use_cases.md) とします。個別の API、ストレージ、UI、状態、ナビゲーション等は、各専門仕様を正とします。

## プロダクト定義

プロダクトの存在理由、対象、非目標は [`overview.md`](./overview.md) を正本とします。
アーキテクチャー方針は [`architecture.md`](./architecture.md) を正本とします。

## 正規仕様書

関心事ごとのファイル一覧は [`specs.md`](./specs.md) を正本とします。
本仕様は、名簿を再掲しません。アプリケーションは、プロバイダ固有 API モデルを直接 UI に公開しません。層境界は [`models_spec.md`](./models_spec.md) を正とします。

## 仕様のヒエラルキー

本仕様と個別仕様の関係は、下記とします。

[`overview.md`](./overview.md) が入口、本仕様が統合の見取り図です。関心事は、下記に分かれます。名簿は [`specs.md`](./specs.md) を正本とします。

入口の目次およびファイルの名簿は [`specs.md`](./specs.md)、分割方針は [`spec_structure.md`](./spec_structure.md) を参照します。

* アプリケーション: [`use_cases`](./use_cases.md) / [`application_state`](./application_state.md) / [`state_machine`](./state_machine.md) / [`domain_rules`](./domain_rules.md) / [`authentication_spec`](./authentication_spec.md)
* データ: [`models_spec`](./models_spec.md) / [`storage_spec`](./storage_spec.md) / [`cache_spec`](./cache_spec.md) / [`ios_spec`](./ios_spec.md) / [`android_spec`](./android_spec.md)
* API: [`api-packagist`](./api-packagist.md) / [`api-github`](./api-github.md)
* UI: [`ux_flows_spec`](./ux_flows_spec.md) / [`navigation_spec`](./navigation_spec.md) / [`screen_spec`](./screen_spec.md) / [`component_spec`](./component_spec.md) / [`ui-viewport`](./ui-viewport.md) / [`ui`](./ui.md) / [`design_spec`](./design_spec.md) / [`statistics_spec`](./statistics_spec.md)
* プラットフォーム: [`architecture`](./architecture.md) / [`security_spec`](./security_spec.md) / [`kmp_spec`](./kmp_spec.md)
* 運用: [`cicd`](./cicd.md) / [`release`](./release.md) / [`testing_spec`](./testing_spec.md)

## コンフリクト解決

個別仕様と本仕様が矛盾する場合は、**関心事ごとの正本を優先します**。本仕様は、再掲しません。

横断的な境界の正本は、下記とします。

* アーキテクチャー境界: [`architecture.md`](./architecture.md)
* セキュリティ方針: [`security_spec.md`](./security_spec.md)

## 仕様変更の方針

仕様変更時は、関連する正本を同時に確認します。たとえば下記は、パッケージの識別子 の変更が、少なくとも、影響する可能性があるものです。

* [`models_spec.md`](./models_spec.md)
* [`domain_rules.md`](./domain_rules.md)
* [`use_cases.md`](./use_cases.md)
* [`state_machine.md`](./state_machine.md)
* [`navigation_spec.md`](./navigation_spec.md)
* [`storage_spec.md`](./storage_spec.md)

仕様変更後は、下記の整合を、各正本で確認します。

* アーキテクチャーの一貫性
* 状態の一貫性
* ストレージの一貫性
* API の一貫性
* UI の一貫性
* Kotlin Multiplatform (KMP) の互換性
* テスト・カバレッジ

## 実用最小限の製品 (MVP) 範囲

MVP で優先するユースケースは、[`use_cases.md`](./use_cases.md) の MVP ユースケースを正本とします。
受け入れ条件は、各専門仕様に従います。

## デザインサマリー

設計原則は、[`architecture.md`](./architecture.md) を正本とします。
本仕様は、原則を再掲しません。
