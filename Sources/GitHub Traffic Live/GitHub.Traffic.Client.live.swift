//
//  GitHub.Traffic.Client.live.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import GitHub_Live_Shared
import GitHub_Traffic_Types

extension GitHub.Traffic.Client {
    public static func live(
        makeRequest: @escaping @Sendable (_ route: GitHub.Traffic.API) throws -> URLRequest
    ) -> Self {
        @Dependency(URLRequest.Handler.GitHub.self) var handleRequest

        return Self(
            // https://docs.github.com/en/rest/metrics/traffic#get-repository-views
            views: { owner, repo, per in
                try await handleRequest(
                    for: makeRequest(.views(owner: owner, repo: repo, per: per)),
                    decodingTo: GitHub.Traffic.Views.Response.self
                )
            },

            // https://docs.github.com/en/rest/metrics/traffic#get-repository-clones
            clones: { owner, repo, per in
                try await handleRequest(
                    for: makeRequest(.clones(owner: owner, repo: repo, per: per)),
                    decodingTo: GitHub.Traffic.Clones.Response.self
                )
            },

            // https://docs.github.com/en/rest/metrics/traffic#get-top-referral-paths
            paths: { owner, repo in
                try await handleRequest(
                    for: makeRequest(.paths(owner: owner, repo: repo)),
                    decodingTo: GitHub.Traffic.Paths.Response.self
                )
            },

            // https://docs.github.com/en/rest/metrics/traffic#get-top-referral-sources
            referrers: { owner, repo in
                try await handleRequest(
                    for: makeRequest(.referrers(owner: owner, repo: repo)),
                    decodingTo: GitHub.Traffic.Referrers.Response.self
                )
            }
        )
    }
}

extension GitHub.Traffic {
    public typealias Authenticated = GitHub_Live_Shared.Authenticated<
        GitHub.Traffic.API,
        GitHub.Traffic.API.Router,
        GitHub.Traffic.Client
    >
}

extension GitHub.Traffic: @retroactive Dependency.Key {
    public static var liveValue: GitHub.Traffic.Authenticated {
        @Dependency(\.envVars.githubBaseUrl) var baseUrl
        @Dependency(\.envVars.githubToken) var token

        // swiftlint:disable:next force_try
        return try! GitHub.Traffic.Authenticated(
            baseURL: baseUrl,
            token: token
        ) { .live(makeRequest: $0) }
    }

    public static let testValue: GitHub.Traffic.Authenticated = liveValue
}

extension GitHub.Traffic.API.Router: @retroactive Dependency.Key {
    public static let liveValue: Self = .init()
    public static let testValue: Self = .init()
}
