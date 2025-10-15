import Foundation
import Alamofire

/// IFLYNetworkManager 的仓库相关扩展
public extension IFLYNetworkManager {
    // MARK: - 获取某个用户的公开仓库
    
    /// 获取指定用户的仓库列表
    /// - Parameters:
    ///   - username: 用户名
    ///   - type: 用户创建的仓库(owner)，用户个人仓库(personal)，用户为仓库成员(member)，所有(all)。默认: 所有(all)
    ///   - sort: 排序方式: 创建时间(created)，更新时间(updated)，最后推送时间(pushed)，仓库所属与名称(full_name)。默认: full_name
    ///   - direction: 排序方式: 如果sort参数为full_name，用升序(asc)。否则降序(desc)
    ///   - page: 页码，默认1
    ///   - per_page: 每页数量，默认20
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func getGiteeUserPublicRepos(
        username: String,
        page: Int = 1,
        type: String? = "all",
        sort: String? = "full_name",
        direction: String = "desc",
        size: Int = 20,
        completion: @escaping (Result<[GiteeRepo], Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Users.repos(username)
        var parameters: Parameters = [
            "page": page,
            "per_page": size
        ]
        if let type = type {
            parameters["type"] = type
        }
        if let sort = sort {
            parameters["sort"] = sort
        }
        parameters["direction"] = direction
        
        return request(path: path, method: .get, parameters: parameters) { result in self.handleRepoResponse(result: result, completion: completion)
        }
    }
    // MARK: - 获取某个用户的所有仓库
    
    /// 获取指定用户的仓库列表
    /// - Parameters:
    ///   - username: 用户名
    ///   - type: 用户创建的仓库(owner)，用户为仓库成员(member)，所有(all)。默认: 所有(all)
    ///   - sort: 排序方式: 创建时间(created)，更新时间(updated)，最后推送时间(pushed)，仓库所属与名称(full_name)。默认: full_name
    ///   - direction: 排序方式: 升序(asc)或降序(desc)
    ///   - page: 页码，默认1
    ///   - per_page: 每页数量，最大100，默认20
    ///   - q: 搜索关键字，可选
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func getAllGiteeRepos(
        username: String,
        sort: String? = "full_name",
        visibility: String? = "all",
        direction: String? = "asc",
        q: String? = nil,
        page: Int = 1,
        per_page: Int = 20,
        completion: @escaping (Result<[GiteeRepo], Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Users.allRepos(username)
        var parameters: Parameters = [
            "page": page,
            "per_page": per_page
        ]
        if let sort = sort {
            parameters["sort"] = sort
        }
        if let direction = direction {
            parameters["direction"] = direction
        }
        if let q = q, !q.isEmpty {
            parameters["q"] = q
        }
        
        return request(path: path, method: .get, parameters: parameters) { result in self.handleRepoResponse(result: result, completion: completion)
        }
    }
    
    /// 获取指定组织的仓库列表
    /// - Parameters:
    ///   - orgName: 组织名称
    ///   - page: 页码，默认1
    ///   - size: 每页数量，默认20
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func getGiteeOrgRepos(
        orgName: String,
        page: Int = 1,
        size: Int = 20,
        completion: @escaping (Result<[GiteeRepo], Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Orgs.repos(orgName)
        let parameters: Parameters = [
            "page": page,
            "per_page": size
        ]
        
        return request(path: path, method: .get, parameters: parameters) { result in
            self.handleRepoResponse(result: result, completion: completion)
        }
    }
    
    /// 搜索仓库
    /// - Parameters:
    ///   - query: 搜索关键词
    ///   - page: 页码，默认1
    ///   - size: 每页数量，默认20
    ///   - sort: 排序方式，可选 "stars", "forks", "updated"
    ///   - order: 排序顺序，可选 "desc", "asc"
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func searchGiteeRepos(
        query: String,
        page: Int = 1,
        size: Int = 20,
        sort: String? = nil,
        order: String? = nil,
        completion: @escaping (Result<[GiteeRepo], Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Search.repositories
        var parameters: Parameters = [
            "q": query,
            "page": page,
            "per_page": size
        ]
        
        if let sort = sort {
            parameters["sort"] = sort
        }
        
        if let order = order {
            parameters["order"] = order
        }
        
        return request(path: path, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    // 搜索结果是包装在一个包含items字段的对象中
                    let decoder = JSONDecoder()
                    let searchResult = try decoder.decode(GiteeSearchResult<GiteeRepo>.self, from: data)
                    completion(.success(searchResult.items))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 仓库详情相关方法
    
    /// 获取仓库详情
    /// - Parameters:
    ///   - owner: 仓库所有者
    ///   - repo: 仓库名称
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func getGiteeRepoDetail(
        owner: String,
        repo: String,
        completion: @escaping (Result<GiteeRepo, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Repos.repo(owner, repo)
        
        return request(path: path, method: .get) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let repoDetail = try decoder.decode(GiteeRepo.self, from: data)
                    completion(.success(repoDetail))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // MARK: - 分支相关
    // MARK: - 1.1 获取仓库分支列表

    /// 获取仓库分支列表
    /// - Parameters:
    ///   - owner: 仓库所有者
    ///   - repo: 仓库名称
    ///   - sort: 排序方式，可选
    ///   - direction: 排序方向，可选
    ///   - page: 页码，默认1
    ///   - per_page: 每页数量，默认20
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func getGiteeRepoBranches(
        owner: String,
        repo: String,
        sort: String? = nil,
        direction: String? = nil,
        page: Int = 1,
        per_page: Int = 20,
        completion: @escaping (Result<[GiteeBranch], Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Repos.branches(owner, repo)
        var parameters: Parameters = [
            "page": page,
            "per_page": per_page
        ]
        if let sort = sort {
            parameters["sort"] = sort
        }
        if let direction = direction {
            parameters["direction"] = direction
        }
        
        return request(path: path, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    // 修改为使用项目中已定义的支持ISO8601格式的解码器
                    let decoder = JSONDecoder.iso8601withFractionalSeconds
                    let branches = try decoder.decode([GiteeBranch].self, from: data)
                    completion(.success(branches))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // MARK: - 1.2 获取仓库README

    /// 获取仓库 README
    /// - Parameters:
    ///   - owner: 仓库所有者
    ///   - repo: 仓库名称
    ///   - ref: 分支或提交的引用，可选
    ///   - completion: 完成回调，返回 README 内容模型
    /// - Returns: 可取消的请求
    @discardableResult
    func getGiteeRepoReadMe(
        owner: String,
        repo: String,
        ref: String? = nil,
        completion: @escaping (Result<GiteeReadMe, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Repos.readme(owner, repo)
        var parameters: Parameters = [:]
        if let ref = ref {
            parameters["ref"] = ref
        }
        
        return request(path: path, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    var readme = try decoder.decode(GiteeReadMe.self, from: data)
                    
                    if let base64Content = readme.content,
                       let decodedData = Data(base64Encoded: base64Content, options: .ignoreUnknownCharacters),
                       let decodedString = String(data: decodedData, encoding: .utf8) {
                        readme.content = decodedString
                        completion(.success(readme))
                    } else {
                        let error = NSError(domain: "IFLYNetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode README content"])
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // MARK: - 1.3 创建分支
    /// 创建新的分支
    /// - Parameters:
    ///   - owner: 仓库所有者
    ///   - repo: 仓库名称
    ///   - refs: 新分支名称（例如 "feature/new-feature"）
    ///   - branch_name: 从哪个分支或提交创建（默认从默认分支创建）
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func createNewGiteeRepoBranches(
        owner: String,
        repo: String,
        refs: String,
        branch_name: String? = nil,
        completion: @escaping (Result<GiteeBranch, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Repos.branches(owner, repo)
        var parameters: Parameters = [
            "refs": refs,
            "branch_name": branch_name,
        ]
        // 发送 POST 请求创建分支
        return request(path: path, method: .post, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder.iso8601withFractionalSeconds
                    let branch = try decoder.decode(GiteeBranch.self, from: data)
                    completion(.success(branch))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // MARK: - 仓库操作相关方法
    
    /// Star 仓库
    /// - Parameters:
    ///   - owner: 仓库所有者
    ///   - repo: 仓库名称
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func starGiteeRepo(
        owner: String,
        repo: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Repos.star(owner, repo)
        
        return request(path: path, method: .put) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 取消 Star 仓库
    /// - Parameters:
    ///   - owner: 仓库所有者
    ///   - repo: 仓库名称
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func unstarGiteeRepo(
        owner: String,
        repo: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Repos.star(owner, repo)
        
        return request(path: path, method: .delete) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Watch 仓库
    /// - Parameters:
    ///   - owner: 仓库所有者
    ///   - repo: 仓库名称
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func watchGiteeRepo(
        owner: String,
        repo: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Repos.watch(owner, repo)
        
        return request(path: path, method: .put, parameters: [:]) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 取消 Watch 仓库
    /// - Parameters:
    ///   - owner: 仓库所有者
    ///   - repo: 仓库名称
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult
    func unwatchGiteeRepo(
        owner: String,
        repo: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) -> DataRequest {
        let path = GiteeAPI.Repos.watch(owner, repo)
        
        return request(path: path, method: .delete) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 辅助方法
    
    /// 处理仓库列表响应
    /// - Parameters:
    ///   - result: 请求结果
    ///   - completion: 完成回调
    private func handleRepoResponse(
        result: Result<Data, Error>,
        completion: @escaping (Result<[GiteeRepo], Error>) -> Void
    ) {
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                let repos = try decoder.decode([GiteeRepo].self, from: data)
                completion(.success(repos))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

/// Gitee 搜索结果通用模型
public struct GiteeSearchResult<T: Decodable>: Decodable {
    public let total_count: Int
    public let incomplete_results: Bool
    public let items: [T]
}

/// Gitee 分支模型
public struct GiteeBranch: Decodable {
    public let name: String
    public let commit: GiteeCommit?
    public let isProtected: Bool?
    public let protection_url: String?

    enum CodingKeys:String,CodingKey{
        case name
        case commit
        case isProtected = "protected"
        case protection_url
    }
}
/// Gitee 仓库 README 模型
public struct GiteeReadMeLink: Decodable {
    public var html: String?
    public let linkSelf: String?
    
    enum CodingKeys:String,CodingKey{
        case html
        case linkSelf = "self"
    }
}

/// Gitee 仓库 README 模型
public struct GiteeReadMe: Decodable {
    public var content: String?
    public let readMeLinks: GiteeReadMeLink?
    public let download_url: String?
    public let encoding: String?
    public let htmlUrl: String?
    public let name: String?
    public let path: String?
    public let sha: String?
    public let readSize: Int?
    public let type: String?
    public let url: String?
    
    enum CodingKeys:String,CodingKey{
        case readMeLinks = "_links"
        case content
        case download_url
        case encoding
        case htmlUrl = "html_url"
        case name
        case path
        case sha
        case readSize = "size"
        case type
        case url
    }
}
