//  IFLYCommonBaseVC.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/1/22.
//

import UIKit
import RxCocoa
import RxSwift
import RTRootNavigationController
import IFLYGiteeUIStyleKit

// 自定义按钮类，用于扩大点击区域
class EnlargedHitAreaButton: UIButton {
    var hitTestEdgeInsets: UIEdgeInsets = .zero
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if hitTestEdgeInsets == .zero || !isEnabled || isHidden {
            return super.point(inside: point, with: event)
        }
        let relativeFrame = bounds
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        
        // 限制点击区域不超过导航栏边界
        guard let navBar = superview?.superview?.superview as? UINavigationBar else {
            return hitFrame.contains(point)
        }
        let navBarBounds = navBar.bounds
        let pointInNavBar = convert(point, to: navBar)
        return hitFrame.contains(point) && navBarBounds.contains(pointInNavBar)
    }
}

// MARK: - Common Base ViewController
open class IFLYCommonBaseVC: UIViewController {
    private var backButton: UIButton?
    public var disposeBag = DisposeBag()
    
    
    lazy var appearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.navigationBarBackgroundColor // 可根据需要替换成其他颜色
        return appearance
    }()
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        debugPrint("当前类类名:\(String(describing: type(of: self)))")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        view.backgroundColor = AppColors.viewControllerBackgroundColor
    }

    open override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        let backButton = EnlargedHitAreaButton(type: .custom)
        self.backButton = backButton // 保留引用，方便动态切换图片
        // 扩大点击区域（更大范围）
        backButton.hitTestEdgeInsets = UIEdgeInsets(top: -20, left: -20, bottom: -10, right: -20)
        
        // 设置点击区域的背景
        let hitAreaView = UIView()
        hitAreaView.isUserInteractionEnabled = false // 避免拦截触摸事件
        backButton.addSubview(hitAreaView)
        
        // 使用 SnapKit 设置背景视图约束，覆盖整个点击区域
        hitAreaView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(backButton.hitTestEdgeInsets.left)
            make.trailing.equalToSuperview().offset(-backButton.hitTestEdgeInsets.right)
            make.top.equalToSuperview().offset(backButton.hitTestEdgeInsets.top)
            make.bottom.equalToSuperview().offset(-backButton.hitTestEdgeInsets.bottom)
        }
        updateBackButtonImage(for: backButton) // 初始化设置返回按钮图片
        backButton.sizeToFit()
        backButton.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    /// 监听深浅模式切换
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        // 更新返回按钮图片
        if let backButton = backButton {
            updateBackButtonImage(for: backButton)
        }
    }


    private func updateBackButtonImage(for button: UIButton) {
        // 动态加载返回按钮图片
        if let backImage = UIImage.dynamicImage(
            lightModeName: "back_button_light",
            darkModeName: "back_button_dark"
        ) {
            button.setImage(backImage, for: .normal)
        } else {
            print("⚠️ 返回按钮图片未正确加载，请检查资源名称或路径。")
        }
    }
}

// MARK: - UIImage Extension
public extension UIImage {
    static func dynamicImage(lightModeName: String, darkModeName: String) -> UIImage? {
        guard let bundle = Bundle.iflyCommonKitBundle else {
            print("⚠️ 未找到资源 Bundle，请检查资源路径和配置。")
            return nil
        }
        // 加载浅色模式图片
        guard let lightImage = UIImage(named: lightModeName, in: bundle, compatibleWith: .init(userInterfaceStyle: .light)) else {
            print("⚠️ 未能加载浅色模式图片: \(lightModeName)")
            return nil
        }

        // 加载深色模式图片
        guard let darkImage = UIImage(named: darkModeName, in: bundle, compatibleWith: .init(userInterfaceStyle: .dark)) else {
            print("⚠️ 未能加载深色模式图片: \(darkModeName)")
            return nil
        }

        // 动态返回合适的图片
        return UITraitCollection.current.userInterfaceStyle == .dark ? darkImage : lightImage
    }
}
// MARK: - Bundle Extension
public extension Bundle {
    /// 原始资源 Bundle（根据当前类查找资源包）
    static var iflyCommonKitBundle: Bundle? {
        guard let bundleURL = Bundle(for: IFLYCommonBaseVC.self).url(forResource: "IFLYCommonKitResources", withExtension: "bundle") else {
            print("⚠️ 未找到资源包 IFLYCommonKitResources.bundle，请检查路径配置。")
            return nil
        }
        guard let bundle = Bundle(url: bundleURL) else {
            print("⚠️ 无法加载资源包 IFLYCommonKitResources.bundle，请检查路径配置。")
            return nil
        }
        return bundle
    }
    /// 统一资源访问入口，供所有组件使用（推荐）
    static var ifly_bundle: Bundle? {
        return Bundle.iflyCommonKitBundle
    }
}
