
import Foundation


/// A service class for interacting with the Riot Games API.
class RiotAPIService {
    private let apiKey = ""
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 20
        self.session = URLSession(configuration: config)
    }
    
    private func performRequest(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-Riot-Token")
        
        for _ in 1...3 {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "HTTP Error", code: 500, userInfo: [NSLocalizedDescriptionKey: "No response from server"])
            }
            
            if httpResponse.statusCode == 200 {
                print("Status code: \(httpResponse.statusCode)")
                return data
            } else if httpResponse.statusCode == 429 {
                let retryAfter = httpResponse.allHeaderFields["Retry-After"] as? Int ?? 1
                try await Task.sleep(nanoseconds: UInt64(retryAfter) * 1_000_000_000)
            } else {
                throw NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP request failed with status code \(httpResponse.statusCode)"])
            }
        }
        
        throw NSError(domain: "HTTP Error", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limit exceeded"])
    }

    private func parseJSON<T: Decodable>(_ data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - LEAGUE OF LEGENDS

    func fetchPUUID(gameName: String, tagLine: String) async throws -> String? {
        let urlString = "https://americas.api.riotgames.com/riot/account/v1/accounts/by-riot-id/\(gameName)/\(tagLine)?api_key=\(apiKey)"
        let data = try await performRequest(urlString: urlString)
        let json: [String: String] = try parseJSON(data)
        let puuid = json["puuid"]
        
        return puuid
    }

    func fetchSummonerData(puuid: String) async throws -> SummonerData? {
        let urlString = "https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-puuid/\(puuid)?api_key=\(apiKey)"
        let data = try await performRequest(urlString: urlString)
        let summonerData: SummonerData = try parseJSON(data)
        
        return summonerData
    }

    func fetchRankedData(summonerId: String) async throws -> [SummonerRankedData] {
        let rankedUrlString = "https://na1.api.riotgames.com/lol/league/v4/entries/by-summoner/\(summonerId)?api_key=\(apiKey)"
        let data = try await performRequest(urlString: rankedUrlString)
        let rankedData: [SummonerRankedData] = try parseJSON(data)
        
        return rankedData
    }

    func fetchChampionMastery(puuid: String) async throws -> [ChampionMastery] {
        let urlString = "https://na1.api.riotgames.com/lol/champion-mastery/v4/champion-masteries/by-puuid/\(puuid)?api_key=\(apiKey)"
        let data = try await performRequest(urlString: urlString)
        let masteryData: [ChampionMastery] = try parseJSON(data)
        
        return masteryData
    }

    func fetchMatchIds(puuid: String, count: Int) async throws -> [String] {
        let urlString = "https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/\(puuid)/ids?start=0&count=\(count)"
        let data = try await performRequest(urlString: urlString)
        let matchIds: [String] = try parseJSON(data)
        
        return matchIds
    }

    func fetchMatchData(matchId: String) async throws -> MatchDetail {
        let urlString = "https://americas.api.riotgames.com/lol/match/v5/matches/\(matchId)?api_key=\(apiKey)"
        let data = try await performRequest(urlString: urlString)
        let matchData: MatchDetail = try parseJSON(data)
        
        return matchData
    }
}
