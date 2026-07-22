//
//  GitHub.OAuth.Client.live.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import Dependencies
import Foundation
import GitHub_Live_Shared
import GitHub_OAuth_Types
import URLRouting

extension GitHub.OAuth.Client {
    public static func live(
        makeRequest: @escaping @Sendable (_ route: GitHub.OAuth.API) throws -> URLRequest
    ) -> Self {
        @Dependency(URLRequest.Handler.GitHub.self) var handleRequest

        return .init(
            exchangeCode: { clientId, clientSecret, code, redirectUri in
                try await handleRequest(
                    for: makeRequest(
                        .exchangeCode(
                            .init(
                                clientId: clientId,
                                clientSecret: clientSecret,
                                code: code,
                                redirectUri: redirectUri
                            )
                        )
                    ),
                    decodingTo: GitHub.OAuth.TokenResponse.self
                )
            },
            getAuthenticatedUser: { accessToken in
                try await handleRequest(
                    for: makeRequest(.getAuthenticatedUser(accessToken: accessToken)),
                    decodingTo: GitHub.OAuth.User.self
                )
            },
            getUserEmails: { accessToken in
                try await handleRequest(
                    for: makeRequest(.getUserEmails(accessToken: accessToken)),
                    decodingTo: [GitHub.OAuth.Client.Email].self
                )
            }
        )
    }
}
