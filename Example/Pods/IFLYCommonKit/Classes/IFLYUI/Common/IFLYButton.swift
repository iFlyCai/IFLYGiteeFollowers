//
//  IFLYButton.swift
//  Pods
//
//  Created by iFlyCai on 2025/5/16.
//

import Foundation
import UIKit
import IFLYGiteeUIStyleKit

open class IFLYButton: UIButton {
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
         setUpUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    open func setUpUI() {
        layer.borderColor =  AppColors.buttonBorderColor.cgColor
        layer.borderWidth = 0
        layer.cornerRadius =  0
        backgroundColor =  AppColors.buttonBackgroundColor
        titleLabel?.textColor =  AppColors.buttonTitleColor
        setTitleColor(AppColors.buttonTitleColor, for: .normal)
        setTitleColor(AppColors.buttonTitleColor, for: .selected)
    }
}
