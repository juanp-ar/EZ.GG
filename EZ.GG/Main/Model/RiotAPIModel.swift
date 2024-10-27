
import Foundation
import SwiftUI


struct SummonerData: Codable, Hashable {
    let puuid: String?
    let accountId: String?
    let profileIconId: Int?
    let id: String?
    let summonerLevel: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(puuid)
        }
}

struct SummonerRankedData: Decodable {
    let leagueId: String?
    let summonerId: String?
    let queueType: String?
    let tier: String?
    let rank: String?
    let leaguePoints: Int?
    let wins: Int?
    let losses: Int?

    var totalMatches: Int {
        (wins ?? 0) + (losses ?? 0)
    }
}

struct ChampionMastery: Codable, Hashable, Identifiable {
    let championId: Int?
    let championLevel: Int?
    let championPoints: Int?
    
    var id: Int? {
            return championId
        }
    func hash(into hasher: inout Hasher) {
        hasher.combine(championId)
        }
}

struct MatchDetail: Decodable {
    let metadata: Metadata?
    let info: Info?
    
    struct Metadata: Decodable {
        let matchId: String?
    }
    
    struct Info: Decodable {
        let endOfGameResult: String?
        let gameCreation: Int?
        let gameDuration: Int?
        let participants: [Participant]?
        let teams: [Team]?
        let queueId: Int?
    }

    struct Team: Decodable {
        let bans: [Ban]?
        let objectives: Objectives?
        let teamId: Int?
        let win: Bool?

        struct Ban: Decodable {
            let championId: Int?
            let pickTurn: Int?
        }

        struct Objectives: Decodable {
            let baron: Objective?
            let champion: Objective?
            let dragon: Objective?
            let inhibitor: Objective?
            let riftHerald: Objective?
            let tower: Objective?

            struct Objective: Decodable {
                let first: Bool?
                let kills: Int?
            }
        }
    }

    struct Participant: Decodable {
        let challenges: Challenges?
        let perks: Perks?

        struct Challenges: Decodable {
            let killParticipation: Double?
            let kda: Double?
        }

        struct Perks: Decodable {
            let styles: [PerkStyle]?

            struct PerkStyle: Decodable {
                let description: String?
                let style: Int?
                let selections: [PerkStyleSelection]?

                struct PerkStyleSelection: Decodable {
                    let perk: Int?
                    let var1: Int?
                    let var2: Int?
                    let var3: Int?
                }
            }
        }

        let puuid: String?
        let win: Bool?
        let teamId: Int?
        let teamPosition: String?
        let championId: Int?
        let champLevel: Int?
        let championName: String?
        let profileIcon: Int?
        let riotIdGameName: String?
        let riotIdTagline: String?

        let kills: Int?
        let deaths: Int?
        let assists: Int?
        let largestMultiKill: Int?
        let killingSprees: Int?
        let largestKillingSpree: Int?
        let totalDamageDealtToChampions: Int?
        let totalDamageTaken: Int?

        let totalMinionsKilled: Int?
        let neutralMinionsKilled: Int?
        
        var totalCS: Int {
            let minionsKilled = totalMinionsKilled ?? 0
            let neutralKilled = neutralMinionsKilled ?? 0
            return minionsKilled + neutralKilled
        }
        
        let goldEarned: Int?
        let goldSpent: Int?
        let visionScore: Int?
        
        var formattedGoldEarned: String {
            guard let gold = goldEarned else { return "0" }
            
            if gold >= 1000 {
                let formattedValue = Double(gold) / 1000.0
                return String(format: "%.1fk", formattedValue)
            } else {
                return "\(gold)"
            }
        }

        let item0: Int?
        let item1: Int?
        let item2: Int?
        let item3: Int?
        let item4: Int?
        let item5: Int?
        let item6: Int?

        let summoner1Id: Int?
        let summoner2Id: Int?
        
        func getPrimaryRune() -> Int? {
            guard let styles = perks?.styles, !styles.isEmpty,
                  let selections = styles.first?.selections, !selections.isEmpty else {
                return nil
            }
            return selections.first?.perk  // The first rune selection of the first style (primary)
        }
        
        func csPerMinute(gameDuration: Int) -> Double {
            guard gameDuration > 0 else { return 0.0 }
            let gameDurationInMinutes = Double(gameDuration) / 60.0
            return round((Double(totalCS) / gameDurationInMinutes) * 100) / 100
        }
    }
}


struct MatchOutcomeColor {
    let result: String

    var stringColor: Color {
        switch result {
        case "Win":
            return .green
        case "Loss":
            return .red
        default:
            return .gray
        }
    }
}
