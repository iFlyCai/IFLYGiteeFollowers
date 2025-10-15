import Foundation
import Alamofire

public extension IFLYNetworkManager{
    // MARK: - 1.获取授权用户的资料

    /// 获取Gitee用户信息
    /// - Parameters:
    ///   - accessToken: 要使用的 Access Token
    ///   - completion: 完成回调，返回GiteeUser模型或错误
    /// - Returns: 可取消的请求
    @discardableResult
    func getGiteeUserInfo(accessToken: String, completion: @escaping (Result<GiteeUser, Error>) -> Void) -> DataRequest? {
        guard !accessToken.isEmpty else {
            completion(.failure(NSError(domain: "GiteeAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not set"])))
            return nil
        }
        let path = "/user"
        // 构造带有 Authorization 的 header
        let headers: HTTPHeaders = ["Authorization": "token \(accessToken)"]
        return request(path: path, method: .get, parameters: nil, headers: headers, encoding: URLEncoding.default) { result in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Gitee API Response JSON: \(jsonString)")
                }
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(GiteeUser.self, from: data)
                    // 存储传入的 accessToken 到 Keychain，使用 user.id 作为 key
                    IFLYGiteeAccessTokenManager.shared.saveAccessToken(accessToken, forUserId: user.id)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // MARK: - 2.更新授权用户的资料
    
    /// 更新授权用户的资料
    /// - Parameters:
    ///   - name: 用户昵称（可选）
    ///   - blog: 博客链接（可选）
    ///   - weibo: 微博地址（可选）
    ///   - bio: 自我介绍（可选）
    ///   - completion: 回调，返回更新后的 GiteeUser 或错误
    /// - Returns: 可取消的网络请求
    @discardableResult
    func updateGiteeUserInfo(name: String?, blog: String?, weibo: String?, bio: String?, completion: @escaping (Result<GiteeUser, Error>) -> Void) -> DataRequest? {
        let path = "/user"
        var parameters: [String: Any] = [:]
        if let name = name { parameters["name"] = name }
        if let blog = blog { parameters["blog"] = blog }
        if let weibo = weibo { parameters["weibo"] = weibo }
        if let bio = bio { parameters["bio"] = bio }

        // 发起 PATCH 请求更新用户资料
        return request(path: path, method: .patch, parameters: parameters, encoding: JSONEncoding.default) { result in
            switch result {
            case .success(let data):
                #if DEBUG
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🟢 Gitee API Update Response: \(jsonString)")
                }
                #endif
                do {
                    let decoder = JSONDecoder()
                    let updatedUser = try decoder.decode(GiteeUser.self, from: data)
                    completion(.success(updatedUser))
                } catch {
                    print("❌ JSON 解析失败: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 列出授权用户的关注者
    /// - Parameters:
    ///   - page: 页码，默认为1
    ///   - perPage: 每页数量，默认为30
    ///   - completion: 完成回调，返回GiteeOrganization数组或错误
    /// - Returns: 可取消的请求
    @discardableResult
    func meFollowers(
        page: Int = 1,
        perPage: Int = 30,
        completion: @escaping (Result<[GiteeUser], Error>) -> Void
    ) -> DataRequest? {
        // 检查AccessToken是否存在
        guard currentAccessToken() != nil else {
            completion(.failure(NSError(domain: "GiteeAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not set"])))
            return nil
        }
        
        // 设置请求路径和参数
        let path = GiteeAPI.Users.meFollowers
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
                    let organizations = try decoder.decode([GiteeUser].self, from: data)
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
/// Gitee用户模型
public class GiteeUser: Codable {
    public var id: Int
    public var login: String
    public var name: String?
    public var avatarUrl: String?
    public var url: String?
    public var htmlUrl: String?
    public var remark: String?
    public var followersUrl: String?
    public var followingUrl: String?
    public var gistsUrl: String?
    public var starredUrl: String?
    public var subscriptionsUrl: String?
    public var organizationsUrl: String?
    public var reposUrl: String?
    public var eventsUrl: String?
    public var receivedEventsUrl: String?
    public var type: String?
    public var blog: String?
    public var weibo: String?
    public var bio: String?
    public var publicRepos: Int?
    public var publicGists: Int?
    public var followers: Int?
    public var following: Int?
    public var stared: Int?
    public var watched: Int?
    public var createdAt: String?
    public var updatedAt: String?
    public var email: String?
    // 其他字段如 location 可补充

    private enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case avatarUrl = "avatar_url"
        case url
        case htmlUrl = "html_url"
        case remark
        case followersUrl = "followers_url"
        case followingUrl = "following_url"
        case gistsUrl = "gists_url"
        case starredUrl = "starred_url"
        case subscriptionsUrl = "subscriptions_url"
        case organizationsUrl = "organizations_url"
        case reposUrl = "repos_url"
        case eventsUrl = "events_url"
        case receivedEventsUrl = "received_events_url"
        case type
        case blog
        case weibo
        case bio
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case followers
        case following
        case stared
        case watched
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case email
    }
}
/// 管理多个登录的Gitee用户
public class IFLYGiteeUserManager {
    /// 单例实例
    public static let shared = IFLYGiteeUserManager()
    
    private let usersKey = "GiteeUserManagerUsersKey"
    private let currentUserIdKey = "GiteeUserManagerCurrentUserIdKey"
    
    // 使用线程安全的容器存储用户数据
    private var users: [GiteeUser] = []
    private var currentUserId: Int?
    
    // 添加线程锁以保证并发安全性
    private let lock = NSLock()
    
    private init() {
        loadUsers()
        loadCurrentUserId()
    }
    
    /// 添加新用户，如果已存在则更新
    /// - Parameter user: GiteeUser对象
    @discardableResult
    public func addUser(_ user: GiteeUser) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        } else {
            users.append(user)
        }
        
        // 如果保存失败，返回false
        guard saveUsers() else {
            return false
        }
        
        // 如果没有当前用户，默认设置为新添加用户
        if currentUserId == nil {
            currentUserId = user.id
            saveCurrentUserId()
        }
        
        return true
    }
    
    /// 获取当前登录用户
    public func getCurrentUser() -> GiteeUser? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let currentId = currentUserId else { return nil }
        return users.first(where: { $0.id == currentId })
    }
    
    /// 获取当前用户的 accessToken
    public func getCurrentUserAccessToken() -> String? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let userId = currentUserId else { return nil }
        return IFLYGiteeAccessTokenManager.shared.getAccessToken(forUserId: userId)
    }

