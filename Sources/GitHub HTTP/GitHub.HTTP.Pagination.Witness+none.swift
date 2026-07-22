extension GitHub.HTTP.Pagination.Witness where Failure == Never {
    public static let none = Self { _, _ in nil }
}
