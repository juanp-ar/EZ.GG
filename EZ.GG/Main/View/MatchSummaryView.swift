
import SwiftUI


struct MatchSummaryView: View {
    @ObservedObject var summonerContainer: SummonerContainer
    @ObservedObject var viewModel: SummonerViewModel
    @Binding var navigationPath: NavigationPath
    let matchId: String
    
    var body: some View {
        ScrollView {
            
            Text("Match ID: \(matchId)")
                .padding()
                .foregroundStyle(Color.white)
                .font(.title)
                
            if let matchDetail = viewModel.matchHistory.first(where: { $0.key == matchId }) {
                let mainSummonerPUUID = viewModel.summonerData?.puuid
                let mainSummonerTeamId = matchDetail.value?.info?.participants?.first(where: { $0.puuid == mainSummonerPUUID })?.teamId
                
                let gameDuration = matchDetail.value?.info?.gameDuration ?? 0
                let formattedDuration = String(format: "%02d:%02d", gameDuration / 60, gameDuration % 60)
                
                let participants = matchDetail.value?.info?.participants
                
                let maxDamage = participants?.map { $0.totalDamageDealtToChampions ?? 0 }.max() ?? 0

                let teamA = participants?.filter { $0.teamId == mainSummonerTeamId }
                let teamB = participants?.filter { $0.teamId != mainSummonerTeamId }
                
                let teamAName = mainSummonerTeamId == 100 ? "Blue Team" : "Red Team"
                let teamBName = teamAName == "Blue Team" ? "Red Team" : "Blue Team"
                
                let teamAColor = mainSummonerTeamId == 100 ? Color.blue : Color.red
                let teamBColor = teamAColor == Color.blue ? Color.red : Color.blue
                
                let teamAResult = teamA?.first?.win ?? true ? "Win" : "Loss"
                let teamBResult = teamB?.first?.win ?? true ? "Win" : "Loss"
                                
                VStack {
                    VStack {
                        Text("Game Duration:\(formattedDuration)")
                            .font(.subheadline)
                    }
                    
                    Divider()
                        .frame(height: 24)
                    
                    HStack{
                        Text(teamAName)
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundStyle(Color.white.opacity(0.8))
                        
                        Text(teamAResult)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(MatchOutcomeColor(result: teamAResult).stringColor)
                    }
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TeamView(
                        summonerContainer: summonerContainer,
                        viewModel: viewModel,
                        navigationPath: $navigationPath,
                        team: teamA ?? [],
                        teamColor: teamAColor,
                        gameDuration: gameDuration,
                        maxDamage: maxDamage)
                    
                    Divider()
                        .frame(height: 24)
                    
                    HStack{
                        Text(teamBName)
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundStyle(Color.white.opacity(0.8))
                        
                        Text(teamBResult)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(MatchOutcomeColor(result: teamBResult).stringColor)
                    }
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TeamView(
                        summonerContainer: summonerContainer,
                        viewModel: viewModel,
                        navigationPath: $navigationPath,
                        team: teamB ?? [],
                        teamColor: teamBColor,
                        gameDuration: gameDuration,
                        maxDamage: maxDamage)
                    
                    Divider()
                        .frame(height: 24)
                }
            }
        }
        .onAppear() {
            Task {
                await viewModel.loadMatchDetails(for: matchId)
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .commonBackgroundStyle()
        .commonToolbar(navigationPath: $navigationPath)
    }
}


struct TeamView: View {
    @ObservedObject var summonerContainer: SummonerContainer
    @ObservedObject var viewModel: SummonerViewModel
    @Binding var navigationPath: NavigationPath
    let team: [MatchDetail.Participant]
    let teamColor: Color
    let gameDuration: Int
    let maxDamage: Int
    
    var body: some View {
        VStack {
            ForEach(team, id: \.puuid) { participant in
                ParticipantButton(
                    summonerContainer: summonerContainer,
                    viewModel: viewModel,
                    navigationPath: $navigationPath,
                    participant: participant,
                    teamColor: teamColor,
                    gameDuration: gameDuration,
                    maxDamage: maxDamage
                )
            }
        }
        .padding([.leading, .trailing])
    }
}


struct ParticipantButton: View {
    @ObservedObject var summonerContainer: SummonerContainer
    @ObservedObject var viewModel: SummonerViewModel
    @Binding var navigationPath: NavigationPath
    let participant: MatchDetail.Participant
    let teamColor: Color
    let gameDuration: Int
    let maxDamage: Int
    
    @State private var showAlert: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        let gameName = participant.riotIdGameName ?? "N/A"
        let tagLine = participant.riotIdTagline ?? "N/A"
        
        Button(action: {
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
        }) {
            Text("\(gameName.capitalized) #\(tagLine.uppercased())")
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(teamColor, lineWidth: 1)
                    .fill(.black.opacity(0.1))
            )
        }
    }
}
