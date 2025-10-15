//
//  GiteeAPIEndpoints.swift
//  IFLYNetworkManager
//
//  Created by iFlyCai on 2025/8/16.
//

import Foundation

/// Gitee Open API v5 端点常量（核心与常用）
/// 参考： https://gitee.com/api/v5/swagger  （完整清单以官方文档为准）
public enum GiteeAPI {
    public static let base = "https://gitee.com/api/v5"

    // MARK: - 通用工具
    @inlinable public static func path(_ components: String...) -> String {
        components.joined()
    }

    // MARK: - 认证 / 授权
    public enum Auth {
        /// 获取当前用户（基于 access_token）
        public static let me = "/user"
        /// OAuth 授权（网页端用）
        public static let oauthAuthorize = "https://gitee.com/oauth/authorize"
        /// OAuth 交换 token
        public static let oauthToken     = "https://gitee.com/oauth/token"
    }

    // MARK: - 用户 Users
    public enum Users {
        /// 指定用户信息
        public static func user(_ username: String) -> String { "/users/\(username)" }
        /// 指定用户的仓库
        public static func repos(_ username: String) -> String { "/users/\(username)/repos" }
        /// 列出授权用户的所有仓库
        public static func allRepos(_ username: String) -> String { "/user/repos" }
        /// 指定用户的 Star 仓库
        public static func starred(_ username: String) -> String { "/users/\(username)/starred" }
        /// 指定用户的关注列表
        public static func following(_ username: String) -> String { "/users/\(username)/following" }
        /// 指定用户的粉丝
        public static func followers(_ username: String) -> String { "/users/\(username)/followers" }
        /// 指定用户的动态
        public static func events(_ username: String) -> String { "/users/\(username)/events" }
        /// 列出一个用户收到的公开动态
        public static func receivedPublicEvents(_ username: String) -> String { "/users/\(username)/received_events/public" }
        /// 列出一个用户收到的动态
        public static func receivedEvents(_ username: String) -> String { "/users/\(username)/received_events" }

        /// 当前登录用户的邮箱
        public static let emails = "/user/emails"
        /// 当前登录用户的所有公钥
        public static let keys = "/user/keys"
        /// 当前登录用户的关注列表
        public static let meFollowing = "/user/following"
        /// 当前登录用户的粉丝
        public static let meFollowers = "/user/followers"
        /// 当前登录用户 Star 的仓库
        public static let meStarred = "/user/starred"
        /// 当前登录用户的组织
        public static let meOrgs = "/user/orgs"
        /// 当前登录用户的项目（仓库）
        public static let meRepos = "/user/repos"
        /// 当前登录用户的活动
        public static let meEvents = "/users/events"
    }

    // MARK: - 组织 Orgs
    public enum Orgs {
        public static func org(_ org: String) -> String { "/orgs/\(org)" }
        public static func members(_ org: String) -> String { "/orgs/\(org)/members" }
        public static func repos(_ org: String) -> String { "/orgs/\(org)/repos" }
        public static func teams(_ org: String) -> String { "/orgs/\(org)/teams" }
    }

    // MARK: - 仓库 Repos
    public enum Repos {
        public static func repo(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)" }

