import SwiftUI

struct GuidesView: View {
    @EnvironmentObject private var store: GuideStore
    @State private var searchText = ""

    private var categories: [String] {
        var seen: [String] = []
        for guide in store.library.guides where !seen.contains(guide.category) {
            seen.append(guide.category)
        }
        return seen
    }

    private func guides(in category: String) -> [GuideArticle] {
        store.library.guides.filter { guide in
            guide.category == category && matchesSearch(guide)
        }
    }

    private func matchesSearch(_ guide: GuideArticle) -> Bool {
        guard !searchText.isEmpty else { return true }
        if guide.title.localizedCaseInsensitiveContains(searchText) { return true }
        if guide.summary.localizedCaseInsensitiveContains(searchText) { return true }
        return guide.sections.contains { section in
            section.heading.localizedCaseInsensitiveContains(searchText)
                || section.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                // No GlassEffectContainer around the page (cards would merge);
                // each card carries its own .glassEffect, spacing 12.
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        let items = guides(in: category)
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category)
                                    .font(.title3).bold()
                                    .padding(.top, 4)
                                ForEach(items) { guide in
                                    NavigationLink {
                                        GuideDetailView(guide: guide)
                                    } label: {
                                        GuideRow(guide: guide)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    if categories.allSatisfy({ guides(in: $0).isEmpty }) {
                        Text("没有找到匹配的攻略")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 32)
                    }
                    Text("数据更新于 \(store.library.updatedAt)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("攻略")
            .searchable(text: $searchText, prompt: "搜索攻略")
        }
    }
}

struct GuideDetailView: View {
    @EnvironmentObject private var store: GuideStore
    let guide: GuideArticle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(guide.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))

                ForEach(Array(guide.sections.enumerated()), id: \.offset) { _, section in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            IconBadge(systemName: guideIconName(for: guide.category),
                                      color: guideIconColor(for: guide.category),
                                      size: 28, iconSize: 13)
                            Text(section.heading)
                                .font(.headline)
                        }
                        Text(section.body)
                            .font(.subheadline)
                            .lineSpacing(3)
                        if !section.steps.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(Array(section.steps.enumerated()), id: \.offset) { _, step in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.footnote)
                                            .foregroundStyle(.green)
                                            .padding(.top, 2)
                                        Text(step)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.top, 2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleFavorite(guide)
                } label: {
                    Label("收藏",
                          systemImage: store.isFavorite(guide) ? "star.fill" : "star")
                }
            }
        }
    }
}
