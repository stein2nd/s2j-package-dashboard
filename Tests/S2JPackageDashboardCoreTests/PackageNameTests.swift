import Testing
@testable import S2JPackageDashboardCore

@Test func packageNameAcceptsValidFullName() {
    let name = PackageName(fullName: "stein2nd/docs-linter")
    #expect(name?.fullName == "stein2nd/docs-linter")
}

@Test func packageNameRejectsInvalidFullName() {
    #expect(PackageName(fullName: "") == nil)
    #expect(PackageName(fullName: "vendor-only") == nil)
    #expect(PackageName(fullName: "/package") == nil)
}

@Test func loadDashboardUseCaseReturnsFirstLaunchWhenEmpty() async throws {
    let store = InMemoryLocalDataStore()
    let useCase = LoadDashboardUseCase(store: store, connectivity: AlwaysOnlineConnectivityMonitor())
    let result = try await useCase.execute()
    #expect(result.isFirstLaunch)
    #expect(result.snapshot.myPackages.isEmpty)
}
