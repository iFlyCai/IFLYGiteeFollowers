//
//  AppColors.swift
//  Alamofire
//
//  Created by iFlyCai on 2025/2/13.
//

import Foundation
import UIKit

private let IFLYCurrentUserInterfaceStyleKey = "IFLYCurrentUserInterfaceStyleKey"


@objcMembers
public class IFLYUISharedDataManager: NSObject {
    @objc public static var currentUserInterfaceStyle: UIUserInterfaceStyle {
        get {
            let result = UserDefaults.standard.integer(forKey: IFLYCurrentUserInterfaceStyleKey)
            return UIUserInterfaceStyle(rawValue: result) ?? .unspecified
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: IFLYCurrentUserInterfaceStyleKey)
            UserDefaults.standard.synchronize()
            applyInterfaceStyleToAllWindows()
        }
    }

    /// 应用当前界面风格到所有窗口
    @objc public static func applyInterfaceStyleToAllWindows() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = currentUserInterfaceStyle }
    }
}