    /// 获取指定用户的 accessToken
    public func getAccessToken(forUserId userId: Int) -> String? {
        // 不需要加锁，因为调用的是外部管理器的方法
        return IFLYGiteeAccessTokenManager.shared.getAccessToken(forUserId: userId)
    }
    
    /// 获取所有用户
    public func getAllUsers() -> [GiteeUser] {
        lock.lock()
        defer { lock.unlock() }
        
        // 返回副本，避免外部修改内部数据
        return users
    }
    
    /// 更新指定用户信息
    /// - Parameter updatedUser: 更新后的用户信息
    /// - Returns: 是否更新成功
    @discardableResult
    public func updateUser(_ updatedUser: GiteeUser) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        // 查找用户是否存在
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
            return saveUsers()
        }
        print("IFLYGiteeUserManager: Cannot update user - user not found")
        return false
    }
    
    /// 从服务器刷新当前用户信息
    /// - Parameter completion: 完成回调，返回刷新后的GiteeUser模型或错误
    /// - Returns: 可取消的请求
    @discardableResult
    public func refreshCurrentUser(completion: @escaping (Result<GiteeUser, Error>) -> Void) -> DataRequest? {
        guard let accessToken = getCurrentUserAccessToken() else {
            completion(.failure(NSError(domain: "IFLYGiteeUserManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current user or access token"])))
            return nil
        }
        
        // 使用IFLYNetworkManager获取最新用户信息
        return IFLYNetworkManager.shared.getGiteeUserInfo(accessToken: accessToken) { [weak self] result in
            switch result {
            case .success(let refreshedUser):
                // 更新本地存储的用户信息
                let updateResult = self?.updateCurrentUser(refreshedUser) ?? false
                if updateResult {
                    completion(.success(refreshedUser))
                } else {
                    completion(.failure(NSError(domain: "IFLYGiteeUserManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to update local user data"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    /// 切换当前登录用户
    /// - Parameter userId: 用户ID
    /// - Returns: 是否切换成功
    @discardableResult
    public func switchUser(to userId: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard users.contains(where: { $0.id == userId }) else {
            return false
        }
        
        // 检查该用户是否有有效的access token
        guard IFLYGiteeAccessTokenManager.shared.getAccessToken(forUserId: userId) != nil else {
            print("IFLYGiteeUserManager: Cannot switch to user with ID \(userId) - no valid access token")
            return false
        }
        
        currentUserId = userId
        return saveCurrentUserId()
    }
    
    // MARK: - 持久化
    
    /// 保存用户列表到UserDefaults
    /// - Returns: 是否保存成功
    @discardableResult
    private func saveUsers() -> Bool {
        do {
            let data = try JSONEncoder().encode(users)
            UserDefaults.standard.set(data, forKey: usersKey)
            UserDefaults.standard.synchronize() // 确保立即写入
            return true
        } catch {
            print("IFLYGiteeUserManager: Failed to save users: \(error)")
            return false
        }
    }
    
    private func loadUsers() {
        guard let data = UserDefaults.standard.data(forKey: usersKey) else {
            users = []
            return
        }
        
        do {
            users = try JSONDecoder().decode([GiteeUser].self, from: data)
        } catch {
            print("IFLYGiteeUserManager: Failed to load users: \(error)")
            users = []
        }
    }
    
    /// 保存当前用户ID到UserDefaults
    /// - Returns: 是否保存成功
    @discardableResult
    private func saveCurrentUserId() -> Bool {
        UserDefaults.standard.set(currentUserId, forKey: currentUserIdKey)
        UserDefaults.standard.synchronize() // 确保立即写入
        return true
    }
    
    private func loadCurrentUserId() {
        let storedId = UserDefaults.standard.object(forKey: currentUserIdKey) as? Int
        currentUserId = storedId // 直接使用可选值，避免将0错误地解释为nil
    }
    
    /// 删除当前用户
    /// - Returns: 是否删除成功
    @discardableResult
    public func deleteCurrentUser() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard let userId = currentUserId else {
            print("IFLYGiteeUserManager: No current user to delete")
            return false
        }
    
        // 从用户列表中移除用户
        users.removeAll(where: { $0.id == userId })
    
        // 从AccessTokenManager中删除token
        IFLYGiteeAccessTokenManager.shared.deleteAccessToken(forUserId: userId)
    
        // 保存更新后的用户列表
        guard saveUsers() else {
            return false
        }
    
        // 如果还有其他用户，将第一个用户设为当前用户
        if let firstUserId = users.first?.id {
            currentUserId = firstUserId
            saveCurrentUserId()
            print("IFLYGiteeUserManager: Switched to first available user with ID: \(firstUserId)")
        } else {
            // 没有其他用户，重置当前用户ID
            currentUserId = nil
            saveCurrentUserId()
        }
    
        return true
    }
    
    /// 删除所有用户
    /// - Returns: 是否删除成功
    @discardableResult
    public func deleteAllUsers() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        // 获取所有用户ID以便删除对应的access token
        let allUserIds = users.map { $0.id }
        
        // 清空用户列表
        users.removeAll()
        
        // 删除所有用户的access token
        for userId in allUserIds {
            IFLYGiteeAccessTokenManager.shared.deleteAccessToken(forUserId: userId)
        }
        
        // 保存更新后的用户列表
        guard saveUsers() else {
            return false
        }
        
        // 重置当前用户ID
        currentUserId = nil
        saveCurrentUserId()
        
        return true
    }
    
    /// 检查用户是否登录
    public var isUserLoggedIn: Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard let userId = currentUserId else {
            return false
        }
        
        // 检查用户是否存在且有有效的access token
        return users.contains(where: { $0.id == userId }) &&
               IFLYGiteeAccessTokenManager.shared.getAccessToken(forUserId: userId) != nil
    }
    
    /// 更新当前用户信息
    /// - Parameter updatedUser: 更新后的用户信息
    /// - Returns: 是否更新成功
    @discardableResult
    public func updateCurrentUser(_ updatedUser: GiteeUser) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard let currentId = currentUserId else {
            return false
        }
        
        // 确保更新的是当前用户
        guard updatedUser.id == currentId else {
            print("IFLYGiteeUserManager: Cannot update user - ID mismatch")
            return false
        }
        
        if let index = users.firstIndex(where: { $0.id == currentId }) {
            users[index] = updatedUser
            return saveUsers()
        }
        
        return false
    }
}
/// Gitee仓库父仓库简要信息容器，避免递归
public class GiteeRepoContainer: Decodable {
    public let id: Int
    public let name: String
    public let fullName: String?
    public let htmlUrl: String?
    public let owner: GiteeUser?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case owner
    }
}

