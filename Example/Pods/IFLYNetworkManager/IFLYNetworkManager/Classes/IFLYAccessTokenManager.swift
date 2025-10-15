//
//  IFLYAccessTokenManager.swift
//  IFLYNetworkManager
//
//  Created by iFlyCai on 2025/9/30.
//

import Foundation
import KeychainAccess

/// 专门负责 accessToken 存取的管理器
public class IFLYGiteeAccessTokenManager {
    public static let shared = IFLYGiteeAccessTokenManager()
    private let keychain = Keychain(service: "com.ifly.gitee.tokens")
    private let userDefaults = UserDefaults.standard
    private let queue = DispatchQueue(label: "com.ifly.tokenManagerQueue")
    private func tokenKey(for userId: Int) -> String {
        return "gitee_access_token_\(userId)"
    }
    /// 存储 accessToken
    @discardableResult public func saveAccessToken(_ token: String, forUserId userId: Int) -> Bool {
        let key = tokenKey(for: userId)
        do {
            try keychain.set(token, key: key)
            return true
        } catch {
            queue.sync {
                userDefaults.set(token, forKey: key)
            }
            return false
        }
    }
    /// 获取指定用户的 accessToken
    public func getAccessToken(forUserId userId: Int) -> String? {
        let key = tokenKey(for: userId)
        if let token = keychain[key], !token.isEmpty {
            return token
        }
        return queue.sync {
            userDefaults.string(forKey: key)
        }
    }
    /// 删除指定用户的 accessToken
    public func deleteAccessToken(forUserId userId: Int) {
        let key = tokenKey(for: userId)
        try? keychain.remove(key)
        queue.sync {
            userDefaults.removeObject(forKey: key)
        }
    }

    /// 获取指定用户或当前用户的 accessToken
    public func accessToken(for userId: Int? = nil) -> String? {
        if let uid = userId {
            return getAccessToken(forUserId: uid)
        }
        guard let user = IFLYGiteeUserManager.shared.getCurrentUser() else { return nil }
        return getAccessToken(forUserId: user.id)
    }
    /// 获取当前用户的 accessToken（不需要指定 userId）
    public func currentAccessToken() -> String? {
        guard let user = IFLYGiteeUserManager.shared.getCurrentUser() else { return nil }
        return getAccessToken(forUserId: user.id)
    }
}