        // 基础信息
        public static func branches(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/branches" }
        public static func branch(_ owner: String, _ repo: String, _ name: String) -> String { "/repos/\(owner)/\(repo)/branches/\(name)" }
        public static func tags(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/tags" }
        public static func contributors(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/contributors" }
        public static func languages(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/languages" }
        public static func readme(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/readme" }

        // Star / Watch / Fork
        public static func stargazers(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/stargazers" }
        public static func watchers(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/subscribers" }
        public static func forks(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/forks" }
        public static func star(_ owner: String, _ repo: String) -> String { "/user/starred/\(owner)/\(repo)" }         // PUT/DELETE
        public static func watch(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/subscription" }  // PUT/DELETE

        // 内容 / 文件
        public static func contents(_ owner: String, _ repo: String, _ path: String = "") -> String {
            path.isEmpty ? "/repos/\(owner)/\(repo)/contents" : "/repos/\(owner)/\(repo)/contents/\(path)"
        }
        public static func commits(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/commits" }
        public static func commit(_ owner: String, _ repo: String, _ sha: String) -> String { "/repos/\(owner)/\(repo)/commits/\(sha)" }
        public static func compare(_ owner: String, _ repo: String, _ base: String, _ head: String) -> String {
            "/repos/\(owner)/\(repo)/compare/\(base)...\(head)"
        }

        // 里程碑 / Labels
        public static func milestones(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/milestones" }
        public static func milestone(_ owner: String, _ repo: String, _ id: Int) -> String { "/repos/\(owner)/\(repo)/milestones/\(id)" }
        public static func labels(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/labels" }
        public static func label(_ owner: String, _ repo: String, _ name: String) -> String { "/repos/\(owner)/\(repo)/labels/\(name)" }

        // Release
        public static func releases(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/releases" }
        public static func release(_ owner: String, _ repo: String, _ id: Int) -> String { "/repos/\(owner)/\(repo)/releases/\(id)" }
        public static func releaseAssets(_ owner: String, _ repo: String, _ id: Int) -> String { "/repos/\(owner)/\(repo)/releases/\(id)/assets" }

        // Webhooks
        public static func hooks(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/hooks" }
        public static func hook(_ owner: String, _ repo: String, _ id: Int) -> String { "/repos/\(owner)/\(repo)/hooks/\(id)" }

        // 合作成员
        public static func collaborators(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/collaborators" }
        public static func collaborator(_ owner: String, _ repo: String, _ username: String) -> String { "/repos/\(owner)/\(repo)/collaborators/\(username)" }
        public static func permissions(_ owner: String, _ repo: String, _ username: String) -> String { "/repos/\(owner)/\(repo)/collaborators/\(username)/permission" }
    }

    // MARK: - Issue
    public enum Issues {
        public static func repoIssues(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/issues" }
        public static func issue(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/issues/\(number)" }
        public static func comments(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/issues/\(number)/comments" }
        public static func timelines(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/issues/\(number)/timeline" }
        public static let myIssues = "/issues"
    }

    // MARK: - Pull Requests (PR / Merge Requests)
    public enum Pulls {
        public static func pulls(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/pulls" }
        public static func pull(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/pulls/\(number)" }
        public static func commits(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/pulls/\(number)/commits" }
        public static func files(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/pulls/\(number)/files" }
        public static func comments(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/pulls/\(number)/comments" }
        public static func reviews(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/pulls/\(number)/reviews" }
        public static func merge(_ owner: String, _ repo: String, _ number: Int) -> String { "/repos/\(owner)/\(repo)/pulls/\(number)/merge" }
    }

    // MARK: - 分支 / 标签 (Branches / Tags)
    public enum GitData {
        public static func branches(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/branches" }
        public static func branch(_ owner: String, _ repo: String, _ name: String) -> String { "/repos/\(owner)/\(repo)/branches/\(name)" }
        public static func tags(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/tags" }
        public static func refs(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/git/refs" }
        public static func ref(_ owner: String, _ repo: String, _ ref: String) -> String { "/repos/\(owner)/\(repo)/git/refs/\(ref)" }
        public static func blobs(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/git/blobs" }
        public static func blob(_ owner: String, _ repo: String, _ sha: String) -> String { "/repos/\(owner)/\(repo)/git/blobs/\(sha)" }
        public static func trees(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/git/trees" }
        public static func tree(_ owner: String, _ repo: String, _ sha: String) -> String { "/repos/\(owner)/\(repo)/git/trees/\(sha)" }
        public static func tagsAnnotated(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/git/tags" }
        public static func tagAnnotated(_ owner: String, _ repo: String, _ sha: String) -> String { "/repos/\(owner)/\(repo)/git/tags/\(sha)" }
    }

    // MARK: - Releases
    public enum Releases {
        public static func releases(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/releases" }
        public static func release(_ owner: String, _ repo: String, _ id: Int) -> String { "/repos/\(owner)/\(repo)/releases/\(id)" }
        public static func assets(_ owner: String, _ repo: String, _ id: Int) -> String { "/repos/\(owner)/\(repo)/releases/\(id)/assets" }
    }

    // MARK: - Webhooks
    public enum Hooks {
        public static func hooks(_ owner: String, _ repo: String) -> String { "/repos/\(owner)/\(repo)/hooks" }
        public static func hook(_ owner: String, _ repo: String, _ id: Int) -> String { "/repos/\(owner)/\(repo)/hooks/\(id)" }
    }

    // MARK: - 通知/消息
    public enum Activity {
        /// 当前用户通知（需要 scope）
        public static let notifications = "/notifications"
        public static func allThreads(_ id: String) -> String { "/notifications/threads"} //所有消息列表
        public static func threads(_ id: String) -> String { "/notifications/threads/\(id)" }
        public static let subscriptions = "/notifications/threads/subscriptions"
        
        public static let message = "/notifications/messages"
        public static let messageCount = "/notifications/count"
    }

    // MARK: - 搜索
    public enum Search {
        /// 仓库搜索
        public static let repositories = "/search/repositories"
        /// 用户搜索
        public static let users = "/search/users"
        /// 代码搜索
        public static let code = "/search/code"
        /// 议题搜索（若支持）
        public static let issues = "/search/issues"
        /// 组织搜索
        public static let organizations = "/search/organizations"
    }

    // MARK: - Markdown 渲染
    public enum Markdown {
        public static let render = "/markdown"             // POST
        public static let raw    = "/markdown/raw"         // POST
    }

    // MARK: - Snippets / Gists (代码片段)
    public enum Snippets {
        public static let mySnippets = "/snippets"
        public static func snippet(_ id: Int) -> String { "/snippets/\(id)" }
        public static func comments(_ id: Int) -> String { "/snippets/\(id)/comments" }
    }

    // MARK: - 合并：常用组合帮助
    public enum Build {
        /// 仓库 Issue 列表
        public static func repoIssues(owner: String, repo: String) -> String {
            Issues.repoIssues(owner, repo)
        }
        /// 仓库 PR 列表
        public static func repoPulls(owner: String, repo: String) -> String {
            Pulls.pulls(owner, repo)
        }
        /// 仓库内容路径
        public static func repoContents(owner: String, repo: String, path p: String = "") -> String {
            Repos.contents(owner, repo, p)
        }
    }
}

