# DiscourseKit

A Swift wrapper around the [Discourse API](https://docs.discourse.org).

## Contributing / project structure

Any PRs welcome!

Discourse API docs can be found [here.](https://docs.discourse.org/)

If you're not familiar with Swift Package Manager, you'll be wondering where the Xcode project is. Open a terminal in the project folder and run `swift package generate-xcodeproj`, and it will be generated for you.

The project is organized into three targets: Extensions, Model, and Networking. Model is where our types reside, and Networking is where API client and boilerplate REST logic resides.

#### Model

Types conform to DKCodable. Before you go implementing `init(from decoder:)`, see if you can use DKCodable to work around whatever trouble Discourse is giving you. I've found that it sometimes returns `null` or leaves out important keys entirely sometimes in a way that doesn't make sense.

***Please*** **read** [DKCodable.md](DKCodable.md) for more information.

#### Networking

API endpoints are stored as an enum in `Endpoints.swift`. `DKClient` is the API client class. The class itself implements various methods for performing generic GET/POST/etc requests, which are to be used by higher-level methods in extensions. For example, here's how you would implement the `/search` endpoint:

```swift
public extension DKClient {
    func search(term: String, includeBlurbs blurbs: Bool = false) -> DKResponse<SearchResult> {
        self.get(["q": term, "include_blurbs": blurbs], from: .search) { parser in
            completion(parser.decodeResponse())
        }
    }
}
```

The `.get()`/`.post()` methods give you a `ResponseParser` in the callback, which uses generic type inference to decode responses based on the method's signature when you call `.decodeResponse()`. `completion` takes a `Result<SearchResult>`, so the response parser will try to decode a `SearchResult`. Parameters go in the dictionary in the first argument to `get()`/`post()`.
