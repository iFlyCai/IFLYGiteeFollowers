import UIKit
import Macaw

/// 便捷的Octicons图标访问类
open class IFLYOcticons {
    // 添加一个标志来跟踪UI是否已初始化
    private static var isUIInitialized: Bool = false
    
    // 添加初始化检查方法
    private static func ensureUIInitialized() {
        if !isUIInitialized {
            // 简单检查UIApplication状态来确定是否可以安全地加载图标
            if Thread.isMainThread {
                isUIInitialized = true
            }
        }
    }
    
    /// 获取指定名称和大小的图标
    /// - Parameters:
    ///   - name: 图标名称
    ///   - size: 图标大小（默认24pt）
    /// - Returns: UIImage对象
    public static func icon(_ name: String, size: Int = 24) -> UIImage? {
        ensureUIInitialized()
        return OcticonsManager.shared.octicon(named: name, size: size)
    }
    
    // 为所有其他静态方法和属性添加类似的初始化检查
    /// 获取指定名称、大小和颜色的图标
    /// - Parameters:
    ///   - name: 图标名称
    ///   - size: 图标大小（默认24pt）
    ///   - color: 图标颜色
    /// - Returns: UIImage对象
    public static func icon(_ name: String, size: Int = 24, color: UIColor) -> UIImage? {
        guard let icon = OcticonsManager.shared.octicon(named: name, size: size) else {
            return nil
        }
        return icon.withRenderingMode(.alwaysTemplate).tinted(with: color)
    }
    
    /// 获取所有可用的图标名称
    /// - Returns: 图标名称数组
    public static func allIcons() -> [String] {
        return OcticonsManager.shared.allIconNames()
    }
    
    // MARK: - 常用图标快捷访问
    
    // 操作类图标
    public static var agent: UIImage? {
        ensureUIInitialized()
        return OcticonsManager.shared.octicon(named: "agent")
    }
    
    // 为所有其他静态属性添加类似的检查
    public static var alert: UIImage? {
        ensureUIInitialized()
        return OcticonsManager.shared.octicon(named: "alert")
    }
    public static var check: UIImage? { OcticonsManager.shared.octicon(named: "check") }
    public static var plus: UIImage? { OcticonsManager.shared.octicon(named: "plus") }
    public static var minus: UIImage? { OcticonsManager.shared.octicon(named: "dash") }
    public static var x: UIImage? { OcticonsManager.shared.octicon(named: "x") }
    
    // 导航类图标
    public static var home: UIImage? { OcticonsManager.shared.octicon(named: "home") }
    public static var home_fill: UIImage? { OcticonsManager.shared.octicon(named: "home-fill") }

    public static var search: UIImage? { OcticonsManager.shared.octicon(named: "search") }
    public static var settings: UIImage? { OcticonsManager.shared.octicon(named: "gear") }
    public static var back: UIImage? { OcticonsManager.shared.octicon(named: "reply") }
    
    // 社交类图标
    public static var heart: UIImage? { OcticonsManager.shared.octicon(named: "heart") }
    public static var star: UIImage? { OcticonsManager.shared.octicon(named: "star") }
    public static var share: UIImage? { OcticonsManager.shared.octicon(named: "share") }
    
    // 内容类图标
    public static var book: UIImage? { OcticonsManager.shared.octicon(named: "book") }
    public static var file: UIImage? { OcticonsManager.shared.octicon(named: "file") }
    public static var image: UIImage? { OcticonsManager.shared.octicon(named: "image") }
    public static var video: UIImage? { OcticonsManager.shared.octicon(named: "video") }
    
    // 状态类图标
    public static var circle: UIImage? { OcticonsManager.shared.octicon(named: "circle") }
    public static var dot: UIImage? { OcticonsManager.shared.octicon(named: "dot") }
    public static var eye: UIImage? { OcticonsManager.shared.octicon(named: "eye") }
    public static var lock: UIImage? { OcticonsManager.shared.octicon(named: "lock") }
    public static var unlock: UIImage? { OcticonsManager.shared.octicon(named: "unlock") }
    
    // 技术类图标
    public static var code: UIImage? { OcticonsManager.shared.octicon(named: "code") }
    public static var repo: UIImage? { OcticonsManager.shared.octicon(named: "repo") }
    public static var terminal: UIImage? { OcticonsManager.shared.octicon(named: "terminal") }
    
    // 通知类图标
    public static var bell: UIImage? { OcticonsManager.shared.octicon(named: "bell") }
    public static var bell_fill: UIImage? { OcticonsManager.shared.octicon(named: "bell-fill") }
    // 通知类图标
    public static var person: UIImage? { OcticonsManager.shared.octicon(named: "person") }
    public static var person_fill: UIImage? { OcticonsManager.shared.octicon(named: "person-fill") }
    public static var pulse: UIImage? { OcticonsManager.shared.octicon(named: "pulse") }
    public static var pulse_fill: UIImage? { OcticonsManager.shared.octicon(named: "pulse-fill") }
    public static var mail: UIImage? { OcticonsManager.shared.octicon(named: "mail") }
    public static var inbox: UIImage? { OcticonsManager.shared.octicon(named: "inbox") }
}

