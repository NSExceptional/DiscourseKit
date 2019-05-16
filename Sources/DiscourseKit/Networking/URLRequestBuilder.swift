//
//  URLRequestBuilder.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation
import Extensions

/// A class that implements the "builder" pattern for a `URLRequest`.
///
/// Usage: call `make(configurationHandler:)`. In the closure, you
/// will be given a temporary `URLRequestBuilder` instance. Here,
/// you will use its methods to build a proxy for `URLRequest`,
/// which is returned by `make(configurationHandler:)`. This
/// instance can be used to make requests, or you can access
/// its `URL`* properties directly for whatever reason.
class URLRequestBuilder {
    
    // MARK: Public
    
    enum ParamFormat {
        case query
        case bodyJSON
        case bodyFormURLEncoded
        case `default` // query
    }
    
    /// - Parameter configurationHandler: A block that configures a `URLRequestBuilder`
    static func make(configurationHandler: (URLRequestBuilder) -> Void) -> URLRequestProxy {
        let builder = URLRequestBuilder()
        configurationHandler(builder)
        return builder.build()
    }
    
    @discardableResult
    func URL(_ url: String) -> Self {
        assert(_baseURL == nil && _endpoint == nil, "Cannot use a full URL and a base URL")
        _URL = url
        return self
    }
    
    /// Takes a URL to be used in conjunction with any `endpoint` provided.
    /// - Note: You cannot use this *and* `URL(_:)`
    @discardableResult
    func baseURL(_ baseURL: String) -> Self {
        assert(_URL == nil, "Cannot use a base URL and a full URL")
        _baseURL = baseURL
        return self
    }
    
    /// Takes an endpoint (trailing half of a URL) to be used in
    /// conjunction with the `baseURL` provided.
    /// - Note: You must use provide a base URL via `baseURL(_:)`
    @discardableResult
    func endpoint(_ endpoint: String) -> Self {
        assert(_baseURL != nil, "Must first use a baseURL")
        _endpoint = endpoint
        return self
    }
    
    /// Pass API parameters. Defaults to using URL query parameters.
    ///
    /// Most modern APIs will accept any parameter format.
    /// This method simply calls into `queries(_:)`, `body(json:)`,
    /// and `body(jsonFormString:)` depending on which format you specify.
    ///
    /// You might find using this method preferrable to its counterparts
    /// if you don't want to hard-code a call to a specific format. This
    /// method provides the flexibility to change the parameter format
    /// by simply changing the `format` parameter to something else.
    @discardableResult
    func params(_ object: [String: JSONValue], format: ParamFormat = .default) -> Self {
        switch format {
        case .query, .default:
            return self.queries(object)
        case .bodyJSON:
            return self.body(json: object)
        case .bodyFormURLEncoded:
            return self.body(jsonFormString: object)
        }
    }
    
    /// Passes `identifier` into `URLSessionConfiguration.background(_:)`,
    /// then passes the resulting configuration to `configuration(_:)`.
    @discardableResult
    func background(identifier: String) -> Self {
        self.configuration(URLSessionConfiguration.background(withIdentifier: identifier))
        return self
        
    }
    
    @discardableResult
    func body(string: String) -> Self {
        return self.body(string.utf8Data)
    }
    
    @discardableResult
    func body(json: [String: JSONValue]) -> Self {
        _contentTypeHeader = ContentType.JSON
        return self.body(try! JSONSerialization.data(withJSONObject: json, options: []))
    }
    
    /// `ContentType.formURLEncoded`
    @discardableResult
    func body(formString: String) -> Self {
        _contentTypeHeader = ContentType.formURLEncoded
        return self.body(string: formString)
    }
    
    /// `ContentType.formURLEncoded`
    @discardableResult
    func body(jsonFormString: [String: JSONValue]) -> Self {
        _contentTypeHeader = ContentType.formURLEncoded
        return self.body(json: jsonFormString)
    }
    
    /// Sets the HTTP body of the request.
    ///
    /// All other `body()` methods call into this method.
    /// Additionally, all of the `multipart`* methods are
    /// wrappers around setting the HTTP body and content type.
    @discardableResult
    func body(_ data: Data) -> Self { _body = data; return self }
    
    @discardableResult
    func headers(_ headers: [String: String]) -> Self { _headers += headers; return self }
    