/// Gitee仓库模型
public class GiteeRepo: Decodable {
    public var id: Int
    public var name: String
    public var path: String
    public var fullName: String?
    public var privateRepo: Bool?
    public var repositoryDescription: String?
    public var htmlUrl: String?
    public var cloneUrl: String?
    public var sshUrl: String?
    public var createdAt: String?
    public var updatedAt: String?
    public var pushedAt: String?
    public var stargazersCount: Int?
    public var watchersCount: Int?
    public var forksCount: Int?
    public var openIssuesCount: Int?
    public var defaultBranch: String?
    public var owner: GiteeUser?
    public var humanName: String?
    public var fork: Bool?
    public var parent: GiteeRepo?
    public var recommend: Bool?
    public var hasWiki: Bool?
    public var testers: [GiteeUser]?
    public var testersNumber: Int?
    public var url: String?
    public var permission: GiteeRepoPermission?
    public var language: String?
    public var namespace: GiteeNamespace?
    public var homepage: String?
    public var forksUrl: String?
    public var license: String?


    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case path
        case fullName = "full_name"
        case privateRepo = "private"
        case repositoryDescription = "description"
        case htmlUrl = "html_url"
        case cloneUrl = "clone_url"
        case sshUrl = "ssh_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case defaultBranch = "default_branch"
        case owner
        case humanName = "human_name"
        case fork
        case parent
        case recommend
        case hasWiki = "has_wiki"
        case testers
        case testersNumber = "testers_number"
        case url
        case permission
        case language
        case namespace
        case homepage
        case forksUrl = "forks_url"
        case license
    }
}

/// Gitee 仓库权限模型
public struct GiteeRepoPermission: Codable {
    public var pull: Bool?
    public var push: Bool?
    public var admin: Bool?
}

/// Gitee 命名空间模型
public class GiteeNamespace: Codable {
    public var id: Int?
    public var type: String?
    public var name: String?
    public var path: String?
    public var htmlUrl: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case path
        case htmlUrl = "html_url"
    }
}

