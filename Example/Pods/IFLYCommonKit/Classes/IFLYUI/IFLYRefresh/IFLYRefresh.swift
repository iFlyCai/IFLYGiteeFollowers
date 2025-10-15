//
//  IFLYRefresh.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/3/31.
//

import UIKit
import MJRefresh

/// 刷新视图类型
public enum IFLYRefreshViewType: Int {
    case header  // 头部刷新
    case footer  // 底部刷新
}

/// 刷新协议，要求遵循的对象必须实现相关的刷新方法
public protocol IFLYRefreshProtocol: NSObjectProtocol {
    var scrollView: UIScrollView { get }
    func refreshLoadNewData()  // 加载新数据
    func refreshLoadMoreData() // 加载更多数据
}

public extension IFLYRefreshProtocol {
    /// 设置刷新视图
    func setRefreshView(type: IFLYRefreshViewType) {
        let action: MJRefreshComponentAction = { [weak self] in
            switch type {
            case .header:
                self?.refreshLoadNewData()
            case .footer:
                self?.refreshLoadMoreData()
            }
        }
        
        switch type {
        case .header:
            scrollView.mj_header = IFLYRefresh.refreshHeader(refreshingBlock: action)
        case .footer:
            scrollView.mj_footer = IFLYRefresh.refreshFooter(refreshingBlock: action)
        }
    }
    
    /// 显示或隐藏刷新视图
    func setRefreshViewHidden(type: IFLYRefreshViewType, isHidden: Bool) {
        switch type {
        case .header:
            scrollView.mj_header?.isHidden = isHidden
        case .footer:
            scrollView.mj_footer?.isHidden = isHidden
        }
    }
    
    func showRefreshView(type: IFLYRefreshViewType) {
        setRefreshViewHidden(type: type, isHidden: false)
    }
    
    func hiddenRefreshView(type: IFLYRefreshViewType) {
        setRefreshViewHidden(type: type, isHidden: true)
    }
    
    /// 开始刷新
    func beginRefreshView(type: IFLYRefreshViewType) {
        switch type {
        case .header:
            scrollView.mj_header?.beginRefreshing()
        case .footer:
            scrollView.mj_footer?.beginRefreshing()
        }
    }
    
    /// 结束刷新
    func endRefreshView(type: IFLYRefreshViewType) {
        switch type {
        case .header:
            scrollView.mj_header?.endRefreshing()
        case .footer:
            scrollView.mj_footer?.endRefreshing()
        }
    }
    
    /// 结束底部刷新并标记为没有更多数据
    func endRefreshFooterWithNoMoreData() {
        scrollView.mj_footer?.endRefreshingWithNoMoreData()
    }
    
    /// 重置底部刷新状态
    func resetRefreshFooter() {
        scrollView.mj_footer?.resetNoMoreData()
    }
    
    /// 重新加载刷新视图的文本内容
    func justReloadRefreshView() {
        IFLYRefresh.justRefreshFooter(footer: scrollView.mj_footer as? MJRefreshAutoStateFooter)
        IFLYRefresh.justRefreshHeader(header: scrollView.mj_header as? MJRefreshNormalHeader)
    }
}

@objcMembers public class IFLYRefresh: NSObject {
    /// 自定义刷新文本内容
    public static func set(headerIdleTextBlock: @escaping () -> String,
                           headerPullingTextBlock: @escaping () -> String,
                           headerRefreshingTextBlock: @escaping () -> String,
                           autoFooterRefreshingTextBlock: @escaping () -> String,
                           autoFooterNoMoreDataTextBlock: @escaping () -> String) {
        MJRefreshHeaderIdleTextBlock = headerIdleTextBlock
        MJRefreshHeaderPullingTextBlock = headerPullingTextBlock
        MJRefreshHeaderRefreshingTextBlock = headerRefreshingTextBlock
        MJRefreshAutoFooterRefreshingTextBlock = autoFooterRefreshingTextBlock
        MJRefreshAutoFooterNoMoreDataTextBlock = autoFooterNoMoreDataTextBlock
    }
    
    private static var MJRefreshHeaderIdleTextBlock: (() -> String)?
    private static var MJRefreshHeaderPullingTextBlock: (() -> String)?
    private static var MJRefreshHeaderRefreshingTextBlock: (() -> String)?
    private static var MJRefreshAutoFooterRefreshingTextBlock: (() -> String)?
    private static var MJRefreshAutoFooterNoMoreDataTextBlock: (() -> String)?
    
    /// 创建 MJRefresh 头部刷新组件
    public static func refreshHeader(refreshingBlock:@escaping MJRefreshComponentAction) -> MJRefreshHeader {
        let header = MJRefreshNormalHeader(refreshingBlock: refreshingBlock)
        header.lastUpdatedTimeLabel?.isHidden = true
        updateHeaderText(header: header)
        return header
    }
    
    /// 创建 MJRefresh 底部刷新组件
    public static func refreshFooter(refreshingBlock:@escaping MJRefreshComponentAction) -> MJRefreshFooter {
        let footer = MJRefreshAutoStateFooter(refreshingBlock: refreshingBlock)
        updateFooterText(footer: footer)
        return footer
    }
    
    /// 更新头部刷新控件的文本内容
    public static func justRefreshHeader(header: MJRefreshNormalHeader?) {
        updateHeaderText(header: header)
    }
    
    /// 更新底部刷新控件的文本内容
    public static func justRefreshFooter(footer: MJRefreshAutoStateFooter?) {
        updateFooterText(footer: footer)
    }
    
    /// 统一更新头部文本
    private static func updateHeaderText(header: MJRefreshNormalHeader?) {
        header?.setTitle(MJRefreshHeaderIdleTextBlock?() ?? "下拉可以刷新", for: .idle)
        header?.setTitle(MJRefreshHeaderPullingTextBlock?() ?? "松开立即刷新", for: .pulling)
        header?.setTitle(MJRefreshHeaderRefreshingTextBlock?() ?? "正在刷新数据中...", for: .refreshing)
    }
    
    /// 统一更新底部文本
    private static func updateFooterText(footer: MJRefreshAutoStateFooter?) {
        footer?.setTitle("", for: .idle)
        footer?.setTitle(MJRefreshAutoFooterRefreshingTextBlock?() ?? "正在加载更多的数据...", for: .refreshing)
        footer?.setTitle(MJRefreshAutoFooterNoMoreDataTextBlock?() ?? "已经全部加载完毕", for: .noMoreData)
    }
}
