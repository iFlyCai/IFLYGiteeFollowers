import Foundation
import Alamofire

/// 事件类型枚举
public enum GiteeEventType: String, Decodable {
    case push = "PushEvent"
    case fork = "ForkEvent"
    case star = "WatchEvent"
    case issue = "IssuesEvent"
    case pullRequest = "PullRequestEvent"
    case pullRequestComment = "PullRequestCommentEvent"
    case commitComment = "CommitCommentEvent"
    case issueComment = "IssueCommentEvent"
    case pullRequestReviewComment = "PullRequestReviewCommentEvent"
    case create = "CreateEvent"
    case delete = "DeleteEvent"
    case release = "ReleaseEvent"
    case other = "OtherEvent"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = GiteeEventType(rawValue: rawValue) ?? .other
    }
}

/// Gitee 事件模型
public struct GiteeEvent: Decodable {
    public let id: String?//
    public let type: GiteeEventType?
    public let actor: GiteeActor?          //
    public let repo: GiteeEventRepo?       //
    public let payload: GiteeEventPayload? //
    public let publicEvent: Bool?          //
    public let createdAt: Date?            // 服务器返回的ISO 8601格式字符串
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case actor
        case repo
        case payload
        case publicEvent = "public"
        case createdAt = "created_at"
    }
}

/// 事件发起者模型
public struct GiteeActor: Decodable {
    public let id: Int?
    public let login: String?
    public let displayName: String?
    public let avatarUrl: String?
    public let url: String?
    public let remark: String?
    public let htmlUrl: String?

    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case displayName = "name"
        case avatarUrl = "avatar_url"
        case url
        case remark
        case htmlUrl = "html_url"
    }
}

/// 事件仓库模型
public struct GiteeEventRepo: Decodable {
    public let id: Int?
    public let name: String?
    public let url: String?
    public let human_name: String?
    public let namespace: GiteeEventRepoNameSpace?

    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "full_name"
        case url
        case human_name
        case namespace
    }
}
/// 事件仓库模型
public struct GiteeEventRepoNameSpace: Decodable {
    public let id: Int?
    public let path: String?
    public let type: String?
    public let name: String?
    public let htmlRrl: String?

    
    enum CodingKeys: String, CodingKey {
        case id
        case path
        case type
        case name
        case htmlRrl = "html_url"
    }
}

/// 事件负载模型（基础结构）
public struct GiteeEventPayload: Decodable {
    // 基础字段，实际使用时可以根据事件类型扩展
    public let before: String?
    public let ref: String?
    public let deleted: Bool?
    public let size: Int?
    public let created: Bool?
    public let after: String?
    public let default_branch: String?
    public let description: String?
    public let ref_type: String?


    public let commits: [GiteeEventCommit]?
    
    enum CodingKeys: String, CodingKey {
        case before
        case ref
        case deleted
        case size
        case created
        case after
        case commits
        case default_branch
        case description
        case ref_type

    }
}


/// 提交作者模型
public struct GiteeCommitAuthor: Decodable {
    public let name: String?
    public let date: Date?
    public let email: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case date
   }
}
/// 提交作者模型
public struct GiteeCommitCommitter: Decodable {
    public let name: String?
    public let date: Date?
    public let email: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case date
   }
}

/// 议题模型（简化版）
public struct GiteeIssue: Decodable {
    public let id: Int
    public let number: Int
    public let title: String
    public let body: String?
    public let user: GiteeUser?
    public let state: String
    public let created_at: String
    public let updated_at: String
}


/// 拉取请求模型（简化版）
public struct GiteePullRequest: Decodable {
    public let id: Int
    public let number: Int
    public let title: String
    public let body: String?
    public let user: GiteeUser?
    public let state: String
    public let created_at: String
    public let updated_at: String
    public let merged_at: String?
    
    // 这里只包含基本字段，可根据需要扩展
}

/// 提交模型
public struct GiteeCommit: Decodable {
    public let url: String?
    public let sha: String?
    public let commit: GiteeCommitCommit?

    
    enum CodingKeys: String, CodingKey {
        case url
        case commit
        case sha
    }
}
/// 提交模型
public struct GiteeEventCommit: Decodable {
    public let sha: String?
    public let author: GiteeCommitAuthor?
    public let message: String?
    public let url: String?

    
    enum CodingKeys: String, CodingKey {
        case sha
        case author
        case message
        case url
    }
}
/// 提交作者模型
public struct GiteeCommitCommit: Decodable {
    public let name: String?
    public let author: GiteeCommitAuthor?
    public let committer: GiteeCommitCommitter?
    public let message: String?

    
    enum CodingKeys: String, CodingKey {
        case name
        case author
        case committer
        case message
   }
}


