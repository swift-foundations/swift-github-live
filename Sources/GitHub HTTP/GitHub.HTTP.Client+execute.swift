import GitHub
import HTTP_Standard

extension GitHub.HTTP.Client {
    func response(
        for request: HTTP.Request
    ) async throws(GitHub.HTTP.Error<ExecutionFailure, Never>) -> HTTP.Response {
        let response: HTTP.Response
        do throws(ExecutionFailure) {
            response = try await self.execute(request)
        } catch {
            throw .execute(error)
        }

        guard response.status.isSuccessful else {
            throw .status(response.status)
        }
        return response
    }
}
