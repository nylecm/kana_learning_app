import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        VStack(spacing: 0) {
            header
            Divider()
            Group {
                switch model.tab {
                case .study: StudyTabView()
                case .progress: StatsView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.canvas)
        .frame(minWidth: 1000, minHeight: 700)
    }

    private var header: some View {
        @Bindable var model = model

        return HStack(spacing: 18) {
            HStack(spacing: 8) {
                Text("仮")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.accent)
                Text("Kana")
                    .font(.title3.weight(.semibold))
            }

            Picker("Section", selection: $model.tab) {
                ForEach(AppModel.Tab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 320)

            Spacer()

            Text("⌘1 ⌘2 ⌘3 switch · ⌘N new session")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

/// Study tab: either the deck setup screen or a live session.
struct StudyTabView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let session = model.session {
            SessionView(session: session)
        } else {
            HomeView()
        }
    }
}
