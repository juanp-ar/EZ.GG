
import SwiftUI


struct ProfileView: View {
    @ObservedObject var viewModel : SummonerViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ProfileHeaderView(viewModel: viewModel)
                ScrollMenuView(viewModel: viewModel)
                MatchHistoryView(viewModel: viewModel, navigationPath: $navigationPath)
            }
        }
        .id(viewModel.summonerData) // View's identity for resetting the view.
        .frame(maxWidth: .infinity)
        .navigationTitle("\(viewModel.gameName?.capitalized ?? "N/A")#\(viewModel.tagLine?.uppercased() ?? "N/A")")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .commonBackgroundStyle()
        .commonToolbar(navigationPath: $navigationPath)
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    @ObservedObject var viewModel: SummonerViewModel
    
    var body: some View {
        let profileIconId = viewModel.summonerData?.profileIconId ?? 0
        let summonerLevel = viewModel.summonerData?.summonerLevel ?? 0
        
        HStack {
            profileImageView(iconId: profileIconId)
            
            VStack(alignment: .leading) {
                Text("\(viewModel.gameName?.capitalized ?? "N/A")#\(viewModel.tagLine?.uppercased() ?? "N/A")")
                    .padding(.bottom)
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.white.opacity(0.8))
                
                Text("Level: \(summonerLevel)")
                    .font(.footnote)
                    .fontWeight(.light)
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack(alignment: .center) {
    
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 80, alignment: .trailing)
        .background(Color.black.opacity(0.1))
    }
}

// MARK: - Profile Image View
private func profileImageView(iconId: Int) -> some View {
    let apiService = DdragonAPIService()
    let imageUrl = apiService.iconURL(for: .profileIcon(id: iconId))
    return Group {
        if let imageUrl = imageUrl {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                case .failure(_):
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}


struct ScrollMenuView: View {
    @ObservedObject var viewModel: SummonerViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                RankedInfoView(title: "Ranked Solo / Duo", rankedData: viewModel.rankedData)
                    .frame(maxWidth: .infinity, maxHeight: 64)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                
                RankedInfoView(title: "Ranked Flex", rankedData: viewModel.rankedFlexData)
                    .frame(maxWidth: .infinity, maxHeight: 64)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
        .background(Color.black.opacity(0.1))
    }
}

private struct RankedInfoView: View {
    let title: String
    let rankedData: SummonerRankedData?

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .fontWeight(.light)
                .foregroundStyle(Color.white.opacity(0.8))
            
            Spacer()
            
            Text(matchRecordText)
                .font(.caption2)
                .fontWeight(.light)
                .foregroundStyle(Color.white.opacity(0.8))
            
            Spacer()
            
            Text(winRateText)
                .font(.caption2)
                .fontWeight(.light)
                .foregroundStyle(Color.white.opacity(0.8))
        }
        .padding()
        .frame(width: 140, alignment: .leading)
    }
    
    private var matchRecordText: String {
        guard let data = rankedData else { return "0W - 0L" }
        let wins = data.wins ?? 0
        let losses = data.losses ?? 0
        return "\(wins)W - \(losses)L"
    }

    private var winRateText: String {
        guard let data = rankedData, data.totalMatches > 0 else { return "WR 0.0%" }
        let winRate = Double(data.wins ?? 0) / Double(data.totalMatches) * 100
        return "WR \(String(format: "%.1f", winRate))%"
    }
}

struct MatchHistoryView: View {
    @ObservedObject var viewModel: SummonerViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.matchHistory.sorted(by: { $0.key > $1.key }), id: \.key) { (key, match) in
                VStack(alignment: .leading, spacing: 8) {
                    // Display match ID or timestamp (key)
                    Text("Match ID: \(key)")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 8)
                .onTapGesture {
                    navigationPath.append(key)
                    print("Tapped match ID: \(key)")
                }
            }
            .padding([.leading, .trailing])
        }
    }
}
