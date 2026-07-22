extension GitHub.HTTP.User.Accessor {
    public var authenticated:
        GitHub.HTTP.User.Authenticated.Accessor<ExecutionFailure, PaginationFailure>
    {
        .init(client: self.client)
    }
}
