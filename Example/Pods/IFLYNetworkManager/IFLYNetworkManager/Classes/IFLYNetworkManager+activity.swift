import Foundation
import Alamofire

/// 通知类型枚举
enum GiteeNotificationType: String, Codable {
    case issue = "Issue"
    case pullRequest = "PullRequest"
    case commit = "Commit"
    case repo = "Repository"
    case comment = "Comment"
    case other = "Other"
}

/// 通知状态枚举
enum GiteeNotificationStatus: String, Codable {
    case unread = "unread"
    case read = "read"
}

/// 通知主题模型
public struct GiteeNotificationSubject: Decodable {
    public let title: String
    public let url: String
    public let type: String
    public let latestCommentURL: String?
    public let commentURL: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case url
        case type
        case latestCommentURL = "latest_comment_url"
        case commentURL = "comment_url"
    }
}

/// Gitee 通知模型
public struct GiteeNotification: Decodable {
    public let id: String
    public let unread: Bool
    public let updatedAt: String
    public let lastReadAt: String?
    public let reason: String?
    public let url: String
    public let repository: GiteeRepo?
    public let subject: GiteeNotificationSubject?
    public let notificationsURL: String?
    public let subscriptionURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case unread
        case updatedAt = "updated_at"
        case lastReadAt = "last_read_at"
        case reason
        case url
        case repository
        case subject
        case notificationsURL = "notifications_url"
        case subscriptionURL = "subscription_url"
    }
}
/// Gitee 通知模型
public struct IFLYGiteeMessage: Decodable {
    public let messageId: Int
    public let sender: IFLYGiteeMessageSender?
    public let unread: Bool
    public let content: String?
    public let updatedAt: Date?
    public let url: String?
    public let htmlUrl: String?

    
    enum CodingKeys: String, CodingKey {
        case messageId = "id"
        case sender
        case unread
        case content
        case updatedAt
        case url
        case htmlUrl = "html_url"
    }
}
/// Gitee 通知发送者模型
public struct IFLYGiteeMessageSender: Decodable {
    public let id: Int
    public let login: String
    public let name: String?
    public let avatarURL: String?
    public let url: String?
    public let htmlURL: String?
    public let remark: String?
    public let followersURL: String?
    public let followingURL: String?
    public let gistsURL: String?
    public let starredURL: String?
    public let subscriptionsURL: String?
    public let organizationsURL: String?
    public let reposURL: String?
    public let eventsURL: String?
    public let receivedEventsURL: String?
    public let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case avatarURL = "avatar_url"
        case url
        case htmlURL = "html_url"
        case remark
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type
    }
}


/// 通知线程模型
public struct GiteeNotificationThread: Decodable {
    public let id: Int?
    public let unread: Bool?
    public let reason: String?
    public let content: String?
    public let updatedAt: String?
    public let lastReadAt: String?
    public let subject: GiteeNotificationSubject?
    public let repository: GiteeRepo?
    public let url: String?
    public let subscriptionsURL: String?
    public let notificationsURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case unread
        case reason
        case updatedAt = "updated_at"
        case lastReadAt = "last_read_at"
        case content
        case subject
        case repository
        case url
        case subscriptionsURL = "subscriptions_url"
        case notificationsURL = "notifications_url"
    }
}
/// Gitee 通知数量模型
public struct GiteeNotificationCount: Decodable {
    /// 通知总数
    public let totalCount: Int?
    /// 系统通知数量
    public let notificationCount: Int?
    /// 私信数量
    public let messageCount: Int?

    /// 是否有未读消息（任意数量大于 0）
    public var hasUnread: Bool {
        return (totalCount ?? 0) > 0 || (notificationCount ?? 0) > 0 || (messageCount ?? 0) > 0
    }

    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case notificationCount = "notification_count"
        case messageCount = "message_count"
    }
}


/// 通知列表响应包装器
public struct GiteeNotificationListResponse: Decodable {
    public let total_count: Int
    public let list: [GiteeNotificationThread]
    
    enum CodingKeys: String, CodingKey {
        case total_count
        case list
    }
}


