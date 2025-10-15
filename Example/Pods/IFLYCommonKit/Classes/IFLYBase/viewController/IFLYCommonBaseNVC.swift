//
//  IFLYCommonBaseNVC.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/1/22.
//

import UIKit
import RTRootNavigationController

open class IFLYCommonBaseNVC: RTRootNavigationController {

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.children.count ==  1{
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    


}
