import UIKit

public class AppColors {
    // 通用操作按钮主色，适用于主要操作按钮
    public static let primaryColor = AppColors.color(named: "PrimaryColor")//buttonBackgroundColor
    // 通用操作按钮主色，适用于主要操作按钮
    public static let commonOperationColor = AppColors.color(named: "CommonOperationColor")
    /// 禁用状态颜色，适用于按钮、文本等不可用状态
    public static let disabledColor = AppColors.color(named: "DisabledColor")
    /// 推荐操作色，适用于推荐/次要操作按钮
    public static let recommendOperationColor = AppColors.color(named: "RecommendOperationColor")
    /// 测试用色，适用于调试或特殊标记
    public static let testColor = AppColors.color(named: "TestColor")
    /// 警告操作色，适用于警告、危险操作
    public static let warningOperationColor = AppColors.color(named: "WarningOperationColor")
    
    /// 列表单元格背景色
    public static let cellBackgroundColor = AppColors.color(named: "ZLCellBack")
    /// 列表单元格选中背景色
    public static let cellSelectedBackgroundColor = AppColors.color(named: "ZLCellBackSelected")

    /// 一级文本色，适用于主标题
    public static let labelColor1 = AppColors.color(named: "label1")
    /// 二级文本色，适用于副标题
    public static let labelColor2 = AppColors.color(named: "label2")
    /// 三级文本色，适用于说明文字
    public static let labelColor3 = AppColors.color(named: "label3")
    /// 四级文本色，适用于提示、占位等
    public static let labelColor4 = AppColors.color(named: "label4")

    /// 主链接色，适用于可点击文本
    public static let linkLabelColor1 = AppColors.color(named: "linkLabel1")
    /// 次链接色，适用于次要可点击文本
    public static let linkLabelColor2 = AppColors.color(named: "linkLabel2")

    /// 分割线主色
    public static let separatorLineColor = AppColors.color(named: "seperatorLine1")
    /// 分割线次色
    public static let separatorLineColor2 = AppColors.color(named: "seperatorLine2")
    /// 子栏背景色，适用于底部栏、工具栏等
    public static let subBarColor = AppColors.color(named: "SubBarColor")
    
    // BaseButton
    /// 按钮背景色
    public static let buttonBackgroundColor      = AppColors.color(named: "BaseButtonBackColor")
    /// 按钮边框色
    public static let buttonBorderColor        = AppColors.color(named: "BaseButtonBorderColor")
    /// 按钮禁用状态标题色
    public static let buttonDisabledTitleColor = AppColors.color(named: "BaseButtonDisabledTitleColor")
    /// 按钮标题色
    public static let buttonTitleColor         = AppColors.color(named: "BaseButtonTitleColor")
    
    // NavigationBar背景颜色和标题颜色
    /// 导航栏标题色
    public static let navigationBarTitleColor       = AppColors.color(named: "navigationBarTitleColor")
    /// 导航栏背景色
    public static let navigationBarBackgroundColor  = AppColors.color(named: "navigationBarBackgoundColor")
    
    // BaseViewController
    /// 控制器背景色
    public static let viewControllerBackgroundColor  = AppColors.color(named: "viewControllerBackgoundColor")
    public static func color(named name: String) -> UIColor {
        // 方法1：直接从嵌套的bundle中加载（最有可能成功的方式）
        // 修复：Bundle(for:)返回非可选类型，不需要if let
        let frameworkBundle = Bundle(for: AppColors.self)
        if let nestedBundleURL = frameworkBundle.url(forResource: "IFLYGiteeUIStyleKit", withExtension: "bundle") {
            if let nestedBundle = Bundle(url: nestedBundleURL) {
                print("方法1: 找到嵌套bundle: \(nestedBundle.bundlePath)")
                if let color = UIColor(named: name, in: nestedBundle, compatibleWith: nil) {
                    print("方法1: 成功从嵌套bundle加载颜色 '\(name)'")
                    return color
                } else {
                    print("方法1: 嵌套bundle中未找到颜色 '\(name)'")
                }
            }
        }
        
        // 方法2：通过CocoaPods标准bundle标识符查找
        if let bundle = Bundle(identifier: "org.cocoapods.IFLYGiteeUIStyleKit") {
            print("方法2: 找到bundle: \(bundle.bundlePath)")
            if let color = UIColor(named: name, in: bundle, compatibleWith: nil) {
                print("方法2: 成功加载颜色 '\(name)'")
                return color
            }
        }
        
        // 方法3：通过当前类查找正确的bundle
        let bundle3 = Bundle(for: AppColors.self)
        print("方法3: 找到bundle: \(bundle3.bundlePath)")
        if let color = UIColor(named: name, in: bundle3, compatibleWith: nil) {
            print("方法3: 成功加载颜色 '\(name)'")
            return color
        }
        
        // 方法4：检查是否在主bundle中能找到
        if let color = UIColor(named: name, in: .main, compatibleWith: nil) {
            print("方法4: 在主bundle中成功加载颜色 '\(name)'")
            return color
        }
        
        // 方法5：后备方案 - 根据当前外观模式返回默认颜色
        let appearance = UIScreen.main.traitCollection.userInterfaceStyle
        print("颜色加载失败，使用后备颜色，外观模式: \(appearance == .dark ? "深色" : "浅色")")
        return appearance == .dark ? .black : .white
    }
    
    public static func debugBundleContents() {
        print("\n=== 调试资源包内容 ===")
        
        // 检查嵌套bundle
        // 修复：Bundle(for:)返回非可选类型，不需要if let
        let frameworkBundle = Bundle(for: AppColors.self)
        if let nestedBundleURL = frameworkBundle.url(forResource: "IFLYGiteeUIStyleKit", withExtension: "bundle") {
            if let nestedBundle = Bundle(url: nestedBundleURL) {
                print("嵌套Bundle路径: \(nestedBundle.bundlePath)")
                listBundleContents(bundle: nestedBundle)
            }
        }
        
        // 检查方法2的bundle
        if let bundle = Bundle(identifier: "org.cocoapods.IFLYGiteeUIStyleKit") {
            print("\n方法2 Bundle路径: \(bundle.bundlePath)")
            listBundleContents(bundle: bundle)
        } else {
            print("方法2: 未找到bundle")
        }
        
        // 检查方法3的bundle
        let bundle3 = Bundle(for: AppColors.self)
        print("\n方法3 Bundle路径: \(bundle3.bundlePath)")
        listBundleContents(bundle: bundle3)
        
        // 检查主bundle
        let mainBundle = Bundle.main
        print("\n主Bundle路径: \(mainBundle.bundlePath)")
        
        print("\n=== 调试结束 ===\n")
    }
    
    private static func listBundleContents(bundle: Bundle) {
        if let enumerator = FileManager.default.enumerator(atPath: bundle.bundlePath) {
            print("Bundle内容:")
            for case let file as String in enumerator {
                print("- \(file)")
                // 特别检查是否存在xcassets或car文件
                if file.hasSuffix(".xcassets") || file.hasSuffix(".car") {
                    print("  [重要资源文件] \(file)")
                }
            }
        }
    }
}