/// IFLYNetworkManager 的事件相关扩展
public extension IFLYNetworkManager {
    
    // MARK: - 用户活动相关方法
    
    /// 获取指定用户的活动事件列表。
    ///
    /// - Parameters:
    ///   - username: 目标用户的用户名。
    ///   - prev_id: 可选参数，表示滚动列表最后一条记录的 ID，用于分页加载更多数据。
    ///   - limit: 每次请求返回的事件数量，默认为 20，最大支持 100。
    ///   - completion: 请求完成后的回调，返回事件数组或错误信息。
    ///
    /// - Returns: 返回一个 `DataRequest` 对象，可用于取消请求。
    ///
    /// - Note:
    ///   - 该接口用于分页获取用户的活动事件，当 `prev_id` 传入时，接口会返回在该 ID 之前的事件，用于实现滚动加载。
    ///   - `limit` 参数控制单页返回的事件数量，建议不超过 100 以保证性能。
    @discardableResult func getGiteeUserEvents(
        username: String,
        prev_id: String? = nil,
        limit: Int? = 20, // 默认 20 最大为100
        completion: @escaping (Result<[GiteeEvent], Error>) -> Void
    ) -> DataRequest {
        // 使用正确的路径：指定用户的活动路径
        let path = GiteeAPI.Users.events(username)
        
        var parameters: Parameters = [:]
        
        // 如果提供了prev_id参数，添加到请求参数中
        if let prevId = prev_id {
            parameters["prev_id"] = prevId
        }
        
        return request(path: path, method: .get, parameters: parameters) { result in
            // 处理响应结果
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    // 解析响应数据
                    let events = try decoder.decode([GiteeEvent].self, from: data)
                    completion(.success(events))
                } catch {
                    // 处理解析错误
                    completion(.failure(error))
                }
            case .failure(let error):
                // 处理网络错误
                completion(.failure(error))
            }
        }
    }
    // MARK: - 列出一个用户收到的动态
    
    /// 列出一个用户收到的动态
    /// - Parameters:
    ///   - username: 用户登录名
    ///   - prev_id: 滚动列表的最后一条记录的id
    ///   - completion: 接口完成请求回调
    /// - Returns: 用户收到的公开动态
    @discardableResult
    func getGiteeReceivedEvents(
        username: String,
        prev_id: String? = nil,
        completion: @escaping (Result<[GiteeEvent], Error>) -> Void
    ) -> DataRequest {
        // 使用正确的路径：指定用户的公开活动路径
        let path = GiteeAPI.Users.receivedEvents(username)
        
        var parameters: Parameters = [:]
        
        // 如果提供了prev_id参数，添加到请求参数中
        if let prevId = prev_id {
            parameters["prev_id"] = prevId
        }
        
        return request(path: path, method: .get, parameters: parameters) { result in
            // 处理响应结果
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    // 解析响应数据
                    let events = try decoder.decode([GiteeEvent].self, from: data)
                    completion(.success(events))
                } catch {
                    // 处理解析错误
                    completion(.failure(error))
                }
            case .failure(let error):
                // 处理网络错误
                completion(.failure(error))
            }
        }
    }
    // MARK: - 列出一个用户收到的公开动态
    
    /// 列出一个用户收到的公开动态
    /// - Parameters:
    ///   - username: 用户登录名
    ///   - prev_id: 滚动列表的最后一条记录的id
    ///   - completion: 接口完成请求回调
    /// - Returns: 用户收到的公开动态
    @discardableResult
    func getGiteeReceivedPublicEvents(
        username: String,
        prev_id: String? = nil,
        completion: @escaping (Result<[GiteeEvent], Error>) -> Void
    ) -> DataRequest {
        // 使用正确的路径：指定用户的公开活动路径
        let path = GiteeAPI.Users.receivedPublicEvents(username)
        
        var parameters: Parameters = [:]
        
        // 如果提供了prev_id参数，添加到请求参数中
        if let prevId = prev_id {
            parameters["prev_id"] = prevId
        }
        
        return request(path: path, method: .get, parameters: parameters) { result in
            // 处理响应结果
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    // 解析响应数据
                    let events = try decoder.decode([GiteeEvent].self, from: data)
                    completion(.success(events))
                } catch {
                    // 处理解析错误
                    completion(.failure(error))
                }
            case .failure(let error):
                // 处理网络错误
                completion(.failure(error))
            }
        }
    }
}
//https://gitee.com/api/v5/users/{username}/events
// 文档地址:https://gitee.com/api/v5/swagger#/getV5UsersUsernameEvents
// 实现这个接口
