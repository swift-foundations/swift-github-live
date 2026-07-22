extension GitHub.HTTP.User.Authenticated.Accessor {
    public var emails:
        GitHub.HTTP.User.Authenticated.Emails.Accessor<ExecutionFailure, PaginationFailure>
    {
        .init(client: self.client)
    }
}
