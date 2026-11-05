import Foundation
import Observation
import S2JPackageDashboardCore

enum DashboardScreenPhase: Equatable {
    case loading
    case loaded(DashboardLoadResult)
    case failed(DashboardFailure)
}

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var phase: DashboardScreenPhase = .loading
    private let loadDashboard: LoadDashboardUseCase

    init(loadDashboard: LoadDashboardUseCase) {
        self.loadDashboard = loadDashboard
    }

    func load() async {
        phase = .loading
        do {
            let result = try await loadDashboard.execute()
            phase = .loaded(result)
        } catch let failure as DashboardFailure {
            phase = .failed(failure)
        } catch {
            phase = .failed(.underlyingMessage(error.localizedDescription))
        }
    }

    func refresh() async {
        await load()
    }
}
