import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var store: GuideStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    overallCard
                    ForEach(store.library.checklistGroups) { group in
                        groupCard(group)
                    }
                    Text("勾选状态保存在本机；清单内容会随在线数据更新而增减，已勾选的条目按 ID 保留。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("清单")
        }
    }

    private var overallCard: some View {
        VStack(spacing: 8) {
            Text("总进度 \(Int((store.overallProgress * 100).rounded()))%")
                .font(.title2).bold()
            ProgressView(value: store.overallProgress)
                .tint(.pink)
            Text("已完成 \(store.overallCheckedCount) / \(store.library.allChecklistItems.count) 项")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .glassEffect(.regular.tint(.pink.opacity(0.15)), in: RoundedRectangle(cornerRadius: 16))
    }

    private func groupCard(_ group: ChecklistGroup) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(group.title)
                    .font(.headline)
                Spacer()
                Text("\(store.checkedCount(in: group))/\(group.items.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: store.progress(in: group))
                .tint(.purple)
            VStack(spacing: 12) {
                ForEach(group.items) { item in
                    itemRow(item)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }

    private func itemRow(_ item: ChecklistItem) -> some View {
        let checked = store.isChecked(item)
        return Button {
            store.toggleChecked(item)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(checked ? Color.green : Color.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline).bold()
                        .strikethrough(checked)
                        .foregroundStyle(checked ? Color.secondary : Color.primary)
                    Text(item.detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
