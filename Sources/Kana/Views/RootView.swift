import SwiftUI

/// The window shell: a native sidebar on the left, the current screen on the right.
///
/// Building it on `NavigationSplitView` means macOS itself supplies the Liquid Glass sidebar, the
/// rounded selection, the sidebar-toggle button, and the sidebar's own keyboard navigation. The
/// `⌘1` `⌘2` `⌘3` commands keep driving the same selection binding they always did.
///
/// The minimum size lives on the *detail* column, not on the split view: a minimum on the split
/// view makes the whole window lay out wider than its frame and clip both edges when it is shrunk,
/// whereas this way the window's own minimum is the sidebar plus the detail, and `KanaApp` pins the
/// window to it with `.windowResizability(.contentMinSize)`.
struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        NavigationSplitView {
            Sidebar(selection: $model.tab)
                .navigationSplitViewColumnWidth(min: 200, ideal: 226, max: 260)
        } detail: {
            detail
                // 2 x 20 window padding + 460 middle + 20 gap + 220 panel = the layout's real
                // minimum, so the window stops before either column can be squeezed. The alignment
                // matters: if the width ever falls short of that minimum, the detail overflows to
                // the trailing edge instead of centring, which would slide it under the sidebar.
                .frame(minWidth: 740, minHeight: 620, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch model.tab {
        case .study: StudyTabView()
        case .progress: StatsView()
        case .settings: SettingsView()
        }
    }
}

/// The left column: the three screens, with today's numbers pinned to the bottom of the column.
///
/// The badge on *Study* is the number of cards the queue would hand out right now, so the sidebar
/// answers "is there anything to do?" without leaving whichever screen you are on.
private struct Sidebar: View {
    @Environment(AppModel.self) private var model
    @Binding var selection: AppModel.Tab

    var body: some View {
        VStack(spacing: 0) {
            BrandMark()
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 10)

            List(selection: $selection) {
                ForEach(AppModel.Tab.allCases) { tab in
                    Label(tab.title, systemImage: tab.symbol)
                        .badge(tab == .study ? model.plannedQueue.count : 0)
                        .tag(tab)
                }
            }
            .listStyle(.sidebar)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { TodayFooter() }
    }
}

private struct BrandMark: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: 9) {
            Text("仮")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.accent)

            VStack(alignment: .leading, spacing: 0) {
                Text("Kana")
                    .font(.headline)
                Text(model.sessionTitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Today's counters, floating on their own glass surface at the bottom of the sidebar.
private struct TodayFooter: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let log = model.todayLog

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("Today").font(.caption.weight(.semibold))
                Spacer(minLength: 0)
                if model.dueCount > 0 {
                    Text("\(model.dueCount) due")
                        .font(.caption)
                        .foregroundStyle(Theme.accent)
                        .lineLimit(1)
                }
            }

            HStack(spacing: 12) {
                metric("\(log.newIntroduced)", "new")
                metric("\(log.reviews)", "reviews")
                metric("\(model.plannedQueue.count)", "queued")
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 10)
        .padding(.top, 4)
        .padding(.bottom, 10)
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
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
