
import Foundation


/// A service class for interacting with the League of Legends Data Dragon API.
///
/// This class provides functionality to construct URLs for fetching various icons (profile and champion icons)
/// from the League of Legends Data Dragon API based on the specified version.
///
/// The class utilizes a private constant to define the current version of the API and provides an enum to handle
/// different types of icons, each with its corresponding path.
///
/// - Note: You can use the following request to fetch the latest API version:
/// `curl -X GET https://ddragon.leagueoflegends.com/api/versions.json`
///
/// Usage:
/// ```swift
/// let service = DdragonAPIService()
/// if let profileIconURL = service.iconURL(for: .profileIcon(id: 1234)) {
///     // Use the URL to fetch the profile icon
/// }
///
class DdragonAPIService {
    
    private let ddragonLeagueAPIVersion = "14.20.1"


    enum IconType {
        case profileIcon(id: Int)
        case championIconById(id: Int)
        case championIconByName(name: String)

        /// The path for the specific icon type, constructed based on the icon type case.
        var path: String {
            switch self {
            case .profileIcon(let id):
                return "img/profileicon/\(id).png"
            case .championIconById(let id):
                if let championName = championIDNameMap[id] {
                    return "img/champion/\(championName).png"
                }
                return ""
            case .championIconByName(let name):
                return "img/champion/\(name).png"
            }
        }
    }

    func iconURL(for type: IconType) -> URL? {
        let baseURL = "https://ddragon.leagueoflegends.com/cdn/\(ddragonLeagueAPIVersion)/"
        let urlString = baseURL + type.path
        return URL(string: urlString)
    }
}
