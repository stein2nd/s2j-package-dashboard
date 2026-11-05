import Testing
@testable import S2JPackageDashboardCore

@Test func dashboardSnapshotEmptyIsStable() {
    let snapshot = DashboardSnapshot.empty
    #expect(snapshot.myPackages.isEmpty)
    #expect(snapshot.favorites.isEmpty)
}
