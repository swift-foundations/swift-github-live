//
//  GitHub.Stargazers.Client.live.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 30/08/2025.
//

import GitHub_Live_Shared
import GitHub_Stargazers_Types

extension GitHub.Stargazers.Client {
    public static func live(
        makeRequest: @escaping @Sendable (_ route: GitHub.Stargazers.API) throws -> URLRequest
    ) -> Self {
        @Dependency(URLRequest.Handler.GitHub.self) var handleRequest

        return Self(
            // https://docs.github.com/en/rest/activity/starring#list-stargazers
            list: { owner, repo, request in
                try await handleRequest(
                    for: makeRequest(.list(owner: owner, repo: repo, request: request)),
                    decodingTo: GitHub.Stargazers.List.Response.self
                )
            }
        )
    }
}

extension GitHub.Stargazers {
    public typealias Authenticated = GitHub_Live_Shared.Authenticated<
        GitHub.Stargazers.API,
        GitHub.Stargazers.API.Router,
        GitHub.Stargazers.Client
    >
}

extension GitHub.Stargazers: @retroactive Dependency.Key {
    public static var liveValue: GitHub.Stargazers.Authenticated {
        @Dependency(\.envVars.githubBaseUrl) var baseUrl
        @Dependency(\.envVars.githubToken) var token

        // swiftlint:disable:next force_try
        return try! GitHub.Stargazers.Authenticated(
            baseURL: baseUrl,
            token: token
        ) { .live(makeRequest: $0) }
    }

    public static let testValue: GitHub.Stargazers.Authenticated = liveValue
}

extension GitHub.Stargazers.API.Router: @retroactive Dependency.Key {
    public static let liveValue: Self = .init()
    public static let testValue: Self = .init()
}
