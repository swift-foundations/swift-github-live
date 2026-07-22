# swift-github-http

[![CI](https://github.com/swift-foundations/swift-github-http/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-foundations/swift-github-http/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

HTTP bindings for the typed GitHub operations published by `swift-github`.

## Overview

`swift-github-http` maps canonical GitHub requests and responses to Foundation-free HTTP values. It provides:

- explicit bearer-token authentication at construction sites;
- repository metadata and content operations;
- user and organization repository pagination;
- repository stargazer pagination;
- repository traffic views, clones, paths, and referrers;
- injected HTTP execution for deterministic, credential-free tests.

## Installation

Add the package dependency:

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-foundations/swift-github-http.git",
        branch: "main"
    )
]
```

Then depend on the product:

```swift
.product(name: "GitHub HTTP", package: "swift-github-http")
```

## Usage

```swift
import GitHub_HTTP

let http = GitHub.HTTP.Client(
    agent: .init(rawValue: "example-service"),
    version: .init(rawValue: "2026-03-10"),
    execute: transport.execute
)

let traffic = http.traffic(authentication: .token(token))
let views = try await traffic.views(
    .init(
        owner: .init(rawValue: "swiftlang"),
        repository: .init(rawValue: "swift")
    )
)
```

## Architecture

`GitHub Standard` owns provider vocabulary and wire-shaped values. `GitHub` owns typed operation clients and bounded traversal. `GitHub HTTP` owns request construction, response decoding, authentication headers, and RFC 8288 pagination witnesses.

Traffic and Stargazers remain separate provider domains: Traffic describes repository analytics aggregates, while Stargazers describes user-attributed starring events.

## Testing

All package tests inject an in-memory HTTP execution closure. They make no live API calls and require no credentials.

## Requirements

- Swift 6.3+

## License

This package is licensed under the AGPL 3.0 License. See [LICENSE.md](LICENSE.md) for details.
