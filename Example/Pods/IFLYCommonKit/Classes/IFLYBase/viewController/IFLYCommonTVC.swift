//  IFLYCommonBaseVC.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/1/22.
//

import UIKit
import MJRefresh


open class IFLYCommonTVC<T>: IFLYCommonBaseVC, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - 泛型数据数组
    /// 类型安全的数据源数组，存储表格显示的所有数据项。
    open var items: [T] = []
    
    // MARK: - UITableView 懒加载
    /// 表格视图，使用懒加载创建。配置了数据源和代理，默认样式为plain。
    /// 注册了默认的 UITableViewCell，并隐藏了分割线。
    public lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.tableFooterView = UIView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return table
    }()
    
    // MARK: - 分页
    /// 当前页码，分页加载数据时使用，默认为1。
    public var page: Int   = 1      // 当前的页码
    /// 每页加载的数据数量，最大限制为100。用于分页请求。
    public var perPage: Int       = 20     // 每页的数量，最大为 100
    /// 标记是否还有更多数据可以加载，控制上拉加载更多的显示与隐藏。
    public var hasMoreData: Bool  = true   // 是否有更多数据
    
    /// 数据更新回调闭包，当表格数据发生变化时触发
    public var dataUpdateHandler: (([T], Bool) -> Void)?
    
    /// 空状态视图的容器视图
    private var emptyStateViewContainer: UIView?
    
    // MARK: - View Lifecycle
    /// 视图加载完成后调用，设置表格视图布局及刷新控件。
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
    }
    
    // MARK: - 布局 tableView
    /// 添加并布局 tableView，使用 SnapKit 设置约束。
    /// 默认设置为左右、底部和顶部约束到安全区域。
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            // 添加默认顶部约束到安全区域
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    /// 便捷方法，允许子类自定义表格顶部约束
    /// - Parameter topConstraint: 自定义的顶部约束设置闭包
    public func setupTableViewTopConstraint(_ topConstraint: (ConstraintMaker) -> Void) {
        tableView.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            topConstraint(make)
        }
    }
    
    // MARK: - 空状态处理
    /// 显示自定义空状态视图
    /// - Parameter view: 要显示的空状态视图
    public func showEmptyStateView(_ view: UIView) {
        // 移除已有的空状态视图
        hideEmptyStateView()
        
        // 创建容器视图
        let container = UIView()
        container.backgroundColor = .clear
        container.tag = -999
        emptyStateViewContainer = container
        
        // 添加容器视图到主视图
        self.view.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }
        
        // 添加空状态视图到容器
        container.addSubview(view)
        view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            // 避免空状态视图过大
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
            make.height.lessThanOrEqualToSuperview().multipliedBy(0.8)
        }
        
        // 确保空状态视图在表格上方
        self.view.bringSubviewToFront(container)
    }
    
    /// 显示默认的空状态视图（简单文本提示）
    /// - Parameter message: 空状态提示信息
    public func showDefaultEmptyState(with message: String = "暂无数据") {
        let emptyView = UIView()
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "list.bullet.slash")
        iconView.tintColor = .lightGray
        iconView.contentMode = .scaleAspectFit
        emptyView.addSubview(iconView)
        
        let label = UILabel()
        label.text = message
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        emptyView.addSubview(label)
        
        // 设置约束
        iconView.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        showEmptyStateView(emptyView)
    }
    
    /// 隐藏空状态视图
    public func hideEmptyStateView() {
        if let container = emptyStateViewContainer {
            container.removeFromSuperview()
            emptyStateViewContainer = nil
        }
        
        // 也检查并移除直接添加的旧空状态视图
        for subview in view.subviews where subview.tag == -999 {
            subview.removeFromSuperview()
        }
    }
    
    // MARK: - 下拉刷新和上拉加载更多
    /// 判断当前表格是否正在刷新中（包括下拉刷新和上拉加载）。
    /// - Returns: 返回true表示正在刷新，false表示未刷新。
    public func isRefreshing() -> Bool {
        let headerRefreshing = tableView.mj_header?.isRefreshing ?? false
        let footerRefreshing = tableView.mj_footer?.isRefreshing ?? false
        return headerRefreshing || footerRefreshing
    }
    /// 结束下拉刷新动画，通常在数据加载完成后调用。
    public func endHeaderRefreshing() {
        tableView.mj_header?.endRefreshing()
    }
    /// 配置下拉刷新和上拉加载控件，设置刷新事件的回调方法。
    /// 上拉控件初始隐藏，只有有数据时才显示。
    private func setupRefreshControl() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(handleHeaderRefresh))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(handleFooterLoadMore))
        tableView.mj_footer?.isHidden = true
    }

    /// 下拉刷新事件处理，重置页码并加载第一页数据。
    @objc private func handleHeaderRefresh() {
        if isRefreshing() && !(tableView.mj_header?.isRefreshing ?? false) {
            return // 避免重复触发
        }
        page = 1
        fetchPage(page: page, perPage: perPage, isRefresh: true)
    }
    
    /// 上拉加载更多事件处理，根据是否有更多数据加载下一页。
    @objc private func handleFooterLoadMore() {
        if isRefreshing() && !(tableView.mj_footer?.isRefreshing ?? false) {
            return // 避免重复触发
        }
        guard canLoadMore() else {
            endRefreshing(noMoreData: true)
            return
        }
        // 先计算下一页页码，避免并发请求导致的重复页码问题
        let nextPage = page + 1
        fetchPage(page: nextPage, perPage: perPage, isRefresh: false)
    }
    
    /// 子类必须重写的方法，用于根据页码和每页数量加载数据。
    /// - Parameters:
    ///   - page: 当前页码
    ///   - perPage: 每页数量
    ///   - isRefresh: 是否为刷新操作（true表示下拉刷新，false表示上拉加载）
    open func fetchPage(page: Int, perPage: Int, isRefresh: Bool) {
        // 子类必须重写此方法以实现数据加载
    }
    
    /// 程序化触发下拉刷新，开始刷新动画并调用刷新处理方法。
    public func triggerRefresh() {
        if !isRefreshing() {
            tableView.mj_header?.beginRefreshing()
            handleHeaderRefresh()
        }
    }
    
    /// 程序化开始下拉刷新，触发刷新动画和数据加载。
    public func startHeaderRefresh() {
        triggerRefresh() // 复用triggerRefresh方法，避免代码重复
    }
    
    /// 程序化开始上拉加载更多，前提是有更多数据可加载。
    public func startFooterLoadMore() {
        if canLoadMore() && !isRefreshing() {
            tableView.mj_footer?.beginRefreshing()
            handleFooterLoadMore()
        }
    }
    // MARK: - 分页判断逻辑和方法

    /// 判断是否可以加载更多数据，基于 hasMoreData 标记。
    /// - Returns: 返回 true 表示可以加载更多，false 表示没有更多数据。
    public func canLoadMore() -> Bool {
        return hasMoreData
    }

    /// 重置上拉加载控件的状态，恢复到初始状态。
    public func resetRefreshFooter() {
        // 将上拉加载控件从"无更多数据"状态重置
        tableView.mj_footer?.resetNoMoreData()
        // 显示上拉加载控件
        tableView.mj_footer?.isHidden = false
        // 结束任何正在进行的上拉加载动画
        tableView.mj_footer?.endRefreshing()
    }

    /// 更新分页数据和表格视图，支持刷新和加载更多操作。
    /// - Parameters:
    ///   - newItems: 新加载的数据数组
    ///   - isRefresh: 是否为刷新操作，刷新时替换数据，加载更多时追加数据
    ///   - newTotalCount: 新的总数据条数（可选）
    ///   - newTotalPage: 新的总页数（可选）
    public func updatePaginationInfo(with newItems: [T], isRefresh: Bool, newTotalCount: Int? = nil, newTotalPage: Int? = nil) {
        if newItems.isEmpty && !isRefresh {
            endRefreshing(noMoreData: true)
            return
        }
        
        if isRefresh {
            // 刷新时替换数据源
            items = newItems
            tableView.reloadData()
            // 重置页码为1
            page = 1
        } else {
            // 加载更多时，追加数据并插入对应行，避免全部刷新，提高性能
            let startIndex = items.count
            items.append(contentsOf: newItems)
            let endIndex = items.count - 1
            if startIndex <= endIndex {
                var indexPaths: [IndexPath] = []
                for row in startIndex...endIndex {
                    indexPaths.append(IndexPath(row: row, section: 0))
                }
                tableView.performBatchUpdates({ 
                    tableView.insertRows(at: indexPaths, with: .automatic)
                }, completion: nil)
            }
            // 在加载更多成功后增加页码
            page += 1
        }
        
        // 根据新数据数量和可选的总页数/总条数判断是否还有更多数据
        if let newTotalPage = newTotalPage {
            hasMoreData = page < newTotalPage
        } else if let newTotalCount = newTotalCount {
            hasMoreData = items.count < newTotalCount
        } else {
            // 如果没有总页数和总条数，使用原始逻辑，但增加容错性
            hasMoreData = newItems.count >= perPage
        }
        
        // 结束刷新状态，更新刷新控件显示
        endRefreshing(noMoreData: !hasMoreData)
        
        // 根据数据是否为空显示或隐藏空状态视图
        if items.isEmpty {
            showDefaultEmptyState()
        } else {
            hideEmptyStateView()
        }
        
        // 触发数据更新回调
        dataUpdateHandler?(items, isRefresh)
    }
    
    /// 重置分页状态，恢复初始页码和数据状态，清空数据源。
    public func resetPagination() {
        page = 1
        hasMoreData = true
        items.removeAll()
        resetRefreshFooter()
    }
    
    /// 判断当前是否为最后一页，基于 hasMoreData 标记。
    /// - Returns: true 表示已是最后一页，无更多数据。
    public func isLastPage() -> Bool {
        return !hasMoreData
    }
    
    /// 结束刷新动画，根据是否有更多数据切换上拉加载控件状态。
    /// - Parameter noMoreData: 是否无更多数据，默认为false。
    public func endRefreshing(noMoreData: Bool = false) {
        tableView.mj_header?.endRefreshing()
        
        if items.isEmpty {
            // 数据为空时隐藏上拉加载控件
            tableView.mj_footer?.isHidden = true
        } else {
            // 有数据时显示上拉加载控件，根据是否无更多数据调整状态
            tableView.mj_footer?.isHidden = false
            if noMoreData {
                hasMoreData = false
                tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                hasMoreData = true
                tableView.mj_footer?.resetNoMoreData()
                tableView.mj_footer?.endRefreshing()
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    /// 表格分区数量，默认1个分区。
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// 每个分区的行数，返回数据源数组的元素数量。
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    /// 创建并配置单元格，默认使用 UITableViewCell，显示数据的字符串描述。
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = "\(items[indexPath.row])"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    /// 单元格选中事件，默认取消选中状态。子类可重写实现具体行为。
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// 单元格高度，默认自动计算高度。
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
