//
//  UIApplication+Extensions.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//

import IFLYNetworkManager


// MARK: - IFLYGiteeUserManager RxSwift 扩展
extension IFLYGiteeUserManager {
    // 返回当前用户，如果没有则发出错误
    public func rx_getCurrentUser() -> Single<GiteeUser> {
        return Single.create { single in
            if let user = self.getCurrentUser() {
                single(.success(user))
            } else {
                let error = NSError(domain: "IFLYGiteeUserManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current user"])
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}
