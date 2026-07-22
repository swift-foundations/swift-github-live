extension GitHub.HTTP.Client {
    public var user: GitHub.HTTP.User.Accessor<ExecutionFailure, PaginationFailure> {
        .init(client: self)
    }
}
