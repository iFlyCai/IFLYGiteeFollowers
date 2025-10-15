import Foundation
import Alamofire

/// Gitee组织模型
enum GiteeAPIOrg: String {
    case meOrgs = "/user/orgs"
}

public struct GiteeOrganization: Codable {
    public let avatarUrl: String?
    public let organizationDesc: String?
    public let eventsUrl: String?
    public let followersCount: Int?
    public let id: Int?
    public let login: String?
    public let membersUrl: String?
    public let name: String?
    public let reposUrl: String?
    public let url: String?

    
    private enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case organizationDesc = "description"
        case eventsUrl = "events_url"
        case followersCount = "followers_count"
        case id
        case login
        case membersUrl = "members_url"
        case name
        case reposUrl = "repos_url"
        case url
    }
}

public extension IFLYNetworkManager {
    /// 获取当前登录用户的组织列表
    /// - Parameters:
    ///   - page: 页码，默认为1
    ///   - perPage: 每页数量，默认为30
    ///   - completion: 完成回调，返回GiteeOrganization数组或错误
    /// - Returns: 可取消的请求
    @discardableResult
    func getUserOrgs(
        page: Int = 1,
        perPage: Int = 30,
        completion: @escaping (Result<[GiteeOrganization], Error>) -> Void
    ) -> DataRequest? {
        // 检查AccessToken是否存在
        guard currentAccessToken() != nil else {
            completion(.failure(NSError(domain: "GiteeAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not set"])))
            return nil
        }
        
        // 设置请求路径和参数
        let path = GiteeAPI.Users.meOrgs
        let parameters: Parameters = ["page": page, "per_page": perPage]
        
        // 发起请求
        return request(path: path, method: .get, parameters: parameters, encoding: URLEncoding.default) { result in
            switch result {
            case .success(let data):
                // 打印响应JSON（调试用）
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Gitee API Organizations Response JSON: \(jsonString)")
                }
                
                // 解析JSON数据
                do {
                    let decoder = JSONDecoder()
                    let organizations = try decoder.decode([GiteeOrganization].self, from: data)
                    completion(.success(organizations))
                } catch {
                    // 解析失败时打印错误信息
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Failed to decode GiteeOrganization. JSON: \(jsonString), error: \(error)")
                    }
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
