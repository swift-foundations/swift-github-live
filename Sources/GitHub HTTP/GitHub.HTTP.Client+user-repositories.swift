import GitHub
import GitHub_Standard
import HTTP_Standard
import JSON

extension GitHub.HTTP.Client {
    public func userRepositories(
        authentication: GitHub.HTTP.Authentication
    ) -> GitHub.User.Repositories.Client<
        GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>
    > {
        .init { request async throws(GitHub.HTTP.Error<ExecutionFailure, PaginationFailure>) in
            var parameters: [(String, String?)] = []
            if let visibility = request.visibility {
                parameters.append(("visibility", visibility.rawValue))
            }
            if let affiliation = request.affiliation {
                parameters.append(("affiliation", affiliation))
            }
            if let type = request.type {
                parameters.append(("type", type.rawValue))
            }
            if let sort = request.sort {
                parameters.append(("sort", sort.rawValue))
            }
            if let direction = request.direction {
                parameters.append(("direction", direction.rawValue))
            }
            if let size = request.size {
                parameters.append(("per_page", String(size.rawValue)))
            }
            if let page = request.page {
                parameters.append(("page", String(page.rawValue)))
            }
            if let since = request.since {
                parameters.append(("since", since.rawValue))
            }
            if let before = request.before {
                parameters.append(("before", before.rawValue))
            }

            let httpRequest: HTTP.Request
            do throws(GitHub.HTTP.Error<ExecutionFailure, Never>) {
                httpRequest = try self.request(
                    path: ["user", "repos"],
                    query: parameters,
                    authentication: authentication
                )
            } catch {
                throw error.widening()
            }

            let httpResponse: HTTP.Response
            do throws(GitHub.HTTP.Error<ExecutionFailure, Never>) {
                httpResponse = try await self.response(for: httpRequest)
            } catch {
                throw error.widening()
            }

            let response: GitHub.User.Repositories.Response
            do throws(JSON.Error) {
                let elements = try [JSON].deserialize(JSON.parse(httpResponse.body ?? []))
                var repositories: [GitHub.Repository.Metadata] = []
                repositories.reserveCapacity(elements.count)
                for element in elements {
                    repositories.append(try Self.metadata(from: element))
                }
                response = .init(repositories: repositories)
            } catch {
                throw .json(error)
            }

            let nextPage: GitHub.Page.Number?
            do throws(PaginationFailure) {
                nextPage = try self.pagination.next(httpResponse.headers)
            } catch {
                throw .pagination(error)
            }

            return .init(
                response: response,
                next: nextPage.map {
                    .init(
                        visibility: request.visibility,
                        affiliation: request.affiliation,
                        type: request.type,
                        sort: request.sort,
                        direction: request.direction,
                        page: $0,
                        size: request.size,
                        since: request.since,
                        before: request.before
                    )
                }
            )
        }
    }
}
