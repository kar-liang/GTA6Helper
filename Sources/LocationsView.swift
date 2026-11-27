import SwiftUI

struct LocationsView: View {
    @EnvironmentObject private var store: GuideStore
    @State private var searchText = ""

    private var areas: [String] {
        var seen: [String] = []
        for point in store.library.locations where !seen.contains(point.area) {
            seen.append(point.area)
        }
        return seen
    }

    private func points(in area: String) -> [LocationPoint] {
        store.library.locations.filter { point in
            point.area == area && matchesSearch(point)
        }
    }

    private func matchesSearch(_ point: LocationPoint) -> Bool {
        guard !searchText.isEmpty else { return true }
        return point.name.localizedCaseInsensitiveContains(searchText)
            || point.detail.localizedCaseInsensitiveContains(searchText)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(areas, id: \.self) { area in
                        let items = points(in: area)
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(area)
                                    .font(.title3).bold()
                                    .padding(.top, 4)
                                ForEach(items) { point in
                                    pointCard(point)
                                }
                            }
                        }
                    }
                    if areas.allSatisfy({ points(in: $0).isEmpty }) {
                        Text("没有找到匹配的点位")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 32)
                    }
                    Text("当前为已确认的主要区域清单；更细的兴趣点（商店、设施、收集点）会在核实后通过在线数据补充，这里不放未经确认的坐标。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("点位")
            .searchable(text: $searchText, prompt: "搜索点位")
        }
    }

    private func pointCard(_ point: LocationPoint) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: "mappin.circle.fill", color: .pink)
            VStack(alignment: .leading, spacing: 2) {
                Text(point.name)
                    .font(.headline)
                Text(point.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }
}
