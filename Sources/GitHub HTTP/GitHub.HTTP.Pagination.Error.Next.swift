extension GitHub.HTTP.Pagination.Error {
    public enum Next: Swift.Error, Hashable, Sendable {
        case multiple(Int)
    }
}
