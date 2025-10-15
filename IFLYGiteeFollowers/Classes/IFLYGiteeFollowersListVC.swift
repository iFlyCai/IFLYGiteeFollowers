//
//  IFLYGiteeFollowersListVC.swift
//  IFLYGiteeFollowers
//
//  Created by iFlyCai on 2025/10/15.
//

import UIKit
import IFLYCommonKit

open class IFLYGiteeFollowersListVC: IFLYCommonTVC<GiteeUser> {
    
    // 自定义单元格标识符
    private let followerCellIdentifier = "FollowerCell"
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏标题为"关注者"
        title = "粉丝(关注我的人)"
        // 注册自定义单元格
        tableView.register(IFLYFollowersCell.self, forCellReuseIdentifier: followerCellIdentifier)
        // 设置数据更新回调
        dataUpdateHandler = { [weak self] items, isRefresh in
            print("关注者数据已更新，总数：\(items.count)")
        }
        // 触发刷新获取数据
        triggerRefresh()
    }
    
    open override func fetchPage(page: Int, perPage: Int, isRefresh: Bool) {
        IFLYNetworkManager.shared.meFollowers(completion: { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let followers):
                    self.updatePaginationInfo(with: followers, isRefresh: isRefresh)
                    if isRefresh && followers.isEmpty {
                        self.showDefaultEmptyState(with: "暂无关注者数据")
                    }
                case .failure(let error):
                    self.endRefreshing()
                    if isRefresh && self.items.isEmpty {
                        let errorView = self.createErrorEmptyStateView(error: error)
                        self.showEmptyStateView(errorView)
                    }
                }
            }
        })
    }
    
    // 创建错误状态视图
    private func createErrorEmptyStateView(error: Error) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "exclamationmark.circle")
        iconView.tintColor = .orange
        iconView.contentMode = .scaleAspectFit
        containerView.addSubview(iconView)
        
        let errorLabel = UILabel()
        errorLabel.text = error.localizedDescription
        errorLabel.textColor = .darkGray
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        containerView.addSubview(errorLabel)
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("重试", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.backgroundColor = .systemBlue
        retryButton.layer.cornerRadius = 25
        retryButton.clipsToBounds = true
        retryButton.addTarget(self, action: #selector(retryLoadData), for: .touchUpInside)
        containerView.addSubview(retryButton)
        
        // 设置约束
        iconView.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        
        return containerView
    }
    
    // 重试加载数据
    @objc private func retryLoadData() {
        triggerRefresh()
    }
    
    // 重写表格单元格配置方法
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: followerCellIdentifier, for: indexPath) as? IFLYFollowersCell else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let follower = items[indexPath.row]
        cell.configure(with: follower)
        return cell
    }

}

open class IFLYFollowersCell: UITableViewCell {

    // 主容器视图
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.cellBackgroundColor
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()

    // 用户头像
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // 用户名
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pingfangSemibold(withSize: 16)
        label.textColor = AppColors.labelColor1
        label.numberOfLines = 1
        return label
    }()

    // 用户昵称
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pingfangMedium(withSize: 14)
        label.textColor = AppColors.labelColor2
        label.numberOfLines = 1
        return label
    }()

    // 个人简介
    lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.pingfangRegular(withSize: 13)
        label.textColor = AppColors.labelColor3
        return label
    }()

    // 统计信息容器
    lazy var statsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()

    // 关注者数量
    lazy var followersStatView: UIView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        return view
    }()

    // 关注按钮
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("已关注", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.pingfangMedium(withSize: 14)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15))
        }

        // 添加头像
        containerView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }

        // 添加用户名
        containerView.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.left.equalTo(avatarImageView.snp.right).offset(15)
            make.right.lessThanOrEqualToSuperview().offset(-15)
        }

        // 添加昵称
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(4)
            make.left.equalTo(avatarImageView.snp.right).offset(15)
            make.right.lessThanOrEqualToSuperview().offset(-15)
        }

        // 添加个人简介
        containerView.addSubview(bioLabel)
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalTo(avatarImageView.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        // 添加统计信息容器
        containerView.addSubview(statsContainerView)
        statsContainerView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(12)
            make.left.equalTo(avatarImageView.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-15)
        }




        // 添加关注按钮
        containerView.addSubview(followButton)
        followButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(avatarImageView)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
    }

    // 配置单元格数据
    public func configure(with user: GiteeUser) {
        // 设置用户名
        usernameLabel.text = user.login
        
        // 设置昵称（如果有）
        if let name = user.name, !name.isEmpty {
            nameLabel.text = name
        } else {
            nameLabel.text = nil
        }
        
        // 设置个人简介（如果有）
        if let bio = user.bio, !bio.isEmpty {
            bioLabel.text = bio
            bioLabel.isHidden = false
        } else {
            bioLabel.text = nil
            bioLabel.isHidden = true
        }
        
        // 加载用户头像
        if let avatarURLString = user.avatarUrl, let url = URL(string: avatarURLString) {
            // 使用SDWebImage异步加载头像（如果项目中使用了SDWebImage）
            SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { [weak self] image, _, _, _, _, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self?.avatarImageView.image = image
                    }
                }
            }
        } else {
            // 设置默认头像
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}

