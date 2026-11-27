import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var store: GuideStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    progressSummaryCard
                    Text("收藏的攻略")
                        .font(.title3).bold()
                        .padding(.top, 4)
                    if store.favoriteGuides.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "star")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("还没有收藏。在攻略详情页右上角点星星就能加进来。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
                    } else {
                        VStack(spacing: 12) {
                            ForEach(store.favoriteGuides) { guide in
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
                .padding()
            }
            .navigationTitle("收藏")
        }
    }

    private var progressSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                IconBadge(systemName: "checklist", color: .purple)
                Text("清单进度")
                    .font(.headline)
                Spacer()
                Text("\(Int((store.overallProgress * 100).rounded()))%")
                    .font(.headline)
                    .foregroundStyle(.purple)
            }
            ProgressView(value: store.overallProgress)
                .tint(.purple)
            VStack(spacing: 8) {
                ForEach(store.library.checklistGroups) { group in
                    HStack {
                        Text(group.title)
                            .font(.subheadline)
                        Spacer()
                        Text("\(store.checkedCount(in: group))/\(group.items.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }
}
