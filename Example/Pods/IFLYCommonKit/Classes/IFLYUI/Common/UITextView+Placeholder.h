//
//  UITextView+Placeholder.h
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/9/4.
//

#import <UIKit/UIKit.h>
#if __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (Placeholder)

@property (nonatomic, readonly) UITextView *placeholderTextView NS_SWIFT_NAME(placeholderTextView);

@property (nonatomic, strong) IBInspectable NSString *placeholder;
@property (nonatomic, strong) NSAttributedString *attributedPlaceholder;
@property (nonatomic, strong) IBInspectable UIColor *placeholderColor;

+ (UIColor *)defaultPlaceholderColor;

@end


NS_ASSUME_NONNULL_END
