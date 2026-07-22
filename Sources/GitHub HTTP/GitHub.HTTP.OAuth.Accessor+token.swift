extension GitHub.HTTP.OAuth.Accessor {
    public var token: GitHub.HTTP.OAuth.Token.Accessor<ExecutionFailure, PaginationFailure> {
        .init(client: self.client)
    }
}
