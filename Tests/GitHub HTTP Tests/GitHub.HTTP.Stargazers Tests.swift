import GitHub_HTTP
import Testing

extension GitHub.HTTP {
    @Suite("GitHub.HTTP.Stargazers.Unit")
    struct Stargazers {
        @Test("Stargazers use the event media type and preserve pagination fields")
        func page() async throws {
            let headers = try HTTP.Headers([
                .init(
                    name: "Link",
                    value: "<https://api.github.com/repos/swiftlang/swift/stargazers?per_page=100&page=2>; rel=next"
                )
            ])
            let http = GitHub.HTTP.Client<Fixture.Execution, GitHub.HTTP.Pagination.Error>(
                agent: .init(rawValue: "stargazer-tests"),
                version: .init(rawValue: "2026-03-10"),
                execute: { request async throws(Fixture.Execution) in
                    #expect(
                        request.target.rawValue
                            == "https://api.github.com/repos/swiftlang/swift/stargazers?per_page=100&page=1"
                    )
                    #expect(
                        request.headers.first("Accept")?.rawValue
                            == "application/vnd.github.star+json"
                    )
                    return .init(
                        status: .ok,
                        headers: headers,
                        body: Fixture.bytes(
                            "[{\"starred_at\":\"2026-07-21T12:00:00Z\",\"user\":\(Fixture.user)}]"
                        )
                    )
                },
                pagination: .link
            )
            let page = try await http.stargazers(authentication: .none).page(
                .init(
                    owner: .init(rawValue: "swiftlang"),
                    repository: .init(rawValue: "swift"),
                    page: .first,
                    size: .maximum
                )
            )

            #expect(page.response.stargazers.first?.user.login.rawValue == "octocat")
            #expect(page.next?.owner.rawValue == "swiftlang")
            #expect(page.next?.repository.rawValue == "swift")
            #expect(page.next?.page?.rawValue == 2)
            #expect(page.next?.size == .maximum)
        }
    }
}
