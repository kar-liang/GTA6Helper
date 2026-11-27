import SwiftUI

// MARK: - Shared bits

/// Circular soft-tinted icon badge, same style as HayDay 助手.
struct IconBadge: View {
    let systemName: String
    let color: Color
    var size: CGFloat = 34
    var iconSize: CGFloat = 17

    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.18))
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

/// SF Symbol for a guide category, matched by keyword so categories added
/// later through the online JSON still get a sensible icon.
func guideIconName(for category: String) -> String {
    if category.contains("新手") || category.contains("入门") { return "sparkles" }
    if category.contains("世界") || category.contains("背景") { return "globe.americas.fill" }
    if category.contains("探索") { return "binoculars.fill" }
    if category.contains("赚钱") || category.contains("金钱") { return "dollarsign.circle.fill" }
    if category.contains("生存") || category.contains("警察") || category.contains("通缉") { return "shield.fill" }
    if category.contains("载具") { return "car.fill" }
    if category.contains("房产") { return "house.fill" }
    if category.contains("系统") { return "gearshape.2.fill" }
    if category.contains("任务") { return "flag.fill" }
    if category.contains("收集") { return "magnifyingglass" }
    return "book.fill"
}

func guideIconColor(for category: String) -> Color {
    switch guideIconName(for: category) {
    case "sparkles": return .pink
    case "globe.americas.fill": return .blue
    case "binoculars.fill": return .teal
    case "dollarsign.circle.fill": return .green
    case "shield.fill": return .red
    case "car.fill": return .indigo
    case "house.fill": return .orange
    case "gearshape.2.fill": return .purple
    case "flag.fill": return .orange
    case "magnifyingglass": return .teal
    default: return .pink
    }
}

/// One guide row used by both the 攻略 tab and the 收藏 tab.
struct GuideRow: View {
    @EnvironmentObject private var store: GuideStore
    let guide: GuideArticle

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: guideIconName(for: guide.category),
                      color: guideIconColor(for: guide.category))
            VStack(alignment: .leading, spacing: 2) {
                Text(guide.title)
                    .font(.headline)
                Text(guide.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            if store.isFavorite(guide) {
                Image(systemName: "star.fill")
                    .font(.footnote)
                    .foregroundStyle(.yellow)
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Root (tabs)

struct ContentView: View {
    @EnvironmentObject private var store: GuideStore

    var body: some View {
        TabView {
            GuidesView()
                .tabItem {
                    Label("攻略", systemImage: "book.fill")
                }
            ChecklistView()
                .tabItem {
                    Label("清单", systemImage: "checklist")
                }
            MapView()
                .tabItem {
                    Label("地图", systemImage: "map.fill")
                }
            LocationsView()
                .tabItem {
                    Label("点位", systemImage: "mappin.and.ellipse")
                }
            FavoritesView()
                .tabItem {
                    Label("收藏", systemImage: "star.fill")
                }
        }
        .task {
            await store.refreshFromRemote()
        }
    }
}
