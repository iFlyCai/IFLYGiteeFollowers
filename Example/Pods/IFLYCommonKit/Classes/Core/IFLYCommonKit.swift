//
//  UIApplication+Extensions.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//

@_exported import MJRefresh          // 让 MJRefresh       被导出
@_exported import SnapKit            // 让 SnapKit         被导出
@_exported import RxDataSources      // 让 RxDataSources   被导出
@_exported import RxCocoa            // 让 RxCocoa         被导出
@_exported import RxSwift            // 让 RxSwift         被导出
@_exported import RxRelay            // 让 RxRelay         被导出
@_exported import YYText             // 让 YYText          被导出
@_exported import SDWebImage         // 让 SDWebImage      被导出
@_exported import IFLYNetworkManager // 让 NetworkManager  被导出
@_exported import IFLYUtilities      // 让 IFLYUtilities   被导出
@_exported import IFLYGiteeUIStyleKit// 让 IFLYUIStyleKit  被导出
@_exported import IFLYOcticons       // 让 IFLYOcticons    被导出
@_exported import Alamofire          // 让 Alamofire       被导出


/// IFLYCommonKit 初始化时打印依赖库和自身版本号
private func printIFLYCommonKitVersions() {
    print("[IFLYCommonKit] Version: \(IFLYCommonKitVersion.current)")
}

// 自动初始化逻辑，首次用到 IFLYCommonKit 时打印依赖库和自身版本号
public enum IFLYCommonKitAutoInit {
    public static let didInit: Void = {
        print("[IFLYCommonKit] Version: \(IFLYCommonKitVersion.current)")
    }()
}

public enum IFLYCommonKitVersion {
    public static let current = "1.5.25"
}