    /// Sets the URL query parameters of the request.
    @discardableResult
    func queries(_ queries: [String: JSONValue]) -> Self { _queries = queries; return self }
    
    @discardableResult
    func multipartStrings(_ pairs: [String: String]) -> Self { _multipartStrings = pairs; return self }
    
    @discardableResult
    func multipartData(_ pairs: [String: Data]) -> Self { _multipartData = pairs; return self }
    
    /// Sets the boundary for multipart data payloads.
    /// If you do not provide one, one will be provided for you.
    @discardableResult
    func boundary(_ boundary: String) -> Self { _boundary = boundary; return self }
    
    @discardableResult
    func timeout(_ timeout: TimeInterval) -> Self { _timeout = timeout; return self }
    
    @discardableResult
    func serviceType(_ type: URLRequest.NetworkServiceType) -> Self { _serviceType = type; return self }
    
    @discardableResult
    func configuration(_ config: URLSessionConfiguration) -> Self { _configuration = config; return self }
    
    @discardableResult
    func session(_ session: URLSession) -> Self { _session = session; return self }
    
    @discardableResult
    func metadata(_ metadata: Any) -> Self { _metadata = metadata; return self }
    
    // MARK: Private
    
    private var _URL: String?
    private var _baseURL: String?
    private var _endpoint: String?
    private var _headers: [String: String] = [:]
    private var _contentTypeHeader: String?
    private var _queries: [String: JSONValue] = [:]
    private var _body: Data?
    private var _multipartStrings: [String: String] = [:]
    private var _multipartData: [String: Data] = [:]
    private var _boundary: String?
    private var _timeout: TimeInterval?
    private var _serviceType: URLRequest.NetworkServiceType?
    private var _configuration: URLSessionConfiguration?
    private var _session: URLSession?
    private var _metadata: Any?
    
    private var boundary: String {
        if _boundary == nil {
            _boundary = NSUUID().uuidString
        }
        
        return _boundary!
    }
    
    private var multipartBodyData: Data? {
        if _multipartData.isEmpty && _multipartStrings.isEmpty {
            return nil
        }
        
        var body = Data()
        
        // Initial boundary
        body.append("--\(self.boundary)\r\n".utf8Data)
        
        // Form parameters
        for (key, value) in _multipartStrings {
            body.append(Data(with: self.boundary, key: key, forString: value))
        }
        
        // Raw data
        for (key, value) in _multipartData {
            body.append(Data(with: self.boundary, key: key, forData: value))
        }
        
        let closing = "--".utf8Data
        body.replaceSubrange(body.count-2..<body.count, with: closing)
        
        return body
    }
    
    private var multipartContentTypeHeader: String? {
        let header = _contentTypeHeader?.lowercased() ?? ""
        
        if header.hasPrefix("multipart") {
            if !header.contains("boundary") {
                return "\(_contentTypeHeader!); boundary=\(self.boundary)"
            }
        } else if !_multipartData.isEmpty || !_multipartStrings.isEmpty {
            _contentTypeHeader = ContentType.multipartFormData
            return self.multipartContentTypeHeader
        }
        
        return nil
    }
    
    private var headers: [String: String] {
        // Explicit Content-Type
        if let contentType = self.multipartContentTypeHeader ?? _contentTypeHeader {
            _headers += ["Content-Type": contentType]
        }
        
        return _headers
    }
    
    private var body: Data? {
        return self.multipartBodyData ?? _body
    }
    
    private var serviceType: URLRequest.NetworkServiceType {
        return _serviceType ?? .default
    }
    
    private var requestURL: URL {
        let urlString = _URL ?? _baseURL!.appending(_endpoint ?? "")
        return urlString.url(with: _queries)
    }
    
    private func request(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpBody = self.body
        request.allHTTPHeaderFields = self.headers
        request.networkServiceType = self.serviceType
        if let t = _timeout {
            request.timeoutInterval = t
        }
        
        return request
    }
    
    private init() { }
    
    private func build() -> URLRequestProxy {
        guard _URL != nil || _baseURL != nil else {
            fatalError("You must specify a URL or base URL")
        }
        
        let request = self.request(with: self.requestURL)
        let proxy = URLRequestProxy(request: request)
        proxy._configuration = _configuration
        proxy.metadata = _metadata
        if let session = _session {
            proxy.session = session;
        }
        
        return proxy
    }
}
