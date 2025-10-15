//
//  ViewController.swift
//  IFLYGiteeFollowers
//
//  Created by iFlyCai on 10/15/2025.
//  Copyright (c) 2025 iFlyCai. All rights reserved.
//

import UIKit
import IFLYCommonKit
import IFLYGiteeFollowers

class ViewController: IFLYCommonBaseVC {

    // UI Elements
    private var loginButton: UIButton!
    private var avatarImageView: UIImageView!
    private var welcomeLabel: UILabel!
    private var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkLoginStates()
    }
    func checkLoginStates()  {
        if let currentUser = IFLYGiteeUserManager.shared.getCurrentUser() {
            showUserInfo(avatarURL: currentUser.avatarUrl, username: currentUser.login)
        }else{
            loginButton.isHidden = false
            avatarImageView.isHidden = true
            welcomeLabel.isHidden = true
            nextButton.isHidden = true
        }
    }

    // Setup UI elements
    private func setupUI() {
        title = "首页"
        // Login Button
        loginButton = UIButton(type: .system)
        loginButton.setTitle("登录", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)

        // Avatar Image View
        avatarImageView = UIImageView()
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.clipsToBounds = true
        avatarImageView.isHidden = true
        view.addSubview(avatarImageView)

        // Welcome Label
        welcomeLabel = UILabel()
        welcomeLabel.textAlignment = .center
        welcomeLabel.isHidden = true
        view.addSubview(welcomeLabel)
        
        // Next Button (Hidden initially)
        nextButton = UIButton(type: .system)
        nextButton.setTitle("下一步", for: .normal)
        nextButton.layer.cornerRadius = 12
        nextButton.clipsToBounds = true
        nextButton.backgroundColor = UIColor.systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.isHidden = true
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        
        // Layout using SnapKit
        setupConstraints()
    }
    
    // Setup SnapKit constraints
    private func setupConstraints() {
        // Login Button Constraints
        loginButton.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        // Avatar Image View Constraints
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(loginButton.snp.bottom).offset(30)
            make.width.height.equalTo(100)
        }

        // Welcome Label Constraints
        welcomeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.width.equalTo(view).inset(50)
            make.height.equalTo(30)
        }
        
        // Next Button Constraints
        nextButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(welcomeLabel.snp.bottom).offset(30)
            make.width.equalTo(160)
            make.height.equalTo(45)
        }
    }

    // Login Button Action
    @objc private func loginButtonTapped() {
        IFLYNetworkManager.shared.getGiteeUserInfo(accessToken: "30b5e0a9274b1b19d1e676587212b1b4") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentUser): //GiteeUser类型
                    IFLYGiteeUserManager.shared.addUser(currentUser)
                    self.showUserInfo(avatarURL: currentUser.avatarUrl, username: currentUser.login)

                case .failure(let error):
                    debugPrint("登录失败: \(error.localizedDescription)")
                }
            }
        }

    }

    // Simulated login function (replace with real API call)
    private func login(completion: @escaping (Bool, String?, String?) -> Void) {
        // Simulate a successful login response
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion(true, "https://example.com/avatar.jpg", "iFlyCai")
        }
    }
    
    // Show user info (avatar and welcome message)
    private func showUserInfo(avatarURL: String?, username: String?) {
        // Hide login button
        loginButton.isHidden = true
        
        // Set avatar image (load from URL or local image)
        if let urlString = avatarURL, let url = URL(string: urlString) {
            avatarImageView.loadImage(from: url)
        }
        
        // Set welcome message
        welcomeLabel.text = "Welcome, \(username ?? "User")!"
        avatarImageView.isHidden = false
        welcomeLabel.isHidden = false
        nextButton.isHidden = false
    }

    // Next Button Action - navigation
    @objc private func nextButtonTapped() {
        let destinationVC = IFLYGiteeFollowersListVC() // Replace with actual destination view controller
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}

// Image Loading Extension (Optional)
extension UIImageView {
    func loadImage(from url: URL) {
        // Load image from URL using SDWebImage
        self.sd_setImage(with: url, completed: nil)
    }
}
