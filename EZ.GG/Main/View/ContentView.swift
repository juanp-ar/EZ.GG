
import SwiftUI


struct ContentView: View {
    @StateObject private var summonerContainer = SummonerContainer()
    @State private var gameName: String = "Proximusprime002"
    @State private var tagLine: String = "NA1"
    @State private var showAlert: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack {
                    // Title and Logo Section
                    Text("EZ.GG")
                        .padding()
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .bold()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                                .fill(.clear)
                        )
                        .overlay(
                            Image("poro-coolguy")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .offset(x: 40, y: 16)
                                .zIndex(1),
                            alignment: .bottomTrailing
                        )
                        .padding(.bottom, 48)

                    // Input Fields
                    TextField("Game Name", text: $gameName)
                        .padding()
                        .frame(height: 48)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .padding(.horizontal, 48)

                    TextField("Tag Line", text: $tagLine)
                        .padding()
                        .frame(height: 48)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .padding(.horizontal, 48)
                        .padding(.bottom, 24)

                    SearchButton {
                        Task {
                            let newSummoner = SummonerViewModel()
                            await newSummoner.fetchData(gameName: gameName, tagLine: tagLine)
                            
                            if newSummoner.errorMessage != nil {
                                showAlert = true
                                errorMessage = newSummoner.errorMessage
                            } else if let summonerData = newSummoner.summonerData {
                                summonerContainer.addSummoner(summoner: newSummoner)
                                navigationPath.append(summonerData)
                            }
                        }
                    }

                }
                .padding(.top, 96)
                
                // Loading Indicator
                if summonerContainer.summoners.last?.isLoading == true {
                    VStack {
                        ProgressView("Fetching Profile...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundStyle(Color.white)
                        Image("poro-question")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity)
            .commonBackgroundStyle()
            
            // Navigation Destinations
            .navigationDestination(for: SummonerData.self) { summonerData in
                if let viewModel = summonerContainer.getSummoner(for: summonerData) {
                    ProfileView(viewModel: viewModel, navigationPath: $navigationPath)
                } else {
                    Text("Summoner not found")
                        .foregroundColor(.red)
                }
            }
            .navigationDestination(for: String.self) { matchId in
                if let lastSummoner = summonerContainer.summoners.last {
                    MatchSummaryView(summonerContainer: summonerContainer, viewModel: lastSummoner, navigationPath: $navigationPath, matchId: matchId)
                } else {
                    Text("Error loading match summary.")
                        .foregroundColor(.red)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unexpected error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct SearchButton: View {
    
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack {
                    Image("lol_icon_v3_white")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text("Search Summoner")
                        .padding()
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .background(Color.mint)
                .cornerRadius(8)
                .padding(.horizontal, 48)
            }
        }
    }
}

struct CommonBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.teal)
    }
}

extension View {
    func commonBackgroundStyle() -> some View {
        self.modifier(CommonBackgroundStyle())
    }
}

struct CommonToolbar: ViewModifier {
    @Binding var navigationPath: NavigationPath

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        navigationPath.removeLast()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        navigationPath.removeLast(navigationPath.count)
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .tint(Color.black.opacity(0.6))
    }
}

extension View {
    func commonToolbar(navigationPath: Binding<NavigationPath>) -> some View {
        self.modifier(CommonToolbar(navigationPath: navigationPath))
    }
}


#Preview {
    ContentView()
}


