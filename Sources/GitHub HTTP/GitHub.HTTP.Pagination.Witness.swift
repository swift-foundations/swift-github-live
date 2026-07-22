import GitHub
import HTTP_Standard

extension GitHub.HTTP.Pagination {
    public struct Witness<Failure: Swift.Error & Sendable>: Sendable {
        public var next:
            @Sendable (
                HTTP.Headers,
                GitHub.Organization.Repositories.Request
            ) throws(Failure) -> GitHub.Organization.Repositories.Request?

        public init(
            next:
                @escaping @Sendable (
                    HTTP.Headers,
                    GitHub.Organization.Repositories.Request
                ) throws(Failure) -> GitHub.Organization.Repositories.Request?
        ) {
            self.next = next
        }
    }
}
