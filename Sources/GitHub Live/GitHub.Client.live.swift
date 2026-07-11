//
//  GitHub.Client.live.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import GitHub_Collaborators_Live
import GitHub_Live_Shared
import GitHub_OAuth_Live
import GitHub_Repositories_Live
import GitHub_Stargazers_Live
import GitHub_Traffic_Live
import GitHub_Types

// https://docs.github.com/en/rest?apiVersion=2022-11-28
extension GitHub.Client {
    public static func live() throws -> GitHub.Authenticated {
        @Dependency(\.envVars.githubToken) var token
        return try GitHub.Client.live(token: token)
    }
}

extension GitHub.Client {
    public static func live(token: String) throws -> GitHub.Authenticated {
        @Dependency(\.envVars.githubBaseUrl) var baseUrl

        return try .init(
            baseURL: baseUrl,
            token: token
        ) { makeRequest in
            GitHub.Client(
                traffic: .live { route in
                    try makeRequest(.traffic(route))
                },
                repositories: .live { route in
                    try makeRequest(.repositories(route))
                },
                stargazers: .live { route in
                    try makeRequest(.stargazers(route))
                },
                oauth: .live { api in
                    try makeRequest(.oauth(api))
                },
                collaborators: .live { api in
                    try makeRequest(.collaborators(api))
                }
            )
        }
    }
}

extension GitHub {
    public typealias Authenticated = GitHub_Live_Shared.Authenticated<
        GitHub.API,
        GitHub.API.Router,
        GitHub.Client
    >
}

extension GitHub.Client: @retroactive Dependency.Key {
    public static var liveValue: GitHub.Authenticated {
        // swiftlint:disable:next force_try
        try! GitHub.Client.live()
    }

    public static let testValue: GitHub.Authenticated = liveValue
}

extension GitHub.API.Router: @retroactive Dependency.Key {
    public static let liveValue: Self = .init()
    public static let testValue: Self = .init()
}

extension Dependency.Values {
    public var github: GitHub.Authenticated {
        get { self[GitHub.Client.self] }
        set { self[GitHub.Client.self] = newValue }
    }
}
