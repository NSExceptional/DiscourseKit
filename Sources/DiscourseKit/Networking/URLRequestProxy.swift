//
//  RequestProxy.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

typealias ResponseHandler = (ResponseParser) -> Void

/// A wrapper around the URLSession family of classes
/// for the purpose of simplifying the process of making
/// a request.

/// This type acts as layer of indirection (a proxy)
/// between your code and the URLSession classes. You
/// may use `request` directly if you need to, but it
/// is advised that you instead use the provided family
/// of methods to make requests and parse responses.
public class URLRequestProxy {
    
    enum HTTPMethod: String {
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
    
    init(request: URLRequest) {
        self.request = request
    }
    
    func get(_ completion: @escaping ResponseHandler) {
        self.start(method: .get, completion)
    }
    
    func post(_ completion: @escaping ResponseHandler) {
        self.start(method: .post, completion)
    }
    
    func put(_ completion: @escaping ResponseHandler) {
        self.start(method: .put, completion)
    }
    
    func delete(_ completion: @escaping ResponseHandler) {
        self.start(method: .delete, completion)
    }
    
    func start(method: HTTPMethod, _ completion: @escaping ResponseHandler) {
        self.request.httpMethod = method.rawValue
        
        self.session.dataTask(with: self.request, completionHandler: { (data, response, error) in
            ResponseParser.parse(response as? HTTPURLResponse, data, error, callback: completion)
        }).resume()
    }
}
