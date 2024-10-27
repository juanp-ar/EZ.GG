
import Combine
import Foundation


@MainActor
class SummonerViewModel: ObservableObject {
    @Published var gameName: String? = nil
    @Published var tagLine: String? = nil
    @Published var puuid: String? = nil
    
    @Published var summonerData: SummonerData? = nil
    @Published var rankedData: SummonerRankedData? = nil
    @Published var rankedFlexData: SummonerRankedData? = nil
    @Published var masteryData: [ChampionMastery]? = nil
    @Published var matchHistory: [String: MatchDetail?] = [:]
    @Published var isLoading: Bool = false
    
    private let apiService = RiotAPIService()
    
    private let errorHandlerService = ErrorHandlerService()
    var errorMessage: String? {
        errorHandlerService.errorMessage
    }
    
    func fetchData(gameName: String, tagLine: String) async {
        isLoading = true
        defer { isLoading = false }
        
        errorHandlerService.clearError()
        
        do {
            self.gameName = gameName
            self.tagLine = tagLine
            
            // Fetch PUUID
            guard let puuid = try await apiService.fetchPUUID(gameName: gameName, tagLine: tagLine) else {
                errorHandlerService.handleError(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "PUUID not found"]))
                return
            }
            self.puuid = puuid
            
            // Fetch Summoner Data
            if let summonerData = try await apiService.fetchSummonerData(puuid: puuid) {
                self.summonerData = summonerData
                
                // Fetch Ranked Data (Solo/Duo and Flex)
                let rankedData = try await apiService.fetchRankedData(summonerId: summonerData.id ?? "N/A")
                self.rankedData = rankedData.first(where: { $0.queueType == "RANKED_SOLO_5x5" })
                self.rankedFlexData = rankedData.first(where: { $0.queueType == "RANKED_FLEX_SR" })
            }
            
            // Fetch Champion Mastery
            self.masteryData = try await apiService.fetchChampionMastery(puuid: puuid)
            
            // Fetch Match IDs
            let matchIds = try await apiService.fetchMatchIds(puuid: puuid, count: 40)
            
            // Fetch Match Data
            for matchId in matchIds {
                let matchData = try await apiService.fetchMatchData(matchId: matchId)
                await MainActor.run {
                    matchHistory[matchId] = matchData
                }
            }
        } catch {
            errorHandlerService.handleError(error)
        }
    }
    
    func loadMatchDetails(for matchId: String) async {
        do {
            let matchDetail = try await apiService.fetchMatchData(matchId: matchId)
            print("Re-loading match details for \(matchId)")
            await MainActor.run {
                matchHistory[matchId] = matchDetail
            }
        } catch {
            errorHandlerService.handleError(error)
        }
    }
}
