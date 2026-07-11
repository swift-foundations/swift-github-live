//
//  GitHub.Collaborators.Client.live.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 14/09/2025.
//

import GitHub_Collaborators_Types
import GitHub_Live_Shared

extension GitHub.Collaborators.Client {
    public static func live(
        makeRequest: @escaping @Sendable (_ route: GitHub.Collaborators.API) throws -> URLRequest
    ) -> Self {
        @Dependency(URLRequest.Handler.GitHub.self) var handleRequest

        return Self(
            // https://docs.github.com/en/rest/collaborators/collaborators#list-repository-collaborators
            list: { owner, repo, request in
                try await handleRequest(
                    for: makeRequest(.list(owner: owner, repo: repo, request: request)),
                    decodingTo: GitHub.Collaborators.List.Response.self
                )
            },

            // https://docs.github.com/en/rest/collaborators/collaborators#check-if-a-user-is-a-repository-collaborator
            check: { owner, repo, username in
                _ = try await handleRequest(
                    for: makeRequest(.check(owner: owner, repo: repo, username: username)),
                    decodingTo: GitHub.Collaborators.Check.Response.self
                )
            },

            // https://docs.github.com/en/rest/collaborators/collaborators#add-a-repository-collaborator
            add: { owner, repo, username, request in
                try await handleRequest(
                    for: makeRequest(
                        .add(owner: owner, repo: repo, username: username, request: request)
                    ),
                    decodingTo: GitHub.Collaborators.Add.Response.self
                )
            },

            // https://docs.github.com/en/rest/collaborators/collaborators#remove-a-repository-collaborator
            remove: { owner, repo, username in
                _ = try await handleRequest(
                    for: makeRequest(.remove(owner: owner, repo: repo, username: username)),
                    decodingTo: GitHub.Collaborators.Remove.Response.self
                )
            },

            // https://docs.github.com/en/rest/collaborators/collaborators#get-repository-permissions-for-a-user
            getPermission: { owner, repo, username in
                try await handleRequest(
                    for: makeRequest(.getPermission(owner: owner, repo: repo, username: username)),
                    decodingTo: GitHub.Collaborators.GetPermission.Response.self
                )
            },

            // https://docs.github.com/en/rest/collaborators/invitations#list-repository-invitations
            listInvitations: { owner, repo, request in
                try await handleRequest(
                    for: makeRequest(.listInvitations(owner: owner, repo: repo, request: request)),
                    decodingTo: GitHub.Collaborators.Invitations.List.Response.self
                )
            },

            // https://docs.github.com/en/rest/collaborators/invitations#update-a-repository-invitation
            updateInvitation: { owner, repo, invitationId, request in
                try await handleRequest(
                    for: makeRequest(
                        .updateInvitation(
                            owner: owner,
                            repo: repo,
                            invitationId: invitationId,
                            request: request
                        )
                    ),
                    decodingTo: GitHub.Collaborators.Invitations.Update.Response.self
                )
            },

            // https://docs.github.com/en/rest/collaborators/invitations#delete-a-repository-invitation
            deleteInvitation: { owner, repo, invitationId in
                _ = try await handleRequest(
                    for: makeRequest(
                        .deleteInvitation(owner: owner, repo: repo, invitationId: invitationId)
                    ),
                    decodingTo: GitHub.Collaborators.Invitations.Delete.Response.self
                )
            }
        )
    }
}

extension GitHub.Collaborators {
    public typealias Authenticated = GitHub_Live_Shared.Authenticated<
        GitHub.Collaborators.API,
        GitHub.Collaborators.API.Router,
        GitHub.Collaborators.Client
    >
}

extension GitHub.Collaborators: @retroactive Dependency.Key {
    public static var liveValue: GitHub.Collaborators.Authenticated {
        @Dependency(\.envVars.githubBaseUrl) var baseUrl
        @Dependency(\.envVars.githubToken) var token

        return try! GitHub.Collaborators.Authenticated(
            baseURL: baseUrl,
            token: token
        ) { .live(makeRequest: $0) }
    }

    public static let testValue: GitHub.Collaborators.Authenticated = liveValue
}

extension GitHub.Collaborators.API.Router: @retroactive Dependency.Key {
    public static let liveValue: Self = .init()
    public static let testValue: Self = .init()
}