/// 管理GitHub Octicons图标的单例类
open class OcticonsManager {
    /// 单例实例
    public static let shared = OcticonsManager()
    
    /// 缓存已加载的UIImage
    private var imageCache: [String: UIImage] = [:]
    
    /// 资源包名称
    private let bundleName = "IFLYOcticons"
    
    /// 资源包引用
    private var resourceBundle: Bundle? {
        guard let bundleURL = Bundle(for: type(of: self)).url(forResource: bundleName, withExtension: "bundle") else {
            print("Warning: Could not find IFLYOcticons resource bundle")
            return nil
        }
        
        return Bundle(url: bundleURL)
    }
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    /// 加载指定名称和大小的Octicon图标
    /// - Parameters:
    ///   - name: 图标名称（不包含扩展名和大小）
    ///   - size: 图标大小（16或24）
    /// - Returns: 加载的UIImage，如果加载失败则返回nil
    public func octicon(named name: String, size: Int = 24) -> UIImage? {
        // 创建缓存键
        let cacheKey = "\(name)-\(size)"
        
        // 检查缓存
        if let cachedImage = imageCache[cacheKey] {
            return cachedImage
        }
        
        // 确保大小是有效的
        guard [16, 24].contains(size) else {
            print("Error: Invalid octicon size. Must be 16 or 24.")
            return nil
        }
        
        // 加载SVG文件并渲染为UIImage
        guard let image = loadSVG(named: "\(name)-\(size)") else {
            return nil
        }
        
        // 缓存并返回
        imageCache[cacheKey] = image
        return image
    }
    
    /// 加载SVG文件并渲染为UIImage
    /// - Parameter name: SVG文件名称（不包含.svg扩展名）
    /// - Returns: 渲染得到的UIImage，如果失败则返回nil
    private func loadSVG(named name: String) -> UIImage? {
        guard let bundle = resourceBundle else {
            return nil
        }
        
        do {
            let node = try SVGParser.parse(resource: name, fromBundle: bundle)
            let svgView = MacawView(node: node, frame: CGRect(origin: .zero, size: CGSize(width: 24, height: 24)))
            
            // Render MacawView to UIImage
            UIGraphicsBeginImageContextWithOptions(svgView.bounds.size, false, 0)
            if let context = UIGraphicsGetCurrentContext() {
                svgView.layer.render(in: context)
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
        } catch {
            print("Error loading SVG file \"\(name)\": \(error)")
            return nil
        }
    }
    
    /// 获取所有可用的图标名称（不包含大小和扩展名）
    /// - Returns: 所有可用图标名称的数组
    public func allIconNames() -> [String] {
        guard let bundle = resourceBundle else {
            return []
        }
        
        // 获取资源包中所有的SVG文件
        guard let resourcePaths = try? FileManager.default.contentsOfDirectory(atPath: bundle.bundlePath) else {
            return []
        }
        
        // 提取图标名称（去掉大小和扩展名）
        var iconNames: Set<String> = []
        
        for path in resourcePaths {
            if path.hasSuffix(".svg") {
                // 移除.svg扩展名
                let nameWithoutExtension = path.replacingOccurrences(of: ".svg", with: "")
                
                // 移除大小后缀（-16或-24）
                let components = nameWithoutExtension.split(separator: "-")
                if components.count >= 2, let _ = Int(components.last ?? "") {
                    let baseName = components.dropLast().joined(separator: "-")
                    iconNames.insert(baseName)
                }
            }
        }
        
        return Array(iconNames).sorted()
    }
}

/// UIImage扩展，提供直接加载Octicons的便捷方法
public extension UIImage {
    /// 创建一个Octicon图标
    /// - Parameters:
    ///   - octiconName: Octicon图标名称
    ///   - size: 图标大小（16或24）
    /// - Returns: 创建的UIImage，如果创建失败则返回nil
    convenience init?(octiconName: String, size: Int = 24) {
        guard let image = OcticonsManager.shared.octicon(named: octiconName, size: size) else {
            return nil
        }
        self.init(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
    }
    
    /// 为UIImage添加颜色
    /// - Parameter color: 要应用的颜色
    /// - Returns: 着色后的UIImage
    func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // 设置填充颜色
        color.setFill()
        
        // 绘制图像蒙版
        draw(in: CGRect(origin: .zero, size: size))
        
        // 应用混合模式
        context.setBlendMode(.sourceIn)
        
        // 填充颜色
        context.fill(CGRect(origin: .zero, size: size))
        
        // 获取结果图像
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage ?? self
    }
}
