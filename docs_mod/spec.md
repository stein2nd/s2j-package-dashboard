# S2J Package Dashboard - アプリケーション詳細仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、アプリケーション全体の統合の見取り図を定義します。

## 目的

本仕様は、S2J Package Dashboard のアプリケーション全体に関する統合の見取り図である。残すのは仕様階層、競合時の優先順位、変更時の確認範囲である。

## 非目的

本仕様は、個別仕様の本文を再定義しない。状態・ユースケース・ナビゲーション等の詳細をここに持たない。ファイルの名簿を持たない。

## 責務

仕様階層、競合時の優先、変更時に見る正本の範囲を定義する。

## 非責務

ファイルの名簿は [`specs.md`](./specs.md)、分割方針は [`spec_structure.md`](./spec_structure.md)、プロダクト定義は [`overview.md`](./overview.md)、MVP の優先ユースケースは [`use_cases.md`](./use_cases.md) とする。個別の API、Storage、UI、状態、ナビゲーション等は各専門仕様を正とする。

## Product Definition

プロダクトの存在理由、対象、非目標は [`overview.md`](./overview.md) を正本とする。アーキテクチャー方針は [`architecture.md`](./architecture.md) を正本とする。

## Canonical Specs

関心事ごとのファイル一覧は [`specs.md`](./specs.md) を正本とする。本仕様は名簿を再掲しない。Application は Provider 固有 API Model を直接 UI に公開しない。層境界は [`models_spec.md`](./models_spec.md) を正とする。

## Specification Hierarchy

本仕様と個別仕様の関係は下記とする。`overview.md` が入口、本仕様が統合の見取り図である。関心事は アプリケーション (`use_cases` / `application_state` / `state_machine` / `domain_rules` / `authentication_spec`)、データ (`models_spec` / `storage_spec` / `cache_spec` / `ios_spec` / `android_spec`)、API (`api-packagist` / `api-github`)、UI (`ux_flows_spec` / `navigation_spec` / `screen_spec` / `component_spec` / `ui-viewport` / `ui` / `design_spec` / `statistics_spec`)、プラットフォーム (`architecture` / `security_spec` / `kmp_spec`)、運用 (`cicd` / `release` / `testing_spec`) に分かれる。名簿は [`specs.md`](./specs.md) を正本とする。

入口の目次およびファイルの名簿は [`specs.md`](./specs.md)、分割方針は [`spec_structure.md`](./spec_structure.md) を参照する。

## Conflict Resolution

個別仕様と本仕様が矛盾する場合は、**関心事ごとの正本を優先する**。本仕様は再掲しない。

横断的な境界の正本は下記とする。

* アーキテクチャー境界: [`architecture.md`](./architecture.md)
* セキュリティ方針: [`security_spec.md`](./security_spec.md)

## Specification Change Policy

仕様変更時は、関連する正本を同時に確認する。たとえば Package Identifier の変更は、少なくとも下記に影響する可能性がある。

* [`models_spec.md`](./models_spec.md)
* [`domain_rules.md`](./domain_rules.md)
* [`use_cases.md`](./use_cases.md)
* [`state_machine.md`](./state_machine.md)
* [`navigation_spec.md`](./navigation_spec.md)
* [`storage_spec.md`](./storage_spec.md)

仕様変更後は Architecture / State / Storage / API / UI / KMP compatibility / Test coverage の整合を、各正本で確認する。

## MVP Scope

MVP で優先するユースケースは [`use_cases.md`](./use_cases.md) の MVP ユースケースを正本とする。受け入れ条件は各専門仕様に従う。

## Design Summary

設計原則は [`architecture.md`](./architecture.md) を正本とする。本仕様は原則を再掲しない。