/// 通知订阅模型
public struct GiteeNotificationSubscription: Decodable {
    public let id: Int
    public let reason: String
    public let createdAt: String
    public let url: String
    public let subscribed: Bool
    public let ignored: Bool
    public let repositoryURL: String
    public let threadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case reason
        case createdAt = "created_at"
        case url
        case subscribed
        case ignored
        case repositoryURL = "repository_url"
        case threadURL = "thread_url"
    }
}

/// IFLYNetworkManager 的通知相关扩展
public extension IFLYNetworkManager {
    // MARK: - 获取授权用户的通知数
    
    /// 授权用户的所有通知
    /// - Parameters:
    ///   - unread: 是否只获取未读消息，默认：否
    ///   - completion: 完成回调，返回通知数组或错误
    /// - Returns: 可取消的请求 DataRequest
    @discardableResult
    func getGiteeNotificationsCount(
        unread: Bool = false,
        completion: @escaping (Result<GiteeNotificationCount, Error>) -> Void
    ) -> DataRequest {
        // 使用正确的路径：所有通知线程列表
        let path = GiteeAPI.Activity.messageCount
        let parameters: Parameters = [
            "unread": unread,
        ]
        return request(path: path, method: .get, parameters: parameters) { result in
            self.handleNotificationCountResponse(result: result, completion: completion)
        }
    }
    // MARK: - 列出授权用户的所有通知
    
    /// 授权用户的所有通知
    /// - Parameters:
    ///   - unread: 是否只获取未读消息，默认：否
    ///   - participating: 是否只获取自己直接参与的消息，默认：否
    ///   - type: 筛选指定类型的通知，all：所有，event：事件通知，referer：@ 通知
    ///   - since: 只获取在给定时间后更新的消息，要求时间格式为 ISO 8601
    ///   - before: 只获取在给定时间前更新的消息，要求时间格式为 ISO 8601
    ///   - ids: 指定一组通知 ID，以 , 分隔，非必需参数
    ///   - page: 当前的页码，默认1
    ///   - per_page: 每页的数量，最大为 100，默认20
    ///   - completion: 完成回调，返回通知数组或错误
    /// - Returns: 可取消的请求 DataRequest
    @discardableResult
    func getGiteeAllNotifications(
        unread: Bool = false,
        participating: Bool = false,
        type: String = "all",
        since: String = "",
        before: String = "",
        ids: [Int] = [],
        page: Int = 1,
        per_page: Int = 20,
        completion: @escaping (Result<[GiteeNotificationThread], Error>) -> Void
    ) -> DataRequest {
        // 使用正确的路径：所有通知线程列表
        let path = GiteeAPI.Activity.allThreads("")
        
        var parameters: Parameters = [
            "unread": unread,
            "participating": participating,
            "type": type,
            "page": page,
            "per_page": per_page
        ]
        
        // 添加时间范围参数（如果有值）
        if !since.isEmpty {
            parameters["since"] = since
        }
        
        if !before.isEmpty {
            parameters["before"] = before
        }
        
        // 添加通知ID参数（如果有值）
        if !ids.isEmpty {
            parameters["ids"] = ids.map { String($0) }.joined(separator: ",")
        }
        
        return request(path: path, method: .get, parameters: parameters) { result in
            self.handleNotificationThreadsResponse(result: result, completion: completion)
        }
    }
    // MARK: - 列出授权用户的所有私信
    
