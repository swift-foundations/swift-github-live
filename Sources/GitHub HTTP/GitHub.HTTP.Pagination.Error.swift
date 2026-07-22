public import RFC_8288

extension GitHub.HTTP.Pagination {
    public enum Error: Swift.Error, Hashable, Sendable {
        case link(RFC_8288.Link.Parse.Error)
        case next(Next)
        case page(Page)
    }
}
