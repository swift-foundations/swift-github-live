import GitHub_HTTP
import RFC_3986
import Testing

extension GitHub.HTTP {
    @Suite("GitHub.HTTP.OAuth.Unit")
    struct OAuthTests {
        @Test("Authorization maps provider query values without executing")
        func authorization() throws {
            let http = Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "oauth-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Fixture.Execution) in throw .unexpected },
                pagination: .none
            )
            let response = try http.oauth.authorization.authorize(
                .init(
                    clientID: "client id",
                    redirectURI: try RFC_3986.URI("https://example.com/callback"),
                    scopes: ["read:user", "user:email"],
                    state: "opaque state"
                )
            )

            #expect(
                response.uri.description
                    == "https://github.com/login/oauth/authorize?client_id=client%20id&redirect_uri=https://example.com/callback&scope=read:user%20user:email&state=opaque%20state"
            )
        }

        @Test("Token exchange uses canonical form body and decodes success")
        func token() async throws {
            let http = Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "oauth-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(Fixture.Execution) in
                    #expect(request.method == .post)
                    #expect(request.target.rawValue == "https://github.com/login/oauth/access_token")
                    #expect(request.headers.first("Accept")?.rawValue == "application/json")
                    #expect(
                        request.headers.first("Content-Type")?.rawValue
                            == "application/x-www-form-urlencoded"
                    )
                    let body = String(
                        decoding: (request.body ?? []).map(\.underlying),
                        as: UTF8.self
                    )
                    #expect(
                        body
                            == "client_id=client+id&client_secret=secret%26value&code=code%2Bvalue"
                    )
                    return .init(
                        status: .ok,
                        body: Fixture.bytes(
                            #"{"access_token":"token","token_type":"bearer","scope":"read:user,user:email"}"#
                        )
                    )
                },
                pagination: .none
            )
            let response = try await http.oauth.token.exchange.exchange(
                .init(
                    clientID: "client id",
                    clientSecret: "secret&value",
                    code: "code+value"
                )
            )

            #expect(response.accessToken == "token")
            #expect(response.scope == "read:user,user:email")
        }

        @Test("Token endpoint provider errors remain typed")
        func providerError() async throws {
            let http = Client<Fixture.Execution, Never>(
                agent: .init(rawValue: "oauth-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { _ async throws(Fixture.Execution) in
                    .init(
                        status: .ok,
                        body: Fixture.bytes(
                            #"{"error":"bad_verification_code","error_description":"The code passed is incorrect or expired."}"#
                        )
                    )
                },
                pagination: .none
            )

            do {
                _ = try await http.oauth.token.exchange.exchange(
                    .init(clientID: "id", clientSecret: "secret", code: "bad")
                )
                Issue.record("Expected a typed provider failure")
            } catch let error {
                guard case .provider(let provider) = error else {
                    Issue.record("Expected provider failure, got \(error)")
                    return
                }
                #expect(provider.error == "bad_verification_code")
            }
        }
    }
}
