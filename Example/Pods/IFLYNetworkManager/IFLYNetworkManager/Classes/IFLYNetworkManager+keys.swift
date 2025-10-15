import Foundation
import Alamofire

/// Gitee用户公钥模型
public struct GiteeUserKey: Codable {
    public let id: Int
    public let key: String
    public let title: String?
    public let createdAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case title
        case createdAt = "created_at"
    }
}

/// IFLYNetworkManager 的事件相关扩展
public extension IFLYNetworkManager {
    /// 获取Gitee用户所有公钥
    /// - Parameter completion: 完成回调，返回GiteeUserKey数组或错误
    /// - Returns: 可取消的请求
    @discardableResult
    func getUserKeys(completion: @escaping (Result<[GiteeUserKey], Error>) -> Void) -> DataRequest? {
        guard currentAccessToken() != nil else {
            completion(.failure(NSError(domain: "GiteeAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not set"])))
            return nil
        }
        let path = "/user/keys"
        return request(path: path, method: .get, parameters: nil, encoding: URLEncoding.default) { result in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Gitee API Response JSON: \(jsonString)")
                }
                do {
                    let decoder = JSONDecoder.iso8601withFractionalSeconds
                    let keys = try decoder.decode([GiteeUserKey].self, from: data)
                    completion(.success(keys))
                } catch {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Failed to decode GiteeUserKey. JSON: \(jsonString), error: \(error)")
                    }
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
//https://gitee.com/api/v5/users/{username}/events
// 文档地址:https://gitee.com/api/v5/swagger#/getV5UsersUsernameEvents
// 实现这个接口
