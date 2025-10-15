import Foundation

public enum LanguageType: Int {
    case auto = -1
    case english = 0
    case simpleChinese
}

public enum LanguageError: Error {
    case unknown
}

public final class IFLYLanguageManager {

    public static let shared = IFLYLanguageManager()
    public static let LanguageDidChangeNotification = Notification.Name("LanguageDidChangeNotification")

    private let languageKey = "ZLLanguageTypeForUserDefaults"

    private init() {}

    public var currentLanguageType: LanguageType {
        let rawValue = UserDefaults.standard.integer(forKey: languageKey)
        return LanguageType(rawValue: rawValue) ?? .auto
    }

    public func setLanguage(type: LanguageType) {
        UserDefaults.standard.set(type.rawValue, forKey: languageKey)
        NotificationCenter.default.post(name: Self.LanguageDidChangeNotification, object: nil)
    }

    public func localized(forKey key: String) -> String {
        let bundle: Bundle

        switch resolvedLanguageType() {
        case .english:
            bundle = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj") ?? "") ?? .main
        case .simpleChinese:
            bundle = Bundle(path: Bundle.main.path(forResource: "zh-Hans", ofType: "lproj") ?? "") ?? .main
        default:
            bundle = .main
        }

        return NSLocalizedString(key, bundle: bundle, comment: "")
    }

    /// 自动模式下根据系统语言判断实际使用语言
    private func resolvedLanguageType() -> LanguageType {
        switch currentLanguageType {
        case .auto:
            let preferred = Locale.preferredLanguages.first ?? ""
            if preferred.hasPrefix("zh") {
                return .simpleChinese
            } else {
                return .english
            }
        default:
            return currentLanguageType
        }
    }
}
