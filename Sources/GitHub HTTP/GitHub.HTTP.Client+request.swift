import GitHub
import HTTP_Standard
import RFC_3986

extension GitHub.HTTP.Client {
    func request(
        path segments: [String],
        query parameters: [(String, String?)] = [],
        accept: String = "application/vnd.github+json",
        authentication: GitHub.HTTP.Authentication
    ) throws(GitHub.HTTP.Error<ExecutionFailure, Never>) -> HTTP.Request {
        let path: RFC_3986.URI.Path
        do throws(RFC_3986.URI.Path.Error) {
            path = try .init(segments: segments)
        } catch {
            throw .path(error)
        }

        let query: RFC_3986.URI.Query?
        do throws(RFC_3986.URI.Query.Error) {
            query = parameters.isEmpty ? nil : try .init(parameters)
        } catch {
            throw .query(error)
        }

        let scheme: RFC_3986.URI.Scheme
        do throws(RFC_3986.URI.Scheme.Error) {
            scheme = try .init("https")
        } catch {
            throw .scheme(error)
        }

        var headers = HTTP.Headers()
        do throws(HTTP.Header.Field.Error) {
            headers.append(try .init(name: "Accept", value: accept))
            headers.append(try .init(name: "User-Agent", value: self.agent.rawValue))
            headers.append(
                try .init(name: "X-GitHub-Api-Version", value: self.version.rawValue)
            )
            if case .token(let token) = authentication {
                headers.append(
                    try .init(name: "Authorization", value: "Bearer \(token.rawValue)")
                )
            }
        } catch {
            throw .header(error)
        }

        let uri = RFC_3986.URI(
            scheme: scheme,
            authority: .init(host: .registeredName("api.github.com")),
            path: path,
            query: query
        )
        return .init(method: .get, target: .absolute(uri), headers: headers)
    }
}
