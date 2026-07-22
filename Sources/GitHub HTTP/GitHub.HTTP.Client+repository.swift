import GitHub
import GitHub_Standard
import JSON

extension GitHub.HTTP.Client {
    public func repository(
        authentication: GitHub.HTTP.Authentication
    ) -> GitHub.Repository.Get.Client<
        GitHub.HTTP.Error<ExecutionFailure, Never>
    > {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) in
            let httpRequest = try self.request(
                path: ["repos", request.owner.rawValue, request.repository.rawValue],
                authentication: authentication
            )
            let httpResponse = try await self.response(for: httpRequest)

            do throws(JSON.Error) {
                return try .init(
                    repository: Self.metadata(
                        from: JSON.parse(httpResponse.body ?? [])
                    )
                )
            } catch {
                throw .json(error)
            }
        }
    }
}
