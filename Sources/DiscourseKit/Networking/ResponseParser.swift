//
//  ResponseParser.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation
import Extensions

typealias ResponseParserBlock = (ResponseParser) -> Void

/// A convenient wrapper around handling `URLSessionTask`
/// responses that consolidate errors and gives you convenient
/// accessors for various content types.
class ResponseParser {
    
    // MARK: Response information
    
    func result<T: Decodable>() -> Result<T, Error> {
        if let error = self.error {
            return .failure(error)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return .success(try decoder.decode(T.self, from: self.data))
        } catch {
            return .failure(error)
        }
    }
    
    private(set) var response: HTTPURLResponse?
    private(set) var data: Data
    var error: Error?
    lazy var contentType: String? = (self.response?.allHeaderFields[HTTPHeader.contentType] as! String?)?.lowercased()
    
    // MARK: Response data helper accessors
    private(set) lazy var JSONDictionary: [String : JSONValue]? = try? self.forceDecodeJSON().object
    private(set) lazy var JSONArray: [Any]? = try? self.forceDecodeJSON().array
    private(set) lazy var text: String? = self.hasText ? String(data: self.data, encoding: .utf8) : nil
    var HTML: String? {
        return self.hasHTML ? self.text : nil
    }
    var XML: String? {
        return self.hasXML ? self.text : nil
    }
    var javascript: String? {
        return self.hasJavascript ? self.text : nil
    }
    
    private(set) var hasJSON = false
    var hasText: Bool {
        return (self.contentType?.hasPrefix("text") ?? false) || self.hasJSON || self.hasJavascript
    }
    
    // MARK: Initializers, misc
    
    convenience init(error: Error) {
        self.init(data:nil, response: nil, error: error)
    }
    
    /// Use to conveniently call a callback closure on the main thread with a `ResponseParser`
    class func parse(_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?, callback: @escaping ResponseParserBlock) {
        DispatchQueue.global().async {
            let parser = ResponseParser(data: data, response: response, error: error)
            DispatchQueue.main.async {
                callback(parser)
            }
        }
    }
    
    init(data: Data?, response: HTTPURLResponse?, error: Error?) {
        self.data     = data ?? Data()
        self.response = response
        self.error    = error
        
        if let contentType = self.contentType, !contentType.isEmpty, !self.data.isEmpty {
            self.hasJSON       = contentType.hasPrefix(ContentType.JSON)
            self.hasHTML       = contentType.hasPrefix(ContentType.HTML)
            self.hasXML        = contentType.hasPrefix(ContentType.XML)
            self.hasJavascript = contentType.hasPrefix(ContentType.javascript)
            // You could add more types here as needed and the properties at the bottom
        }
        
        if error == nil, let code = self.response?.statusCode, code >= 400 {
            self.error = ResponseParser.error(HTTPStatusCodeDescription(code), code: code)
        }
    }
    
    /// Attempt to decode the response to JSON, regardless of the Content-Type
    ///
    /// Useful if an API isn't using the right Content-Type
    func forceDecodeJSON() throws -> (object: [String : JSONValue]?, array: [Any]?) {
        let json = try JSONSerialization.jsonObject(with: self.data, options: [])
        if json is NSDictionary {
            return (json as? [String : JSONValue], nil)
        } else {
            return (nil, json as? [Any])
        }
    }
    
    /// Convenience method to create an NSError
    class func error(_ message: String, domain: String = "ResponseParser", code: Int) -> NSError {
        return NSError(domain: domain, code: code,
                       userInfo: [
                        NSLocalizedDescriptionKey: message,
                        NSLocalizedFailureReasonErrorKey: message
            ]
        )
    }
    
    private var hasHTML       = false
    private var hasXML        = false
    private var hasJavascript = false
}

// MARK: Headers and content types
struct ContentType {
    static let CSS                = "text/css"
    static let formURLEncoded     = "application/x-www-form-urlencoded"
    static let GZIP               = "application/gzip"
    static let HTML               = "text/html"
    static let javascript         = "application/javascript"
    static let JSON               = "application/json"
    static let JWT                = "application/jwt"
    static let markdown           = "text/markdown"
    static let multipartFormData  = "multipart/form-data"
    static let multipartEncrypted = "multipart/encrypted"
    static let plainText          = "text/plain"
    static let rtf                = "text/rtf"
    static let textXML            = "text/xml"
    static let XML                = "application/xml"
    static let ZIP                = "application/zip"
    static let ZLIB               = "application/zlib"
}

struct HTTPHeader {
    static let accept          = "Accept"
    static let acceptEncoding  = "Accept-Encoding"
    static let acceptLanguage  = "Accept-Language"
    static let acceptLocale    = "Accept-Locale"
    static let authorization   = "Authorization"
    static let cacheControl    = "Cache-Control"
    static let contentLength   = "Content-Length"
    static let contentType     = "Content-Type"
    static let date            = "Date"
    static let expires         = "Expires"
    static let cookie          = "Cookie"
    static let setCookie       = "Set-Cookie"
    static let status          = "Status"
    static let userAgent       = "User-Agent"
}

