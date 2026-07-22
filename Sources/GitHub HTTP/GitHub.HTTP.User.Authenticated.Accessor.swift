extension GitHub.HTTP.User.Authenticated {
    public struct Accessor<ExecutionFailure, PaginationFailure>: Sendable
    where
        ExecutionFailure: Swift.Error & Sendable,
        PaginationFailure: Swift.Error & Sendable
    {
        let client: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>

        init(client: GitHub.HTTP.Client<ExecutionFailure, PaginationFailure>) {
            self.client = client
        }
    }
}
