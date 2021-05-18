//
//  DKClient.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation
import Networking
import Extensions
import Combine
import Jsum

public typealias Query = [String: JSONValue]
public typealias DKVoidableBlock = (Error?) -> Void
public typealias DKResponse<T> = AnyPublisher<T, DKError>

extension Publisher where Output == ResponseParser {
    func decode<T>(_ keyPath: String? = nil) -> AnyPublisher<T,DKError> {
        return self.tryMap { try $0.decodeResponse(T.self, keyPath) }
            .mapError { $0 as! DKError }
            .eraseToAnyPublisher()
    }
    
    func parse() -> AnyPublisher<Void,DKError> {
        return self.map { _ in () }
            .mapError { $0 as! DKError }
            .eraseToAnyPublisher()
    }
}

public class DKClient {
    static let shared = DKClient("https://forums.swift.org")
    
    internal let baseURL: URL
    internal var csrf: String = "undefined"
    internal let defaultQueryParams: [String: JSONValue] = [:]
    internal var defaultHTTPHeaders: [String: String] {
        return [
            "X-CSRF-Token": self.csrf,
            HTTPHeader.accept: ContentType.JSON,
        ]
    }
    
    /// A singular global cache to allow different
    /// endpoints to cache their results if I so desire
    private var cache: [Endpoint: [String: Any]] = [:]
    
    /// Cache a value under a given key and domain
    internal func encache(_ domain: Endpoint, key: Any, value: Any) {
        let key = key as? String ?? "\(key)"
        if var cache = self.cache[domain] {
            cache[key] = value
        } else {
            self.cache[domain] = [:]
            self.cache[domain]![key] = value
        }
        // TODO save cache
    }
    
    /// Check the cache for a given domain and key 
    internal func check<T>(cache domain: Endpoint, key: Any) -> T? {
        let key = key as? String ?? "\(key)"
        return self.cache[domain]?[key] as? T
    }
    
    public convenience init(_ baseURL: String) {
        self.init(baseURL: URL(string: baseURL)!)
    }
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: Internal convenience methods
    
    /// For GET requests.
    ///
    /// Takes a set of query params, an endpiont, and any path parameters.
    /// For example, getting a list of posts from a particular category
    /// sorted by new, in descending order. Usage could look like this:
    /// ```
    /// client.get(["ascending": false], from: .listPosts, pathParams: "pitches", "new") { parser in
    ///     guard self.callbackIfError(parser, completion) else { return }
    ///     // Parse the response into something useful
    ///     // ...
    ///     callback(posts, nil)
    /// }
    /// ```
    /// The resulting URL might look something like: `https://example.org/pitches/new?ascending=0`
    func get<T>(_ query: Query? = nil, from endpoint: Endpoint, node: String? = nil) -> DKResponse<T> {
        self.get({ self.configure($0, query, endpoint, false) }).decode(node)
    }
    
    func get(_ query: Query? = nil, from endpoint: Endpoint) -> DKResponse<Void> {
        self.get({ self.configure($0, query, endpoint, false) }).parse()
    }
    
    /// For POST requests.
    /// 
    /// Behaves like `get(_:from:pathParams:callback)`, but the given query is sent as a part of the HTTP body.
    func post<T>(_ query: Query? = nil, to endpoint: Endpoint, node: String? = nil) -> DKResponse<T> {
        self.post({ self.configure($0, query, endpoint, true) }).decode(node)
    }
    
    func post(_ query: Query? = nil, to endpoint: Endpoint) -> DKResponse<Void> {
        self.post({ self.configure($0, query, endpoint, true) }).parse()
    }
    
    /// Does any **shared** configuration of requests, such as setting the **base URL**
    /// or providing **default header values** or other parameters.
    @discardableResult
    private func request(with configurationHandler: (URLRequestBuilder) -> Void) -> URLRequestProxy {
        return URLRequestBuilder.make { make in
            make.baseURL(self.baseURL.absoluteString).headers(self.defaultHTTPHeaders)
            configurationHandler(make)
        }
    }
    
    private func post(_ configurationHandler: (URLRequestBuilder) -> Void) -> AnyPublisher<ResponseParser,Error> {
        return self.request(with: configurationHandler).post().map(self.preCallbackHook(_:)).eraseToAnyPublisher()
    }
    
    private func get(_ configurationHandler: (URLRequestBuilder) -> Void) -> AnyPublisher<ResponseParser,Error> {
        return self.request(with: configurationHandler).get().map(self.preCallbackHook(_:)).eraseToAnyPublisher()
    }
    
    /// Does **boilerplate** configuration of requests, such as
    /// setting **the endpoint** or applying any **query or path parameters.**
    ///
    /// TODO: this should be an extension on URLRequestBuilder instead
    func configure(_ make: URLRequestBuilder, _ query: Query?, _ endpoint: Endpoint, _ useBody: Bool) {
        // Gather the parameters and decide which format to send them in;
        // POST requests use the body instead of standard queries
        let format: URLRequestBuilder.ParamFormat = useBody ? .bodyJSON : .query
        let params = (query ?? [:]) + self.defaultQueryParams
        
        // Assign the endpoint and pass any parameters
        make.endpoint(endpoint.rawValue).params(params, format: format)
    }
    
    /// This is a chance for API-specific code to run once a request has finished.
    ///
    /// Here, we intercept the response before it is passed to client code
    /// and we parse the API response for an error. Any error found is used
    /// to populate the parser.error field. This is a good place to check for
    /// special header and do something with them for use in subsequent requests.
    private func preCallbackHook(_ parser: ResponseParser) -> ResponseParser {
        if parser.error == nil, let response = parser.JSONDictionary,
            let errors = response["errors"] as? [String] {
            let msg = errors.joined(separator: "\n")
            parser.error = ResponseParser.error(msg, code: parser.response!.statusCode)
        }
    
        return parser
    }
}
