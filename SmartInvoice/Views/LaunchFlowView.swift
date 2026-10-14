import SwiftUI

struct LaunchFlowView: View {
    private enum Screen {
        case splash
        case overview
        case getStarted
        case home
    }

    @State private var currentScreen: Screen = .splash

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.99)
                .ignoresSafeArea()

            Group {
                switch currentScreen {
                case .splash:
                    SplashView()

                case .overview:
                    OverviewView(
                        onSkip: { currentScreen = .getStarted },
                        onContinue: { currentScreen = .getStarted }
                    )

                case .getStarted:
                    GetStartedView(
                        onBack: { currentScreen = .overview },
                        onGetStarted: { currentScreen = .home }
                    )

                case .home:
                    ContentView()
                }
            }
            .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.35), value: screenKey)
        .task {
            try? await Task.sleep(for: .seconds(1.8))

            if currentScreen == .splash {
                currentScreen = .overview
            }
        }
    }

    private var screenKey: Int {
        switch currentScreen {
        case .splash: return 0
        case .overview: return 1
        case .getStarted: return 2
        case .home: return 3
        }
    }
}
