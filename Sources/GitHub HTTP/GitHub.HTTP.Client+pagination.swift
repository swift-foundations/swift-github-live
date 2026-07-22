import HTTP_Standard

extension GitHub.HTTP.Client where PaginationFailure == GitHub.HTTP.Pagination.Error {
    /// Creates a GitHub HTTP client with RFC 8288 Link-field pagination.
    public init(
        agent: GitHub.HTTP.Agent,
        version: GitHub.HTTP.Version,
        execute: @escaping @Sendable (HTTP.Request) async throws(ExecutionFailure) -> HTTP.Response
    ) {
        self.init(
            agent: agent,
            version: version,
            execute: execute,
            pagination: .link
        )
    }
}
