import SwiftUI
import S2JPackageDashboardCore

struct DashboardView: View {
    @Bindable var model: DashboardViewModel

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                ProgressView("読み込み中…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let failure):
                ContentUnavailableView {
                    Label("データを読み込めません", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(failureMessage(failure))
                } actions: {
                    Button("再試行") {
                        Task { await model.refresh() }
                    }
                }
            case .loaded(let result):
                dashboardContent(result)
            }
        }
        .navigationTitle("ダッシュボード")
        .task {
            if case .loading = model.phase {
                await model.load()
            }
        }
        .refreshable {
            await model.refresh()
        }
    }

    @ViewBuilder
    private func dashboardContent(_ result: DashboardLoadResult) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if result.isOffline {
                    Label("オフラインです。端末内のデータを表示しています。", systemImage: "wifi.slash")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                if result.isFirstLaunch {
                    ContentUnavailableView {
                        Label("ようこそ", systemImage: "tray")
                    } description: {
                        Text("管理対象のパッケージやお気に入りは、まだ登録されていません。Packagist 認証を設定すると、管理対象を取得できます。")
                    }
                    .frame(maxWidth: .infinity)
                }

                packageSection(
                    title: "管理対象のパッケージ",
                    emptyMessage: "管理対象のパッケージはありません",
                    items: result.snapshot.myPackages
                )

                packageSection(
                    title: "お気に入り",
                    emptyMessage: "お気に入りはありません",
                    items: result.snapshot.favorites
                )

                statisticsSection(result.snapshot.statisticsSummary)

                snapshotStatusSection(result.snapshot)
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder
    private func packageSection(
        title: String,
        emptyMessage: String,
        items: [PackageListItem]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            if items.isEmpty {
                Text(emptyMessage)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(items) { item in
                        PackageRowView(item: item)
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private func statisticsSection(_ summary: StatisticsSummary?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("統計の概要")
                .font(.headline)
                .padding(.horizontal)

            if let summary {
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.headline)
                    if let detail = summary.detail {
                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("統計データはまだありません")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private func snapshotStatusSection(_ snapshot: DashboardSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("スナップショット")
                .font(.headline)
                .padding(.horizontal)
            Text(freshnessLabel(snapshot.snapshotFreshness))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            if let updated = snapshot.lastUpdatedAt {
                Text("最終更新: \(updated.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    private func freshnessLabel(_ freshness: SnapshotFreshness) -> String {
        switch freshness {
        case .fresh: "データは最新です"
        case .stale: "データは Stale です"
        case .unknown: "更新状態は不明です"
        }
    }

    private func failureMessage(_ failure: DashboardFailure) -> String {
        switch failure {
        case .storageUnavailable:
            "ローカルデータを読み込めませんでした。"
        case .underlyingMessage(let message):
            message
        }
    }
}

private struct PackageRowView: View {
    let item: PackageListItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shippingbox")
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.fullName)
                    .font(.body.weight(.medium))
                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
