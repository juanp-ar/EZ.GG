
import Combine
import Foundation


@MainActor
class SummonerContainer: ObservableObject {
    @Published var summoners: [SummonerViewModel] = []
    
    func addSummoner(summoner: SummonerViewModel) {
        summoners.append(summoner)
    }
    
    func getSummoner(at index: Int) -> SummonerViewModel {
        return summoners[index]
    }
    
    func getSummoner(for summonerData: SummonerData) -> SummonerViewModel? {
        print("Searching container for summoner with puuid: \(summonerData.puuid ?? "nil")")
        return summoners.first { $0.summonerData == summonerData }
    }
}