    /// 获取授权用户的所有私信消息
    /// - Parameters:
    ///   - unread: 是否只获取未读消息，默认 false
    ///   - since: 只获取指定时间之后的消息，ISO 8601 格式
    ///   - before: 只获取指定时间之前的消息，ISO 8601 格式
    ///   - ids: 指定通知 ID 列表
    ///   - page: 页码，默认 1
    ///   - per_page: 每页数量，默认 20，最大 100
    ///   - completion: 完成回调，返回消息数组或错误
    /// - Returns: 可取消的请求 DataRequest
    @discardableResult
    func getGiteeAllMessages(
        unread: Bool = false,
        since: String = "",
        before: String = "",
        ids: [Int] = [],
        page: Int = 1,
        per_page: Int = 20,
        completion: @escaping (Result<[IFLYGiteeMessage], Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Activity.message
    
        var parameters: Parameters = [
            "unread": unread,
            "page": page,
            "per_page": per_page
        ]
    
        if !since.isEmpty {
            parameters["since"] = since
        }
    
        if !before.isEmpty {
            parameters["before"] = before
        }
    
        if !ids.isEmpty {
            parameters["ids"] = ids.map { String($0) }.joined(separator: ",")
        }
    
        return request(path: path, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Debug: 原始返回数据: \(dataString)")
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    // 尝试先作为包含list字段的字典解码
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // 检查是否包含list字段
                        if let messagesArray = json["list"] as? [[String: Any]] {
                            // 将字典数组转换回数据，然后解码
                            let messagesData = try JSONSerialization.data(withJSONObject: messagesArray, options: [])
                            let messages = try decoder.decode([IFLYGiteeMessage].self, from: messagesData)
                            completion(.success(messages))
                            return
                        } else {
                            print("Debug: 响应字典中不包含'list'字段")
                        }
                    } else {
                        print("Debug: 响应数据不是有效的JSON字典")
                    }
                    
                    // 如果上面的尝试失败，回退到直接尝试解码数组
                    do {
                        let messages = try decoder.decode([IFLYGiteeMessage].self, from: data)
                        completion(.success(messages))
                        return
                    } catch {
                        print("Debug: 尝试直接解码数组失败: \(error)")
                    }
                    
                    // 如果所有解码尝试都失败，提供详细错误信息
                    throw NSError(domain: "GiteeAPI", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "无法解码Gitee私信消息",
                        "RawDataSize": data.count
                    ])
                } catch {
                    print("Debug: JSON解码错误: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 获取指定通知线程的详情
    /// - Parameters:
    ///   - threadId: 通知线程ID
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func getGiteeNotificationThread(
        threadId: String,
        completion: @escaping (Result<GiteeNotificationThread, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Activity.threads(threadId)
        
        return request(path: path, method: .get) { result in
            self.handleNotificationThreadResponse(result: result, completion: completion)
        }
    }
    
    // MARK: - 通知状态操作方法
    
    /// 标记单个通知线程为已读
    /// - Parameters:
    ///   - threadId: 通知线程ID
    ///   - lastReadAt: 最后读取时间，可选，格式：YYYY-MM-DDTHH:MM:SSZ
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func markGiteeNotificationAsRead(
        threadId: String,
        lastReadAt: String? = nil,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Activity.threads(threadId)
        
        var parameters: Parameters = [:]
        if let lastReadAt = lastReadAt {
            parameters["last_read_at"] = lastReadAt
        }
        
        return request(path: path, method: .patch, parameters: parameters, encoding: JSONEncoding.default) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 标记所有通知为已读
    /// - Parameters:
    ///   - lastReadAt: 最后读取时间，可选，格式：YYYY-MM-DDTHH:MM:SSZ
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func markAllGiteeNotificationsAsRead(
        lastReadAt: String? = nil,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Activity.notifications
        
        var parameters: Parameters = [:]
        if let lastReadAt = lastReadAt {
            parameters["last_read_at"] = lastReadAt
        }
        
        return request(path: path, method: .put, parameters: parameters, encoding: JSONEncoding.default) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 通知订阅相关方法
    
    /// 获取通知订阅列表
    /// - Parameters:
    ///   - page: 页码，默认1
    ///   - size: 每页数量，默认20
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func getGiteeNotificationSubscriptions(
        page: Int = 1,
        size: Int = 20,
        completion: @escaping (Result<[GiteeNotificationSubscription], Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Activity.subscriptions
        let parameters: Parameters = [
            "page": page,
            "per_page": size
        ]
        
        return request(path: path, method: .get, parameters: parameters) { result in
            self.handleSubscriptionsResponse(result: result, completion: completion)
        }
    }
    
    /// 管理通知订阅（创建/更新）
    /// - Parameters:
    ///   - threadId: 通知线程ID
    ///   - subscribed: 是否订阅
    ///   - ignored: 是否忽略
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func manageGiteeNotificationSubscription(
        threadId: String,
        subscribed: Bool = true,
        ignored: Bool = false,
        completion: @escaping (Result<GiteeNotificationSubscription, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Activity.subscriptions + "/" + threadId
        let parameters: Parameters = [
            "subscribed": subscribed,
            "ignored": ignored
        ]
        
        return request(path: path, method: .put, parameters: parameters, encoding: JSONEncoding.default) { result in
            self.handleSubscriptionResponse(result: result, completion: completion)
        }
    }
    
    // MARK: - 响应处理辅助方法
    
    /// 处理通知列表响应
    private func handleNotificationsResponse(
        result: Result<Data, Error>,
        completion: @escaping (Result<[GiteeNotification], Error>) -> Void
    ) {
        switch result {
        case .success(let data):
            do {
                let notifications = try JSONDecoder().decode([GiteeNotification].self, from: data)
                completion(.success(notifications))
            } catch {
                // 增加调试日志，打印原始返回数据和解码错误
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Debug: 原始返回数据: \(dataString)")
                } else {
                    print("Debug: 无法转换返回数据为字符串")
                }
                print("Debug: JSON解码错误: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    /// 处理通知线程响应
    private func handleNotificationThreadResponse(
        result: Result<Data, Error>,
        completion: @escaping (Result<GiteeNotificationThread, Error>) -> Void
    ) {
        switch result {
        case .success(let data):
            do {
                let thread = try JSONDecoder().decode(GiteeNotificationThread.self, from: data)
                completion(.success(thread))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    /// 处理通知线程列表响应
    private func handleNotificationThreadsResponse(
        result: Result<Data, Error>,
        completion: @escaping (Result<[GiteeNotificationThread], Error>) -> Void
    ) {
        switch result {
        case .success(let data):
            do {
                // 先解析最外层的响应对象
                let response = try JSONDecoder().decode(GiteeNotificationListResponse.self, from: data)
                // 提取 list 字段中的消息列表
                completion(.success(response.list))
            } catch {
                // 增加调试日志，打印原始返回数据和解码错误
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Debug: 原始返回数据: \(dataString)")
                } else {
                    print("Debug: 无法转换返回数据为字符串")
                }
                print("Debug: JSON解码错误: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }

    /// 处理单个订阅响应
    private func handleSubscriptionResponse(
        result: Result<Data, Error>,
        completion: @escaping (Result<GiteeNotificationSubscription, Error>) -> Void
    ) {
        switch result {
        case .success(let data):
            do {
                let subscription = try JSONDecoder().decode(GiteeNotificationSubscription.self, from: data)
                completion(.success(subscription))
            } catch {
                // 增加调试日志，打印原始返回数据和解码错误
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Debug: 原始返回数据: \(dataString)")
                } else {
                    print("Debug: 无法转换返回数据为字符串")
                }
                print("Debug: JSON解码错误: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    /// 处理订阅列表响应
    private func handleSubscriptionsResponse(
        result: Result<Data, Error>,
        completion: @escaping (Result<[GiteeNotificationSubscription], Error>) -> Void
    ) {
        switch result {
        case .success(let data):
            do {
                let subscriptions = try JSONDecoder().decode([GiteeNotificationSubscription].self, from: data)
                completion(.success(subscriptions))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    // 优化后的handleNotificationCountResponse方法，只尝试解码为单个对象
    private func handleNotificationCountResponse(
        result: Result<Data, Error>,
        completion: @escaping (Result<GiteeNotificationCount, Error>) -> Void
    ) {
        switch result {
        case .success(let data):
            do {
                // 打印原始数据以进行调试
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Debug: 原始返回数据: \(dataString)")
                }
                
                // 设置解码器，只使用结构体中定义的CodingKeys映射
                let decoder = JSONDecoder()
                
                // 直接尝试解码为单个对象，因为服务器返回的就是单个对象
                let notificationCount = try decoder.decode(GiteeNotificationCount.self, from: data)
                completion(.success(notificationCount))
                
            } catch {
                print("Debug: JSON解码错误: \(error)")
                // 创建更友好的错误信息
                let friendlyError = NSError(
                    domain: "IFLYNetworkError",
                    code: 400,
                    userInfo: [
                        NSLocalizedDescriptionKey: "通知数量数据解析失败",
                        NSUnderlyingErrorKey: error
                    ]
                )
                completion(.failure(friendlyError))
            }
        case .failure(let error):
            print("Debug: 网络请求错误: \(error)")
            completion(.failure(error))
        }
    }
}
