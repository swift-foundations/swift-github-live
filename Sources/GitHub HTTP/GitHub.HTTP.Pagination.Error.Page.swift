extension GitHub.HTTP.Pagination.Error {
    public enum Page: Swift.Error, Hashable, Sendable {
        case invalid(String)
        case missing
        case multiple(Int)
    }
}
