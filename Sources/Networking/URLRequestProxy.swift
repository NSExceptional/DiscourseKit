//
//  RequestProxy.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation
import Combine

public typealias ResponseHandler = (ResponseParser) -> Void

/// A wrapper around the URLSession family of classes
/// for the purpose of simplifying the process of making
/// a request.

/// This type acts as layer of indirection (a proxy)
/// between your code and the URLSession classes. You
/// may use `request` directly if you need to, but it
/// is advised that you instead use the provided family
/// of methods to make requests and parse responses.
public class URLRequestProxy {
    
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    /// Use however you want, like `UIView.tag`
    ///
    /// You could extend this class and write computed
    /// properties that use `metadata` for backing storage.
    public var metadata: Any?
    public var request: URLRequest
    /// Defaults to `URLSession.shared`
    public lazy var session: URLSession = _configuration != nil ? URLSession(configuration: _configuration!) : URLSession.shared
    /// Defaults to `session.configuration`
    public var configuration: URLSessionConfiguration {
        get {
            return _configuration ?? self.session.configuration
        }
        set { self._configuration = newValue }
    }
    
    internal var _configuration: URLSessionConfiguration?
    
    public init(request: URLRequest) {
        self.request = request
    }
    
    public func get() -> AnyPublisher<ResponseParser,Error> {
        self.start(method: .get)
    }
    
    public func post() -> AnyPublisher<ResponseParser,Error> {
        self.start(method: .post)
    }
    
    public func put() -> AnyPublisher<ResponseParser,Error> {
        self.start(method: .put)
    }
    
    public func delete() -> AnyPublisher<ResponseParser,Error> {
        self.start(method: .delete)
    }
    
    public func start(method: HTTPMethod) -> AnyPublisher<ResponseParser,Error> {
        self.request.httpMethod = method.rawValue
        
        return Future.promise { resolve in
            self.session.dataTask(with: self.request, completionHandler: { (data, response, error) in
                ResponseParser.parse(response as? HTTPURLResponse, data, error) { parser in
                    if let e = parser.error {
                        resolve(.failure(e))
                    } else {
                        resolve(.success(parser))
                    }
                }
            }).resume()
        }
    }
}
