import SwiftUI

struct RootView: View {
    @State private var selection: AppSection? = .dashboard
    @State private var dashboardModel: DashboardViewModel

    init(environment: AppEnvironment) {
        _dashboardModel = State(initialValue: DashboardViewModel(loadDashboard: environment.loadDashboard))
    }

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("S2J Package Dashboard")
        } detail: {
            detailView
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection ?? .dashboard {
        case .dashboard:
            NavigationStack {
                DashboardView(model: dashboardModel)
            }
        case .packages:
            NavigationStack {
                PackagesPlaceholderView()
            }
        case .statistics:
            NavigationStack {
                StatisticsPlaceholderView()
            }
        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
}
