extension GitHub.HTTP.Client {
    public var oauth: GitHub.HTTP.OAuth.Accessor<ExecutionFailure, PaginationFailure> {
        .init(client: self)
    }
}
