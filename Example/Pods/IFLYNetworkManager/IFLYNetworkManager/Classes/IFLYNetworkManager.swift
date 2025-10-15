//  IFLYNetworkManager.swift
//  IFLYNetworkManager
//
//  Created by iFlyCai on 2025/8/16.
//

import Foundation
import Alamofire

/// IFLYNetworkManager 版本号信息
enum IFLYNetworkManagerVersion {
    public static let current = "1.1.55"
}

/// Gitee网络请求管理器
public class IFLYNetworkManager {
    /// 单例实例
    public static let shared = IFLYNetworkManager()
    
    /// 全局日志开关 - 控制是否打印网络请求和响应日志，默认开启
    public static var isLoggingEnabled: Bool = true

    /// 基础URL
    private var baseURL: String = "https://gitee.com/api/v5"

    /// 会话管理器
    private let sessionManager: Session

    /// 请求超时时间（秒）
    private let timeoutInterval: TimeInterval = 30.0

    /// 缓存策略
    private let cachePolicy: URLRequest.CachePolicy = .reloadRevalidatingCacheData

    /// Gitee Access Token
    public var giteeAccessToken: String?

    /// 初始化
    private init() {
        // 配置会话
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.requestCachePolicy = cachePolicy

        // 初始化会话管理器
        sessionManager = Session(configuration: configuration)
    }

    /// 设置Gitee Access Token
    /// - Parameter token: Access Token字符串
    public func setGiteeAccessToken(_ token: String) {
        self.giteeAccessToken = token
    }

    // 根据优先级获取当前可用的 AccessToken：先用手动设置的 giteeAccessToken，其次用当前登录用户的 Keychain Token
    public func currentAccessToken() -> String? {
        if let t = giteeAccessToken, !t.isEmpty { return t }
        if let uid = IFLYGiteeUserManager.shared.getCurrentUser()?.id,
           let kt = IFLYGiteeAccessTokenManager.shared.getAccessToken(forUserId: uid), !kt.isEmpty {
            return kt
        }
        return nil
    }

    // 合并鉴权 Header（若外部未显式传入 Authorization，则自动注入）
    private func authorizedHeaders(_ headers: HTTPHeaders?) -> HTTPHeaders? {
        var final = headers ?? HTTPHeaders()
        if final["Authorization"] == nil, let token = currentAccessToken() {
            final.add(name: "Authorization", value: "token \(token)")
        }
        return final
    }

    /// 通用请求方法
    /// - Parameters:
    ///   - path: 请求路径
    ///   - method: HTTP方法
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - encoding: 参数编码方式
    ///   - completion: 完成回调
    /// - Returns: 可取消的请求
    @discardableResult public func request(
        path: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> DataRequest {
        // 构建完整URL
        let url = baseURL + path
        
        let finalHeaders = authorizedHeaders(headers)
        
        // 打印请求日志
        if IFLYNetworkManager.isLoggingEnabled {
            print("\n[IFLYNetworkManager] Request: \(method.rawValue) \(url)")
            if let params = parameters, !params.isEmpty {
                print("[IFLYNetworkManager] Parameters: \(params)")
            }
            if let reqHeaders = finalHeaders, !reqHeaders.isEmpty {
                // 避免打印完整的token信息，保护用户隐私
                var headersToPrint = reqHeaders.dictionary
                if let authHeader = headersToPrint["Authorization"],
                   authHeader.hasPrefix("token ") {
                    headersToPrint["Authorization"] = "token [HIDDEN]"
                }
                print("[IFLYNetworkManager] Headers: \(headersToPrint)")
            }
        }

        // 发起请求
        let request = sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: finalHeaders)
            .validate(statusCode: 200..<300)
            .responseData {
                response in
                // 打印响应日志
                if IFLYNetworkManager.isLoggingEnabled {
                    if let httpResponse = response.response {
                        print("[IFLYNetworkManager] Response: \(httpResponse.statusCode) \(url)")
                        
                        // 尝试将数据转换为JSON格式打印
                        if let data = response.data,
                           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                           let prettyJson = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                           let prettyJsonString = String(data: prettyJson, encoding: .utf8) {
                            print("[IFLYNetworkManager] Response Data: \n\(prettyJsonString)")
                        } else if let data = response.data,
                                  let responseString = String(data: data, encoding: .utf8) {
                            print("[IFLYNetworkManager] Response Data: \n\(responseString)")
                        } else {
                            print("[IFLYNetworkManager] Response Data: [Empty]")
                        }
                    }
                    
                    // 打印错误信息
                    if let error = response.error {
                        print("[IFLYNetworkManager] Error: \(error.localizedDescription)")
                        if let underlyingError = error.underlyingError {
                            print("[IFLYNetworkManager] Underlying Error: \(underlyingError)")
                        }
                    }
                }
                
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }

        return request
    }
}
