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

public typealias Query = [String: JSONValue]
public typealias DKVoidableBlock = (Error?) -> Void
public typealias DKResponseBlock<T: DKCodable> = (Result<T, DKCodingError>) -> Void


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
    func get(_ query: Query? = nil, from endpoint: Endpoint, pathParams: String..., callback: @escaping ResponseParserBlock) {
        self.get({ self.configure($0, query, endpoint, pathParams, false) }, callback: callback)
    }
    
    /// For POST requests.
    /// 
    /// Behaves like `get(_:from:pathParams:callback)`, but the given query is sent as a part of the HTTP body.
    func post(_ query: Query? = nil, to endpoint: Endpoint, pathParams: String..., callback: @escaping ResponseParserBlock) {
        self.post({ self.configure($0, query, endpoint, pathParams, true) }, callback: callback)
    }
    
    /// Executes the given callback with any error found.
    ///
    /// Useful for checking for response errors before trying to parse
    /// the rest of the response. This reduces boilerplate. Common use:
    /// ```
    /// guard self.callbackIfError(parser, completion) else { return }
    /// ```
    /// - returns: `true` if there was no error, `false` otherwise
    func callbackIfError<T: DKCodable>(_ parser: ResponseParser, _ callback: DKResponseBlock<T>) -> Bool {
        if let error = parser.error {
            callback(.failure(error))
            return false
        }
        
        return true
    }
    
    /// Executes the given callback with any error found.
    func callbackIfError(_ parser: ResponseParser, _ callback: DKVoidableBlock) -> Bool {
        if let error = parser.error {
            callback(error)
            return false
        }
        
        return true
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
    
    private func post(_ configurationHandler: (URLRequestBuilder) -> Void, callback: @escaping ResponseParserBlock) {
        self.request(with: configurationHandler).post(preCallbackHook(callback))
    }
    
    private func get(_ configurationHandler: (URLRequestBuilder) -> Void, callback: @escaping ResponseParserBlock) {
        self.request(with: configurationHandler).get(preCallbackHook(callback))
    }
    
    /// Does **boilerplate** configuration of requests, such as
    /// setting **the endpoint** or applying any **query or path parameters.**
    ///
    /// TODO: this should be an extension on URLRequestBuilder instead
    func configure(_ make: URLRequestBuilder, _ query: Query?, _ endpoint: Endpoint, _ pathParams: [String], _ useBody: Bool) {
        // Construct the endpoint if given a path parameter. For example, given an
        // endpoint "/user/%@" and path "mxcl", this would produce "/user/mxcl"
        let ep = endpoint.make(pathParams)
        
        // Gather the parameters and decide which format to send them in;
        // POST requests use the body instead of standard queries
        let format: URLRequestBuilder.ParamFormat = useBody ? .bodyJSON : .query
        let params = (query ?? [:]) + self.defaultQueryParams
        
        // Assign the endpoint and pass any parameters
        make.endpoint(ep).params(params, format: format)
    }
    
    /// This is a chance for API-specific code to run once a request has finished.
    ///
    /// Here, we intercept the response before it is passed to client code
    /// and we parse the API response for an error. Any error found is used
    /// to populate the parser.error field. This is a good place to check for
    /// special header and do something with them for use in subsequent requests.
    private func preCallbackHook(_ callback: @escaping ResponseParserBlock) -> ResponseParserBlock {
        return { parser in
            if let response = parser.JSONDictionary,
                let errors = response["errors"] as? [String] {
                let msg = errors.joined(separator: "\n")
                parser.error = ResponseParser.error(msg, code: parser.response!.statusCode)
            }
            
            callback(parser)
        }
    }
}