// MARK: Status codes
enum HTTPStatusCode: Int {
    /// Force unwraps code, you have been warned
    init(_ code: Int) {
        self.init(rawValue: code)!
    }
    
    case Continue = 100
    case SwitchProtocol
    
    case OK = 200
    case Created
    case Accepted
    case NonAuthorativeInfo
    case NoContent
    case ResetContent
    case PartialContent
    
    case MultipleChoice = 300
    case MovedPermanently
    case Found
    case SeeOther
    case NotModified
    case UseProxy
    case Unused
    case TemporaryRedirect
    case PermanentRedirect
    
    case BadRequest = 400
    case Unauthorized
    case PaymentRequired
    case Forbidden
    case NotFound
    case MethodNotAllowed
    case NotAcceptable
    case ProxyAuthRequired
    case RequestTimeout
    case Conflict
    case Gone
    case LengthRequired
    case PreconditionFailed
    case PayloadTooLarge
    case URITooLong
    case UnsupportedMediaType
    case RequestedRangeUnsatisfiable
    case ExpectationFailed
    case ImATeapot
    case MisdirectedRequest = 421
    case UpgradeRequired = 426
    case PreconditionRequired = 428
    case TooManyRequests
    case RequestHeaderFieldsTooLarge = 431
    
    case InternalServerError = 500
    case NotImplemented
    case BadGateway
    case ServiceUnavailable
    case GatewayTimeout
    case HTTPVersionUnsupported
    case VariantAlsoNegotiates
    case AuthenticationRequired = 511
}

func HTTPStatusCodeDescription(_ code: Int) -> String {
    guard let status = HTTPStatusCode(rawValue: code) else {
        return "Unknown Error (code \(code)"
    }
    
    switch status {
    case .Continue:
        return "Continue"
    case .SwitchProtocol:
        return "Switch Protocol"
    case .OK:
        return "OK"
    case .Created:
        return "Created"
    case .Accepted:
        return "Accepted"
    case .NonAuthorativeInfo:
        return "Non Authorative Info"
    case .NoContent:
        return "No content"
    case .ResetContent:
        return "Reset Content"
    case .PartialContent:
        return "Partial Content"
    case .MultipleChoice:
        return "Multiple Choice"
    case .MovedPermanently:
        return "Moved Permanently"
    case .Found:
        return "Found"
    case .SeeOther:
        return "See Other"
    case .NotModified:
        return "Not Modified"
    case .UseProxy:
        return "Use Proxy"
    case .Unused:
        return "Unused"
    case .TemporaryRedirect:
        return "Temporary Redirect"
    case .PermanentRedirect:
        return "Permanent Redirect"
    case .BadRequest:
        return "Bad Request"
    case .Unauthorized:
        return "Unauthorized"
    case .PaymentRequired:
        return ""
    case .Forbidden:
        return "Forbidden"
    case .NotFound:
        return "Not Found"
    case .MethodNotAllowed:
        return "Method Not Allowed"
    case .NotAcceptable:
        return "Not Acceptable"
    case .ProxyAuthRequired:
        return "Proxy Authentication Required"
    case .RequestTimeout:
        return "Request Timeout"
    case .Conflict:
        return "Conflict"
    case .Gone:
        return "Gone"
    case .LengthRequired:
        return "Length Required"
    case .PreconditionFailed:
        return "Precondition Failed"
    case .PayloadTooLarge:
        return "Payload Too Large"
    case .URITooLong:
        return "URI Too Long"
    case .UnsupportedMediaType:
        return "Unsupported Media Type"
    case .RequestedRangeUnsatisfiable:
        return "Requested Range Unsatisfiable"
    case .ExpectationFailed:
        return "Expectation Failed"
    case .ImATeapot:
        return "???"
    case .MisdirectedRequest:
        return "Misdirected Request"
    case .UpgradeRequired:
        return "Upgrade Required"
    case .PreconditionRequired:
        return "Precondition Required"
    case .TooManyRequests:
        return "Too many requests"
    case .RequestHeaderFieldsTooLarge:
        return "Request Header Fields Too Large"
    case .InternalServerError:
        return "Internal Server Error"
    case .NotImplemented:
        return "Not Implemented"
    case .BadGateway:
        return "Bad gateway"
    case .ServiceUnavailable:
        return "Service Unavailable"
    case .GatewayTimeout:
        return "Gateway timeout"
    case .HTTPVersionUnsupported:
        return "HTTP Version Unsupported"
    case .VariantAlsoNegotiates:
        return "Variant Also Negotiates"
    case .AuthenticationRequired:
        return "Authentication Required"
    }
}
